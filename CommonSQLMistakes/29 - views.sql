USE tempdb
GO

DROP TABLE IF EXISTS dbo.tbl
GO

CREATE TABLE dbo.tbl (a INT, b INT)
GO
INSERT INTO dbo.tbl VALUES (0, 1)
GO

DROP VIEW IF EXISTS dbo.vw_tbl
GO

CREATE VIEW dbo.vw_tbl
AS
    SELECT * FROM dbo.tbl
GO

SELECT * FROM dbo.vw_tbl

------------------------------------------------------------------

ALTER TABLE dbo.tbl
    ADD c INT NOT NULL DEFAULT 2
GO

SELECT * FROM dbo.vw_tbl

------------------------------------------------------------------

EXEC sys.sp_refreshview @viewname = N'dbo.vw_tbl'
GO

SELECT * FROM dbo.vw_tbl

------------------------------------------------------------------

USE AdventureWorks2014
GO

ALTER VIEW HumanResources.vEmployee
AS
    SELECT e.BusinessEntityID
         , p.Title
         , p.FirstName
         , p.MiddleName
         , p.LastName
         , p.Suffix
         , e.JobTitle
         , pp.PhoneNumber
         , pnt.[Name] AS PhoneNumberType
         , ea.EmailAddress
         , p.EmailPromotion
         , a.AddressLine1
         , a.AddressLine2
         , a.City
         , sp.[Name] AS StateProvinceName
         , a.PostalCode
         , cr.[Name] AS CountryRegionName
         , p.AdditionalContactInfo
    FROM HumanResources.Employee e
    JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
    JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = e.BusinessEntityID
    JOIN Person.[Address] a ON a.AddressID = bea.AddressID
    JOIN Person.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID
    JOIN Person.CountryRegion cr ON cr.CountryRegionCode = sp.CountryRegionCode
    LEFT JOIN Person.PersonPhone pp ON pp.BusinessEntityID = p.BusinessEntityID
    LEFT JOIN Person.PhoneNumberType pnt ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID
    LEFT JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
GO

------------------------------------------------------------------

SET STATISTICS IO ON

SELECT BusinessEntityID
     , FirstName
     , LastName
FROM HumanResources.vEmployee

SELECT p.BusinessEntityID
     , p.FirstName
     , p.LastName
FROM Person.Person p
WHERE p.BusinessEntityID IN (
        SELECT e.BusinessEntityID
        FROM HumanResources.Employee e
    )

------------------------------------------------------------------

SELECT d.ProductID
     , h.OrderDate
     , OrderQty = SUM(d.OrderQty)
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
WHERE h.OrderDate < '20120101'
GROUP BY d.ProductID
       , h.OrderDate

------------------------------------------------------------------

DROP VIEW IF EXISTS dbo.vwSalesOrder
GO
CREATE VIEW dbo.vwSalesOrder
WITH SCHEMABINDING
AS
    SELECT d.ProductID
         , h.OrderDate
         , OrderQty = SUM(d.OrderQty)
         , OrderCnt = COUNT_BIG(*)
    FROM Sales.SalesOrderDetail d
    JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
    GROUP BY d.ProductID
           , h.OrderDate
GO
CREATE UNIQUE CLUSTERED INDEX IX ON dbo.vwSalesOrder (ProductID, OrderDate)

------------------------------------------------------------------

SELECT d.ProductID
     , OrderQty = SUM(d.OrderQty)
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
WHERE h.OrderDate < '20120101'
GROUP BY d.ProductID
--OPTION(EXPAND VIEWS)

SELECT ProductID
     , OrderQty = SUM(OrderQty)
FROM dbo.vwSalesOrder
WHERE OrderDate < '20120101'
GROUP BY ProductID

------------------------------------------------------------------

CREATE UNIQUE CLUSTERED INDEX IX ON dbo.vwSalesOrder (OrderDate, ProductID)
    WITH DROP_EXISTING

/*
    FROM/JOIN
    WHERE
    GROUP BY
    HAVING
    SELECT
    DISTINCT
    ORDER BY
    TOP
*/