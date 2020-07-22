USE [master]
GO

IF DB_ID('test') IS NOT NULL BEGIN
    ALTER DATABASE test SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE test
END
GO

IF OBJECT_ID('tempdb.dbo.#temp') IS NOT NULL
    DROP TABLE #temp
GO

SELECT wait_type
     , waiting_tasks_count
     , wait_time_ms
INTO #temp
FROM sys.dm_exec_session_wait_stats
WHERE session_id = @@spid
GO

DBCC TRACEON(1806)

CREATE DATABASE test
ON PRIMARY 
    (NAME = N'test', FILENAME = N'F:\test.mdf', SIZE = 64MB, FILEGROWTH = 1MB)
LOG ON 
    (NAME = N'test_log', FILENAME = N'F:\test.ldf', SIZE = 1MB, FILEGROWTH = 1MB)

DBCC TRACEOFF(1806)

SELECT s.wait_type
     , wait_time = CAST((s.wait_time_ms - ISNULL(t.wait_time_ms, 0)) / 1000. AS DECIMAL(18,4))
     , waiting_tasks = s.waiting_tasks_count - ISNULL(t.waiting_tasks_count, 0)
FROM sys.dm_exec_session_wait_stats s
LEFT JOIN #temp t ON s.wait_type = t.wait_type
WHERE s.session_id = @@spid
    AND s.wait_time_ms - ISNULL(t.wait_time_ms, 0) > 0
ORDER BY wait_time DESC

/*
    PREEMPTIVE_OS_WRITEFILEGATHER occurs when a file is being zero-initialized

    SQL Server Configuration Manager > SQL_2014 > NT Service\MSSQL$SQL_2014

    Local Security Policy
        > User Rights Assignment
            > Perform volume maintenance tasks

    Restart SQL Server
*/

------------------------------------------------------

/*
    USE [master]
    GO

    ALTER DATABASE [model] MODIFY FILE (NAME = N'modeldev', SIZE = 32MB, FILEGROWTH = 64MB)
    GO
    ALTER DATABASE [model] MODIFY FILE (NAME = N'modellog', SIZE = 32MB, FILEGROWTH = 64MB)
    GO

    ALTER DATABASE [tempdb]
        MODIFY FILE (NAME = N'tempdev', SIZE = 256MB, FILEGROWTH = 128MB)
    GO
    ALTER DATABASE [tempdb]
        MODIFY FILE (NAME = N'templog', SIZE = 256MB, FILEGROWTH = 128MB)
    GO

    ALTER DATABASE [tempdb]
        ADD FILE (NAME = N'tempdev2', FILENAME = N'D:\DATABASE\SQL_2014\TEMP\tempdev2.ndf',
                  SIZE = 256MB, FILEGROWTH = 128MB)
    GO
    ALTER DATABASE [tempdb]
        ADD FILE (NAME = N'tempdev3', FILENAME = N'D:\DATABASE\SQL_2014\TEMP\tempdev3.ndf',
                  SIZE = 256MB, FILEGROWTH = 128MB)
    GO
    ALTER DATABASE [tempdb]
        ADD FILE (NAME = N'tempdev4', FILENAME = N'D:\DATABASE\SQL_2014\TEMP\tempdev4.ndf',
                  SIZE = 256MB, FILEGROWTH = 128MB)
    GO
*/