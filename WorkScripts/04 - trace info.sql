SET NOCOUNT ON

DECLARE @path NVARCHAR(4000)
SELECT TOP(1) @path = [path]
FROM sys.traces
WHERE [path] LIKE '%CloudHQ%'

DROP TABLE IF EXISTS #trace_file

--SELECT @path

SELECT [StartTime]
     , [TextData] = CAST([TextData] AS NVARCHAR(MAX))
     , [Size] = CAST(DATALENGTH(TextData) / 1024. / 1024. AS DECIMAL(32,2))
     , [Duration] = [Duration] / 1000
     , [CPU]
     , [Reads]
     , [Writes]
     , [Rows]  = [RowCounts]
     , [App]   = [ApplicationName]
     , [Login] = [LoginName]
     , [SPID]
INTO #trace_file
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE 1 = 1
    AND [LoginName] != 'RTW\ssyrovatchenko'
    AND [EventClass] IN (10, 12)
    AND [StartTime] >= DATEADD(DAY, -1, GETDATE())
    --AND [Duration] / 1000 > 5000
    --AND [ApplicationName] = 'CloudHQ'
    --AND [TextData] LIKE '%dbo%'
    --AND [Reads] > 10000
    --AND [LoginName] = 'sa'

SELECT TOP(100) StartTime
              , TextData = CAST('<?query --' + CHAR(13) + [TextData] + CHAR(13) + '--?>' AS XML)
              , [Size]
              , Duration
              , CPU
              , Reads
              , Writes
              , [Rows]
              , [App]
              , [Login]
              , SPID
FROM #trace_file
WHERE 1 = 1