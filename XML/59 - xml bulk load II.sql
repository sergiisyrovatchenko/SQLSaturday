SET NOCOUNT ON

USE tempdb
GO

TRUNCATE TABLE dbo.OrderDetails
DELETE FROM dbo.Orders

------------------------------------------------------

SET STATISTICS TIME ON

EXEC sys.xp_cmdshell 'CScript "D:\PROJECT\XML\SQLXMLBulkLoad\sample2.vbs"'

SET STATISTICS TIME OFF

/*
    SQL Server Execution Times:
        CPU time = 0 ms,  elapsed time = 3823 ms.
*/

------------------------------------------------------

SELECT TOP(100) *
FROM dbo.Orders o
LEFT JOIN dbo.OrderDetails d ON d.SalesOrderID = o.SalesOrderID
ORDER BY o.SalesOrderID