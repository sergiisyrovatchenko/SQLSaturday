SET NOCOUNT ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET STATISTICS IO, TIME OFF

IF OBJECT_ID('tempdb.dbo.#database_files') IS NOT NULL
    DROP TABLE #database_files

CREATE TABLE #database_files (
      [db_id]      INT DEFAULT DB_ID()
    , [name]         SYSNAME
    , [type]         INT
    , [size_mb]      BIGINT
    , [used_size_mb] BIGINT
)

IF OBJECT_ID('tempdb.dbo.#dbcc') IS NOT NULL
    DROP TABLE #dbcc

CREATE TABLE #dbcc (
      [key]   VARCHAR(1000)
    , [value] VARCHAR(1000)
    , [db_id] INT DEFAULT DB_ID()
)

DECLARE @sql NVARCHAR(MAX) = STUFF((
    SELECT '
USE ' + QUOTENAME([name]) + '
INSERT INTO #database_files ([name], [type], [size_mb], [used_size_mb])
SELECT [name]
     , [type]
     , CAST([size] AS BIGINT) * 8 / 1024
     , CAST(FILEPROPERTY([name], ''SpaceUsed'') AS BIGINT) * 8 / 1024
FROM sys.database_files WITH(NOLOCK);

INSERT INTO #dbcc ([key], [value])
EXEC(''DBCC OPENTRAN WITH TABLERESULTS'');'
    FROM sys.databases WITH(NOLOCK)
    WHERE [state] = 0
        AND ISNULL(HAS_DBACCESS([name]), 0) = 1
    FOR XML PATH(''), TYPE).value('(./text())[1]', 'NVARCHAR(MAX)'), 1, 2, '')

EXEC sys.sp_executesql @sql

IF OBJECT_ID('tempdb.dbo.#backup_size') IS NOT NULL
    DROP TABLE #backup_size

CREATE TABLE #backup_size (
      [db_name]        SYSNAME PRIMARY KEY
    , [full_last_date] DATETIME2(0)
    , [full_size]      DECIMAL(32,2)
    , [diff_last_date] DATETIME2(0)
    , [diff_size]      DECIMAL(32,2)
    , [log_last_date]  DATETIME2(0)
    , [log_size]       DECIMAL(32,2)
)

INSERT INTO #backup_size
SELECT [database_name]
     , MAX(CASE WHEN [type] = 'D' THEN [backup_finish_date] END)
     , MAX(CASE WHEN [type] = 'D' THEN [backup_size] END)
     , MAX(CASE WHEN [type] = 'I' THEN [backup_finish_date] END)
     , MAX(CASE WHEN [type] = 'I' THEN [backup_size] END)
     , MAX(CASE WHEN [type] = 'L' THEN [backup_finish_date] END)
     , MAX(CASE WHEN [type] = 'L' THEN [backup_size] END)
FROM (
    SELECT [database_name]
         , [type]
         , [backup_finish_date]
         , [backup_size] =
                CAST(CASE WHEN [backup_size] = [compressed_backup_size]
                        THEN [backup_size]
                        ELSE [compressed_backup_size]
                END / 1048576. AS DECIMAL(32,2))
         , RN = ROW_NUMBER() OVER (PARTITION BY [database_name], [type] ORDER BY [backup_finish_date] DESC)
    FROM msdb.dbo.backupset WITH(NOLOCK)
    WHERE [type] IN ('D', 'L', 'I')
        AND [is_copy_only] = 0
) t
WHERE RN = 1
GROUP BY [database_name]

SELECT [db_id]          = d.[database_id]
     , [db_name]        = d.[name]
     , [state]          = d.[state_desc]
     , [recovery_model] = d.[recovery_model_desc]
     , [log_reuse]      = d.[log_reuse_wait_desc]
     , [spid]           = t.[value]
     , [total_mb]       = s.[data_size] + s.[log_size]
     , [data_mb]        = s.[data_size]
     , [data_used_mb]   = s.[data_used_size]
     , [data_free_mb]   = s.[data_size] - s.[data_used_size]
     , [log_mb]         = s.[log_size]
     , [log_used_mb]    = s.[log_used_size]
     , [log_free_mb]    = s.[log_size] - s.[log_used_size]
     , [readonly]       = d.[is_read_only]
     , [access]         = ISNULL(HAS_DBACCESS(d.[name]), 0)
     , [durability]     = d.[delayed_durability_desc]
     , [user_access]    = d.[user_access_desc]
     , [full_last_date] = b.[full_last_date]
     , [full_mb]        = b.[full_size]
     , [diff_last_date] = b.[diff_last_date]
     , [diff_mb]        = b.[diff_size]
     , [log_last_date]  = b.[log_last_date]
     , [log_mb]         = b.[log_size]
     , [create_date]    = CAST(d.create_date AS DATETIME2(0))
FROM sys.databases d WITH(NOLOCK)
LEFT JOIN (
    SELECT [db_id]
         , [data_size]      = SUM(CASE WHEN [type] = 0 THEN [size_mb] END)
         , [data_used_size] = SUM(CASE WHEN [type] = 0 THEN [used_size_mb] END)
         , [log_size]       = SUM(CASE WHEN [type] = 1 THEN [size_mb] END)
         , [log_used_size]  = SUM(CASE WHEN [type] = 1 THEN [used_size_mb] END)
    FROM #database_files
    GROUP BY [db_id]
) s ON d.[database_id] = s.[db_id]
LEFT JOIN #backup_size b ON d.[name] = b.[db_name]
LEFT JOIN #dbcc t ON d.[database_id] = t.[db_id] AND t.[key] = 'OLDACT_SPID'
ORDER BY [total_mb] DESC

EXEC sys.xp_fixeddrives

SELECT [db_name]
     , [name]
     , [type]
     , [size_mb]
     , [used_size_mb]
     , [shrink_size_mb] = [size_mb] - [used_size_mb]
     , 'USE ' + QUOTENAME([db_name]) 
            + CASE WHEN [db_name] = 'tempdb' AND [type] = 0
                  THEN '; DBCC FREEPROCCACHE; CHECKPOINT;'
                  ELSE ';'
              END + ' DBCC SHRINKFILE (N''' + [name] + ''' , ' + CAST([size_mb] AS NVARCHAR(MAX)) + ')'
FROM #database_files
CROSS APPLY (SELECT [db_name] = DB_NAME([db_id])) t
ORDER BY [shrink_size_mb] DESC

--SELECT DB_NAME(dbid), * FROM sys.sysprocesses WHERE open_tran = 1

--BACKUP LOG [CloudHQ] TO DISK = 'nul'

/*
    SELECT D.name
         , percent_complete
         , session_id
         , start_time
         , status
         , command
         , E.blocking_session_id
    FROM sys.dm_exec_requests E
    LEFT JOIN sys.databases D ON E.database_id = D.database_id
    WHERE command IN ('DbccFilesCompact', 'DbccSpaceReclaim', 'DbccLOBCompact')
*/