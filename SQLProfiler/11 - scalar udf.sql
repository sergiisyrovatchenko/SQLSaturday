USE Users
GO

SET NOCOUNT ON

/*
    EXEC dbo.GetStatisticsByCity @City = 'London'
    GO

    EXEC dbo.GetStatisticsByCity @City = 'Berlin'
    GO

    Table 'Users'. Scan count 2, logical reads 24919, ...
        CPU time = 3453 ms, elapsed time = 3497 ms

    Table 'Users'. Scan count 2, logical reads 24485, ...
        CPU time = 2532 ms, elapsed time = 2572 ms
*/

------------------------------------------------------

/*
    SQL Profiler: SQL:StmtStarting + SP:StmtCompleted
    XEvent:       sp_statement_starting + sp_statement_completed
*/

SET STATISTICS IO, TIME ON

SELECT dbo.GetEOMonth(CreatedDate), COUNT_BIG(*)
FROM dbo.Users
WHERE City = 'London'
GROUP BY dbo.GetEOMonth(CreatedDate)
OPTION(MAXDOP 4, RECOMPILE)

SELECT EOMONTH(CreatedDate), COUNT_BIG(*)
FROM dbo.Users
WHERE City = 'London'
GROUP BY EOMONTH(CreatedDate)
OPTION(MAXDOP 4, RECOMPILE)

SET STATISTICS IO, TIME OFF

/*
    Table 'Users'. Scan count 2, logical reads 24919, ...
        CPU time = 3172 ms, elapsed time = 3213 ms

    Table 'Users'. Scan count 10, logical reads 25149, ...
        CPU time = 969 ms, elapsed time = 250 ms
*/

------------------------------------------------------

ALTER PROCEDURE dbo.GetStatisticsByCity
(
    @City VARCHAR(30)
)
AS BEGIN

    SELECT [Month] = EOMONTH(CreatedDate)
         , Cnt = COUNT_BIG(*)
    FROM dbo.Users
    WHERE City = @City
    GROUP BY EOMONTH(CreatedDate)
    ORDER BY Cnt DESC
    OPTION(MAXDOP 4, RECOMPILE)

END
GO

/*
    Table 'Users'. Scan count 10, logical reads 25149, ...
        CPU time = 937 ms,  elapsed time = 254 ms.

    Table 'Users'. Scan count 10, logical reads 24693, ...
        CPU time = 656 ms,  elapsed time = 191 ms.
*/