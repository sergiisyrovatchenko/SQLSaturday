SELECT StartTime
     , Duration = Duration / 1000
     , DatabaseName = DB_NAME(DatabaseID)
     , [FileName]
     , GrowType = CASE WHEN EventClass = 92 THEN 'DATA' ELSE 'LOG' END
FROM sys.traces i
CROSS APPLY sys.fn_trace_gettable(i.[path], DEFAULT) t
WHERE t.EventClass IN (92, 93)
    AND i.is_default = 1
ORDER BY t.StartTime DESC

/*
    ALTER DATABASE KillDB MODIFY FILE (NAME = N'KillDB', FILEGROWTH = 64MB)
    ALTER DATABASE KillDB MODIFY FILE (NAME = N'KillDB_log', FILEGROWTH = 64MB)
*/