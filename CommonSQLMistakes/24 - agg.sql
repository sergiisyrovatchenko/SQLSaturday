USE AdventureWorks2014
GO

SET STATISTICS IO, TIME ON

SELECT s.CountryRegionCode
     , s.[Name]
     , Cnt = COUNT_BIG(*)
FROM Person.StateProvince s
JOIN Person.[Address] a ON s.StateProvinceID = a.StateProvinceID
GROUP BY s.CountryRegionCode
       , s.[Name]

SELECT s.CountryRegionCode
     , s.[Name]
     , a.Cnt
FROM Person.StateProvince s
JOIN (
    SELECT a.StateProvinceID, Cnt = COUNT_BIG(*)
    FROM Person.[Address] a
    GROUP BY a.StateProvinceID
) a ON s.StateProvinceID = a.StateProvinceID

------------------------------------------------------------------

SELECT StateProvince = s.[Name]
     , Country = r.[Name]
     , Cnt = COUNT_BIG(*)
FROM Person.StateProvince s
JOIN Person.CountryRegion r ON s.CountryRegionCode = r.CountryRegionCode
JOIN Person.[Address] a ON s.StateProvinceID = a.StateProvinceID
GROUP BY s.[Name]
       , r.[Name]

SELECT StateProvince = s.[Name]
     , Country = r.[Name]
     , a.Cnt
FROM Person.StateProvince s
JOIN Person.CountryRegion r ON s.CountryRegionCode = r.CountryRegionCode
JOIN (
    SELECT a.StateProvinceID, Cnt = COUNT_BIG(*)
    FROM Person.[Address] a
    GROUP BY a.StateProvinceID
) a ON s.StateProvinceID = a.StateProvinceID

------------------------------------------------------------------

SELECT
    (
        SELECT COUNT_BIG(*)
        FROM Person.[Address]
        WHERE StateProvinceID = 79
    ),
    (
        SELECT COUNT_BIG(*)
        FROM Person.[Address]
        WHERE StateProvinceID = 80
    ),
    (
        SELECT COUNT_BIG(*)
        FROM Person.[Address]
        WHERE StateProvinceID = 9
    )

SELECT p.*
FROM (
    SELECT AddressID, StateProvinceID
    FROM Person.[Address]
    --WHERE StateProvinceID IN (79, 80, 9)
) t
PIVOT (
    COUNT_BIG(AddressID)
    FOR StateProvinceID IN ([79], [80], [9]) 
) p

SELECT COUNT_BIG(CASE WHEN StateProvinceID = 79 THEN 1 END)
     , COUNT_BIG(CASE WHEN StateProvinceID = 80 THEN 1 END)
     , COUNT_BIG(CASE WHEN StateProvinceID = 9 THEN 1 END)
FROM Person.[Address]
WHERE StateProvinceID IN (79, 80, 9)

------------------------------------------------------------------

SELECT
    (
        SELECT COUNT_BIG(*)
        FROM Person.[Address]
        WHERE City = 'London'
    ),
    (
        SELECT COUNT_BIG(*)
        FROM Person.[Address]
        WHERE City = 'Paris'
    )

SELECT COUNT_BIG(CASE WHEN City = 'London' THEN 1 END)
     , COUNT_BIG(CASE WHEN City = 'Paris' THEN 1 END)
FROM Person.[Address]
WHERE City IN ('London', 'Paris')

------------------------------------------------------------------

USE AdventureWorks2008R2
GO

SELECT CustomerID
     , Cnt = COUNT_BIG(*)
     , NumDays = COUNT_BIG(DISTINCT OrderDate)
     , TotalDue = SUM(TotalDue)
FROM Sales.SalesOrderHeader
GROUP BY CustomerID

;WITH cte AS (
    SELECT CustomerID
         , OrderDate
         , Cnt = COUNT_BIG(*)
         , TotalDue = SUM(TotalDue)
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
           , OrderDate
)
SELECT CustomerID
     , Cnt = SUM(Cnt)
     , NumDays = COUNT_BIG(OrderDate)
     , TotalDue = SUM(TotalDue)
FROM cte
GROUP BY CustomerID

SELECT CustomerID
     , Cnt = SUM(Cnt)
     , NumDays = COUNT_BIG(OrderDate)
     , TotalDue = SUM(TotalDue)
FROM (
    SELECT CustomerID
         , OrderDate
         , Cnt = COUNT_BIG(*)
         , TotalDue = SUM(TotalDue)
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
           , OrderDate
) t
GROUP BY CustomerID