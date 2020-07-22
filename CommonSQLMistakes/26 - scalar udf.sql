USE AdventureWorks2014
GO

UPDATE TOP(1) Person.[Address]
SET AddressLine2 = AddressLine1
GO

DROP FUNCTION IF EXISTS dbo.IsEqual
GO

CREATE FUNCTION dbo.IsEqual
(
      @val1 NVARCHAR(100)
    , @val2 NVARCHAR(100)
)
RETURNS BIT
AS BEGIN
    RETURN
        CASE WHEN (@val1 IS NULL AND @val2 IS NULL) OR @val1 = @val2
            THEN 1
            ELSE 0
        END
END
GO

------------------------------------------------------------------

SET STATISTICS TIME ON

SELECT AddressID, AddressLine1, AddressLine2
FROM Person.[Address]
WHERE dbo.IsEqual(AddressLine1, AddressLine2) = 1

SELECT AddressID, AddressLine1, AddressLine2
FROM Person.[Address]
WHERE (AddressLine1 IS NULL AND AddressLine2 IS NULL)
    OR AddressLine1 = AddressLine2

SELECT AddressID, AddressLine1, AddressLine2
FROM Person.[Address]
WHERE AddressLine1 = ISNULL(AddressLine2, '')

SET STATISTICS TIME OFF

------------------------------------------------------------------

DROP FUNCTION IF EXISTS dbo.GetPI
GO

CREATE FUNCTION dbo.GetPI ()
RETURNS FLOAT
--WITH SCHEMABINDING
AS BEGIN
    RETURN PI()
END
GO

SELECT dbo.GetPI()
FROM Sales.Currency