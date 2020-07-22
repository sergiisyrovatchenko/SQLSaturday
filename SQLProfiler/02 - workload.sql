USE AdventureWorks2014
GO

SELECT D.[Name]
     , CASE
           WHEN GROUPING_ID(D.[Name], E.JobTitle) = 0 THEN E.JobTitle
           WHEN GROUPING_ID(D.[Name], E.JobTitle) = 1 THEN N'Total: ' + D.[Name]
           WHEN GROUPING_ID(D.[Name], E.JobTitle) = 3 THEN N'Company Total:'
           ELSE N'Unknown'
       END AS N'Job Title'
     , COUNT(E.BusinessEntityID) AS N'Employee Count'
FROM HumanResources.Employee E
JOIN HumanResources.EmployeeDepartmentHistory DH ON E.BusinessEntityID = DH.BusinessEntityID
JOIN HumanResources.Department D ON D.DepartmentID = DH.DepartmentID
WHERE DH.enddate IS NULL
    AND D.DepartmentID IN (12, 14)
GROUP BY ROLLUP (D.[Name], E.JobTitle)
GO

SELECT D.[Name]
     , E.JobTitle
     , GROUPING_ID(D.[Name], E.JobTitle) AS 'Grouping Level'
     , COUNT(E.BusinessEntityID) AS N'Employee Count'
FROM HumanResources.Employee AS E
JOIN HumanResources.EmployeeDepartmentHistory AS DH ON E.BusinessEntityID = DH.BusinessEntityID
JOIN HumanResources.Department AS D ON D.DepartmentID = DH.DepartmentID
WHERE DH.enddate IS NULL
    AND D.DepartmentID IN (12, 14)
GROUP BY ROLLUP (D.[Name], E.JobTitle)
HAVING GROUPING_ID(D.[Name], E.JobTitle) = 0
GO

SELECT D.[Name]
     , E.JobTitle
     , GROUPING_ID(D.[Name], E.JobTitle) AS 'Grouping Level'
     , COUNT(E.BusinessEntityID) AS N'Employee Count'
FROM HumanResources.Employee AS E
JOIN HumanResources.EmployeeDepartmentHistory AS DH ON E.BusinessEntityID = DH.BusinessEntityID
JOIN HumanResources.Department AS D ON D.DepartmentID = DH.DepartmentID
WHERE DH.EndDate IS NULL
    AND D.DepartmentID IN (12, 14)
GROUP BY ROLLUP (D.[Name], E.JobTitle)
HAVING GROUPING_ID(D.[Name], E.JobTitle) = 1
GO

DECLARE @CurrentEmployee HIERARCHYID

SELECT @CurrentEmployee = OrganizationNode
FROM HumanResources.Employee
WHERE LoginID = 'adventure-works\david0'

SELECT OrganizationNode.ToString() AS Text_OrganizationNode
FROM HumanResources.Employee
WHERE OrganizationNode.GetAncestor(1) = @CurrentEmployee
GO

DECLARE @CurrentEmployee HIERARCHYID

SELECT @CurrentEmployee = OrganizationNode
FROM HumanResources.Employee
WHERE LoginID = 'adventure-works\ken0'

SELECT OrganizationNode.ToString() AS Text_OrganizationNode
FROM HumanResources.Employee
WHERE OrganizationNode.GetAncestor(2) = @CurrentEmployee
GO

DECLARE @CurrentEmployee HIERARCHYID

SELECT @CurrentEmployee = OrganizationNode
FROM HumanResources.Employee
WHERE LoginID = 'adventure-works\david0'

SELECT OrganizationNode.ToString() AS Text_OrganizationNode
FROM HumanResources.Employee
WHERE OrganizationNode.GetAncestor(0) = @CurrentEmployee
GO

SELECT CustomerID
     , OrderDate
     , SubTotal
     , TotalDue
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = 35
ORDER BY OrderDate
GO

SELECT SalesPersonID
     , CustomerID
     , OrderDate
     , SubTotal
     , TotalDue
FROM Sales.SalesOrderHeader
ORDER BY SalesPersonID
       , OrderDate
GO

USE AdventureWorks2014
GO

SELECT *
FROM Production.Product
ORDER BY [Name]
GO

SELECT p.*
FROM Production.Product AS p
ORDER BY [Name]
GO

SELECT [Name]
     , ProductNumber
     , ListPrice AS Price
FROM Production.Product
ORDER BY [Name] ASC
GO

SELECT [Name]
     , ProductNumber
     , ListPrice AS Price
FROM Production.Product
WHERE ProductLine = 'R'
    AND DaysToManufacture < 4
ORDER BY [Name] ASC
GO

USE Users
GO

EXEC dbo.GetStatisticsByCity @City = 'London'
GO

EXEC dbo.GetStatisticsByCity @City = 'Berlin'
GO

USE AdventureWorks2014
GO

SELECT p.[Name] AS ProductName
     , NonDiscountSales = (OrderQty * UnitPrice)
     , Discounts = ((OrderQty * UnitPrice) * UnitPriceDiscount)
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
ORDER BY ProductName DESC
GO

SELECT p.[Name] AS ProductName
     , NonDiscountSales = (OrderQty * UnitPrice)
     , Discounts = ((OrderQty * UnitPrice) * UnitPriceDiscount)
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE ProductNumber = N'SB-M891-S'
ORDER BY ProductName DESC
GO

SELECT DISTINCT JobTitle
FROM HumanResources.Employee
ORDER BY JobTitle
GO

USE Users
GO

EXEC dbo.GetUsers @Date = '20170320'
GO

EXEC dbo.GetUsers @City = 'Kharkiv'
GO

EXEC dbo.GetUsers @City = 'London'
GO

EXEC dbo.GetUsers @City = 'Kiev'
GO

USE AdventureWorks2014
GO

SELECT DISTINCT p.LastName
              , p.FirstName
FROM Person.Person p
JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
WHERE 5000.00 IN (
        SELECT Bonus
        FROM Sales.SalesPerson AS sp
        WHERE e.BusinessEntityID = sp.BusinessEntityID
    )
GO

SELECT p1.ProductModelID
FROM Production.Product p1
GROUP BY p1.ProductModelID
HAVING MAX(p1.ListPrice) >= ALL (
        SELECT AVG(p2.ListPrice)
        FROM Production.Product p2
        WHERE p1.ProductModelID = p2.ProductModelID
    )
GO

SELECT DISTINCT pp.LastName
              , pp.FirstName
FROM Person.Person pp
JOIN HumanResources.Employee e ON e.BusinessEntityID = pp.BusinessEntityID
WHERE pp.BusinessEntityID IN (
        SELECT SalesPersonID
        FROM Sales.SalesOrderHeader
        WHERE SalesOrderID IN (
                SELECT SalesOrderID
                FROM Sales.SalesOrderDetail
                WHERE ProductID IN (
                        SELECT ProductID
                        FROM Production.Product p
                        WHERE ProductNumber = 'BK-M68B-42'
                    )
            )
    )
GO

SELECT SalesOrderID
     , SUM(LineTotal) AS SubTotal
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY SalesOrderID
GO

SELECT ProductID
     , SpecialOfferID
     , AVG(UnitPrice) AS 'Average Price'
     , SUM(LineTotal) AS SubTotal
FROM Sales.SalesOrderDetail
GROUP BY ProductID
       , SpecialOfferID
ORDER BY ProductID
GO

SELECT ProductModelID
     , AVG(ListPrice) AS 'Average List Price'
FROM Production.Product
WHERE ListPrice > $1000
GROUP BY ProductModelID
ORDER BY ProductModelID
GO

SELECT AVG(OrderQty) AS 'Average Quantity'
     , NonDiscountSales = (OrderQty * UnitPrice)
FROM Sales.SalesOrderDetail
GROUP BY (OrderQty * UnitPrice)
ORDER BY (OrderQty * UnitPrice) DESC
GO

SELECT ProductID
     , AVG(UnitPrice) AS 'Average Price'
FROM Sales.SalesOrderDetail
WHERE OrderQty > 10
GROUP BY ProductID
ORDER BY AVG(UnitPrice)
GO

SELECT ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING AVG(OrderQty) > 5
ORDER BY ProductID
GO

SELECT SalesOrderID
     , CarrierTrackingNumber
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
       , CarrierTrackingNumber
HAVING CarrierTrackingNumber LIKE '4BD%'
ORDER BY SalesOrderID
GO

SELECT ProductID
FROM Sales.SalesOrderDetail
WHERE UnitPrice < 25.00
GROUP BY ProductID
HAVING AVG(OrderQty) > 5
ORDER BY ProductID
GO

SELECT ProductID
     , AVG(OrderQty) AS AverageQuantity
     , SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(LineTotal) > $1000000.00
    AND AVG(OrderQty) < 3
GO

SELECT ProductID
     , Total = SUM(LineTotal)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(LineTotal) > $2000000.00
GO

SELECT ProductID
     , SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) > 1500
GO

SELECT ProductID
     , LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID
       , LineTotal

SELECT ProductID
     , LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID
       , LineTotal
GO

SELECT ProductID
     , OrderQty
     , UnitPrice
     , LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $2.00
GO

SELECT ProductID
     , OrderQty
     , UnitPrice
     , LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID
GO

SELECT ProductID
     , OrderQty
     , LineTotal
FROM Sales.SalesOrderDetail
GO

SELECT ProductID
     , OrderQty
     , UnitPrice
     , LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID
       , OrderQty
       , LineTotal
GO

SELECT ProductID
     , LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID
GO

SELECT ProductID
     , SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID
ORDER BY ProductID
GO

SELECT ProductID
     , OrderQty
     , SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID
       , OrderQty
ORDER BY ProductID
       , OrderQty
GO

SELECT pp.FirstName
     , pp.LastName
     , e.NationalIDNumber
FROM HumanResources.Employee e WITH (INDEX (AK_Employee_NationalIDNumber))
JOIN Person.Person pp ON e.BusinessEntityID = pp.BusinessEntityID
WHERE LastName = 'Johnson'
GO

SELECT pp.LastName
     , pp.FirstName
     , e.JobTitle
FROM HumanResources.Employee e WITH(INDEX = 0) -- force a table scan
JOIN Person.Person pp ON e.BusinessEntityID = pp.BusinessEntityID
WHERE LastName = 'Johnson'