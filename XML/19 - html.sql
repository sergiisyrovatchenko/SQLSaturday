/*
    EXEC sys.sp_configure 'show advanced options', 1
    GO
    RECONFIGURE
    GO

    EXEC sys.sp_configure 'xp_cmdshell', 1
    GO
    RECONFIGURE WITH OVERRIDE
    GO
*/

USE AdventureWorks2014
GO

DROP TABLE IF EXISTS ##temp
GO

------------------------------------------------------

DROP TABLE IF EXISTS #waits
GO

SELECT TOP(20) wait_type
             , wait_time = CAST(wait_time_ms / 1000. AS DECIMAL(18,4))
             , wait_resource = CAST((wait_time_ms - signal_wait_time_ms) / 1000. AS DECIMAL(18,4))
             , wait_signal = CAST(signal_wait_time_ms / 1000. AS DECIMAL(18,4))
             , wait_time_percent = CAST(100. * wait_time_ms / NULLIF(SUM(wait_time_ms) OVER (), 0) AS DECIMAL(18,2))
             , waiting_tasks_count
INTO #waits
FROM sys.dm_os_wait_stats
WHERE waiting_tasks_count > 0
    AND wait_time_ms > 0
    AND wait_type NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP', N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE', N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES', N'WAIT_FOR_RESULTS',
        N'WAITFOR', N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT'
    )
ORDER BY wait_time_ms DESC

------------------------------------------------------

DROP TABLE IF EXISTS #db
DROP TABLE IF EXISTS #space
GO

CREATE TABLE #space (
      database_id INT PRIMARY KEY
    , data_used_size DECIMAL(18,2)
    , log_used_size DECIMAL(18,2)
)

DECLARE @SQL NVARCHAR(MAX) = STUFF((
    SELECT '
    USE [' + d.[name] + ']
    INSERT INTO #space (database_id, data_used_size, log_used_size)
    SELECT DB_ID()
         , SUM(CASE WHEN [type] = 0 THEN space_used END)
         , SUM(CASE WHEN [type] = 1 THEN space_used END)
    FROM (
        SELECT s.[type], space_used = SUM(FILEPROPERTY(s.name, ''SpaceUsed'') * 8. / 1024)
        FROM sys.database_files s
        GROUP BY s.[type]
    ) t;'
    FROM sys.databases d
    WHERE d.[state] = 0
    FOR XML PATH(''), TYPE).value('(./text())[1]', 'NVARCHAR(MAX)'), 1, 2, '')

EXEC sys.sp_executesql @SQL

SELECT d.[name]
     , d.state_desc
     , d.recovery_model_desc
     , t.total_size
     , t.data_size
     , s.data_used_size
     , t.log_size
     , s.log_used_size
     , b.full_backup_last_date
     , b.full_backup_size
     , b.log_backup_last_date
     , b.log_backup_size
INTO #db
FROM (
    SELECT database_id
         , log_size = CAST(SUM(CASE WHEN [type] = 1 THEN size END) * 8. / 1024 AS DECIMAL(18,2))
         , data_size = CAST(SUM(CASE WHEN [type] = 0 THEN size END) * 8. / 1024 AS DECIMAL(18,2))
         , total_size = CAST(SUM(size) * 8. / 1024 AS DECIMAL(18,2))
    FROM sys.master_files
    GROUP BY database_id
) t
JOIN sys.databases d ON d.database_id = t.database_id
LEFT JOIN #space s ON d.database_id = s.database_id
LEFT JOIN (
    SELECT [database_name]
         , full_backup_last_date = MAX(CASE WHEN [type] = 'D' THEN backup_finish_date END)
         , full_backup_size = MAX(CASE WHEN [type] = 'D' THEN backup_size END)
         , log_backup_last_date = MAX(CASE WHEN [type] = 'L' THEN backup_finish_date END)
         , log_backup_size = MAX(CASE WHEN [type] = 'L' THEN backup_size END)
    FROM (
        SELECT s.[database_name]
             , s.[type]
             , s.backup_finish_date
             , backup_size =
                         CAST(CASE WHEN s.backup_size = s.compressed_backup_size
                                     THEN s.backup_size
                                     ELSE s.compressed_backup_size
                         END / 1048576.0 AS DECIMAL(18,2))
             , RowNum = ROW_NUMBER() OVER (PARTITION BY s.[database_name], s.[type] ORDER BY s.backup_finish_date DESC)
        FROM msdb.dbo.backupset s
        WHERE s.[type] IN ('D', 'L')
    ) f
    WHERE f.RowNum = 1
    GROUP BY f.[database_name]
) b ON d.[name] = b.[database_name]

------------------------------------------------------

DECLARE @waits XML = (
SELECT [@style] = 'border:1px solid #ddd;margin:5px;border-collapse:collapse;'
,(
    SELECT [@style] = 'border:1px solid #ddd; text-align: left;background-color: #ccc'
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'wait_type'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'wait_time'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'wait_resource'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'wait_signal'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'wait_time_percent'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'wait_resource'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'waiting_tasks_count'
    FOR XML PATH('tr'), TYPE
)
,(
    SELECT [@style] = 'border:1px solid #ddd' + IIF(ROW_NUMBER() OVER (ORDER BY 1/0) % 2 = 0, ';background-color: #f5f5f5', '')
         , [td/@style] = 'padding:5px;font-weight: normal' + IIF(wait_time_percent > 20, ';color:red', '')
         , td = wait_type
         , ''
         , [td/@style] = 'padding:5px'
         , td = wait_time
         , ''
         , [td/@style] = 'padding:5px'
         , td = wait_resource
         , ''
         , [td/@style] = 'padding:5px'
         , td = wait_signal
         , ''
         , [td/@style] = 'padding:5px'
         , td = wait_time_percent 
         , ''
         , [td/@style] = 'padding:5px'
         , td = wait_resource
         , ''
         , [td/@style] = 'padding:5px'
         , td = waiting_tasks_count
    FROM #waits
    FOR XML PATH('tr'), TYPE
)
FOR XML PATH('table'))

------------------------------------------------------

DECLARE @db XML = (
SELECT [@style] = 'border:1px solid #ddd;margin:5px;border-collapse:collapse'
,(
    SELECT [@style] = 'border:1px solid #ddd; text-align: left;background-color: #ccc'
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'database'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'state'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'recovery_model'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'total_size'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'data_size'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'data_used_size'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'log_size'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'log_used_size'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'full_backup_last_date'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'full_backup_size'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'log_backup_last_date'
         , ''
         , [th/@style] = 'padding:5px;font-weight: normal'
         , th = 'log_backup_size'
    FOR XML PATH('tr'), TYPE
)
,(
    SELECT [@style] = 'border:1px solid #ddd' + IIF(ROW_NUMBER() OVER (ORDER BY 1/0) % 2 = 0, ';background-color: #f5f5f5', '')
         , [td/@style] = 'padding:5px'
         , td = [name]
         , ''
         , [td/@style] = 'padding:5px' + IIF(state_desc != 'ONLINE', ';color:red', '')
         , td = state_desc
         , ''
         , [td/@style] = 'padding:5px'
         , td = recovery_model_desc
         , ''
         , [td/@style] = 'padding:5px'
         , td = total_size
         , ''
         , [td/@style] = 'padding:5px'
         , td = data_size 
         , ''
         , [td/@style] = 'padding:5px' + IIF(data_size - data_used_size < data_size * .10, ';color:red', '')
         , td = data_used_size
         , ''
         , [td/@style] = 'padding:5px'
         , td = log_size
         , ''
         , [td/@style] = 'padding:5px' + IIF(log_size - log_used_size < log_size * .10, ';color:red', '')
         , td = log_used_size
         , ''
         , [td/@style] = 'padding:5px' + IIF(DATEDIFF(DAY, full_backup_last_date, GETDATE()) > 1, ';color:red', '')
                                       + IIF(full_backup_last_date IS NULL, ';background-color:#ffd4d4;', '')
         , td = full_backup_last_date
         , ''
         , [td/@style] = 'padding:5px'
         , td = full_backup_size
         , ''
         , [td/@style] = 'padding:5px' + IIF(recovery_model_desc = 'FULL' AND DATEDIFF(DAY, log_backup_last_date, GETDATE()) > 1, ';color:red', '')
                                       + IIF(recovery_model_desc = 'FULL' AND log_backup_last_date IS NULL, ';background-color:#ffd4d4;', '')
         , td = log_backup_last_date
         , ''
         , [td/@style] = 'padding:5px'
         , td = log_backup_size
    FROM #db
    ORDER BY [name]
    FOR XML PATH('tr'), TYPE
)
FOR XML PATH('table'))

SELECT x = (
        SELECT [*] = x
        FROM (
            VALUES (@waits), (@db)
        ) t(x)
        FOR XML PATH(''), TYPE
    )
INTO ##temp

DECLARE @bcp NVARCHAR(4000) = 'bcp "SELECT * FROM ##temp" queryout "X:\sample.html" -S ' + @@servername + ' -T -w -r -t'
EXEC sys.xp_cmdshell @bcp

/*
    <html>
      <table>
        <tr>
          <th>...</th>
          ...
        </tr>
        <tr>
          <td>...</td>
          ...
        </tr>
        ...
      </table>
    </html>
*/