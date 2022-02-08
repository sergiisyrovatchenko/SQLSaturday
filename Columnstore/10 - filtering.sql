USE CCI
GO

DROP TABLE IF EXISTS #Param

SELECT DISTINCT TOP(60) RowID_Datetime -- TOP(70)
INTO #Param
FROM dbo.tCCI

SET STATISTICS IO, TIME ON

DECLARE @ID MONEY
SELECT @ID = SUM(UnitPrice)
FROM dbo.tCCI
WHERE RowID_Datetime IN (SELECT * FROM #Param)
GROUP BY CustomerID
OPTION(MAXDOP 1)

DECLARE @SQL NVARCHAR(MAX) = '
DECLARE @ID MONEY
SELECT @ID = SUM(UnitPrice)
FROM dbo.tCCI
WHERE RowID_Datetime IN (' + 
    (SELECT STRING_AGG('''' + CAST(CONVERT(CHAR(8), RowID_Datetime, 112) AS VARCHAR(MAX)) + '''', ',') FROM #Param) 
+ ')
GROUP BY CustomerID
OPTION(MAXDOP 1)
'

EXEC sys.sp_executesql @SQL

SET STATISTICS IO, TIME OFF

/*
    SQL Server Execution Times:
        CPU time = 125 ms,  elapsed time = 131 ms.

    SQL Server Execution Times:
        CPU time = 78 ms,  elapsed time = 65 ms.
*/