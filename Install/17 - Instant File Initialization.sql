USE [master]
GO

IF DB_ID('IFI_DB') IS NOT NULL
    DROP DATABASE IFI_DB
GO

DBCC TRACEON(3004, 3605, -1) WITH NO_INFOMSGS
CREATE DATABASE IFI_DB
DBCC TRACEOFF(3004, 3605, -1) WITH NO_INFOMSGS
GO

IF DB_ID('IFI_DB') IS NOT NULL
    DROP DATABASE IFI_DB
GO

EXEC sys.sp_readerrorlog 0, 1

------------------------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#temp') IS NOT NULL
    DROP TABLE #temp
GO

CREATE TABLE #temp (txt VARCHAR(8000))
GO

INSERT INTO #temp
EXEC sys.xp_cmdshell 'whoami /priv'

SELECT IsEnabled =
    CASE WHEN txt LIKE '%Enabled%' COLLATE SQL_Latin1_General_CP1_CI_AS
        THEN 1
        ELSE 0
    END
FROM #temp
WHERE txt LIKE '%SeManageVolumePrivilege%'

------------------------------------------------------------------

USE [master]
GO

IF DB_ID('IFI_DB') IS NOT NULL
    DROP DATABASE [IFI_DB]
GO

CREATE DATABASE [IFI_DB]
    CONTAINMENT = NONE
    ON PRIMARY (NAME = N'IFI_DB', FILENAME = N'D:\DATABASE\SQL_2016\DATA\IFI_DB.mdf', SIZE = 2048MB)
    LOG ON (NAME = N'IFI_DB_log', FILENAME = N'D:\DATABASE\SQL_2016\LOG\IFI_DB_log.ldf', SIZE = 2048KB)
GO

-- OFF: 
--  ON: 

ALTER DATABASE [IFI_DB] MODIFY FILE (NAME = N'IFI_DB', SIZE = 4096MB)
GO

-- OFF: 
--  ON: 

BACKUP DATABASE [IFI_DB]
    TO DISK = N'D:\DATABASE\SQL_2016\BACKUP\IFI_DB.bak'
    WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
GO
IF DB_ID('IFI_DB') IS NOT NULL
    DROP DATABASE [IFI_DB]
GO

-- OFF: 
--  ON: 

USE [master]
GO
RESTORE DATABASE [IFI_DB]
    FROM DISK = N'D:\DATABASE\SQL_2016\BACKUP\IFI_DB.bak'
    WITH FILE = 1, NOUNLOAD

-- OFF: 
--  ON: 

------------------------------------------------------------------

/*
    SQL Server Configuration Manager
        > SQL_2014
            > NT Service\MSSQL$SQL_2014

    Local Security Policy
        > User Rights Assignment
            > Perform volume maintenance tasks

    Restart SQL Server
*/