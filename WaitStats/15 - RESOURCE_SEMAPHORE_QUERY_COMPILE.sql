-- KB #3024815 : Large query compilation waits on RESOURCE_SEMAPHORE_QUERY_COMPILE in SQL Server 2014

/*
    DBCC FREEPROCCACHE
*/

USE AdventureWorks2014
GO

IF OBJECT_ID('tempdb.dbo.#SalesOrderDetail') IS NOT NULL
    DROP TABLE #SalesOrderDetail

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

------------------------------------------------------

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

------------------------------------------------------

/*
    SP:Recompile / SQL:StmtRecomple

    DBCC FREEPROCCACHE
*/

SELECT s.plan_generation_num
     , s.execution_count
     , t.[text]
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_sql_text(s.[sql_handle]) t
WHERE t.[text] LIKE '%ProductID%'
    OR t.[text] LIKE '%NationalIDNumber%'

------------------------------------------------------

SELECT NationalIDNumber
FROM HumanResources.Employee
WHERE BusinessEntityID = 1
GO

SELECT NationalIDNumber
FROM HumanResources.Employee
WHERE BusinessEntityID = 2
GO

SELECT NationalIDNumber
FROM HumanResources.Employee
WHERE BusinessEntityID = 3
GO

------------------------------------------------------

SELECT NationalIDNumber
FROM HumanResources.Employee
WHERE NationalIDNumber = N'10708100'
    AND BusinessEntityID IN (SELECT BusinessEntityID FROM Sales.PersonCreditCard)
GO

SELECT NationalIDNumber
FROM HumanResources.Employee
WHERE NationalIDNumber = N'109272464'
    AND BusinessEntityID IN (SELECT BusinessEntityID FROM Sales.PersonCreditCard)
GO

SELECT NationalIDNumber
FROM HumanResources.Employee
WHERE NationalIDNumber = N'112432117'
    AND BusinessEntityID IN (SELECT BusinessEntityID FROM Sales.PersonCreditCard)
GO

------------------------------------------------------

EXEC sys.sp_executesql N'
        SELECT NationalIDNumber
        FROM HumanResources.Employee
        WHERE NationalIDNumber = @NationalIDNumber
            AND BusinessEntityID IN (SELECT BusinessEntityID FROM Sales.PersonCreditCard)'
                     , N'@NationalIDNumber NVARCHAR(15)'
                     , @NationalIDNumber = N'10708100'
GO

EXEC sys.sp_executesql N'
        SELECT NationalIDNumber
        FROM HumanResources.Employee
        WHERE NationalIDNumber = @NationalIDNumber
            AND BusinessEntityID IN (SELECT BusinessEntityID FROM Sales.PersonCreditCard)'
                     , N'@NationalIDNumber NVARCHAR(15)'
                     , @NationalIDNumber = N'109272464'
GO

EXEC sys.sp_executesql N'
        SELECT NationalIDNumber
        FROM HumanResources.Employee
        WHERE NationalIDNumber = @NationalIDNumber
            AND BusinessEntityID IN (SELECT BusinessEntityID FROM Sales.PersonCreditCard)'
                     , N'@NationalIDNumber NVARCHAR(15)'
                     , @NationalIDNumber = N'112432117'
GO

/*
    var value = ...;
    
    SqlCommand command = new SqlCommand(
        string.Format("
            SELECT NationalIDNumber
            FROM HumanResources.Employee
            WHERE BusinessEntityID = {0}
        ", val), conn);

    SqlCommand command = new SqlCommand("
            SELECT NationalIDNumber
            FROM HumanResources.Employee
            WHERE BusinessEntityID = @BusinessEntityID
        ", conn);
    command.Parameters.Add(new SqlParameter("BusinessEntityID", val));
*/

------------------------------------------------------

/*
    Check about parameter sniffing:
    http://www.somewheresomehow.ru/fast-in-ssms-slow-in-app-part1/
*/

------------------------------------------------------

SET STATISTICS IO ON

USE AdventureWorks2014
GO

SELECT SalesOrderDetailID, UnitPrice * OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 870

SELECT SalesOrderDetailID, UnitPrice * OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 897
GO

------------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#GetOrderTotalSum') IS NOT NULL
    DROP PROCEDURE #GetOrderTotalSum
GO

CREATE PROCEDURE #GetOrderTotalSum
(
    @ProductID INT
)
AS BEGIN

    SELECT SalesOrderDetailID, Total = UnitPrice * OrderQty
    FROM Sales.SalesOrderDetail
    WHERE ProductID = @ProductID

END
GO

EXEC #GetOrderTotalSum @ProductID = 870
EXEC #GetOrderTotalSum @ProductID = 897
GO