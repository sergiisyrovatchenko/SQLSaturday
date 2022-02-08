USE CCI
GO

SET NOCOUNT ON
SET STATISTICS TIME, IO ON

SELECT RowID_Datetime, SUM(UnitPrice)
FROM dbo.tCCI
WHERE CONVERT(VARCHAR(10), ProductID) = '850'
GROUP BY RowID_Datetime

SELECT RowID_Datetime, SUM(UnitPrice)
FROM dbo.tCCI
WHERE ProductID + 0 = 850
GROUP BY RowID_Datetime

SELECT RowID_Datetime, SUM(UnitPrice)
FROM dbo.tCCI
WHERE ProductID = 850
GROUP BY RowID_Datetime

SET STATISTICS TIME, IO OFF

/*
    Table 'tCCI'. ..., lob logical reads 810, lob physical reads 0, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 375 ms,  elapsed time = 370 ms.

    Table 'tCCI'. ..., lob logical reads 810, lob physical reads 0, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 47 ms,  elapsed time = 46 ms.

    Table 'tCCI'. ..., lob logical reads 810, lob physical reads 0, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 16 ms,  elapsed time = 4 ms.
*/

SET STATISTICS TIME, IO ON

SELECT RowID_Datetime, SUM(UnitPrice)
FROM dbo.tCCI
WHERE ISNULL(UnitPrice, 0) < 10000
GROUP BY RowID_Datetime
OPTION (RECOMPILE)

SELECT RowID_Datetime, SUM(UnitPrice)
FROM dbo.tCCI
WHERE COALESCE(UnitPrice, 0) < 10000
GROUP BY RowID_Datetime

SELECT RowID_Datetime, SUM(UnitPrice)
FROM dbo.tCCI
WHERE UnitPrice IS NULL OR UnitPrice < 10000
GROUP BY RowID_Datetime

SET STATISTICS TIME, IO OFF

/*
    Table 'tCCI'. ..., lob logical reads 562, lob physical reads 0, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 187 ms,  elapsed time = 187 ms.

    Table 'tCCI'. ..., lob logical reads 562, lob physical reads 0, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 94 ms,  elapsed time = 101 ms.

    Table 'tCCI'. ..., lob logical reads 562, lob physical reads 0, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 31 ms,  elapsed time = 26 ms.
*/