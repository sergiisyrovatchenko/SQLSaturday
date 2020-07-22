USE AdventureWorks2014
GO

SET STATISTICS IO ON

SELECT BusinessEntityID
FROM Person.Person
WHERE BusinessEntityID * 2 = 10000

SELECT BusinessEntityID
FROM Person.Person
WHERE BusinessEntityID = 2500 * 2

SELECT BusinessEntityID
FROM Person.Person
WHERE BusinessEntityID = 5000

/*
    Table 'Person'. Scan count 1, logical reads 67, ...
    Table 'Person'. Scan count 0, logical reads 3, ...
    Table 'Person'. Scan count 0, logical reads 3, ...
*/

