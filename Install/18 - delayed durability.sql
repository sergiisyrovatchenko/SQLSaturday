USE [master] 
GO

IF DB_ID('db') IS NOT NULL BEGIN
    ALTER DATABASE db SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE db
END
GO

CREATE DATABASE db
GO
ALTER DATABASE db
    MODIFY FILE (NAME = N'db', SIZE = 64MB, FILEGROWTH = 8MB)
GO
ALTER DATABASE db
    MODIFY FILE (NAME = N'db_log', SIZE = 64MB, FILEGROWTH = 8MB)
GO

USE db
GO

/*
    ALTER DATABASE TT SET DELAYED_DURABILITY = FORCED -- 2014+
*/

SET NOCOUNT ON

IF OBJECT_ID('dbo.tbl', 'U') IS NOT NULL
    DROP TABLE dbo.tbl
GO

CREATE TABLE dbo.tbl (
      a INT IDENTITY PRIMARY KEY
    , b INT
    , c CHAR(2000)
)
GO

IF OBJECT_ID('tempdb.dbo.#temp') IS NOT NULL
    DROP TABLE #temp
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