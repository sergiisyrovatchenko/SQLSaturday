USE CCI
GO

SET STATISTICS IO, TIME ON

SELECT SUM(TotalSum)
FROM (
    SELECT CustomerID, TotalSum = SUM(OrderQty * UnitPrice)
    FROM dbo.tCCI
    GROUP BY CustomerID
) t

SELECT SUM(TotalSum)
FROM (
    SELECT CustomerID, TotalSum = SUM(TotalSum)
    FROM dbo.tCCI
    GROUP BY CustomerID
) t

SET STATISTICS IO, TIME OFF

/*
    SQL Server Execution Times:
       CPU time = 94 ms,  elapsed time = 102 ms.

    SQL Server Execution Times:
       CPU time = 78 ms,  elapsed time = 81 ms.
*/

/*
    ALTER TABLE dbo.tCCI ADD TestColumn AS OrderQty * UnitPrice PERSISTED !!!

    Msg 35307, Level 16, State 1, Line 10
    The statement failed because column 'TestColumn' on table 'tCCI' is a computed column. Columnstore index cannot include a computed column implicitly or explicitly.
*/