USE CCI

SET STATISTICS TIME, IO ON

SELECT COUNT(UnitPrice)
FROM dbo.tCCI
OPTION(MAXDOP 1)

SELECT COUNT(*)
FROM dbo.tCCI
WHERE UnitPrice IS NOT NULL
OPTION(MAXDOP 1)

SET STATISTICS TIME, IO OFF

/*
    SQL Server Execution Times:
       CPU time = 250 ms,  elapsed time = 248 ms.

    SQL Server Execution Times:
       CPU time = 63 ms,  elapsed time = 61 ms.
*/

SET STATISTICS TIME, IO ON

SELECT COUNT(PurchaseOrderNumber)
FROM dbo.tCCI
OPTION(MAXDOP 1)

SELECT COUNT(*)
FROM dbo.tCCI
WHERE PurchaseOrderNumber IS NOT NULL
OPTION(MAXDOP 1)

SET STATISTICS TIME, IO OFF

/*
    SQL Server Execution Times:
       CPU time = 406 ms,  elapsed time = 406 ms.

    SQL Server Execution Times:
       CPU time = 328 ms,  elapsed time = 320 ms.
*/

SET STATISTICS TIME, IO ON

SELECT MIN(PurchaseOrderNumber)
FROM dbo.tCCI
OPTION(MAXDOP 1)

SELECT MIN(PurchaseOrderNumber)
FROM dbo.tCCI
WHERE PurchaseOrderNumber IS NOT NULL
OPTION(MAXDOP 1)

SET STATISTICS TIME, IO OFF

/*
    SQL Server Execution Times:
       CPU time = 453 ms,  elapsed time = 451 ms.

    SQL Server Execution Times:
       CPU time = 453 ms,  elapsed time = 444 ms.
*/
