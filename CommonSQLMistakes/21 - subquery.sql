USE AdventureWorks2014
GO

SET STATISTICS IO ON

SELECT p.BusinessEntityID
     , (
        SELECT s.SalesQuota
        FROM Sales.SalesPersonQuotaHistory s
        WHERE s.BusinessEntityID = p.BusinessEntityID
      )
FROM Person.Person p

------------------------------------------------------------------

SELECT p.BusinessEntityID
     , (
        SELECT TOP(1) s.SalesQuota
        FROM Sales.SalesPersonQuotaHistory s
        WHERE s.BusinessEntityID = p.BusinessEntityID
        ORDER BY s.QuotaDate DESC
      )
FROM Person.Person p

SELECT p.BusinessEntityID
     , t.SalesQuota
FROM Person.Person p
OUTER APPLY (
    SELECT TOP(1) s.SalesQuota
    FROM Sales.SalesPersonQuotaHistory s
    WHERE s.BusinessEntityID = p.BusinessEntityID
    ORDER BY s.QuotaDate DESC
) t

SELECT p.BusinessEntityID
     , t.SalesQuota
FROM Person.Person p
LEFT JOIN (
    SELECT s.BusinessEntityID
         , s.SalesQuota
         , RowNum = ROW_NUMBER() OVER (PARTITION BY s.BusinessEntityID ORDER BY s.QuotaDate DESC)
    FROM Sales.SalesPersonQuotaHistory s
) t ON p.BusinessEntityID = t.BusinessEntityID AND t.RowNum = 1

------------------------------------------------------------------

SET STATISTICS TIME ON

DECLARE @id INT
SELECT @id = BusinessEntityID
FROM Person.BusinessEntity
ORDER BY NEWID()
GO

DECLARE @id INT = (
        SELECT TOP(1) BusinessEntityID
        FROM Person.BusinessEntity
        ORDER BY NEWID()
    )
GO

DECLARE @id INT
SELECT TOP(1) @id = BusinessEntityID
FROM Person.BusinessEntity
ORDER BY NEWID()

SET STATISTICS IO, TIME OFF

------------------------------------------------------------------

DECLARE @BusinessEntityID INT
      , @ModifiedDate DATETIME

SELECT TOP(1) @BusinessEntityID = BusinessEntityID
            , @ModifiedDate = ModifiedDate
FROM Person.BusinessEntity

