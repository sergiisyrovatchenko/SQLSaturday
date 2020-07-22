USE AdventureWorks2014
GO

/*
    https://docs.microsoft.com/en-us/sql/t-sql/data-types/data-type-precedence-transact-sql
*/

SET STATISTICS IO ON

SELECT BusinessEntityID
FROM HumanResources.Employee
WHERE NationalIDNumber = 30845

SELECT BusinessEntityID
FROM HumanResources.Employee
WHERE NationalIDNumber = '30845'

------------------------------------------------------------------

SELECT AddressID
FROM Person.[Address]
WHERE PostalCode = 92700

SELECT AddressID
FROM Person.[Address]
WHERE PostalCode = '92700'

------------------------------------------------------------------

SELECT CustomerID, AccountNumber
FROM Sales.Customer
WHERE AccountNumber = N'AW00000009'

SELECT CustomerID, AccountNumber
FROM Sales.Customer
WHERE AccountNumber = 'AW00000009'

------------------------------------------------------------------

/*
    IF OBJECT_ID('#GetCustomer') IS NOT NULL
        DROP PROCEDURE #GetCustomer
    GO

    CREATE PROCEDURE #GetCustomer
    (
        @AccountNumber VARCHAR(10)
    )
    AS
        SELECT *
        FROM Sales.Customer
        WHERE AccountNumber = @AccountNumber
*/

DECLARE @AccountNumber NVARCHAR(4000) = N'AW00000009'
EXEC sys.sp_executesql N'SELECT * FROM Sales.Customer WHERE AccountNumber = @1'
                     , N'@1 NVARCHAR(4000)'
                     , @AccountNumber
GO

DECLARE @AccountNumber NVARCHAR(4000) = N'AW00000009'
EXEC sys.sp_executesql N'#GetCustomer @1'
                     , N'@1 NVARCHAR(4000)'
                     , @AccountNumber