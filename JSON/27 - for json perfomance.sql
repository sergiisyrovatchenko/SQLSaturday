USE AdventureWorks2014
GO

SELECT s.[Name] FROM Sales.Store s FOR JSON AUTO
SELECT s.[Name] FROM Sales.Store s FOR JSON PATH

SELECT s.[Name] FROM Sales.Store s FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
SELECT s.[Name] FROM Sales.Store s FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

SELECT s.[Name] FROM Sales.Store s FOR JSON AUTO, ROOT
SELECT s.[Name] FROM Sales.Store s FOR JSON PATH, ROOT

/*
    1000 requests * 5 threads (5 runs)

    18.61s - FOR JSON AUTO
    18.64s - FOR JSON PATH

    18.98s - FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
    18.65s - FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

    18.79s - FOR JSON AUTO, ROOT
    18.59s - FOR JSON PATH, ROOT
*/

------------------------------------------------------

SELECT s.[Name]
     , x = (
           SELECT b.PersonID
           FROM Person.BusinessEntityContact b
           WHERE b.BusinessEntityID = s.BusinessEntityID
           FOR JSON AUTO
       )
FROM Sales.Store s
FOR JSON AUTO -- 8.68s

SELECT s.[Name]
     , x = (
           SELECT b.PersonID
           FROM Person.BusinessEntityContact b
           WHERE b.BusinessEntityID = s.BusinessEntityID
           FOR JSON AUTO
       )
FROM Sales.Store s
FOR JSON PATH -- 8.61s

SELECT s.[Name]
     , x = (
           SELECT b.PersonID
           FROM Person.BusinessEntityContact b
           WHERE b.BusinessEntityID = s.BusinessEntityID
           FOR JSON PATH
       )
FROM Sales.Store s
FOR JSON AUTO -- 8.62s

SELECT s.[Name]
     , x = (
           SELECT b.PersonID
           FROM Person.BusinessEntityContact b
           WHERE b.BusinessEntityID = s.BusinessEntityID
           FOR JSON PATH
       )
FROM Sales.Store s
FOR JSON PATH -- 8.39s

/*
    1000 requests (5 runs) ~8.50s
*/