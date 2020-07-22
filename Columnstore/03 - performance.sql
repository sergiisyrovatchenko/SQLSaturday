USE CCI

DBCC DROPCLEANBUFFERS
SET STATISTICS IO, TIME ON

SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tHeap         OPTION(MAXDOP 1)
SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tNoCompress   OPTION(MAXDOP 1)
SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tRowCompress  OPTION(MAXDOP 1)
SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tPageCompress OPTION(MAXDOP 1)
SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tCCI          OPTION(MAXDOP 1)
SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tCCIArch      OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF

/*
    Table 'tHeap'. Scan count 1, logical reads 100328, physical reads 0, read-ahead reads 100328, ...
    SQL Server Execution Times:
       CPU time = 1219 ms,  elapsed time = 1487 ms.

    Table 'tNoCompress'. Scan count 1, logical reads 101434, physical reads 1, read-ahead reads 101435, ...
    SQL Server Execution Times:
       CPU time = 1093 ms,  elapsed time = 1347 ms.

    Table 'tRowCompress'. Scan count 1, logical reads 58658, physical reads 1, read-ahead reads 58651, ...
    SQL Server Execution Times:
       CPU time = 1469 ms,  elapsed time = 1718 ms.

    Table 'tPageCompress'. Scan count 1, logical reads 25925, physical reads 1, read-ahead reads 25923, ...
    SQL Server Execution Times:
       CPU time = 1578 ms,  elapsed time = 1681 ms.

    Table 'tCCI'. ..., lob logical reads 1454, lob physical reads 2, lob read-ahead reads 3401.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 16 ms,  elapsed time = 23 ms.

    Table 'tCCIArch'. ..., lob logical reads 654, lob physical reads 4, lob read-ahead reads 329.
    Table 'tCCIArch'. Segment reads 8, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 31 ms,  elapsed time = 32 ms.
*/

---------------------------------------------------------------------------------------------------------

DBCC DROPCLEANBUFFERS
SET STATISTICS IO, TIME ON

SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tHeap         OPTION(MAXDOP 4, QUERYTRACEON 8649)
SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tNoCompress   OPTION(MAXDOP 4, QUERYTRACEON 8649)
SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tRowCompress  OPTION(MAXDOP 4, QUERYTRACEON 8649)
SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tPageCompress OPTION(MAXDOP 4, QUERYTRACEON 8649)
SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tCCI          OPTION(MAXDOP 4, QUERYTRACEON 8649)
SELECT COUNT(*), MIN(OrderDate), MAX(OrderDate), AVG(UnitPrice) FROM dbo.tCCIArch      OPTION(MAXDOP 4, QUERYTRACEON 8649)

SET STATISTICS IO, TIME OFF

/*
    Table 'tHeap'. Scan count 5, logical reads 100328, physical reads 0, read-ahead reads 100328, ...
    SQL Server Execution Times:
       CPU time = 1140 ms,  elapsed time = 411 ms.

    Table 'tNoCompress'. Scan count 5, logical reads 102444, physical reads 1, read-ahead reads 101436, ...
    SQL Server Execution Times:
       CPU time = 1251 ms,  elapsed time = 371 ms.

    Table 'tRowCompress'. Scan count 5, logical reads 59092, physical reads 1, read-ahead reads 58655, ...
    SQL Server Execution Times:
       CPU time = 1500 ms,  elapsed time = 455 ms.

    Table 'tPageCompress'. Scan count 5, logical reads 26115, physical reads 1, read-ahead reads 25926, ...
    SQL Server Execution Times:
       CPU time = 1641 ms,  elapsed time = 460 ms.

    Table 'tCCI'. ..., lob logical reads 1471, lob physical reads 2, lob read-ahead reads 3401.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 15 ms,  elapsed time = 9 ms.

    Table 'tCCIArch'. ..., lob logical reads 666, lob physical reads 4, lob read-ahead reads 329.
    Table 'tCCIArch'. Segment reads 8, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 15 ms,  elapsed time = 15 ms.
*/

---------------------------------------------------------------------------------------------------------

DBCC DROPCLEANBUFFERS
SET STATISTICS IO, TIME ON

SELECT COUNT(*) FROM dbo.tHeap         OPTION(MAXDOP 1)
SELECT COUNT(*) FROM dbo.tNoCompress   OPTION(MAXDOP 1)
SELECT COUNT(*) FROM dbo.tRowCompress  OPTION(MAXDOP 1)
SELECT COUNT(*) FROM dbo.tPageCompress OPTION(MAXDOP 1)
SELECT COUNT(*) FROM dbo.tCCI          OPTION(MAXDOP 1)
SELECT COUNT(*) FROM dbo.tCCIArch      OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF

/*
    Table 'tHeap'. Scan count 1, logical reads 100328, physical reads 0, read-ahead reads 100328, ...
    SQL Server Execution Times:
       CPU time = 343 ms,  elapsed time = 743 ms.

    Table 'tNoCompress'. Scan count 1, logical reads 101434, physical reads 1, read-ahead reads 101435, ...
    SQL Server Execution Times:
       CPU time = 407 ms,  elapsed time = 674 ms.

    Table 'tRowCompress'. Scan count 1, logical reads 58658, physical reads 1, read-ahead reads 58651, ...
    SQL Server Execution Times:
       CPU time = 281 ms,  elapsed time = 659 ms.

    Table 'tPageCompress'. Scan count 1, logical reads 25925, physical reads 1, read-ahead reads 25923, ...
    SQL Server Execution Times:
       CPU time = 312 ms,  elapsed time = 500 ms.

    Table 'tCCI'. ..., lob logical reads 43, lob physical reads 1, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 2 ms.

    Table 'tCCIArch'. ..., lob logical reads 18, lob physical reads 1, lob read-ahead reads 0.
    Table 'tCCIArch'. Segment reads 8, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 1 ms.
*/