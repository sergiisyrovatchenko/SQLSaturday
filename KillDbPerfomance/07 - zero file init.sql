USE [master]
GO

IF DB_ID('zfi') IS NOT NULL
    DROP DATABASE zfi
GO

DBCC TRACEON(1806 , -1) -- will disable Instant File Initialization
DBCC TRACEON(3004, 3605, -1) WITH NO_INFOMSGS
CREATE DATABASE zfi
DBCC TRACEOFF(3004, 3605, -1) WITH NO_INFOMSGS
DBCC TRACEOFF(1806 , -1)
GO

IF DB_ID('zfi') IS NOT NULL
    DROP DATABASE zfi
GO

EXEC sys.sp_readerrorlog 0, 1

------------------------------------------------------------------

SELECT servicename
     , startup_type_desc
     , status_desc
     , service_account
     , instant_file_initialization_enabled
FROM sys.dm_server_services

/*
    EXEC sys.sp_configure 'show advanced options', 1
    GO
    RECONFIGURE
    GO

    EXEC sys.sp_configure 'xp_cmdshell', 1
    GO
    RECONFIGURE WITH OVERRIDE
    GO
    
    IF OBJECT_ID('tempdb.dbo.#temp') IS NOT NULL
        DROP TABLE #temp
    GO

    CREATE TABLE #temp (Value VARCHAR(8000))
    GO

    IF EXISTS (
            SELECT 1
            FROM sys.configurations
            WHERE name = 'xp_cmdshell'
                AND value_in_use = 1
                AND IS_SRVROLEMEMBER('sysadmin') = 1
        )
    BEGIN

        INSERT INTO #temp
        EXEC sys.xp_cmdshell 'whoami /priv'

        SELECT IsEnabled =
            CASE WHEN Value LIKE '%Enabled%' COLLATE SQL_Latin1_General_CP1_CI_AS
                THEN 1
                ELSE 0
            END
        FROM #temp
        WHERE Value LIKE '%SeManageVolumePrivilege%'

    END
*/

------------------------------------------------------------------

USE [master]
GO

DBCC TRACEON(1806 , -1)
DBCC TRACEOFF(1806 , -1)

IF DB_ID('zfi') IS NOT NULL
    DROP DATABASE zfi
GO

CREATE DATABASE zfi
    CONTAINMENT = NONE
    ON PRIMARY (NAME = N'zfi', FILENAME = N'D:\DATABASE\SQL_2017\DATA\zfi.mdf', SIZE = 1048MB)
    LOG ON (NAME = N'zfi_log', FILENAME = N'D:\DATABASE\SQL_2017\LOG\zfi_log.ldf', SIZE = 2048KB)
GO

-- OFF: 
--  ON: 

ALTER DATABASE zfi MODIFY FILE (NAME = N'zfi', SIZE = 2096MB)
GO

-- OFF: 
--  ON: 

BACKUP DATABASE zfi
    TO DISK = N'D:\BACKUP\zfi.bak'
    WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
GO
IF DB_ID('zfi') IS NOT NULL
    DROP DATABASE zfi
GO

-- OFF: 
--  ON: 

USE [master]
GO
RESTORE DATABASE zfi
    FROM DISK = N'D:\BACKUP\zfi.bak'
    WITH FILE = 1, NOUNLOAD

-- OFF: 
--  ON: 

------------------------------------------------------------------

/*
    SQL Server Configuration Manager
        > SQL_2017
            > NT Service\MSSQL$SQL_2017

    Local Security Policy
        > User Rights Assignment
            > Perform volume maintenance tasks

    Restart SQL Server
*/