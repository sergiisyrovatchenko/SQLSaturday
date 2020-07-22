USE AdventureWorks2014
GO

SET STATISTICS IO ON

SELECT AddressLine1
FROM Person.[Address]
WHERE SUBSTRING(AddressLine1, 1, 3) = '100'

SELECT AddressLine1
FROM Person.[Address]
WHERE LEFT(AddressLine1, 3) = '100'

SELECT AddressLine1
FROM Person.[Address]
WHERE CAST(AddressLine1 AS CHAR(3)) = '100'

SELECT AddressLine1
FROM Person.[Address]
WHERE AddressLine1 LIKE '100%'

/*
    Table 'Address'. Scan count 1, logical reads 216, ...
    Table 'Address'. Scan count 1, logical reads 216, ...
    Table 'Address'. Scan count 1, logical reads 216, ...
    Table 'Address'. Scan count 1, logical reads 4, ...
*/

------------------------------------------------------------------

SELECT AddressLine1
FROM Person.[Address]
WHERE AddressLine1 LIKE '%100%'

/*
    Table 'Address'. Scan count 1, logical reads 216, ...
*/