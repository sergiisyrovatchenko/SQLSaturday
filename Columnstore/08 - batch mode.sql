USE CCI
GO

DROP TABLE IF EXISTS dbo.CCI_Table
CREATE TABLE dbo.CCI_Table (_ INT, INDEX CCI CLUSTERED COLUMNSTORE)
GO

--ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = OFF -- ON = DEFAULT (2019)

SET STATISTICS IO, TIME ON

DECLARE @ID INT
SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
GROUP BY RowID / 100
OPTION(MAXDOP 1, USE HINT('DISALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
GROUP BY RowID / 100
OPTION(MAXDOP 1, USE HINT('ALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
LEFT JOIN dbo.CCI_Table ON 1=0
GROUP BY RowID / 100
OPTION(MAXDOP 1)

SELECT @ID = COUNT(*)
FROM dbo.tCCI
GROUP BY RowID / 100
OPTION(MAXDOP 1, USE HINT('ALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tCCI
GROUP BY RowID / 100
OPTION(MAXDOP 1, USE HINT('DISALLOW_BATCH_MODE'))

SET STATISTICS IO, TIME OFF
GO

/*
    SQL Server Execution Times:
       CPU time = 906 ms,  elapsed time = 902 ms.

    SQL Server Execution Times:
       CPU time = 437 ms,  elapsed time = 438 ms.

    SQL Server Execution Times:
       CPU time = 438 ms,  elapsed time = 430 ms.

    SQL Server Execution Times:
       CPU time = 63 ms,  elapsed time = 69 ms.

    SQL Server Execution Times:
       CPU time = 609 ms,  elapsed time = 605 ms.
*/

SET STATISTICS IO, TIME ON

DECLARE @ID INT
SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
GROUP BY RowID_Varchar / 100
OPTION(MAXDOP 1, USE HINT('DISALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
GROUP BY RowID_Varchar / 100
OPTION(MAXDOP 1, USE HINT('ALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
LEFT JOIN dbo.CCI_Table ON 1=0
GROUP BY RowID_Varchar / 100
OPTION(MAXDOP 1)

SELECT @ID = COUNT(*)
FROM dbo.tCCI
GROUP BY RowID_Varchar / 100
OPTION(MAXDOP 1, USE HINT('ALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tCCI
GROUP BY RowID_Varchar / 100
OPTION(MAXDOP 1, USE HINT('DISALLOW_BATCH_MODE'))

SET STATISTICS IO, TIME OFF
GO

/*
    SQL Server Execution Times:
       CPU time = 1203 ms,  elapsed time = 1210 ms.

    SQL Server Execution Times:
       CPU time = 734 ms,  elapsed time = 735 ms.

    SQL Server Execution Times:
       CPU time = 719 ms,  elapsed time = 736 ms.

    SQL Server Execution Times:
       CPU time = 609 ms,  elapsed time = 655 ms.

    SQL Server Execution Times:
       CPU time = 1141 ms,  elapsed time = 1157 ms.
*/

SET STATISTICS IO, TIME ON

DECLARE @ID INT
SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
GROUP BY RowID_NVarcharMax / 100
OPTION(MAXDOP 1, USE HINT('DISALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
GROUP BY RowID_NVarcharMax / 100
OPTION(MAXDOP 1, USE HINT('ALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
LEFT JOIN dbo.CCI_Table ON 1=0
GROUP BY RowID_NVarcharMax / 100
OPTION(MAXDOP 1)

SELECT @ID = COUNT(*)
FROM dbo.tCCI
GROUP BY RowID_NVarcharMax / 100
OPTION(MAXDOP 1, USE HINT('ALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tCCI
GROUP BY RowID_NVarcharMax / 100
OPTION(MAXDOP 1, USE HINT('DISALLOW_BATCH_MODE'))

SET STATISTICS IO, TIME OFF
GO

/*
    SQL Server Execution Times:
       CPU time = 1469 ms,  elapsed time = 1483 ms.

    SQL Server Execution Times:
       CPU time = 1328 ms,  elapsed time = 1327 ms.

    SQL Server Execution Times:
       CPU time = 1328 ms,  elapsed time = 1320 ms.

    SQL Server Execution Times:
       CPU time = 734 ms,  elapsed time = 734 ms.

    SQL Server Execution Times:
       CPU time = 1484 ms,  elapsed time = 1491 ms.
*/

SET STATISTICS IO, TIME ON

DECLARE @ID INT
SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
GROUP BY CAST(RowID_NVarcharMax AS INT) / 100
OPTION(MAXDOP 1, USE HINT('DISALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
GROUP BY CAST(RowID_NVarcharMax AS INT) / 100
OPTION(MAXDOP 1, USE HINT('ALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tRowCompress
LEFT JOIN dbo.CCI_Table ON 1=0
GROUP BY CAST(RowID_NVarcharMax AS INT) / 100
OPTION(MAXDOP 1)

SELECT @ID = COUNT(*)
FROM dbo.tCCI
GROUP BY CAST(RowID_NVarcharMax AS INT) / 100
OPTION(MAXDOP 1, USE HINT('ALLOW_BATCH_MODE'))

SELECT @ID = COUNT(*)
FROM dbo.tCCI
GROUP BY CAST(RowID_NVarcharMax AS INT) / 100
OPTION(MAXDOP 1, USE HINT('DISALLOW_BATCH_MODE'))

SET STATISTICS IO, TIME OFF

/*
    SQL Server Execution Times:
       CPU time = 1594 ms,  elapsed time = 1590 ms.

    SQL Server Execution Times:
       CPU time = 1297 ms,  elapsed time = 1359 ms.

    SQL Server Execution Times:
       CPU time = 1312 ms,  elapsed time = 1338 ms.

    SQL Server Execution Times:
       CPU time = 657 ms,  elapsed time = 697 ms.

    SQL Server Execution Times:
       CPU time = 1406 ms,  elapsed time = 1482 ms.
*/