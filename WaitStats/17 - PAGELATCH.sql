USE tempdb
GO

--DBCC TRACEON(1118, 3605, -1) WITH NO_INFOMSGS

IF OBJECT_ID('tempdb.dbo.#t') IS NOT NULL
    DROP TABLE #t
GO

CREATE TABLE #t (ID INT DEFAULT 1)
GO

CHECKPOINT
GO

INSERT #t DEFAULT VALUES
GO

--DBCC TRACEOFF(1118, 3605, -1) WITH NO_INFOMSGS
--GO


-- MixedExtent vs FullExtent

SELECT [Current LSN], Operation, Context, AllocUnitName, [Description]
FROM sys.fn_dblog(NULL, NULL)

/*
    SQL Server 2016: T1118 = ON

    ALTER DATABASE db SET MIXED_PAGE_ALLOCATION OFF

    ALTER DATABASE db
        MODIFY FILEGROUP [PRIMARY] AUTOGROW_ALL_FILES
*/

------------------------------------------------------

/*
    SELECT *
    FROM dbo.HeavyInsertLoad
    WHERE ID = @ID
*/

CREATE PARTITION FUNCTION PF (INT)
    AS RANGE LEFT FOR VALUES (0 ,1, 2)
GO

CREATE PARTITION SCHEME PS
    AS PARTITION PF ALL TO ([PRIMARY])
GO

CREATE TABLE dbo.HeavyInsertLoad (
      ID INT NOT NULL
    , Val VARCHAR(50)
    , HashID AS CAST(ABS(ID % 4) AS TINYINT) PERSISTED NOT NULL
)

CREATE UNIQUE CLUSTERED INDEX UX
    ON dbo.HeavyInsertLoad (ID, HashID)
    ON PS(HashID)

/*
    SELECT *
    FROM dbo.HeavyInsertLoad
    WHERE ID = @ID
        AND HashID = @ID % 4
*/
