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
       CPU time = 703 ms,  elapsed time = 828 ms.

    Table 'tNoCompress'. Scan count 1, logical reads 101434, physical reads 1, read-ahead reads 101435, ...
    SQL Server Execution Times:
       CPU time = 579 ms,  elapsed time = 734 ms.

    Table 'tRowCompress'. Scan count 1, logical reads 58658, physical reads 1, read-ahead reads 58651, ...
    SQL Server Execution Times:
       CPU time = 625 ms,  elapsed time = 733 ms.

    Table 'tPageCompress'. Scan count 1, logical reads 25925, physical reads 1, read-ahead reads 25923, ...
    SQL Server Execution Times:
       CPU time = 640 ms,  elapsed time = 751 ms.

    Table 'tCCI'. ..., lob logical reads 1454, lob physical reads 2, lob read-ahead reads 3401.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 15 ms,  elapsed time = 15 ms.

    Table 'tCCIArch'. ..., lob logical reads 654, lob physical reads 4, lob read-ahead reads 329.
    Table 'tCCIArch'. Segment reads 8, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 16 ms,  elapsed time = 27 ms.
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
       CPU time = 500 ms,  elapsed time = 575 ms.

    Table 'tNoCompress'. Scan count 1, logical reads 101434, physical reads 1, read-ahead reads 101435, ...
    SQL Server Execution Times:
       CPU time = 329 ms,  elapsed time = 495 ms.

    Table 'tRowCompress'. Scan count 1, logical reads 58658, physical reads 1, read-ahead reads 58651, ...
    SQL Server Execution Times:
       CPU time = 312 ms,  elapsed time = 355 ms.

    Table 'tPageCompress'. Scan count 1, logical reads 25925, physical reads 1, read-ahead reads 25923, ...
    SQL Server Execution Times:
       CPU time = 234 ms,  elapsed time = 242 ms.

    Table 'tCCI'. ..., lob logical reads 43, lob physical reads 1, lob read-ahead reads 0.
    Table 'tCCI'. Segment reads 7, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 2 ms.

    Table 'tCCIArch'. ..., lob logical reads 18, lob physical reads 1, lob read-ahead reads 0.
    Table 'tCCIArch'. Segment reads 8, segment skipped 0.
    SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 1 ms.
*/

DBCC DROPCLEANBUFFERS
SET STATISTICS IO, TIME ON

DECLARE @ID INT
SELECT @ID = COUNT(*) FROM dbo.tHeap         GROUP BY RowID_Datetime OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tNoCompress   GROUP BY RowID_Datetime OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tRowCompress  GROUP BY RowID_Datetime OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tPageCompress GROUP BY RowID_Datetime OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tCCI          GROUP BY RowID_Datetime OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tCCIArch      GROUP BY RowID_Datetime OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF
GO

/*
    SQL Server Execution Times:
        CPU time = 672 ms,  elapsed time = 730 ms.

    SQL Server Execution Times:
        CPU time = 594 ms,  elapsed time = 639 ms.

    SQL Server Execution Times:
        CPU time = 578 ms,  elapsed time = 631 ms.

    SQL Server Execution Times:
        CPU time = 484 ms,  elapsed time = 527 ms.

    SQL Server Execution Times:
        CPU time = 16 ms,  elapsed time = 14 ms.

    SQL Server Execution Times:
        CPU time = 15 ms,  elapsed time = 25 ms.
*/

DBCC DROPCLEANBUFFERS
SET STATISTICS IO, TIME ON

DECLARE @ID INT
SELECT @ID = COUNT(*) FROM dbo.tHeap         GROUP BY RowID / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tNoCompress   GROUP BY RowID / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tRowCompress  GROUP BY RowID / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tPageCompress GROUP BY RowID / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tCCI          GROUP BY RowID / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tCCIArch      GROUP BY RowID / 100 OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF
GO

/*
    SQL Server Execution Times:
       CPU time = 656 ms,  elapsed time = 746 ms.

    SQL Server Execution Times:
       CPU time = 610 ms,  elapsed time = 685 ms.

    SQL Server Execution Times:
       CPU time = 515 ms,  elapsed time = 639 ms.

    SQL Server Execution Times:
       CPU time = 531 ms,  elapsed time = 534 ms.

    SQL Server Execution Times:
       CPU time = 63 ms,  elapsed time = 86 ms.

    SQL Server Execution Times:
       CPU time = 141 ms,  elapsed time = 153 ms.
*/

DBCC DROPCLEANBUFFERS
SET STATISTICS IO, TIME ON

DECLARE @ID INT
SELECT @ID = COUNT(*) FROM dbo.tHeap         GROUP BY RowID_Varchar / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tNoCompress   GROUP BY RowID_Varchar / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tRowCompress  GROUP BY RowID_Varchar / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tPageCompress GROUP BY RowID_Varchar / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tCCI          GROUP BY RowID_Varchar / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tCCIArch      GROUP BY RowID_Varchar / 100 OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF
GO

/*
    SQL Server Execution Times:
       CPU time = 1016 ms,  elapsed time = 1140 ms.

    SQL Server Execution Times:
       CPU time = 1015 ms,  elapsed time = 1067 ms.

    SQL Server Execution Times:
       CPU time = 782 ms,  elapsed time = 911 ms.

    SQL Server Execution Times:
       CPU time = 781 ms,  elapsed time = 813 ms.

    SQL Server Execution Times:
       CPU time = 860 ms,  elapsed time = 937 ms.

    SQL Server Execution Times:
       CPU time = 781 ms,  elapsed time = 832 ms.
*/

DBCC DROPCLEANBUFFERS
SET STATISTICS IO, TIME ON

DECLARE @ID INT
SELECT @ID = COUNT(*) FROM dbo.tHeap         GROUP BY RowID_NVarcharMax / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tNoCompress   GROUP BY RowID_NVarcharMax / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tRowCompress  GROUP BY RowID_NVarcharMax / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tPageCompress GROUP BY RowID_NVarcharMax / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tCCI          GROUP BY RowID_NVarcharMax / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tCCIArch      GROUP BY RowID_NVarcharMax / 100 OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF
GO

/*
    SQL Server Execution Times:
       CPU time = 1516 ms,  elapsed time = 1554 ms.

    SQL Server Execution Times:
       CPU time = 1437 ms,  elapsed time = 1514 ms.

    SQL Server Execution Times:
       CPU time = 1406 ms,  elapsed time = 1466 ms.

    SQL Server Execution Times:
       CPU time = 1329 ms,  elapsed time = 1325 ms.

    SQL Server Execution Times:
       CPU time = 750 ms,  elapsed time = 793 ms.

    SQL Server Execution Times:
       CPU time = 875 ms,  elapsed time = 901 ms.
*/

DBCC DROPCLEANBUFFERS
SET STATISTICS IO, TIME ON

DECLARE @ID INT
SELECT @ID = COUNT(*) FROM dbo.tHeap         GROUP BY CAST(RowID_NVarcharMax AS INT) / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tNoCompress   GROUP BY CAST(RowID_NVarcharMax AS INT) / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tRowCompress  GROUP BY CAST(RowID_NVarcharMax AS INT) / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tPageCompress GROUP BY CAST(RowID_NVarcharMax AS INT) / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tCCI          GROUP BY CAST(RowID_NVarcharMax AS INT) / 100 OPTION(MAXDOP 1)
SELECT @ID = COUNT(*) FROM dbo.tCCIArch      GROUP BY CAST(RowID_NVarcharMax AS INT) / 100 OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF
GO

/*
    SQL Server Execution Times:
       CPU time = 1672 ms,  elapsed time = 1736 ms.

    SQL Server Execution Times:
       CPU time = 1484 ms,  elapsed time = 1649 ms.

    SQL Server Execution Times:
       CPU time = 1484 ms,  elapsed time = 1615 ms.

    SQL Server Execution Times:
       CPU time = 1360 ms,  elapsed time = 1420 ms.

    SQL Server Execution Times:
       CPU time = 890 ms,  elapsed time = 933 ms.

    SQL Server Execution Times:
       CPU time = 907 ms,  elapsed time = 948 ms.
*/

DBCC DROPCLEANBUFFERS
SET STATISTICS IO, TIME ON

SELECT SUM(OrderQty) FROM dbo.tHeap         OPTION(MAXDOP 1)
SELECT SUM(OrderQty) FROM dbo.tNoCompress   OPTION(MAXDOP 1)
SELECT SUM(OrderQty) FROM dbo.tRowCompress  OPTION(MAXDOP 1)
SELECT SUM(OrderQty) FROM dbo.tPageCompress OPTION(MAXDOP 1)
SELECT SUM(OrderQty) FROM dbo.tCCI          OPTION(MAXDOP 1)
SELECT SUM(OrderQty) FROM dbo.tCCIArch      OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF

/*
    SQL Server Execution Times:
       CPU time = 657 ms,  elapsed time = 743 ms.

    SQL Server Execution Times:
       CPU time = 562 ms,  elapsed time = 679 ms.

    SQL Server Execution Times:
       CPU time = 641 ms,  elapsed time = 653 ms.

    SQL Server Execution Times:
       CPU time = 437 ms,  elapsed time = 482 ms.

    SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 2 ms.

    SQL Server Execution Times:
       CPU time = 0 ms,  elapsed time = 2 ms.
*/

DBCC DROPCLEANBUFFERS
SET STATISTICS IO, TIME ON

SELECT SUM(CAST(OrderQty * 1. AS BIGINT)) FROM dbo.tHeap         OPTION(MAXDOP 1)
SELECT SUM(CAST(OrderQty * 1. AS BIGINT)) FROM dbo.tNoCompress   OPTION(MAXDOP 1)
SELECT SUM(CAST(OrderQty * 1. AS BIGINT)) FROM dbo.tRowCompress  OPTION(MAXDOP 1)
SELECT SUM(CAST(OrderQty * 1. AS BIGINT)) FROM dbo.tPageCompress OPTION(MAXDOP 1)
SELECT SUM(CAST(OrderQty * 1. AS BIGINT)) FROM dbo.tCCI          OPTION(MAXDOP 1)
SELECT SUM(CAST(OrderQty * 1. AS BIGINT)) FROM dbo.tCCIArch      OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF

/*
    SQL Server Execution Times:
       CPU time = 797 ms,  elapsed time = 867 ms.

    SQL Server Execution Times:
       CPU time = 609 ms,  elapsed time = 717 ms.

    SQL Server Execution Times:
       CPU time = 609 ms,  elapsed time = 647 ms.

    SQL Server Execution Times:
       CPU time = 485 ms,  elapsed time = 506 ms.

    SQL Server Execution Times:
       CPU time = 31 ms,  elapsed time = 24 ms.

    SQL Server Execution Times:
       CPU time = 16 ms,  elapsed time = 27 ms.
*/