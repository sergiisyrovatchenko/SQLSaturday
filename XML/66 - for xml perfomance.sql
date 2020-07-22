USE AdventureWorks2014
GO

SELECT s.[Name] FROM Sales.Store s FOR XML RAW, TYPE
SELECT s.[Name] FROM Sales.Store s FOR XML RAW

SELECT s.[Name] FROM Sales.Store s FOR XML AUTO, TYPE
SELECT s.[Name] FROM Sales.Store s FOR XML AUTO

SELECT s.[Name] FROM Sales.Store s FOR XML PATH, TYPE
SELECT s.[Name] FROM Sales.Store s FOR XML PATH(''), TYPE
SELECT s.[Name] FROM Sales.Store s FOR XML PATH('t'), TYPE

SELECT s.[Name] FROM Sales.Store s FOR XML PATH
SELECT s.[Name] FROM Sales.Store s FOR XML PATH('')
SELECT s.[Name] FROM Sales.Store s FOR XML PATH('t')

SELECT [@Name] = s.[Name] FROM Sales.Store s FOR XML PATH, TYPE
SELECT [@Name] = s.[Name] FROM Sales.Store s FOR XML PATH('t'), TYPE

SELECT [@Name] = s.[Name] FROM Sales.Store s FOR XML PATH
SELECT [@Name] = s.[Name] FROM Sales.Store s FOR XML PATH('t')

/*
    1000 requests * 5 threads (5 runs)

    18.02s - FOR XML RAW, TYPE
    19.02s - FOR XML RAW

    18.15s - FOR XML AUTO, TYPE
    18.94s - FOR XML AUTO

    18.23s - FOR XML PATH, TYPE
    18.14s - FOR XML PATH(''), TYPE
    18.12s - FOR XML PATH('t'), TYPE

    19.36s - FOR XML PATH
    18.89s - FOR XML PATH('')
    19.21s - FOR XML PATH('t')

    18.09s - FOR XML PATH, TYPE + @
    18.00s - FOR XML PATH('t'), TYPE + @

    19.00s - FOR XML PATH + @
    19.04s - FOR XML PATH('t') + @
*/

------------------------------------------------------

SELECT s.[Name]
     , (
           SELECT b.PersonID
           FROM Person.BusinessEntityContact b
           WHERE b.BusinessEntityID = s.BusinessEntityID
           FOR XML RAW, TYPE
       )
FROM Sales.Store s
FOR XML RAW, TYPE -- 9.42s

SELECT s.[Name]
     , (
           SELECT b.PersonID
           FROM Person.BusinessEntityContact b
           WHERE b.BusinessEntityID = s.BusinessEntityID
           FOR XML RAW, TYPE
       )
FROM Sales.Store s
FOR XML RAW -- 14.67s

SELECT s.[Name]
     , (
           SELECT b.PersonID
           FROM Person.BusinessEntityContact b
           WHERE b.BusinessEntityID = s.BusinessEntityID
           FOR XML AUTO, TYPE
       )
FROM Sales.Store s
FOR XML AUTO, TYPE -- 9.17s

SELECT s.[Name]
     , (
           SELECT b.PersonID
           FROM Person.BusinessEntityContact b
           WHERE b.BusinessEntityID = s.BusinessEntityID
           FOR XML AUTO, TYPE
       )
FROM Sales.Store s
FOR XML AUTO -- 14.71s

SELECT s.[Name]
     , (
           SELECT b.PersonID
           FROM Person.BusinessEntityContact b
           WHERE b.BusinessEntityID = s.BusinessEntityID
           FOR XML PATH, TYPE
       )
FROM Sales.Store s
FOR XML PATH, TYPE -- 9.26s

SELECT s.[Name]
     , (
           SELECT b.PersonID
           FROM Person.BusinessEntityContact b
           WHERE b.BusinessEntityID = s.BusinessEntityID
           FOR XML PATH, TYPE
       )
FROM Sales.Store s
FOR XML PATH -- 14.93s

/*
    1000 requests (5 runs)

    RAW/AUTO/PATH TYPE + RAW/AUTO/PATH TYPE: 9.17 .. 9.42s -- fast, but remember about voodoo :)
    RAW/AUTO/PATH TYPE + RAW/AUTO/PATH:      14.67 .. 14.93s
*/