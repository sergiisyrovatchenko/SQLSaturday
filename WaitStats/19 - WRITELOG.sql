USE [master]
GO

SET NOCOUNT ON

IF DB_ID('test') IS NOT NULL BEGIN
    ALTER DATABASE test SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE test
END
GO

CREATE DATABASE test
GO
ALTER DATABASE test
    MODIFY FILE (NAME = N'test', SIZE = 64MB, FILEGROWTH = 8MB)
GO
ALTER DATABASE test
    MODIFY FILE (NAME = N'test_log', SIZE = 64MB, FILEGROWTH = 8MB)
GO

USE test
GO

--ALTER DATABASE test SET DELAYED_DURABILITY = FORCED -- 2014+

IF OBJECT_ID('dbo.OLTP', 'U') IS NOT NULL
    DROP TABLE dbo.OLTP
GO

CREATE TABLE dbo.OLTP (
      ID INT IDENTITY PRIMARY KEY
    , Val INT
)
GO

IF OBJECT_ID('tempdb.dbo.#temp') IS NOT NULL
    DROP TABLE #temp
GO

SELECT t.[file_id], t.num_of_writes, t.num_of_bytes_written
INTO #temp
FROM sys.dm_io_virtual_file_stats(DB_ID(), NULL) t

DECLARE @wait_time_ms BIGINT
      , @waiting_tasks_count BIGINT
      , @start_time DATETIME = GETDATE()

SELECT @wait_time_ms = wait_time_ms
     , @waiting_tasks_count = waiting_tasks_count
FROM sys.dm_os_wait_stats
WHERE [wait_type] = N'WRITELOG'

DECLARE @i INT = 1

WHILE @i < 20000 BEGIN

    INSERT INTO dbo.OLTP
    VALUES (@i)

    SELECT @i += 1

END

/*
    DECLARE @i INT = 1

    WHILE @i < 20 BEGIN

        INSERT INTO dbo.OLTP
        SELECT TOP(1000) ROW_NUMBER() OVER (ORDER BY 1/0)
        FROM [master].dbo.spt_values

        SELECT @i += 1

    END
*/

SELECT elapsed_seconds = DATEDIFF(MILLISECOND, @start_time, GETDATE()) * 1. / 1000
     , wait_time = (wait_time_ms - @wait_time_ms) / 1000.
     , waiting_tasks_count = waiting_tasks_count - @waiting_tasks_count
FROM sys.dm_os_wait_stats
WHERE [wait_type] = N'WRITELOG'

SELECT [file] = FILE_NAME(o.[file_id])
     , num_of_writes = t.num_of_writes - o.num_of_writes
     , num_of_mb_written = (t.num_of_bytes_written - o.num_of_bytes_written) * 1. / 1024 / 1024
FROM #temp o
LEFT JOIN sys.dm_io_virtual_file_stats(DB_ID(), NULL) t ON o.[file_id] = t.[file_id]

/*
    tempdb >= 2014
*/