USE AdventureWorks2014
GO

SET STATISTICS IO ON

SELECT e.BusinessEntityID
    , (
        SELECT p.LastName
        FROM Person.Person p
        WHERE e.BusinessEntityID = p.BusinessEntityID
      )
    , (
        SELECT p.FirstName
        FROM Person.Person p
        WHERE e.BusinessEntityID = p.BusinessEntityID
      )
FROM HumanResources.Employee e

SELECT e.BusinessEntityID
     , p.LastName
     , p.FirstName
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID