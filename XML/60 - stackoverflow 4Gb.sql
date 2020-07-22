/*
    Stack Exchange Data Dump: https://archive.org/details/stackexchange
    December 15, 2016

    sqloverflow.com-Badges.7zip
    https://archive.org/download/stackexchange/stackoverflow.com-Badges.7z
    Size: 2.26Gb
    Rows: 20.758.501

    sqloverflow.com-Users.7zip
    https://archive.org/download/stackexchange/stackoverflow.com-Users.7z
    Size: 1.81Gb
    Rows: 6.438.658
*/

USE [master]
GO

IF DB_ID('StackOverflow') IS NOT NULL BEGIN
    ALTER DATABASE StackOverflow SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE StackOverflow
END
GO

CREATE DATABASE StackOverflow
GO

ALTER DATABASE StackOverflow
    ADD FILEGROUP InMemoryFG CONTAINS MEMORY_OPTIMIZED_DATA
GO

ALTER DATABASE StackOverflow
    ADD FILE (NAME = InMemoryFile, FILENAME = N'X:\InMemory')
    TO FILEGROUP InMemoryFG
GO

USE StackOverflow
GO

DROP TABLE IF EXISTS dbo.Badges
GO

CREATE TABLE dbo.Badges (
      Id INT NOT NULL INDEX ix NONCLUSTERED
    , UserId INT NOT NULL
    , [Name] VARCHAR(100) NOT NULL
    , [Date] DATETIME NOT NULL
    , Class INT NOT NULL
    , TagBased BIT NOT NULL
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY)
GO

------------------------------------------------------

SET STATISTICS TIME ON

EXEC sys.xp_cmdshell 'CScript "D:\PROJECT\XML\SQLXMLBulkLoad\sample3.vbs"' -- Badges

SET STATISTICS TIME OFF

/*
    SQL Server Execution Times:
        CPU time = 0 ms,  elapsed time = 349403 ms (5 min 49 sec)
*/

------------------------------------------------------

DROP TABLE IF EXISTS dbo.Users
GO

CREATE TABLE dbo.Users (
      Id INT NOT NULL INDEX ix NONCLUSTERED
    , Reputation INT NOT NULL
    , CreationDate DATETIME NOT NULL
    , DisplayName NVARCHAR(40)
    , LastAccessDate DATETIME NOT NULL
    , WebsiteUrl NVARCHAR(200)
    , [Location] NVARCHAR(100)
    , AboutMe NVARCHAR(MAX)
    , [Views] INT NOT NULL
    , UpVotes INT NOT NULL
    , DownVotes INT NOT NULL
    , Age INT
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY)
GO

------------------------------------------------------

SET STATISTICS TIME ON

EXEC sys.xp_cmdshell 'CScript "D:\PROJECT\XML\SQLXMLBulkLoad\sample4.vbs"' -- Users

SET STATISTICS TIME OFF

/*
    SQL Server Execution Times:
        CPU time = 0 ms,  elapsed time = 219970 ms (3 min 39 sec)
*/