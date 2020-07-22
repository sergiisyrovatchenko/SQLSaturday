/*
    CREATE TABLE model..public_table (ID INT)

    DROP TABLE IF EXISTS model..public_table
*/

USE [master]
GO

IF DB_ID('KillDB') IS NOT NULL BEGIN
    ALTER DATABASE KillDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE KillDB
END
GO

--CREATE DATABASE KillDB
CREATE DATABASE KillDB ON PRIMARY (NAME = N'KillDB', FILENAME = N'Y:\KillDB.mdf')
                           LOG ON (NAME = N'KillDB_log', FILENAME = N'Y:\KillDB_log.ldf')
GO

------------------------------------------------------

SELECT [name]
     , database_id
     , [compatibility_level]
     , collation_name
     , user_access_desc
     , is_auto_close_on
     , is_auto_shrink_on
     , state_desc
     , snapshot_isolation_state_desc
     , is_read_committed_snapshot_on
     , recovery_model_desc
     , page_verify_option_desc
     , is_auto_create_stats_on
     , is_auto_create_stats_incremental_on
     , is_auto_update_stats_on
     , is_auto_update_stats_async_on
     , is_broker_enabled
     , delayed_durability_desc
FROM sys.databases
WHERE [name] IN ('model', 'KillDB')

SELECT [file_id]
     , [type_desc]
     , [name]
     , physical_name
     , [state]
     , state_desc
     , size = size * 8. / 1024
     , max_size
     , growth
     , is_percent_growth
FROM sys.master_files
WHERE database_id IN (DB_ID('model'), DB_ID('KillDB'))

/*
    USE model
    GO

    DBCC SHRINKFILE (N'modeldev' , 3)
    DBCC SHRINKFILE (N'modellog' , EMPTYFILE)
    DBCC SHRINKFILE (N'modellog' , 1)

    SQL Server 2005-2014:

    ALTER DATABASE [model] MODIFY FILE (NAME = N'modeldev', SIZE = 3MB, FILEGROWTH = 1MB)
    ALTER DATABASE [model] MODIFY FILE (NAME = N'modellog', SIZE = 1MB, FILEGROWTH = 10%)


    SQL Server 2016-2017:

    ALTER DATABASE [model] MODIFY FILE (NAME = N'modeldev', SIZE = 8MB, FILEGROWTH = 64MB)
    ALTER DATABASE [model] MODIFY FILE (NAME = N'modellog', SIZE = 8MB, FILEGROWTH = 64MB)
*/