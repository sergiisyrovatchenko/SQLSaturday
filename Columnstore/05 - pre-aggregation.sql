USE CCI
GO

SET NOCOUNT ON
SET STATISTICS IO, TIME ON

SELECT EOMONTH(RowID_Datetime), Cnt = COUNT(*)
FROM dbo.tCCI
GROUP BY EOMONTH(RowID_Datetime)

SELECT EOMONTH(RowID_Datetime), Cnt = SUM(Cnt)
FROM (
    SELECT RowID_Datetime, Cnt = COUNT(*)
    FROM dbo.tCCI
    GROUP BY RowID_Datetime
) t
GROUP BY EOMONTH(RowID_Datetime)

SET STATISTICS IO, TIME OFF

/*
    Table 'tCCI'. ..., lob logical reads 425, lob physical reads 0, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 454 ms,  elapsed time = 474 ms.

    Table 'tCCI'. ..., lob logical reads 425, lob physical reads 0, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 16 ms,  elapsed time = 13 ms.
*/