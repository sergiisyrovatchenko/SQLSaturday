USE AdventureWorks2014
GO

DROP FUNCTION IF EXISTS dbo.GetSalesInfo
GO

CREATE FUNCTION dbo.GetSalesInfo ()
RETURNS @return TABLE
(
      SalesOrderID INT
    , OrderDate DATETIME
    , ShippingCity NVARCHAR(30)
)
AS BEGIN

    INSERT INTO @return (SalesOrderID, OrderDate, ShippingCity)
    SELECT h.SalesOrderID
         , h.OrderDate
         , a.City
    FROM Sales.SalesOrderHeader h
    JOIN Person.[Address] a ON h.ShipToAddressID = a.AddressID

    RETURN
END
GO

DROP FUNCTION IF EXISTS dbo.GetSalesDetails
GO

CREATE FUNCTION dbo.GetSalesDetails ()
RETURNS @return TABLE
(
      SalesOrderID INT
    , Product dbo.[Name]
    , OrderQty SMALLINT
    , UnitPrice MONEY
)
AS BEGIN

    INSERT INTO @return (SalesOrderID, Product, OrderQty, UnitPrice)
    SELECT s.SalesOrderID
         , p.[Name]
         , s.OrderQty
         , s.UnitPrice
    FROM Sales.SalesOrderDetail s
    JOIN Production.Product p ON s.ProductID = p.ProductID

    RETURN
END
GO

DROP FUNCTION IF EXISTS dbo.GetAllSalesInfo
GO

CREATE FUNCTION dbo.GetAllSalesInfo ()
RETURNS @return TABLE
(
      SalesOrderID INT
    , OrderDate DATETIME
    , ShippingCity NVARCHAR(30)
    , Product dbo.[Name]
    , OrderQty SMALLINT
    , UnitPrice MONEY
)
AS BEGIN

    INSERT INTO @return (SalesOrderID, OrderDate, ShippingCity, Product, OrderQty, UnitPrice)
    SELECT s.SalesOrderID
         , s.OrderDate
         , s.ShippingCity
         , d.Product
         , d.OrderQty
         , d.UnitPrice
    FROM dbo.GetSalesInfo() s
    JOIN dbo.GetSalesDetails() d ON d.SalesOrderID = s.SalesOrderID

    RETURN
END
GO

------------------------------------------------------------------

SET STATISTICS IO, TIME ON

SELECT SalesOrderID
     , OrderDate
     , Product
     , OrderQty
     , UnitPrice
FROM dbo.GetAllSalesInfo()
WHERE ShippingCity = 'Odessa'
    AND OrderDate = '20121130'

SET STATISTICS IO, TIME OFF

------------------------------------------------------------------

SELECT q.query_plan
     , t.[text]
     , SUBSTRING(t.[text], (s.statement_start_offset / 2) + 1, (s.statement_end_offset - s.statement_start_offset) / 2 + 1)
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) q
CROSS APPLY sys.dm_exec_sql_text(s.[sql_handle]) t
WHERE q.objectid = OBJECT_ID('dbo.GetAllSalesInfo')

------------------------------------------------------------------

SET STATISTICS IO, TIME ON

SELECT h.SalesOrderID
     , h.OrderDate
     , Product = p.[Name]
     , s.OrderQty
     , s.UnitPrice
FROM Sales.SalesOrderHeader h
JOIN Person.[Address] a ON h.ShipToAddressID = a.AddressID
JOIN Sales.SalesOrderDetail s ON h.SalesOrderID = s.SalesOrderID
JOIN Production.Product p ON s.ProductID = p.ProductID
WHERE a.City = 'Odessa'
    AND h.OrderDate = '20121130'

SELECT h.SalesOrderID
     , h.OrderDate
     , Product = p.[Name]
     , s.OrderQty
     , s.UnitPrice
FROM Sales.SalesOrderHeader h
JOIN Sales.SalesOrderDetail s ON h.SalesOrderID = s.SalesOrderID
JOIN Production.Product p ON s.ProductID = p.ProductID
WHERE h.OrderDate = '20121130'
    AND h.ShipToAddressID IN (
            SELECT a.AddressID
            FROM Person.[Address] a
            WHERE a.City= 'Odessa'
        )

SET STATISTICS IO, TIME OFF