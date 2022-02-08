USE CCI
GO

SET STATISTICS IO, TIME ON

BEGIN TRANSACTION

UPDATE dbo.tCCI
SET OrderDate = OrderDate
WHERE RowID <= 2000000

SET STATISTICS IO, TIME OFF

/*
    Table 'tCCI'. Scan count 4, logical reads 8, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 127921, lob physical reads 279, lob page server reads 0, lob read-ahead reads 272323, lob page server read-ahead reads 0.
    Table 'tCCI'. Segment reads 23, segment skipped 5.
    Table 'Worktable'. Scan count 1, logical reads 12466652, physical reads 0, page server reads 0, read-ahead reads 83267, page server read-ahead reads 0, lob logical reads 2000000, lob physical reads 11, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

     SQL Server Execution Times:
       CPU time = 43907 ms,  elapsed time = 44679 ms.
*/

ROLLBACK

SET STATISTICS IO, TIME ON

DROP TABLE IF EXISTS #t

SELECT *
INTO #t
FROM dbo.tCCI
WHERE RowID <= 2000000

DELETE FROM dbo.tCCI
WHERE RowID <= 2000000

INSERT INTO dbo.tCCI
SELECT * FROM #t

SET STATISTICS IO, TIME OFF

/*
    Table 'tCCI'. Scan count 7, logical reads 46299, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 142614, lob physical reads 169, lob page server reads 0, lob read-ahead reads 219007, lob page server read-ahead reads 0.
    Table 'tCCI'. Segment reads 19, segment skipped 5.
     SQL Server Execution Times:
       CPU time = 5237 ms,  elapsed time = 1813 ms.

    Table 'tCCI'. Scan count 5, logical reads 29224, physical reads 0, page server reads 0, read-ahead reads 136, page server read-ahead reads 0, lob logical reads 5157, lob physical reads 0, lob page server reads 0, lob read-ahead reads 10694, lob page server read-ahead reads 0.
    Table 'tCCI'. Segment reads 23, segment skipped 5.
     SQL Server Execution Times:
       CPU time = 6422 ms,  elapsed time = 6439 ms.

    Table 'tCCI'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
    Table '#t'. Scan count 1, logical reads 44810, physical reads 0, page server reads 0, read-ahead reads 270, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
     SQL Server Execution Times:
       CPU time = 7547 ms,  elapsed time = 7905 ms.
*/