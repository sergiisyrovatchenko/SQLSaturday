USE [master]
GO

IF DB_ID('CCI') IS NOT NULL BEGIN
    ALTER DATABASE [CCI] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE [CCI]
END
GO

CREATE DATABASE [CCI]
GO

USE [CCI] -- SQL Server 2012
GO

IF OBJECT_ID('dbo.CCI_RO', 'U') IS NOT NULL
    DROP TABLE dbo.CCI_RO
GO

CREATE TABLE dbo.CCI_RO (
      DateID DATE NOT NULL
    , UserID INT NOT NULL
    , Salary MONEY NOT NULL
    , PRIMARY KEY (DateID, UserID)
) ON [PRIMARY]
GO

INSERT INTO dbo.CCI_RO (DateID, UserID, Salary)
VALUES ('20190928', 1, 1500)
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCCI ON dbo.CCI_RO
    (DateID, UserID, Salary) WITH (DROP_EXISTING = OFF) ON [PRIMARY]
GO

---------------------------------------------------------------------------------------------------------

UPDATE dbo.CCI_RO
SET Salary = 0
GO

/*
    Msg 35330, Level 15, State 1, Line 20
    UPDATE statement failed because data cannot be updated in a table with a columnstore index.
    Consider disabling the columnstore index before issuing the UPDATE statement, then rebuilding the columnstore index after UPDATE is complete.
*/

---------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.CCI', 'U') IS NOT NULL
    DROP TABLE dbo.CCI
GO

IF OBJECT_ID('dbo.CCI_Copy', 'U') IS NOT NULL
    DROP TABLE dbo.CCI_Copy
GO

IF EXISTS(SELECT * FROM sys.partition_schemes WHERE [name] = 'PS')
    DROP PARTITION SCHEME PS
GO

IF EXISTS(SELECT * FROM sys.partition_functions WHERE [name] = 'PF')
    DROP PARTITION FUNCTION PF
GO

CREATE PARTITION FUNCTION PF (DATE)
    AS RANGE LEFT
    FOR VALUES ('20190901', '20191001')
GO

CREATE PARTITION SCHEME PS
    AS PARTITION PF ALL TO ([PRIMARY])
GO

CREATE TABLE dbo.CCI (
      DateID DATE NOT NULL
    , UserID INT NOT NULL
    , Salary MONEY NOT NULL
    , PRIMARY KEY (DateID, UserID) WITH (DATA_COMPRESSION = PAGE)
) ON PS(DateID)
GO

INSERT INTO dbo.CCI (DateID, UserID, Salary)
VALUES ('20190810', 1, 1500)
     , ('20190928', 2, 1500)
     , ('20191002', 3, 1500)

SELECT *
FROM sys.partitions
WHERE [object_id] = OBJECT_ID('dbo.CCI')

---------------------------------------------------------------------------------------------------------

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCCI ON dbo.CCI
    (DateID, UserID, Salary) WITH (DROP_EXISTING = OFF) ON PS(DateID)
GO

UPDATE dbo.CCI
SET Salary = 0
WHERE DateID = '20190928'
GO

/*
    Msg 35330, Level 15, State 1, Line 20
    UPDATE statement failed because data cannot be updated in a table with a columnstore index.
    Consider disabling the columnstore index before issuing the UPDATE statement, then rebuilding the columnstore index after UPDATE is complete.
*/

---------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.CCI_Copy', 'U') IS NOT NULL
    DROP TABLE dbo.CCI_Copy
GO

CREATE TABLE dbo.CCI_Copy (
      DateID DATE NOT NULL -- !!! IS NOT NULL
    , UserID INT NOT NULL
    , Salary MONEY NOT NULL
    , PRIMARY KEY (DateID, UserID) WITH (DATA_COMPRESSION = PAGE) -- !!!
) ON [PRIMARY]
GO

ALTER TABLE dbo.CCI_Copy
    ADD CONSTRAINT PF_CHECK CHECK (DateID > '20190901' AND DateID <= '20191001' /* AND DateID IS NOT NULL */) -- !!! IS NOT NULL
GO

/*
    Msg 4982, Level 16, State 1, Line 147
    ALTER TABLE SWITCH statement failed. Check constraints of source table 'dbo.CCI_Copy'
    allow values that are not allowed by range defined by partition 2 on target table 'dbo.CCI'.
*/

/*
    IF OBJECT_ID('tempdb.dbo.#temp', 'U') IS NOT NULL
        DROP TABLE #temp
    GO

    CREATE TABLE #temp (
          Color VARCHAR(15) --NULL
        , CONSTRAINT CK CHECK (Color IN ('Black', 'White')) -- NOT FALSE
    )

    INSERT INTO #temp VALUES ('Black')
    INSERT INTO #temp VALUES ('Red')
    INSERT INTO #temp VALUES (NULL)

    SELECT * FROM #temp
*/

ALTER TABLE dbo.CCI SWITCH PARTITION 2 TO dbo.CCI_Copy
GO

SELECT *
FROM sys.partitions
WHERE [object_id] IN (OBJECT_ID('dbo.CCI'), OBJECT_ID('dbo.CCI_Copy'))
GO

UPDATE dbo.CCI_Copy
SET Salary = 0
WHERE DateID = '20190928'
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCCI ON dbo.CCI_Copy
    (DateID, UserID, Salary) ON [PRIMARY]
GO

/*
    Msg 4947, Level 16, State 1, Line 149
    ALTER TABLE SWITCH statement failed. There is no identical index in source table 'dbo.CCI_Copy' for the index 'NCCCI' in target table 'dbo.CCI' .
*/

SELECT * FROM dbo.CCI
SELECT * FROM dbo.CCI_Copy
GO

---------------------------------------------------------------------------------------------------------

ALTER TABLE dbo.CCI_Copy SWITCH PARTITION 1 TO dbo.CCI PARTITION 2
GO

SELECT * FROM dbo.CCI
SELECT * FROM dbo.CCI_Copy
GO

---------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.CCI', 'U') IS NOT NULL
    DROP TABLE dbo.CCI
GO

IF OBJECT_ID('dbo.CCI_Copy', 'U') IS NOT NULL
    DROP TABLE dbo.CCI_Copy
GO

IF EXISTS(SELECT * FROM sys.partition_schemes WHERE [name] = 'PS')
    DROP PARTITION SCHEME PS
GO

IF EXISTS(SELECT * FROM sys.partition_functions WHERE [name] = 'PF')
    DROP PARTITION FUNCTION PF
GO

---------------------------------------------------------------------------------------------------------

IF DB_ID('CCI') IS NOT NULL BEGIN
    ALTER DATABASE [CCI] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE [CCI]
END
GO