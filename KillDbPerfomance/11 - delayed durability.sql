USE [master] 
GO

IF DB_ID('KillDB') IS NOT NULL BEGIN
    ALTER DATABASE KillDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE KillDB
END
GO

CREATE DATABASE KillDB
GO
ALTER DATABASE KillDB MODIFY FILE (NAME = N'KillDB', SIZE = 64MB, FILEGROWTH = 8MB)
ALTER DATABASE KillDB MODIFY FILE (NAME = N'KillDB_log', SIZE = 64MB, FILEGROWTH = 8MB)
GO

USE KillDB
GO

/*
    ALTER DATABASE KillDB SET DELAYED_DURABILITY = FORCED -- 2014+
*/

SET NOCOUNT ON

DROP TABLE IF EXISTS dbo.tbl
GO

CREATE TABLE dbo.tbl (
      a INT IDENTITY PRIMARY KEY
    , b INT
    , c CHAR(2000)
)
GO

DROP TABLE IF EXISTS #temp
GO

SELECT t.[file_id], t.num_of_writes, t.num_of_bytes_written
INTO #temp
FROM sys.dm_io_virtual_file_stats(DB_ID(), NULL) t

DECLARE @WaitTime BIGINT
      , @WaitTasks BIGINT
      , @StartTime DATETIME = GETDATE()

SELECT @WaitTime = wait_time_ms
     , @WaitTasks = waiting_tasks_count
FROM sys.dm_os_wait_stats
WHERE [wait_type] = N'WRITELOG'

DECLARE @i INT = 1

WHILE @i < 20000 BEGIN

    INSERT INTO dbo.tbl (b, c)
    VALUES (@i, 'text')

    SELECT @i += 1

END

CHECKPOINT

SELECT elapsed_seconds = DATEDIFF(MILLISECOND, @StartTime, GETDATE()) * 1. / 1000
     , wait_time = (wait_time_ms - @WaitTime) / 1000.
     , waiting_tasks_count = waiting_tasks_count - @WaitTasks
FROM sys.dm_os_wait_stats
WHERE [wait_type] = N'WRITELOG'

SELECT [file] = FILE_NAME(o.[file_id])
     , num_of_writes = t.num_of_writes - o.num_of_writes
     , num_of_mb_written = (t.num_of_bytes_written - o.num_of_bytes_written) * 1. / 1024 / 1024
FROM #temp o
CROSS APPLY sys.dm_io_virtual_file_stats(DB_ID(), NULL) t
WHERE o.[file_id] = t.[file_id]

/*
    tempdb >= 2014
*/