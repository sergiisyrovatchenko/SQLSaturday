DECLARE @a VARCHAR(10) = 'TEXT' 
      , @b VARCHAR(10) = 'text'

SELECT IIF(@a = @b, 'TRUE', 'FALSE')
GO

/*
    DECLARE @a VARCHAR(10) = 'TEXT' COLLATE Latin1_General_CS_AS
          , @b VARCHAR(10) = 'text' COLLATE Latin1_General_CS_AS

    SELECT IIF(@a = @b, 'TRUE', 'FALSE')
    GO
*/

------------------------------------------------------------------

DECLARE @a VARCHAR(10) = 'TEXT' 
      , @b VARCHAR(10) = 'text'

SELECT IIF(@a COLLATE Latin1_General_CS_AS = @b COLLATE Latin1_General_CS_AS, 'TRUE', 'FALSE')
GO

------------------------------------------------------------------

USE [master]
GO

IF DB_ID('test') IS NOT NULL BEGIN
    ALTER DATABASE test SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE test
END
GO

CREATE DATABASE test COLLATE Albanian_100_CS_AS
GO

USE test
GO

CREATE TABLE t (c CHAR(1))
INSERT INTO t VALUES ('a')
GO

DROP TABLE IF EXISTS #t1
DROP TABLE IF EXISTS #t2
DROP TABLE IF EXISTS #t3
GO

CREATE TABLE #t1 (c CHAR(1))
INSERT INTO #t1 VALUES ('a')

CREATE TABLE #t2 (c CHAR(1) COLLATE database_default)
INSERT INTO #t2 VALUES ('a')

SELECT c = CAST('a' AS CHAR(1))
INTO #t3

DECLARE @t TABLE (c VARCHAR(100))
INSERT INTO @t VALUES ('a')

SELECT 'tempdb', DATABASEPROPERTYEX('tempdb', 'collation')
UNION ALL
SELECT 'test',   DATABASEPROPERTYEX(DB_NAME(), 'collation')
UNION ALL
SELECT 't',   SQL_VARIANT_PROPERTY(c, 'collation') FROM t
UNION ALL
SELECT '#t1', SQL_VARIANT_PROPERTY(c, 'collation') FROM #t1
UNION ALL
SELECT '#t2', SQL_VARIANT_PROPERTY(c, 'collation') FROM #t2
UNION ALL
SELECT '#t3', SQL_VARIANT_PROPERTY(c, 'collation') FROM #t3
UNION ALL
SELECT '@t',  SQL_VARIANT_PROPERTY(c, 'collation') FROM @t

------------------------------------------------------------------

SELECT *
FROM #t1
WHERE c = 'A'

SELECT *
FROM #t1
JOIN t ON [#t1].c = t.c

SELECT *
FROM #t1
JOIN t ON [#t1].c = t.c COLLATE database_default

------------------------------------------------------------------

USE [master]
GO

IF DB_ID('test') IS NOT NULL BEGIN
    ALTER DATABASE test SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE test
END
GO

CREATE DATABASE test COLLATE Latin1_General_CI_AS
GO

USE test
GO

CREATE TABLE dbo.Employee (EmployeeID INT PRIMARY KEY)
GO

------------------------------------------------------------------

select employeeid from employee

------------------------------------------------------------------

ALTER DATABASE test COLLATE Latin1_General_CS_AI

------------------------------------------------------------------

SELECT DATABASEPROPERTYEX('master', 'collation')

DECLARE @EmpID INT = 1
SELECT @empid