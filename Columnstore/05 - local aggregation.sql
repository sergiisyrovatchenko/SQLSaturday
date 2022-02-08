USE CCI
GO

SET STATISTICS TIME, IO ON

SELECT MAX(RowID_Datetime)
FROM dbo.tCCI
OPTION(MAXDOP 1)

SELECT TOP(1) RowID_Datetime
FROM dbo.tCCI
ORDER BY RowID_Datetime DESC
OPTION(MAXDOP 1)

SELECT TOP(1) RowID_Datetime
FROM (
    SELECT DISTINCT RowID_Datetime
    FROM dbo.tCCI
) t
ORDER BY RowID_Datetime DESC
OPTION(MAXDOP 1)

SELECT RowID_Datetime
FROM (
    SELECT RowID_Datetime, RN = ROW_NUMBER() OVER (ORDER BY RowID_Datetime DESC)
    FROM dbo.tCCI
) t
WHERE RN = 1
OPTION(MAXDOP 1)

SET STATISTICS TIME, IO OFF

/*
    SQL Server Execution Times:
       CPU time = 16 ms,  elapsed time = 5 ms.

    SQL Server Execution Times:
       CPU time = 31 ms,  elapsed time = 34 ms.

    SQL Server Execution Times:
       CPU time = 47 ms,  elapsed time = 37 ms.

    SQL Server Execution Times:
       CPU time = 531 ms,  elapsed time = 531 ms.
*/