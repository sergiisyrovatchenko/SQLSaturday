USE CCI
GO

SET NOCOUNT ON
SET STATISTICS IO, TIME ON

SELECT *
FROM dbo.tCCI
WHERE RowID = 1

SELECT *
FROM dbo.tCCI
WHERE RowID_Varchar = '1' -- NUMERIC/DATETIMEOFFSET/[N]CHAR/[N]VARCHAR/VARBINARY/UNIQUEIDENTIFIER

SET STATISTICS IO, TIME OFF

/*
    Table 'tCCI'. ..., lob logical reads 3639, lob physical reads 0, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 1, segment skipped 6.
    SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 7 ms.

    Table 'tCCI'. ..., lob logical reads 21789, lob physical reads 0, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 766 ms,  elapsed time = 313 ms.
*/