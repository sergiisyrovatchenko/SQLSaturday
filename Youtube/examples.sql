-- SQL Server 2019+

USE [master]
GO

IF DB_ID('PerformanceTest') IS NOT NULL BEGIN
    ALTER DATABASE [PerformanceTest] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE [PerformanceTest]
END
GO

CREATE DATABASE [PerformanceTest]
    ON PRIMARY (NAME = N'PerformanceTest', FILENAME = N'C:\GIT\PerformanceTest.mdf', SIZE = 256MB, FILEGROWTH = 256MB)
        LOG ON (NAME = N'PerformanceTest_log', FILENAME = N'C:\GIT\PerformanceTest.ldf', SIZE = 256MB, FILEGROWTH = 256MB)
GO

ALTER DATABASE [PerformanceTest] COLLATE Latin1_General_CI_AS
ALTER DATABASE [PerformanceTest] SET COMPATIBILITY_LEVEL = 140
ALTER DATABASE [PerformanceTest] SET RECOVERY SIMPLE
GO

USE [PerformanceTest]
GO

DROP TABLE IF EXISTS dbo.tblSites
GO

CREATE TABLE dbo.tblSites (
      SiteID  INT NOT NULL
    , BrandID INT NULL
)
GO

CREATE CLUSTERED INDEX [CL:Sites(SiteID,BrandID)] ON dbo.tblSites (SiteID, BrandID)
GO

INSERT INTO dbo.tblSites WITH(TABLOCK) (SiteID, BrandID)
SELECT t.SiteID, t2.BrandID
FROM (
    VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)
) t(SiteID)
CROSS APPLY (
    VALUES (1),(2),(3),(4),(5),(NULL)
) t2(BrandID)
GO

DROP TABLE IF EXISTS dbo.tblCustomers
GO

CREATE TABLE dbo.tblCustomers (
      CustomerID  INT NOT NULL
    , SiteID      INT NOT NULL
    , BrandID     INT NULL
    , IsException BIT NOT NULL
    , CONSTRAINT [PK:Customers(CustomerID)] PRIMARY KEY (CustomerID)
)
GO

;WITH
    E1(N) AS (
        SELECT * FROM (
            VALUES
                (1),(1),(1),(1),(1),
                (1),(1),(1),(1),(1)
        ) t(N)
    ),
    E2(N) AS (SELECT 1 FROM E1 a, E1 b),
    E4(N) AS (SELECT 1 FROM E2 a, E2 b),
    E8(N) AS (SELECT 1 FROM E4 a, E4 b)
INSERT INTO dbo.tblCustomers WITH(TABLOCK) (CustomerID, SiteID, IsException)
SELECT RN, (RN % 9) + 1, IIF(RN % 9 = 0, 1, 0)
FROM (
    SELECT TOP(50000000) RN = ROW_NUMBER() OVER (ORDER BY 1/0)
    FROM E8
) t
GO

INSERT INTO dbo.tblCustomers WITH(TABLOCK) (CustomerID, SiteID, BrandID, IsException)
SELECT TOP(100) -CustomerID, SiteID, 1, 0
FROM dbo.tblCustomers
GO

CREATE INDEX [IX:Customers(SiteID,BrandID+IsException)] ON dbo.tblCustomers (SiteID, BrandID) INCLUDE (IsException)
GO

DROP TABLE IF EXISTS dbo.tblTransactions
GO

CREATE TABLE dbo.tblTransactions (
      TransactionDate   DATETIME NOT NULL
    , TransactionID     BIGINT   NOT NULL IDENTITY
    , TransactionTypeID TINYINT  NOT NULL
    , CustomerID        INT      NOT NULL
    , Turnover          MONEY    NOT NULL
    , CONSTRAINT [PK:Transactions(TransactionDate,TransactionID)] PRIMARY KEY (TransactionDate, TransactionID)
)
GO

INSERT INTO dbo.tblTransactions WITH(TABLOCK) (TransactionDate, TransactionTypeID, CustomerID, Turnover)
SELECT TOP(2000000) RN = DATEADD(MINUTE, ROW_NUMBER() OVER (ORDER BY 1/0) % 720, CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME)), TransactionTypeID, CustomerID, 1
FROM (
    SELECT TOP(500000) CustomerID
    FROM dbo.tblCustomers
    ORDER BY NEWID()
) t
CROSS APPLY (
    VALUES (1),(2),(3),(1),(2)
) t2(TransactionTypeID)
GO

INSERT INTO dbo.tblTransactions WITH(TABLOCK) (TransactionDate, TransactionTypeID, CustomerID, Turnover)
SELECT GETUTCDATE(), 1, CustomerID, 0
FROM dbo.tblCustomers
WHERE CustomerID < 0
GO

INSERT INTO dbo.tblTransactions WITH(TABLOCK) (TransactionDate, TransactionTypeID, CustomerID, Turnover)
SELECT TOP(2000000) RN = DATEADD(MINUTE, ROW_NUMBER() OVER (ORDER BY 1/0) % 720, CAST(DATEADD(DAY, -1, CAST(GETUTCDATE() AS DATE)) AS DATETIME)), TransactionTypeID, CustomerID, 1
FROM (
    SELECT TOP(500000) CustomerID
    FROM dbo.tblCustomers
) t
CROSS APPLY (
    VALUES (1),(2),(3),(1),(2)
) t2(TransactionTypeID)
GO

DROP TABLE IF EXISTS dbo.tblPromotions
GO

CREATE TABLE dbo.tblPromotions (
      PromotionID      INT           NOT NULL PRIMARY KEY IDENTITY
    , PromotionCode    NVARCHAR(100) NOT NULL
    , SiteID           INT           NOT NULL
    , GroupSubCodesID  INT           NULL
    , INDEX [IX:Promotions(PromotionCode,SiteID)] (PromotionCode,SiteID)
)
GO

DROP TABLE IF EXISTS dbo.tblSubCodes
GO

CREATE TABLE dbo.tblSubCodes (
      GroupSubCodesID INT           NOT NULL PRIMARY KEY IDENTITY
    , SubCode         NVARCHAR(100) NOT NULL
)
GO

INSERT INTO dbo.tblPromotions WITH(TABLOCK)
SELECT TOP(3000000) CustomerID, SiteID, NULL
FROM dbo.tblCustomers
GO

INSERT INTO dbo.tblSubCodes WITH(TABLOCK)
SELECT TOP(500000) CustomerID
FROM dbo.tblCustomers
GO

/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.GetPromotionID
(
      @PromotionCode NVARCHAR(100)
    , @SiteID INT = NULL
)
AS BEGIN

    SELECT TOP(1) m.PromotionID
    FROM dbo.tblPromotions m
    LEFT JOIN dbo.tblSubCodes s ON s.GroupSubCodesID = m.GroupSubCodesID
    WHERE (m.PromotionCode = @PromotionCode OR s.SubCode = @PromotionCode)
        AND (@SiteID IS NULL OR m.SiteID = @SiteID)

END
GO

SET STATISTICS IO, TIME ON
GO

EXEC dbo.GetPromotionID @PromotionCode = '121212121212'
GO

/*
    Table 'tblSubCodes'. Scan count 5, logical reads 1984, physical reads 0, ...
    Table 'tblPromotions'. Scan count 5, logical reads 15201, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 844 ms,  elapsed time = 329 ms.
*/

CREATE OR ALTER PROCEDURE dbo.GetPromotionID_1
(
      @PromotionCode NVARCHAR(100)
    , @SiteID INT = NULL
)
AS BEGIN

    SELECT TOP(1) m.PromotionID
    FROM dbo.tblPromotions m
    LEFT JOIN dbo.tblSubCodes s ON s.GroupSubCodesID = m.GroupSubCodesID
    WHERE (m.PromotionCode = @PromotionCode OR s.SubCode = @PromotionCode)
        AND (@SiteID IS NULL OR m.SiteID = @SiteID)
    OPTION(RECOMPILE)

END
GO

EXEC dbo.GetPromotionID_1 @PromotionCode = '121212121212'
GO

/*
    Table 'tblSubCodes'. Scan count 5, logical reads 103, physical reads 0, ...
    Table 'tblPromotions'. Scan count 5, logical reads 15201, physical reads 0, ...
     SQL Server Execution Times:
        CPU time = 781 ms,  elapsed time = 323 ms.
*/

CREATE OR ALTER PROCEDURE dbo.GetPromotionID_2
(
      @PromotionCode NVARCHAR(100)
    , @SiteID INT = NULL
)
AS BEGIN

    SELECT TOP(1) PromotionID
    FROM (
        SELECT TOP(1) m.PromotionID
        FROM dbo.tblPromotions m
        WHERE m.PromotionCode = @PromotionCode
            AND (@SiteID IS NULL OR m.SiteID = @SiteID)

        UNION ALL

        SELECT TOP(1) m.PromotionID
        FROM dbo.tblPromotions m
        JOIN dbo.tblSubCodes s ON s.GroupSubCodesID = m.GroupSubCodesID
        WHERE s.SubCode = @PromotionCode
            AND (@SiteID IS NULL OR m.SiteID = @SiteID)
    ) t
    --OPTION(RECOMPILE)

END
GO

EXEC dbo.GetPromotionID_2 @PromotionCode = '121212121212'
GO

/*
    Table 'tblSubCodes'. Scan count 1, logical reads 1892, physical reads 0, ...
    Table 'tblPromotions'. Scan count 1, logical reads 3, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 31 ms,  elapsed time = 25 ms.
*/

CREATE INDEX [IX:SubCodes(SubCode)] ON dbo.tblSubCodes (SubCode)
GO

EXEC dbo.GetPromotionID_2 @PromotionCode = '121212121212'
GO

/*
    Table 'tblSubCodes'. Scan count 1, logical reads 3, physical reads 0, ...
    Table 'tblPromotions'. Scan count 1, logical reads 2, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER FUNCTION dbo.FromTimeZoneToAnotherTimeZone
(
      @SourceDate   DATETIME
    , @TimeZoneFrom NVARCHAR(128) = N'UTC'
    , @TimeZoneTo   NVARCHAR(128) = N'UTC'
)
RETURNS DATETIME
AS BEGIN
    RETURN CAST(@SourceDate AT TIME ZONE @TimeZoneFrom AT TIME ZONE @TimeZoneTo AS DATETIME)
END
GO

CREATE OR ALTER PROCEDURE dbo.spGetTurnover
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
    INSERT INTO @tblSites
    SELECT SiteID
         , BrandID
    FROM dbo.tblSites
    WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
        AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    DECLARE @tblOutput TABLE (DateKey INT, Turnover MONEY)
    INSERT INTO @tblOutput
    SELECT tz.DateKey
         , Turnover = SUM(t.Turnover)
    FROM dbo.tblTransactions t
    JOIN (
        SELECT dc.CustomerID
        FROM dbo.tblCustomers dc
        JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID IS NULL AND dc.BrandID IS NULL
        WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)

        UNION ALL

        SELECT dc.CustomerID
        FROM dbo.tblCustomers dc
        JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID = dc.BrandID
        WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
    ) dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, dbo.FromTimeZoneToAnotherTimeZone(t.TransactionDate, DEFAULT, @TimeZone))
    ) tz
    WHERE CAST(t.TransactionDate AS DATE) = @Date
        AND t.TransactionTypeID IN (1, 2)
    GROUP BY tz.DateKey

    SELECT DateKey = CAST(DATEADD(HH, DateKey, '19000101') AS TIME)
         , Turnover
    FROM @tblOutput
    ORDER BY DateKey

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover @Date = @Date
GO

/*
    Table '#BDFD6278'. Scan count 0, logical reads 60, physical reads 0, ...
    Table 'tblSites'. Scan count 1, logical reads 2, physical reads 0, ...
    Table 'Worktable'. Scan count 1, logical reads 123, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 1 ms.

    Table '#BEF186B1'. Scan count 0, logical reads 12, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblCustomers'. Scan count 60, logical reads 118100, physical reads 0, ...
    Table '#BDFD6278'. Scan count 2, logical reads 2, physical reads 0, ...
    Table 'tblTransactions'. Scan count 1, logical reads 18865, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 31968 ms,  elapsed time = 33206 ms.

    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#BEF186B1'. Scan count 1, logical reads 1, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

     SQL Server Execution Times:
       CPU time = 31968 ms,  elapsed time = 33207 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_1
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
    INSERT INTO @tblSites
    SELECT SiteID
         , BrandID
    FROM dbo.tblSites
    WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
        AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    DECLARE @tblOutput TABLE (DateKey INT, Turnover MONEY)
    INSERT INTO @tblOutput
    SELECT tz.DateKey
         , Turnover = SUM(t.Turnover)
    FROM dbo.tblTransactions t
    JOIN (
        SELECT dc.CustomerID
        FROM dbo.tblCustomers dc
        JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID IS NULL AND dc.BrandID IS NULL
        WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)

        UNION ALL

        SELECT dc.CustomerID
        FROM dbo.tblCustomers dc
        JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID = dc.BrandID
        WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
    ) dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, dbo.FromTimeZoneToAnotherTimeZone(t.TransactionDate, DEFAULT, @TimeZone))
    ) tz
    WHERE t.TransactionDate >= @Date AND t.TransactionDate < DATEADD(DAY, 1, @Date) -- <<<<<<
        AND t.TransactionTypeID IN (1, 2)
    GROUP BY tz.DateKey
    OPTION(RECOMPILE) -- <<<<<<

    SELECT DateKey = CAST(DATEADD(HH, DateKey, '19000101') AS TIME)
         , Turnover
    FROM @tblOutput
    ORDER BY DateKey

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_1 @Date = @Date
GO

/*
    Table '#A692A879'. Scan count 0, logical reads 60, physical reads 0, ...
    Table 'tblSites'. Scan count 1, logical reads 2, physical reads 0, ...
    Table 'Worktable'. Scan count 1, logical reads 123, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

    SQL Server parse and compile time: 
       CPU time = 10 ms, elapsed time = 10 ms.
    Table '#A786CCB2'. Scan count 0, logical reads 12, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblTransactions'. Scan count 2, logical reads 18886, physical reads 0, ...
    Table 'tblCustomers'. Scan count 2, logical reads 272184, physical reads 0, ...
    Table '#A692A879'. Scan count 2, logical reads 2, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 30938 ms,  elapsed time = 32015 ms.

    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#A786CCB2'. Scan count 1, logical reads 1, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 10 ms.

     SQL Server Execution Times:
       CPU time = 30954 ms,  elapsed time = 32028 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_2
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
    INSERT INTO @tblSites
    SELECT SiteID
         , BrandID
    FROM dbo.tblSites
    WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
        AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    DECLARE @tblTransactions TABLE (CustomerID INT, TransactionDate DATETIME, Turnover MONEY)
    INSERT INTO @tblTransactions
    SELECT CustomerID
         , TransactionDate
         , Turnover = SUM(Turnover)
    FROM dbo.tblTransactions
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    GROUP BY CustomerID
           , TransactionDate
    OPTION(RECOMPILE)

    DECLARE @tblOutput TABLE (DateKey INT, Turnover MONEY)
    INSERT INTO @tblOutput
    SELECT tz.DateKey
         , Turnover = SUM(t.Turnover)
    FROM @tblTransactions t -- <<<<<<
    JOIN (
        SELECT dc.CustomerID
        FROM dbo.tblCustomers dc
        JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID IS NULL AND dc.BrandID IS NULL
        WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)

        UNION ALL

        SELECT dc.CustomerID
        FROM dbo.tblCustomers dc
        JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID = dc.BrandID
        WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
    ) dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, dbo.FromTimeZoneToAnotherTimeZone(t.TransactionDate, DEFAULT, @TimeZone))
    ) tz
    GROUP BY tz.DateKey
    OPTION(RECOMPILE)

    SELECT DateKey = CAST(DATEADD(HH, DateKey, '19000101') AS TIME)
         , Turnover
    FROM @tblOutput
    ORDER BY DateKey

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_2 @Date = @Date
GO

/*
    Table '#A23AC2EE'. Scan count 0, logical reads 60, physical reads 0, ...
    Table 'tblSites'. Scan count 1, logical reads 2, physical reads 0, ...
    Table 'Worktable'. Scan count 1, logical reads 123, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

    SQL Server parse and compile time: 
       CPU time = 1 ms, elapsed time = 1 ms.
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblTransactions'. Scan count 1, logical reads 9443, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1187 ms,  elapsed time = 1180 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 7 ms.
    Table '#A4230B60'. Scan count 0, logical reads 12, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 5352, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#A23AC2EE'. Scan count 800198, logical reads 800198, physical reads 0, ...
    Table 'tblCustomers'. Scan count 0, logical reads 2400594, physical reads 0, ...
    Table '#A32EE727'. Scan count 1, logical reads 5736, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 43406 ms,  elapsed time = 44459 ms.

    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#A4230B60'. Scan count 1, logical reads 1, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

     SQL Server Execution Times:
       CPU time = 44609 ms,  elapsed time = 45659 ms.
*/


/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_3
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
    INSERT INTO @tblSites
    SELECT SiteID
         , BrandID
    FROM dbo.tblSites
    WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
        AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    DECLARE @tblTransactions TABLE (CustomerID INT, TransactionDate DATETIME, Turnover MONEY)
    INSERT INTO @tblTransactions
    SELECT CustomerID
         , TransactionDate
         , Turnover = SUM(Turnover)
    FROM dbo.tblTransactions
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    GROUP BY CustomerID
           , TransactionDate
    OPTION(RECOMPILE)

    DECLARE @tblCustomers TABLE (CustomerID INT)
    INSERT INTO @tblCustomers
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID IS NULL AND dc.BrandID IS NULL
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT t.CustomerID FROM @tblTransactions t)
    OPTION(RECOMPILE)

    INSERT INTO @tblCustomers
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID = dc.BrandID
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT t.CustomerID FROM @tblTransactions t)
    OPTION(RECOMPILE)

    DECLARE @tblOutput TABLE (DateKey INT, Turnover MONEY)
    INSERT INTO @tblOutput
    SELECT tz.DateKey
         , Turnover = SUM(t.Turnover)
    FROM @tblTransactions t
    JOIN @tblCustomers dc ON dc.CustomerID = t.CustomerID -- <<<<<<
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, dbo.FromTimeZoneToAnotherTimeZone(t.TransactionDate, DEFAULT, @TimeZone))
    ) tz
    GROUP BY tz.DateKey
    OPTION(RECOMPILE)

    SELECT DateKey = CAST(DATEADD(HH, DateKey, '19000101') AS TIME)
         , Turnover
    FROM @tblOutput
    ORDER BY DateKey

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_3 @Date = @Date
GO

/*
    Table '#ACB85161'. Scan count 0, logical reads 60, physical reads 0, ...
    Table 'tblSites'. Scan count 1, logical reads 2, physical reads 0, ...
    Table 'Worktable'. Scan count 1, logical reads 123, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 1 ms.
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblTransactions'. Scan count 1, logical reads 9443, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1094 ms,  elapsed time = 1091 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 4 ms.
    Table '#AEA099D3'. Scan count 0, logical reads 356423, physical reads 0, ...
    Table 'Workfile'. Scan count 36, logical reads 5408, physical reads 858, page server reads 0, read-ahead reads 6582, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblCustomers'. Scan count 0, logical reads 1225312, physical reads 0, ...
    Table '#ADAC759A'. Scan count 1, logical reads 5736, physical reads 0, ...
    Table '#ACB85161'. Scan count 1, logical reads 1, physical reads 0, ...
     SQL Server Execution Times:
        CPU time = 2328 ms,  elapsed time = 2911 ms.

    SQL Server parse and compile time: 
       CPU time = 5 ms, elapsed time = 5 ms.
    Table '#AEA099D3'. Scan count 0, logical reads 100, physical reads 0, ...
    Table 'Workfile'. Scan count 36, logical reads 5136, physical reads 858, page server reads 0, read-ahead reads 6582, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblCustomers'. Scan count 0, logical reads 1225312, physical reads 0, ...
    Table '#ADAC759A'. Scan count 1, logical reads 5736, physical reads 0, ...
    Table '#ACB85161'. Scan count 1, logical reads 1, physical reads 0, ...

     SQL Server Execution Times:
       CPU time = 1641 ms,  elapsed time = 2511 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 1 ms.
    Table '#AF94BE0C'. Scan count 0, logical reads 12, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#ADAC759A'. Scan count 1, logical reads 5736, physical reads 0, ...
    Table '#AEA099D3'. Scan count 1, logical reads 573, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 19453 ms,  elapsed time = 20285 ms.

    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#AF94BE0C'. Scan count 1, logical reads 1, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

     SQL Server Execution Times:
       CPU time = 24547 ms,  elapsed time = 26825 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER FUNCTION dbo.FromTimeZoneToAnotherTimeZone_1
(
      @SourceDate   DATETIME
    , @TimeZoneFrom NVARCHAR(128) = N'UTC'
    , @TimeZoneTo   NVARCHAR(128) = N'UTC'
)
RETURNS TABLE
AS
    RETURN (
        SELECT CAST(@SourceDate AT TIME ZONE @TimeZoneFrom AT TIME ZONE @TimeZoneTo AS DATETIME) AS ConvertedDate
    )
GO

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_4
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
    INSERT INTO @tblSites
    SELECT SiteID
         , BrandID
    FROM dbo.tblSites
    WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
        AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    DECLARE @tblTransactions TABLE (CustomerID INT, TransactionDate DATETIME, Turnover MONEY)
    INSERT INTO @tblTransactions
    SELECT CustomerID
         , TransactionDate
         , Turnover = SUM(Turnover)
    FROM dbo.tblTransactions
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    GROUP BY CustomerID
           , TransactionDate
    OPTION(RECOMPILE)

    DECLARE @tblCustomers TABLE (CustomerID INT)
    INSERT INTO @tblCustomers
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID IS NULL AND dc.BrandID IS NULL
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT t.CustomerID FROM @tblTransactions t)
    OPTION(RECOMPILE)

    INSERT INTO @tblCustomers
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID = dc.BrandID
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT t.CustomerID FROM @tblTransactions t)
    OPTION(RECOMPILE)

    DECLARE @tblOutput TABLE (DateKey INT, Turnover MONEY)
    INSERT INTO @tblOutput
    SELECT tz.DateKey
         , Turnover = SUM(t.Turnover)
    FROM @tblTransactions t
    JOIN @tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_1(t.TransactionDate, DEFAULT, @TimeZone) tz -- <<<<<<
    ) tz
    GROUP BY tz.DateKey
    OPTION(RECOMPILE)

    SELECT DateKey = CAST(DATEADD(HH, DateKey, '19000101') AS TIME)
         , Turnover
    FROM @tblOutput
    ORDER BY DateKey

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_4 @Date = @Date
GO

/*
    Table '#B82A040D'. Scan count 0, logical reads 60, physical reads 0, ...
    Table 'tblSites'. Scan count 1, logical reads 2, physical reads 0, ...
    Table 'Worktable'. Scan count 1, logical reads 123, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

    SQL Server parse and compile time: 
       CPU time = 1 ms, elapsed time = 1 ms.
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblTransactions'. Scan count 1, logical reads 9443, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1171 ms,  elapsed time = 1164 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 4 ms.
    Table '#BA124C7F'. Scan count 0, logical reads 356423, physical reads 0, ...
    Table 'Workfile'. Scan count 36, logical reads 5600, physical reads 859, page server reads 0, read-ahead reads 6589, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblCustomers'. Scan count 0, logical reads 1225312, physical reads 0, ...
    Table '#B91E2846'. Scan count 1, logical reads 5736, physical reads 0, ...
    Table '#B82A040D'. Scan count 1, logical reads 1, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 2532 ms,  elapsed time = 3244 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 5 ms.
    Table '#BA124C7F'. Scan count 0, logical reads 100, physical reads 0, ...
    Table 'Workfile'. Scan count 36, logical reads 5320, physical reads 859, page server reads 0, read-ahead reads 6589, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblCustomers'. Scan count 0, logical reads 1225312, physical reads 0, ...
    Table '#B91E2846'. Scan count 1, logical reads 5736, physical reads 0, ...
    Table '#B82A040D'. Scan count 1, logical reads 1, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1984 ms,  elapsed time = 2478 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 2 ms.
    Table '#BB0670B8'. Scan count 0, logical reads 12, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 17, logical reads 4616, physical reads 412, page server reads 0, read-ahead reads 4204, ...
    Table '#BA124C7F'. Scan count 1, logical reads 573, physical reads 0, ...
    Table '#B91E2846'. Scan count 1, logical reads 5736, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 17531 ms,  elapsed time = 18578 ms.

    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#BB0670B8'. Scan count 1, logical reads 1, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

     SQL Server Execution Times:
       CPU time = 23218 ms,  elapsed time = 25483 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_5
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
    INSERT INTO @tblSites
    SELECT SiteID
         , BrandID
    FROM dbo.tblSites
    WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
        AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    DROP TABLE IF EXISTS #tblTransactions
    CREATE TABLE #tblTransactions (CustomerID INT, TransactionDate DATETIME, Turnover MONEY) -- <<<<<<
    INSERT INTO #tblTransactions
    SELECT CustomerID
         , TransactionDate
         , Turnover = SUM(Turnover)
    FROM dbo.tblTransactions
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    GROUP BY CustomerID
           , TransactionDate
    OPTION(RECOMPILE)

    DROP TABLE IF EXISTS #tblCustomers
    CREATE TABLE #tblCustomers (CustomerID INT) -- <<<<<<
    INSERT INTO #tblCustomers
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID IS NULL AND dc.BrandID IS NULL
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT t.CustomerID FROM #tblTransactions t)
    OPTION(RECOMPILE)

    INSERT INTO #tblCustomers 
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID = dc.BrandID
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT t.CustomerID FROM #tblTransactions t)
    OPTION(RECOMPILE)

    DECLARE @tblOutput TABLE (DateKey INT, Turnover MONEY)
    INSERT INTO @tblOutput
    SELECT tz.DateKey
         , Turnover = SUM(t.Turnover)
    FROM #tblTransactions t
    JOIN #tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_1(t.TransactionDate, DEFAULT, @TimeZone) tz
    ) tz
    GROUP BY tz.DateKey
    OPTION(RECOMPILE)

    SELECT DateKey = CAST(DATEADD(HH, DateKey, '19000101') AS TIME)
         , Turnover
    FROM @tblOutput
    ORDER BY DateKey

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_5 @Date = @Date
GO

/*
    Table '#A76C479D'. Scan count 0, logical reads 60, physical reads 0, ...
    Table 'tblSites'. Scan count 1, logical reads 2, physical reads 0, ...
    Table 'Worktable'. Scan count 1, logical reads 123, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 2 ms.
    Table 'tblTransactions'. Scan count 5, logical reads 19252, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1969 ms,  elapsed time = 636 ms.

    SQL Server parse and compile time: 
       CPU time = 130 ms, elapsed time = 130 ms.
    Table '#A76C479D'. Scan count 1, logical reads 1, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________000000000007'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'tblCustomers'. Scan count 5, logical reads 119482, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 11282 ms,  elapsed time = 2991 ms.

    SQL Server parse and compile time: 
       CPU time = 8 ms, elapsed time = 8 ms.
    Table '#A76C479D'. Scan count 1, logical reads 1, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________000000000007'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'tblCustomers'. Scan count 5, logical reads 119482, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 3936 ms,  elapsed time = 1130 ms.

    SQL Server parse and compile time: 
       CPU time = 62 ms, elapsed time = 62 ms.
    Table '#A8606BD6'. Scan count 0, logical reads 12, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________000000000007'. Scan count 1, logical reads 5736, physical reads 0, ...
    Table '#tblCustomers_______________________________________________________________________________________________________000000000008'. Scan count 1, logical reads 575, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 15172 ms,  elapsed time = 16218 ms.

    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#A8606BD6'. Scan count 1, logical reads 1, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

     SQL Server Execution Times:
       CPU time = 33079 ms,  elapsed time = 21340 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_6
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
    INSERT INTO @tblSites
    SELECT SiteID
         , BrandID
    FROM dbo.tblSites
    WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
        AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    DROP TABLE IF EXISTS #tblTransactions
    CREATE TABLE #tblTransactions (CustomerID INT, TransactionDate DATETIME, Turnover MONEY)
    INSERT INTO #tblTransactions
    SELECT CustomerID
         , TransactionDate
         , Turnover = SUM(Turnover)
    FROM dbo.tblTransactions
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    GROUP BY CustomerID
           , TransactionDate
    OPTION(RECOMPILE)

    DROP TABLE IF EXISTS #tblCustomers
    CREATE TABLE #tblCustomers (CustomerID INT)
    INSERT INTO #tblCustomers
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID IS NULL AND dc.BrandID IS NULL
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT t.CustomerID FROM #tblTransactions t)
    OPTION(RECOMPILE)

    INSERT INTO #tblCustomers 
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID = dc.BrandID
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT t.CustomerID FROM #tblTransactions t)
    OPTION(RECOMPILE)

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME) -- <<<<<<
         , Turnover = SUM(t.Turnover)
    FROM #tblTransactions t
    JOIN #tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_1(t.TransactionDate, DEFAULT, @TimeZone) tz
    ) tz
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE)

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_6 @Date = @Date
GO

/*
    Table '#AD2520F3'. Scan count 0, logical reads 60, physical reads 0, ...
    Table 'tblSites'. Scan count 1, logical reads 2, physical reads 0, ...
    Table 'Worktable'. Scan count 1, logical reads 123, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 2 ms.
    Table 'tblTransactions'. Scan count 5, logical reads 19252, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1688 ms,  elapsed time = 578 ms.

    SQL Server parse and compile time: 
       CPU time = 126 ms, elapsed time = 126 ms.
    Table '#AD2520F3'. Scan count 1, logical reads 1, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________000000000009'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'tblCustomers'. Scan count 5, logical reads 119482, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 10250 ms,  elapsed time = 2745 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 8 ms.
    Table '#AD2520F3'. Scan count 1, logical reads 1, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________000000000009'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'tblCustomers'. Scan count 5, logical reads 119482, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 3314 ms,  elapsed time = 857 ms.

    SQL Server parse and compile time: 
       CPU time = 176 ms, elapsed time = 176 ms.
    Table '#tblCustomers_______________________________________________________________________________________________________00000000000A'. Scan count 5, logical reads 574, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________000000000009'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 19297 ms,  elapsed time = 5209 ms.

     SQL Server Execution Times:
       CPU time = 35280 ms,  elapsed time = 9683 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER FUNCTION dbo.FromTimeZoneToAnotherTimeZone_2
(
      @SourceDate   DATETIME
    , @TimeZoneFrom NVARCHAR(128) = N'UTC'
    , @TimeZoneTo   NVARCHAR(128) = N'UTC'
)
RETURNS TABLE
AS
    RETURN (
        SELECT
            CASE
                WHEN @TimeZoneFrom = @TimeZoneTo THEN @SourceDate
                WHEN @TimeZoneFrom = N'UTC'      THEN CAST(CAST(@SourceDate AS DATETIMEOFFSET) AT TIME ZONE @TimeZoneTo AS DATETIME)
                ELSE CAST(@SourceDate AT TIME ZONE @TimeZoneFrom AT TIME ZONE @TimeZoneTo AS DATETIME)
            END AS ConvertedDate
    )
GO

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_7
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
    INSERT INTO @tblSites
    SELECT SiteID
         , BrandID
    FROM dbo.tblSites
    WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
        AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    DROP TABLE IF EXISTS #tblTransactions
    CREATE TABLE #tblTransactions (CustomerID INT, TransactionDate DATETIME, Turnover MONEY)
    INSERT INTO #tblTransactions
    SELECT CustomerID
         , TransactionDate
         , Turnover = SUM(Turnover)
    FROM dbo.tblTransactions
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    GROUP BY CustomerID
           , TransactionDate
    OPTION(RECOMPILE)

    DROP TABLE IF EXISTS #tblCustomers
    CREATE TABLE #tblCustomers (CustomerID INT)
    INSERT INTO #tblCustomers
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID IS NULL AND dc.BrandID IS NULL
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT t.CustomerID FROM #tblTransactions t)
    OPTION(RECOMPILE)

    INSERT INTO #tblCustomers 
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND s.BrandID = dc.BrandID
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT t.CustomerID FROM #tblTransactions t)
    OPTION(RECOMPILE)

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME)
         , Turnover = SUM(t.Turnover)
    FROM #tblTransactions t
    JOIN #tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_2(t.TransactionDate, DEFAULT, @TimeZone) tz -- <<<<<<
    ) tz
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE)

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_7 @Date = @Date
GO

/*
    Table '#B1E9D610'. Scan count 0, logical reads 60, physical reads 0, ...
    Table 'tblSites'. Scan count 1, logical reads 2, physical reads 0, ...
    Table 'Worktable'. Scan count 1, logical reads 122, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 2 ms.
    Table 'tblTransactions'. Scan count 5, logical reads 19252, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1703 ms,  elapsed time = 579 ms.

    SQL Server parse and compile time: 
       CPU time = 121 ms, elapsed time = 121 ms.
    Table '#B1E9D610'. Scan count 1, logical reads 1, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________00000000000B'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'tblCustomers'. Scan count 5, logical reads 119482, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 10499 ms,  elapsed time = 2750 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 8 ms.
    Table '#B1E9D610'. Scan count 1, logical reads 1, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________00000000000B'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'tblCustomers'. Scan count 5, logical reads 119482, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 3439 ms,  elapsed time = 903 ms.

    SQL Server parse and compile time: 
       CPU time = 169 ms, elapsed time = 169 ms.
    Table '#tblCustomers_______________________________________________________________________________________________________00000000000C'. Scan count 5, logical reads 575, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________00000000000B'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1187 ms,  elapsed time = 306 ms.

     SQL Server Execution Times:
       CPU time = 17436 ms,  elapsed time = 4848 ms.
*/


/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_8
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
    INSERT INTO @tblSites
    SELECT SiteID
         , BrandID
    FROM dbo.tblSites
    WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
        AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    DROP TABLE IF EXISTS #tblTransactions
    CREATE TABLE #tblTransactions (CustomerID INT, TransactionDate DATETIME, Turnover MONEY)
    INSERT INTO #tblTransactions
    SELECT CustomerID
         , TransactionDate
         , Turnover = SUM(Turnover)
    FROM dbo.tblTransactions
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    GROUP BY CustomerID
           , TransactionDate
    OPTION(RECOMPILE)

    DROP TABLE IF EXISTS #tblCustomers
    CREATE TABLE #tblCustomers (CustomerID INT) 
    INSERT INTO #tblCustomers
    SELECT dc.CustomerID
    FROM dbo.tblCustomers dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND ISNULL(s.BrandID, -1) = ISNULL(dc.BrandID, -1)  -- <<<<<<
    WHERE (@IncludeTestCustomers = 1 OR dc.IsException = 0)
        AND dc.CustomerID IN (SELECT DISTINCT t.CustomerID FROM #tblTransactions t)
    OPTION(RECOMPILE)

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME)
         , Turnover = SUM(t.Turnover)
    FROM #tblTransactions t
    JOIN #tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_2(t.TransactionDate, DEFAULT, @TimeZone) tz
    ) tz
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE)

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_8 @Date = @Date
GO

/*
    Table '#B735EA36'. Scan count 0, logical reads 60, physical reads 0, ...
    Table 'tblSites'. Scan count 1, logical reads 2, physical reads 0, ...
    Table 'Worktable'. Scan count 1, logical reads 122, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 2 ms.
    Table 'tblTransactions'. Scan count 5, logical reads 19252, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 3063 ms,  elapsed time = 779 ms.

    SQL Server parse and compile time: 
       CPU time = 157 ms, elapsed time = 157 ms.
    Table '#tblCustomers_______________________________________________________________________________________________________000000000018'. Scan count 5, logical reads 574, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________000000000017'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1095 ms,  elapsed time = 287 ms.

     SQL Server Execution Times:
       CPU time = 6186 ms,  elapsed time = 1773 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_9
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
    INSERT INTO @tblSites
    SELECT SiteID
         , BrandID
    FROM dbo.tblSites
    WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
        AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    DROP TABLE IF EXISTS #tblTransactions
    CREATE TABLE #tblTransactions (CustomerID INT, TransactionDate DATETIME, Turnover MONEY)
    INSERT INTO #tblTransactions
    SELECT CustomerID
         , TransactionDate
         , Turnover = SUM(Turnover)
    FROM dbo.tblTransactions
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    GROUP BY CustomerID
           , TransactionDate
    OPTION(RECOMPILE)

    DROP TABLE IF EXISTS #tblCustomers
    CREATE TABLE #tblCustomers (CustomerID INT) 
    INSERT INTO #tblCustomers
    SELECT t.CustomerID
    FROM (
        SELECT DISTINCT t.CustomerID
        FROM #tblTransactions t
    ) t
    CROSS APPLY ( -- <<<<<<
        SELECT TOP(1) *
        FROM dbo.tblCustomers dc
        WHERE dc.CustomerID = t.CustomerID
            AND (@IncludeTestCustomers = 1 OR dc.IsException = 0)
    ) dc
    JOIN @tblSites s ON s.SiteID = dc.SiteID AND ISNULL(s.BrandID, -1) = ISNULL(dc.BrandID, -1)
    OPTION(RECOMPILE)

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME)
         , Turnover = SUM(t.Turnover)
    FROM #tblTransactions t
    JOIN #tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_2(t.TransactionDate, DEFAULT, @TimeZone) tz
    ) tz
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE)

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_9 @Date = @Date
GO

/*
    Table '#A0BF5470'. Scan count 0, logical reads 60, physical reads 0, ...
    Table 'tblSites'. Scan count 1, logical reads 2, physical reads 0, ...
    Table 'Worktable'. Scan count 1, logical reads 122, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

    SQL Server parse and compile time: 
       CPU time = 3 ms, elapsed time = 3 ms.
    Table 'tblTransactions'. Scan count 5, logical reads 19252, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1549 ms,  elapsed time = 551 ms.

    SQL Server parse and compile time: 
       CPU time = 96 ms, elapsed time = 96 ms.
    Table '#A0BF5470'. Scan count 1, logical reads 1, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________00000000001B'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblCustomers'. Scan count 0, logical reads 1225337, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1875 ms,  elapsed time = 477 ms.

    SQL Server parse and compile time: 
       CPU time = 56 ms, elapsed time = 56 ms.
    Table '#tblCustomers_______________________________________________________________________________________________________00000000001C'. Scan count 5, logical reads 574, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________00000000001B'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1201 ms,  elapsed time = 302 ms.

     SQL Server Execution Times:
       CPU time = 5016 ms,  elapsed time = 1490 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_10
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DROP TABLE IF EXISTS #tblTransactions
    CREATE TABLE #tblTransactions (CustomerID INT, TransactionDate DATETIME, Turnover MONEY)
    INSERT INTO #tblTransactions
    SELECT CustomerID
         , TransactionDate
         , Turnover = SUM(Turnover)
    FROM dbo.tblTransactions
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    GROUP BY CustomerID
           , TransactionDate
    OPTION(RECOMPILE)

    DROP TABLE IF EXISTS #tblCustomers
    CREATE TABLE #tblCustomers (CustomerID INT)

    DECLARE @IsFilters BIT = IIF(NULLIF(@Brands, '') IS NOT NULL OR NULLIF(@Sites, '') IS NOT NULL, 1, 0)

    IF @IsFilters = 1 BEGIN -- <<<<<<

        DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
        INSERT INTO @tblSites
        SELECT SiteID
             , BrandID
        FROM dbo.tblSites
        WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
            AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    END

    INSERT INTO #tblCustomers
    SELECT t.CustomerID
    FROM (
        SELECT DISTINCT t.CustomerID
        FROM #tblTransactions t
    ) t
    CROSS APPLY (
        SELECT TOP(1) *
        FROM dbo.tblCustomers dc
        WHERE dc.CustomerID = t.CustomerID
            AND (@IncludeTestCustomers = 1 OR dc.IsException = 0)
    ) dc
    WHERE @IsFilters = 0 -- <<<<<<
        OR EXISTS(
                SELECT *
                FROM @tblSites s
                WHERE s.SiteID = dc.SiteID AND ISNULL(s.BrandID, -1) = ISNULL(dc.BrandID, -1)
            )
    OPTION(RECOMPILE)

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME)
         , Turnover = SUM(t.Turnover)
    FROM #tblTransactions t
    JOIN #tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_2(t.TransactionDate, DEFAULT, @TimeZone) tz
    ) tz
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE)

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_10 @Date = @Date
GO

/*
    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 2 ms.
    Table 'tblTransactions'. Scan count 5, logical reads 19252, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1657 ms,  elapsed time = 552 ms.

    SQL Server parse and compile time: 
       CPU time = 88 ms, elapsed time = 88 ms.
    Table '#tblTransactions____________________________________________________________________________________________________00000000001F'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'tblCustomers'. Scan count 0, logical reads 1225337, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1654 ms,  elapsed time = 433 ms.

    SQL Server parse and compile time: 
       CPU time = 50 ms, elapsed time = 50 ms.
    Table '#tblCustomers_______________________________________________________________________________________________________000000000020'. Scan count 5, logical reads 574, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________00000000001F'. Scan count 5, logical reads 5736, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1096 ms,  elapsed time = 286 ms.

     SQL Server Execution Times:
       CPU time = 4847 ms,  elapsed time = 1415 ms.
*/

/* ---------------------------------------------- */

DROP TABLE IF EXISTS dbo.tblTransactions_CCL
GO

CREATE TABLE dbo.tblTransactions_CCL (
      TransactionDate   DATETIME NOT NULL
    , TransactionID     BIGINT   NOT NULL
    , TransactionTypeID TINYINT  NOT NULL
    , CustomerID        INT      NOT NULL
    , Turnover          MONEY    NOT NULL
)
GO

CREATE CLUSTERED COLUMNSTORE INDEX [CCL:Transactions] ON dbo.tblTransactions_CCL
GO

INSERT INTO dbo.tblTransactions_CCL WITH(TABLOCK)
SELECT *
FROM dbo.tblTransactions
GO

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_11
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DROP TABLE IF EXISTS #tblTransactions
    CREATE TABLE #tblTransactions (CustomerID INT PRIMARY KEY)
    INSERT INTO #tblTransactions
    SELECT DISTINCT CustomerID
    FROM dbo.tblTransactions_CCL -- <<<<<<
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    OPTION(RECOMPILE)

    DROP TABLE IF EXISTS #tblCustomers
    CREATE TABLE #tblCustomers (CustomerID INT)

    DECLARE @IsFilters BIT = IIF(NULLIF(@Brands, '') IS NOT NULL OR NULLIF(@Sites, '') IS NOT NULL, 1, 0)

    IF @IsFilters = 1 BEGIN

        DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
        INSERT INTO @tblSites
        SELECT SiteID
             , BrandID
        FROM dbo.tblSites
        WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
            AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    END

    INSERT INTO #tblCustomers
    SELECT t.CustomerID
    FROM #tblTransactions t
    CROSS APPLY (
        SELECT TOP(1) *
        FROM dbo.tblCustomers dc
        WHERE dc.CustomerID = t.CustomerID
            AND (@IncludeTestCustomers = 1 OR dc.IsException = 0)
    ) dc
    WHERE @IsFilters = 0
        OR EXISTS(
                SELECT *
                FROM @tblSites s
                WHERE s.SiteID = dc.SiteID AND ISNULL(s.BrandID, -1) = ISNULL(dc.BrandID, -1)
            )
    OPTION(RECOMPILE)

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME)
         , Turnover = SUM(t.Turnover)
    FROM dbo.tblTransactions_CCL t -- <<<<<<
    JOIN #tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_2(t.TransactionDate, DEFAULT, @TimeZone) tz
    ) tz
    WHERE t.TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND t.TransactionTypeID IN (1, 2)
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE)

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_11 @Date = @Date
GO

/*
    Table 'tblTransactions_CCL'. Scan count 6, logical reads 132, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 18311, ...
    Table 'tblTransactions_CCL'. Segment reads 4, segment skipped 0.
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 389 ms,  elapsed time = 173 ms.

    SQL Server parse and compile time:
       CPU time = 0 ms, elapsed time = 1 ms.
    Table 'tblCustomers'. Scan count 0, logical reads 1225338, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________000000000022'. Scan count 5, logical reads 647, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 986 ms,  elapsed time = 278 ms.

    SQL Server parse and compile time: 
       CPU time = 57 ms, elapsed time = 57 ms.
    Table 'tblTransactions_CCL'. Scan count 3, logical reads 132, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 1996, ...
    Table 'tblTransactions_CCL'. Segment reads 4, segment skipped 0.
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#tblCustomers_______________________________________________________________________________________________________000000000023'. Scan count 1, logical reads 574, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 125 ms,  elapsed time = 126 ms.

     SQL Server Execution Times:
       CPU time = 1700 ms,  elapsed time = 643 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER FUNCTION dbo.FromTimeZoneToAnotherTimeZone_3
(
      @SourceDate   DATETIME
    , @TimeZoneFrom VARCHAR(128) = '+00:00'
    , @TimeZoneTo   VARCHAR(128) = '+00:00'
)
RETURNS TABLE
AS
    RETURN (
        SELECT
            CASE
                WHEN @TimeZoneFrom = @TimeZoneTo THEN @SourceDate
                WHEN @TimeZoneFrom = N'+00:00'   THEN CAST(SWITCHOFFSET(@SourceDate, @TimeZoneTo) AS DATETIME)
                ELSE CAST(SWITCHOFFSET(CAST(SWITCHOFFSET(@SourceDate, @TimeZoneFrom) AS DATETIME), @TimeZoneTo) AS DATETIME)
            END AS ConvertedDate
    )
GO

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_12
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DROP TABLE IF EXISTS #tblTransactions
    CREATE TABLE #tblTransactions (CustomerID INT PRIMARY KEY)
    INSERT INTO #tblTransactions
    SELECT DISTINCT CustomerID
    FROM dbo.tblTransactions_CCL
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    OPTION(RECOMPILE)

    DROP TABLE IF EXISTS #tblCustomers
    CREATE TABLE #tblCustomers (CustomerID INT)

    DECLARE @IsFilters BIT = IIF(NULLIF(@Brands, '') IS NOT NULL OR NULLIF(@Sites, '') IS NOT NULL, 1, 0)

    IF @IsFilters = 1 BEGIN

        DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
        INSERT INTO @tblSites
        SELECT SiteID
             , BrandID
        FROM dbo.tblSites
        WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
            AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    END

    INSERT INTO #tblCustomers
    SELECT t.CustomerID
    FROM #tblTransactions t
    CROSS APPLY (
        SELECT TOP(1) *
        FROM dbo.tblCustomers dc
        WHERE dc.CustomerID = t.CustomerID
            AND (@IncludeTestCustomers = 1 OR dc.IsException = 0)
    ) dc
    WHERE @IsFilters = 0
        OR EXISTS(
                SELECT *
                FROM @tblSites s
                WHERE s.SiteID = dc.SiteID AND ISNULL(s.BrandID, -1) = ISNULL(dc.BrandID, -1)
            )
    OPTION(RECOMPILE)

    DECLARE @TZ SYSNAME
    SELECT TOP(1) @TZ = current_utc_offset -- <<<<<<
    FROM sys.time_zone_info
    WHERE name = @TimeZone

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME)
         , Turnover = SUM(t.Turnover)
    FROM (
        SELECT CustomerID
             , TransactionDate = DATEADD(HH, DATEDIFF(HH, 0, TransactionDate), 0)
             , Turnover = SUM(Turnover)
        FROM dbo.tblTransactions_CCL
        WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
            AND TransactionTypeID IN (1, 2)
        GROUP BY CustomerID
               , DATEADD(HH, DATEDIFF(HH, 0, TransactionDate), 0)
    ) t
    JOIN #tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_3(t.TransactionDate, DEFAULT, @TZ) tz -- <<<<<<
    ) tz
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE)

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_12 @Date = @Date
GO

/*
    Table 'tblTransactions_CCL'. Scan count 6, logical reads 132, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 18315, ...
    Table 'tblTransactions_CCL'. Segment reads 4, segment skipped 0.
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 547 ms,  elapsed time = 197 ms.

    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 1 ms.
    Table 'tblCustomers'. Scan count 0, logical reads 1225339, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________00000000002A'. Scan count 5, logical reads 647, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1015 ms,  elapsed time = 259 ms.

    SQL Server parse and compile time: 
       CPU time = 53 ms, elapsed time = 53 ms.
    Table 'tblTransactions_CCL'. Scan count 6, logical reads 132, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 18419, ...
    Table 'tblTransactions_CCL'. Segment reads 4, segment skipped 0.
    Table '#tblCustomers_______________________________________________________________________________________________________00000000002B'. Scan count 5, logical reads 574, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 312 ms,  elapsed time = 68 ms.

     SQL Server Execution Times:
       CPU time = 2032 ms,  elapsed time = 586 ms.
*/

/*
    SET STATISTICS TIME, IO OFF

    SELECT MIN(create_date)
    FROM (
        SELECT create_date = dbo.FromTimeZoneToAnotherTimeZone(create_date, 'UTC', 'North Korea Standard Time')
        FROM sys.all_objects
    ) t

    SELECT MIN(create_date)
    FROM (
        SELECT create_date = (SELECT * FROM dbo.FromTimeZoneToAnotherTimeZone_1(create_date, 'UTC', 'North Korea Standard Time'))
        FROM sys.all_objects
    ) t

    SELECT MIN(create_date)
    FROM (
        SELECT create_date = (SELECT * FROM dbo.FromTimeZoneToAnotherTimeZone_2(create_date, 'UTC', 'North Korea Standard Time'))
        FROM sys.all_objects
    ) t

    SELECT MIN(create_date)
    FROM (
        SELECT create_date = (SELECT * FROM dbo.FromTimeZoneToAnotherTimeZone_3(create_date, '+00:00', '+09:00'))
        FROM sys.all_objects
    ) t
*/

/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_13
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DROP TABLE IF EXISTS #tblTransactions
    CREATE TABLE #tblTransactions (CustomerID INT PRIMARY KEY)
    INSERT INTO #tblTransactions
    SELECT DISTINCT CustomerID
    FROM dbo.tblTransactions_CCL
    WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        AND TransactionTypeID IN (1, 2)
    OPTION(RECOMPILE, MAXDOP 2) -- <<<<<<

    DROP TABLE IF EXISTS #tblCustomers
    CREATE TABLE #tblCustomers (CustomerID INT)

    DECLARE @IsFilters BIT = IIF(NULLIF(@Brands, '') IS NOT NULL OR NULLIF(@Sites, '') IS NOT NULL, 1, 0)

    IF @IsFilters = 1 BEGIN

        DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
        INSERT INTO @tblSites
        SELECT SiteID
             , BrandID
        FROM dbo.tblSites
        WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
            AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    END

    INSERT INTO #tblCustomers
    SELECT t.CustomerID
    FROM #tblTransactions t
    CROSS APPLY (
        SELECT TOP(1) *
        FROM dbo.tblCustomers dc
        WHERE dc.CustomerID = t.CustomerID
            AND (@IncludeTestCustomers = 1 OR dc.IsException = 0)
    ) dc
    WHERE @IsFilters = 0
        OR EXISTS(
                SELECT *
                FROM @tblSites s
                WHERE s.SiteID = dc.SiteID AND ISNULL(s.BrandID, -1) = ISNULL(dc.BrandID, -1)
            )
    OPTION(RECOMPILE, MAXDOP 2) -- <<<<<<

    DECLARE @TZ SYSNAME
    SELECT TOP(1) @TZ = current_utc_offset
    FROM sys.time_zone_info
    WHERE name = @TimeZone

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME)
         , Turnover = SUM(t.Turnover)
    FROM (
        SELECT CustomerID
             , TransactionDate = DATEADD(HH, DATEDIFF(HH, 0, TransactionDate), 0)
             , Turnover = SUM(Turnover)
        FROM dbo.tblTransactions_CCL
        WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
            AND TransactionTypeID IN (1, 2)
        GROUP BY CustomerID
               , DATEADD(HH, DATEDIFF(HH, 0, TransactionDate), 0)
    ) t
    JOIN #tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_3(t.TransactionDate, DEFAULT, @TZ) tz
    ) tz
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE, MAXDOP 1) -- <<<<<<

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_13 @Date = @Date
GO

/*
    Table 'tblTransactions_CCL'. Scan count 4, logical reads 132, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 1980, ...
    Table 'tblTransactions_CCL'. Segment reads 4, segment skipped 0.
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...

     SQL Server Execution Times:
       CPU time = 360 ms,  elapsed time = 209 ms.

     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.

     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.
    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 1 ms.
    Table 'tblCustomers'. Scan count 0, logical reads 1225320, physical reads 0, ...
    Table '#tblTransactions____________________________________________________________________________________________________000000000030'. Scan count 3, logical reads 647, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...

     SQL Server Execution Times:
       CPU time = 781 ms,  elapsed time = 355 ms.

     SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 0 ms.
    SQL Server parse and compile time: 
       CPU time = 51 ms, elapsed time = 51 ms.
    Table 'tblTransactions_CCL'. Scan count 3, logical reads 132, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 1996, ...
    Table 'tblTransactions_CCL'. Segment reads 4, segment skipped 0.
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#tblCustomers_______________________________________________________________________________________________________000000000031'. Scan count 1, logical reads 574, physical reads 0, ...

     SQL Server Execution Times:
       CPU time = 157 ms,  elapsed time = 164 ms.

     SQL Server Execution Times:
       CPU time = 1406 ms,  elapsed time = 786 ms.
*/

/* ---------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_14
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @IsFilters BIT = IIF(NULLIF(@Brands, '') IS NOT NULL OR NULLIF(@Sites, '') IS NOT NULL, 1, 0)

    IF @IsFilters = 1 BEGIN

        DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
        INSERT INTO @tblSites
        SELECT SiteID
             , BrandID
        FROM dbo.tblSites
        WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
            AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    END

    DROP TABLE IF EXISTS #tblCustomers
    CREATE TABLE #tblCustomers (CustomerID INT)

    INSERT INTO #tblCustomers
    SELECT t.CustomerID
    FROM (
        SELECT DISTINCT CustomerID
        FROM dbo.tblTransactions_CCL -- <<<<<<
        WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
            AND TransactionTypeID IN (1, 2)
    ) t
    CROSS APPLY (
        SELECT TOP(1) *
        FROM dbo.tblCustomers dc
        WHERE dc.CustomerID = t.CustomerID
            AND (@IncludeTestCustomers = 1 OR dc.IsException = 0)
    ) dc
    WHERE @IsFilters = 0
        OR EXISTS(
                SELECT *
                FROM @tblSites s
                WHERE s.SiteID = dc.SiteID AND ISNULL(s.BrandID, -1) = ISNULL(dc.BrandID, -1)
            )
    OPTION(RECOMPILE, MAXDOP 2)

    DECLARE @TZ SYSNAME
    SELECT TOP(1) @TZ = current_utc_offset
    FROM sys.time_zone_info
    WHERE name = @TimeZone

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME)
         , Turnover = SUM(t.Turnover)
    FROM (
        SELECT CustomerID
             , TransactionDate = DATEADD(HH, DATEDIFF(HH, 0, TransactionDate), 0)
             , Turnover = SUM(Turnover)
        FROM dbo.tblTransactions_CCL
        WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
            AND TransactionTypeID IN (1, 2)
        GROUP BY CustomerID
               , DATEADD(HH, DATEDIFF(HH, 0, TransactionDate), 0)
    ) t
    JOIN #tblCustomers dc ON dc.CustomerID = t.CustomerID
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_3(t.TransactionDate, DEFAULT, @TZ) tz
    ) tz
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE, MAXDOP 1)

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_14 @Date = @Date
GO

/*
    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 2 ms.
    Table 'tblTransactions_CCL'. Scan count 4, logical reads 132, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 1980, ...
    Table 'tblTransactions_CCL'. Segment reads 4, segment skipped 0.
    Table 'tblCustomers'. Scan count 0, logical reads 1225321, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 1077 ms,  elapsed time = 527 ms.

    SQL Server parse and compile time: 
       CPU time = 58 ms, elapsed time = 58 ms.
    Table 'tblTransactions_CCL'. Scan count 3, logical reads 132, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 1996, ...
    Table 'tblTransactions_CCL'. Segment reads 4, segment skipped 0.
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
    Table '#tblCustomers_______________________________________________________________________________________________________000000000035'. Scan count 1, logical reads 574, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 172 ms,  elapsed time = 164 ms.

     SQL Server Execution Times:
       CPU time = 1407 ms,  elapsed time = 755 ms.
*/

/* ---------------------------------------------- */

DROP VIEW IF EXISTS dbo.vTransactions
GO

CREATE VIEW dbo.vTransactions
WITH SCHEMABINDING
AS
    SELECT CustomerID
         , TransactionDate = DATEADD(HH, DATEDIFF(HH, 0, TransactionDate), 0)
         , Turnover = SUM(Turnover)
         , Cnt = COUNT_BIG(*)
    FROM dbo.tblTransactions
    WHERE TransactionTypeID IN (1, 2)
    GROUP BY CustomerID
           , DATEADD(HH, DATEDIFF(HH, 0, TransactionDate), 0)
GO

CREATE UNIQUE CLUSTERED INDEX PK ON dbo.vTransactions (TransactionDate, CustomerID)
GO

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_15
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @IsFilters BIT = IIF(NULLIF(@Brands, '') IS NOT NULL OR NULLIF(@Sites, '') IS NOT NULL, 1, 0)

    IF @IsFilters = 1 BEGIN

        DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
        INSERT INTO @tblSites
        SELECT SiteID
             , BrandID
        FROM dbo.tblSites
        WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
            AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    END

    DECLARE @TZ SYSNAME
    SELECT TOP(1) @TZ = current_utc_offset
    FROM sys.time_zone_info
    WHERE name = @TimeZone

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME)
         , Turnover = SUM(t.Turnover)
    FROM (
        SELECT CustomerID
             , TransactionDate
             , Turnover = SUM(Turnover)
        FROM dbo.vTransactions WITH(NOEXPAND) -- <<<<<<
        WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
        GROUP BY CustomerID
               , TransactionDate
    ) t
    CROSS APPLY (
        SELECT TOP(1) *
        FROM dbo.tblCustomers dc
        WHERE dc.CustomerID = t.CustomerID
            AND (@IncludeTestCustomers = 1 OR dc.IsException = 0)
    ) dc
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_3(t.TransactionDate, DEFAULT, @TZ) tz
    ) tz
    WHERE @IsFilters = 0
        OR EXISTS(
                SELECT *
                FROM @tblSites s
                WHERE s.SiteID = dc.SiteID AND ISNULL(s.BrandID, -1) = ISNULL(dc.BrandID, -1)
            )
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE, MAXDOP 2)

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_15 @Date = @Date
GO

/*
    SQL Server parse and compile time: 
       CPU time = 3 ms, elapsed time = 3 ms.
    Table 'vTransactions'. Scan count 1, logical reads 1998, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 1233, ...
    Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, ...
    Table 'tblCustomers'. Scan count 0, logical reads 1231563, physical reads 0, ...
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...

     SQL Server Execution Times:
       CPU time = 938 ms,  elapsed time = 494 ms.

     SQL Server Execution Times:
       CPU time = 954 ms,  elapsed time = 498 ms.
*/

/* ---------------------------------------------- */

DROP TABLE IF EXISTS dbo.tblTransactions_CCL_v2
GO

CREATE TABLE dbo.tblTransactions_CCL_v2 (
      TransactionDate      DATETIME NOT NULL
    , TransactionID        BIGINT   NOT NULL
    , TransactionTypeID    TINYINT  NOT NULL
    , CustomerID           INT      NOT NULL
    , Turnover             MONEY    NOT NULL
    , SiteID               INT      NOT NULL
    , BrandID              INT      NULL
    , IsException          BIT      NOT NULL
    , TransactionDateCutHH DATETIME NOT NULL
)
GO

CREATE CLUSTERED COLUMNSTORE INDEX [CCL:Transactions_v2] ON dbo.tblTransactions_CCL_v2
GO

INSERT INTO dbo.tblTransactions_CCL_v2 WITH(TABLOCK)
SELECT t.TransactionDate
     , t.TransactionID
     , t.TransactionTypeID
     , c.CustomerID
     , t.Turnover
     , c.SiteID
     , c.BrandID
     , c.IsException
     , TransactionDateCutHH = DATEADD(HH, DATEDIFF(HH, 0, TransactionDate), 0)
FROM dbo.tblTransactions_CCL t
JOIN dbo.tblCustomers c ON c.CustomerID = t.CustomerID
GO

CREATE OR ALTER PROCEDURE dbo.spGetTurnover_16
(
      @Date                 DATE
    , @Sites                NVARCHAR(MAX) = NULL
    , @Brands               NVARCHAR(MAX) = NULL
    , @IncludeTestCustomers BIT           = 0
    , @TimeZone             NVARCHAR(MAX) = 'UTC'
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @IsFilters BIT = IIF(NULLIF(@Brands, '') IS NOT NULL OR NULLIF(@Sites, '') IS NOT NULL, 1, 0)

    IF @IsFilters = 1 BEGIN

        DECLARE @tblSites TABLE (SiteID INT NOT NULL, BrandID INT NULL)
        INSERT INTO @tblSites
        SELECT SiteID
             , BrandID
        FROM dbo.tblSites
        WHERE (NULLIF(@Brands, '') IS NULL OR BrandID IN (SELECT * FROM STRING_SPLIT(@Brands, N',')))
            AND (NULLIF(@Sites, '') IS NULL OR SiteID IN (SELECT * FROM STRING_SPLIT(@Sites, N',')))

    END

    DECLARE @TZ SYSNAME
    SELECT TOP(1) @TZ = current_utc_offset
    FROM sys.time_zone_info
    WHERE name = @TimeZone

    SELECT DateKey = CAST(DATEADD(HH, tz.DateKey, '19000101') AS TIME)
         , Turnover = SUM(t.Turnover)
    FROM (
        SELECT SiteID
             , BrandID
             , TransactionDateCutHH
             , Turnover = SUM(Turnover)
        FROM dbo.tblTransactions_CCL_v2 -- <<<<<<
        WHERE TransactionDate >= @Date AND TransactionDate < DATEADD(DAY, 1, @Date)
            AND TransactionTypeID IN (1, 2)
            AND (@IncludeTestCustomers = 1 OR IsException = 0)
        GROUP BY SiteID
               , BrandID
               , TransactionDateCutHH
    ) t
    CROSS APPLY (
        SELECT DateKey = DATEPART(HH, tz.ConvertedDate)
        FROM dbo.FromTimeZoneToAnotherTimeZone_3(t.TransactionDateCutHH, DEFAULT, @TZ) tz
    ) tz
    WHERE @IsFilters = 0
        OR EXISTS(
                SELECT *
                FROM @tblSites s
                WHERE s.SiteID = t.SiteID AND ISNULL(s.BrandID, -1) = ISNULL(t.BrandID, -1)
            )
    GROUP BY tz.DateKey
    ORDER BY tz.DateKey
    OPTION(RECOMPILE, MAXDOP 2)

END
GO

DECLARE @Date DATE = GETUTCDATE()
EXEC dbo.spGetTurnover_16 @Date = @Date
GO

/*
    SQL Server parse and compile time: 
       CPU time = 0 ms, elapsed time = 2 ms.
    Table 'tblTransactions_CCL_v2'. Scan count 1, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 210, ...
    Table 'tblTransactions_CCL_v2'. Segment reads 4, segment skipped 0.
    Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, ...
     SQL Server Execution Times:
       CPU time = 16 ms,  elapsed time = 8 ms.

     SQL Server Execution Times:
       CPU time = 16 ms,  elapsed time = 12 ms.
*/














