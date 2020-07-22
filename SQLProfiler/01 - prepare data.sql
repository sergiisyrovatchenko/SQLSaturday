USE [master]
GO

IF DB_ID('Users') IS NOT NULL BEGIN
    ALTER DATABASE Users SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE Users
END
GO

CREATE DATABASE Users
    ON PRIMARY (NAME = N'Users', FILENAME = N'X:\Users.mdf', SIZE = 2500MB, FILEGROWTH = 256MB)
        LOG ON (NAME = N'Users_log', FILENAME = N'X:\Users.ldf', SIZE = 1GB, FILEGROWTH = 256MB)
GO

ALTER DATABASE Users SET COMPATIBILITY_LEVEL = 110 -- 2012
                       , ANSI_NULLS ON
                       , ANSI_PADDING ON
                       , ANSI_WARNINGS ON
                       , ARITHABORT ON
                       , CONCAT_NULL_YIELDS_NULL ON
GO

ALTER DATABASE Users COLLATE SQL_Latin1_General_CP1_CI_AS
GO

------------------------------------------------------

SET NOCOUNT ON
GO

USE Users
GO

DROP TABLE IF EXISTS dbo.Users
GO

CREATE TABLE dbo.Users (
      UserID INT IDENTITY NOT NULL
    , EmailAddress NVARCHAR(50) NOT NULL
    , FirstName NVARCHAR(50) NOT NULL
    , LastName NVARCHAR(50) NOT NULL
    , City VARCHAR(30)
    , CreatedDate DATE NOT NULL
    , CONSTRAINT PM_Users PRIMARY KEY CLUSTERED (UserID)
)
GO

USE AdventureWorks2014
GO

DBCC TRACEON (610)

DECLARE @i TINYINT = 10

WHILE @i != 0 BEGIN

    INSERT INTO Users.dbo.Users WITH(TABLOCK) (EmailAddress, FirstName, LastName, City, CreatedDate)
    SELECT ea.EmailAddress
         , p.FirstName
         , p.LastName
         , ISNULL(a.City, 'Kiev')
         , p.ModifiedDate
    FROM Person.Person p
    JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
    LEFT JOIN (
        SELECT a.City
             , bea.BusinessEntityID
             , RowNum = ROW_NUMBER() OVER (PARTITION BY bea.BusinessEntityID ORDER BY 1/0)
        FROM Person.BusinessEntityAddress bea
        JOIN Person.[Address] a ON bea.AddressID = a.AddressID
    ) a ON p.BusinessEntityID = a.BusinessEntityID
        AND a.RowNum = 1
    CROSS JOIN [master].dbo.spt_values a2
    WHERE a2.[type] = 'p'
        AND a2.number BETWEEN 1 AND 75

    SET @i -= 1

    CHECKPOINT

END

DBCC TRACEOFF (610)
GO

USE Users
GO

INSERT INTO dbo.Users (EmailAddress, FirstName, LastName, City, CreatedDate)
VALUES (N'sergey.syrovatchenko@gmail.com', 'Sergey', 'Syrovatchenko', 'Kharkiv', '20170320')
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetUsers
GO
CREATE PROCEDURE dbo.GetUsers
(
      @Date DATE = NULL
    , @City NVARCHAR(30) = NULL
)
AS BEGIN

    SET NOCOUNT ON

    SELECT UserID
    FROM dbo.Users
    WHERE (CreatedDate = @Date AND @Date IS NOT NULL AND @City IS NULL)
        OR (City = @City AND @Date IS NULL AND @City IS NOT NULL)

END
GO

DROP PROCEDURE IF EXISTS dbo.IsUserExists
GO
CREATE PROCEDURE dbo.IsUserExists
(
      @UserID INT
)
AS BEGIN

    DECLARE @sql NVARCHAR(MAX) = '
        SELECT IIF(EXISTS(
            SELECT *
            FROM dbo.Users
            WHERE UserID = ' + CAST(@UserID AS VARCHAR(10)) + '), 1, 0)'

    EXEC(@sql)

END
GO

DROP PROCEDURE IF EXISTS dbo.GetLastUsers
GO
CREATE PROCEDURE dbo.GetLastUsers
(
    @Count INT
)
AS BEGIN

    SELECT TOP(@Count) UserID
    INTO #users
    FROM dbo.Users
    ORDER BY UserID DESC

    ALTER TABLE #users ADD PRIMARY KEY (UserID)

    SELECT City, COUNT(*)
    FROM dbo.Users
    WHERE UserID IN (SELECT u.UserID FROM #users u)
    GROUP BY City

END
GO

DROP FUNCTION IF EXISTS dbo.GetEOMonth
GO
CREATE FUNCTION dbo.GetEOMonth
(
    @Date DATE
)
RETURNS DATE
AS BEGIN
    RETURN EOMONTH(@Date)
END
GO

DROP PROCEDURE IF EXISTS dbo.GetStatisticsByCity
GO
CREATE PROCEDURE dbo.GetStatisticsByCity
(
    @City VARCHAR(30)
)
AS BEGIN

    SELECT [Month] = dbo.GetEOMonth(CreatedDate)
         , Cnt = COUNT_BIG(*)
    FROM dbo.Users
    WHERE City = @City
    GROUP BY dbo.GetEOMonth(CreatedDate)
    ORDER BY Cnt DESC
    OPTION(RECOMPILE)

END
GO

------------------------------------------------------

UPDATE STATISTICS dbo.Users WITH FULLSCAN
GO

CHECKPOINT
GO

DBCC SHRINKFILE (N'Users_log' , 256)
GO