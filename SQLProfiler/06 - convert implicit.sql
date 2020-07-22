USE Users
GO

SET NOCOUNT ON

/*
    DBCC FREEPROCCACHE
    DBCC DROPCLEANBUFFERS
*/

/*
    EXEC sys.sp_executesql N'SELECT COUNT(*), COUNT(DISTINCT FirstName)
                             FROM dbo.Users
                             WHERE City = @City', N'@City NVARCHAR(7)', @City = N'Kharkiv'
*/

SET STATISTICS IO, TIME ON

SELECT COUNT(*) FROM dbo.Users WHERE City = N'Kharkiv'

SELECT COUNT(*) FROM dbo.Users WHERE City = 'Kharkiv'

SET STATISTICS IO, TIME OFF

/*
    Table 'Users'. Scan count 3, logical reads 214276, ...
        CPU time = 2079 ms, elapsed time = 1083 ms

    Table 'Users'. Scan count 3, logical reads 214376, ...
        CPU time = 1030 ms, elapsed time = 555 ms
*/

------------------------------------------------------

DROP INDEX IF EXISTS IX_City ON dbo.Users
GO

CREATE NONCLUSTERED INDEX IX_City ON dbo.Users (City)
GO

/*
    Table 'Users'. Scan count 3, logical reads 42452, ...
        CPU time = 1985 ms, elapsed time = 1007 ms

    Table 'Users'. Scan count 1, logical reads 4, ...
        CPU time = 0 ms, elapsed time = 1 ms
*/

------------------------------------------------------

DROP TABLE IF EXISTS #win_collation
DROP TABLE IF EXISTS #SQL_Latin1_General_CP1_CI_AS
GO

CREATE TABLE #win_collation (txt VARCHAR(40) COLLATE Latin1_General_100_CI_AS PRIMARY KEY)
CREATE TABLE #sql_collation (txt VARCHAR(40) COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY)
GO

INSERT INTO #win_collation
SELECT ISNULL([name], 'NULL') + CAST(ROW_NUMBER() OVER (ORDER BY 1/0) AS VARCHAR(10))
FROM [master].dbo.spt_values
CROSS APPLY (VALUES (1), (2), (3), (4), (5)) t(x)

INSERT INTO #sql_collation
SELECT *
FROM #win_collation

------------------------------------------------------

SET STATISTICS IO ON

SELECT * FROM #win_collation WHERE txt LIKE 'NULL%'
SELECT * FROM #sql_collation WHERE txt LIKE 'NULL%'

SELECT * FROM #win_collation WHERE txt LIKE N'NULL%'
SELECT * FROM #sql_collation WHERE txt LIKE N'NULL%'

SET STATISTICS IO OFF

/*
    Table '#win_collation'. Scan count 1, logical reads 29, ...
    Table '#sql_collation'. Scan count 1, logical reads 29, ...

    Table '#win_collation'. Scan count 1, logical reads 29, ...
    Table '#sql_collation'. Scan count 1, logical reads 38, ...
*/