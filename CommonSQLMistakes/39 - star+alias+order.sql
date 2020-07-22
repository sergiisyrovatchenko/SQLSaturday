USE AdventureWorks2014
GO

SET STATISTICS TIME, IO ON

SELECT *
FROM Person.Person

SELECT BusinessEntityID
     , FirstName
     , MiddleName
     , LastName
FROM Person.Person

SET STATISTICS TIME, IO OFF

------------------------------------------------------------------

DROP TABLE IF EXISTS Sales.UserCurrency
GO

CREATE TABLE Sales.UserCurrency (
    CurrencyCode NCHAR(3) PRIMARY KEY
)
INSERT INTO Sales.UserCurrency
VALUES ('USD')
GO

------------------------------------------------------------------

SELECT COUNT_BIG(*)
FROM Sales.Currency
WHERE CurrencyCode IN (
            SELECT CurrencyCode
            FROM Sales.UserCurrency
        )
GO

EXEC sys.sp_rename 'Sales.UserCurrency.CurrencyCode', 'Code', 'COLUMN'
GO

SELECT COUNT_BIG(*)
FROM Sales.Currency c
WHERE c.CurrencyCode IN (
            SELECT u.CurrencyCode
            FROM Sales.UserCurrency u
        )

/*
    SELECT *
    FROM ...
    WHERE ... IN (SELECT * FROM ...)
*/

------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.DatePeriod
GO

CREATE TABLE dbo.DatePeriod (
      StartDate DATE
    , EndDate DATE
)

INSERT INTO dbo.DatePeriod
SELECT '2015-01-01', '2015-01-31'
GO

------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.DatePeriod
GO

CREATE TABLE dbo.DatePeriod (
      EndDate DATE
    , StartDate DATE
)

INSERT INTO dbo.DatePeriod (StartDate, EndDate)
SELECT '2015-01-01', '2015-01-31'
GO

------------------------------------------------------------------

SELECT TOP(1) *
FROM dbo.DatePeriod
ORDER BY 2 DESC

------------------------------------------------------------------

SELECT TOP(1) StartDate AS EndDate
            , EndDate AS StartDate
FROM dbo.DatePeriod
ORDER BY StartDate DESC