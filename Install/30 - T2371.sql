USE [master]
GO

SET NOCOUNT ON

IF DB_ID('db') IS NOT NULL BEGIN
    ALTER DATABASE db SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE db
END
GO

CREATE DATABASE db
GO

--ALTER DATABASE db SET AUTO_UPDATE_STATISTICS ON -- DW OFF?
--GO

USE db
GO

IF OBJECT_ID('dbo.tbl', 'U') IS NOT NULL
    DROP TABLE dbo.tbl
GO

CREATE TABLE dbo.tbl (
      Id INT IDENTITY(1,1) PRIMARY KEY
    , Val CHAR(1)
    , INDEX ix (Val)
)
GO

INSERT INTO dbo.tbl
SELECT TOP(10000) 'x'
FROM [master].dbo.spt_values c1
CROSS APPLY [master].dbo.spt_values c2

------------------------------------------------------------------

SELECT [>=] = COUNT(1) * .20 + 500
FROM dbo.tbl
HAVING COUNT(1) >= 500

------------------------------------------------------------------

SELECT Val, COUNT(1)
FROM dbo.tbl
GROUP BY Val
OPTION(RECOMPILE)

DBCC SHOW_STATISTICS('dbo.tbl', 'ix') WITH HISTOGRAM

------------------------------------------------------------------

UPDATE dbo.tbl 
SET Val = 'a'
WHERE ID <= 2000 -- 20%

------------------------------------------------------------------

UPDATE dbo.tbl 
SET Val = 'b'
WHERE ID <= 2500 -- 20% + 500

------------------------------------------------------------------

UPDATE dbo.tbl 
SET Val = 'c'
WHERE ID BETWEEN 1 AND 2000
--GO 2 -- 2000 * 2 = 4000 (40%)

------------------------------------------------------------------

UPDATE dbo.tbl 
SET Val = 'd'
WHERE ID BETWEEN 1 AND 2000

UPDATE dbo.tbl
SET Val = 'e'
WHERE ID BETWEEN 2001 AND 3000

-- 2000 + 1000 = 3000 (30%)

------------------------------------------------------------------

/*
    For 2008R2 SP1+ use -T2371
    SQL Server 2016+ : ON

    < 25k   = 20%
    > 30k   = 18%
    > 40k   = 15%
    > 100k  = 10%
    > 500k  = 5%
    > 1000k = 3.2%
*/









