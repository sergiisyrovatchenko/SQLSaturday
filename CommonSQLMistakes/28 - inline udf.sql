USE AdventureWorks2014
GO

IF OBJECT_ID('dbo.GetSalesInfo') IS NOT NULL
    DROP FUNCTION dbo.GetSalesInfo
GO

CREATE FUNCTION dbo.GetSalesInfo ()
RETURNS TABLE
AS RETURN (
    SELECT h.SalesOrderID
         , h.OrderDate
         , ShippingCity = a.City
    FROM Sales.SalesOrderHeader h
    JOIN Person.[Address] a ON h.ShipToAddressID = a.AddressID
)
GO

IF OBJECT_ID('dbo.GetSalesDetails') IS NOT NULL
    DROP FUNCTION dbo.GetSalesDetails
GO

CREATE FUNCTION dbo.GetSalesDetails ()
RETURNS TABLE
AS RETURN (
    SELECT s.SalesOrderID
         , Product = p.[Name]
         , s.OrderQty
         , s.UnitPrice
    FROM Sales.SalesOrderDetail s
    JOIN Production.Product p ON s.ProductID = p.ProductID
)
GO

IF OBJECT_ID('dbo.GetAllSalesInfo') IS NOT NULL
    DROP FUNCTION dbo.GetAllSalesInfo
GO

CREATE FUNCTION dbo.GetAllSalesInfo ()
RETURNS TABLE
AS RETURN (
    SELECT s.SalesOrderID
         , s.OrderDate
         , s.ShippingCity
         , d.Product
         , d.OrderQty
         , d.UnitPrice
    FROM dbo.GetSalesInfo() s
    JOIN dbo.GetSalesDetails() d ON d.SalesOrderID = s.SalesOrderID
)
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