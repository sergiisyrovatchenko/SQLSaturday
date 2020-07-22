USE [master]
GO

DROP TABLE IF EXISTS #t
GO

SELECT COUNT(*) FROM tempdb.sys.tables WHERE [name] LIKE '#_%'
GO

DECLARE @t TABLE (id INT)

SELECT COUNT(*) FROM tempdb.sys.tables WHERE [name] LIKE '#_%'

CREATE TABLE #t (id INT)

SELECT COUNT(*) FROM tempdb.sys.tables WHERE [name] LIKE '#_%'

------------------------------------------------------------------

DROP TABLE IF EXISTS #t
GO

DECLARE @t TABLE (id INT)
CREATE TABLE #t (id INT)

BEGIN TRANSACTION

INSERT INTO @t VALUES (2)
INSERT INTO #t VALUES (2)

ROLLBACK

SELECT COUNT(*) FROM @t
SELECT COUNT(*) FROM #t
GO

------------------------------------------------------------------

DECLARE @t TABLE (id INT PRIMARY KEY)
INSERT INTO @t VALUES (1)

INSERT INTO @t VALUES (1), (2)

SELECT * FROM @t

------------------------------------------------------------------

DECLARE @a INT

BEGIN TRANSACTION
SET @a = 123
ROLLBACK

SELECT @a
GO

------------------------------------------------------------------

IF 1=0 BEGIN
    SELECT 1
    DECLARE @t TABLE (id INT PRIMARY KEY)
END

SELECT * FROM @t
GO

------------------------------------------------------------------

USE AdventureWorks2014
GO

DECLARE @GroupName dbo.[Name]

DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
    SELECT DISTINCT GroupName
    FROM HumanResources.Department

OPEN cur

FETCH NEXT FROM cur INTO @GroupName

WHILE @@FETCH_STATUS = 0 BEGIN

    DECLARE @Departments TABLE (DepartmentID SMALLINT, DepartmentName dbo.[Name])

    --DELETE FROM @Departments

    INSERT INTO @Departments (DepartmentID, DepartmentName)
    SELECT DepartmentID, [Name]
    FROM HumanResources.Department
    WHERE GroupName = @GroupName

    SELECT * FROM @Departments

    FETCH NEXT FROM cur INTO @GroupName

END

CLOSE cur
DEALLOCATE cur

------------------------------------------------------------------

/*
    DBCC FREEPROCCACHE
*/

USE AdventureWorks2014
GO

DROP TABLE IF EXISTS #SalesOrderDetail
GO

CREATE TABLE #SalesOrderDetail (ProductID INT PRIMARY KEY)

INSERT INTO #SalesOrderDetail (ProductID)
SELECT DISTINCT ProductID
FROM Sales.SalesOrderDetail

SET STATISTICS IO ON

SELECT *
FROM Production.Product p
WHERE p.ProductID IN (
                SELECT s.ProductID
                FROM #SalesOrderDetail s
            )

SET STATISTICS IO OFF

------------------------------------------------------------------

DECLARE @SalesOrderDetail TABLE (ProductID INT PRIMARY KEY)

INSERT INTO @SalesOrderDetail (ProductID)
SELECT DISTINCT ProductID
FROM Sales.SalesOrderDetail

--DBCC TRACEON(2453)
SET STATISTICS IO ON

SELECT *
FROM Production.Product p
WHERE p.ProductID IN (
                SELECT s.ProductID
                FROM @SalesOrderDetail s
            )
--OPTION(RECOMPILE)

SET STATISTICS IO OFF
--DBCC TRACEOFF(2453)