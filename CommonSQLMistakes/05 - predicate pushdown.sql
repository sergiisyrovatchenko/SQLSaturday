USE test
GO

SET STATISTICS IO, TIME ON

/*
    CREATE NONCLUSTERED INDEX ix ON big_table (B, C)

    DROP INDEX ix ON big_table
*/

SELECT TOP(1) A
FROM big_table
WHERE B = 'X'
    OR C = 0

SELECT TOP(1) *
FROM (
    SELECT TOP(1) A
    FROM big_table
    WHERE B = 'X'

    UNION ALL

    SELECT TOP(1) A
    FROM big_table
    WHERE C = 0
) t

/*
    Table 'big_table'. Scan count 1, logical reads 3726, ...
        CPU time = 781 ms,  elapsed time = 792 ms.

    Table 'big_table'. Scan count 1, logical reads 6, ...
        CPU time = 0 ms,  elapsed time = 98 ms.
*/

/*
    DROP INDEX ix ON big_table
*/

SELECT TOP(1) A
FROM big_table
WHERE B = 'X'
OPTION(QUERYTRACEON 9130)

SELECT TOP(1) A
FROM big_table
WHERE C = 0
OPTION(QUERYTRACEON 9130)

/*
    CREATE NONCLUSTERED INDEX ix1 ON big_table (C)
    CREATE NONCLUSTERED INDEX ix2 ON big_table (B)

    DROP INDEX ix1 ON big_table
    DROP INDEX ix2 ON big_table
*/

------------------------------------------------------------------

SELECT DISTINCT A
FROM big_table
WHERE B = 'X'
    OR C = 0

SELECT A
FROM big_table
WHERE B = 'X'
    UNION
SELECT A
FROM big_table
WHERE C = 0

/*
    Table 'big_table'. Scan count 2, logical reads 7, ...
        CPU time = 16 ms, elapsed time = 0 ms

    Table 'big_table'. Scan count 2, logical reads 7, ...
        CPU time = 0 ms, elapsed time = 0 ms
*/
