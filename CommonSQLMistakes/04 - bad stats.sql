USE test
GO

ALTER INDEX ix ON big_table REBUILD
GO

UPDATE TOP(99) PERCENT big_table
SET B = 'A'
WHERE B = 'Z'
GO

SELECT B, COUNT_BIG(1)
FROM big_table
GROUP BY B

------------------------------------------------------------------

SELECT *
FROM big_table
WHERE B = 'C'
OPTION(MAXDOP 1)

SELECT *
FROM big_table
WHERE B = 'X'
OPTION(MAXDOP 1)

SELECT *
FROM big_table
WHERE B = 'Z'
OPTION(MAXDOP 1)

/*
    CREATE NONCLUSTERED INDEX ix2 ON big_table (B)
        INCLUDE (A, C, D, E, F)

    SELECT i.name, a.total_pages * 8. / 1024
    FROM sys.indexes i
    LEFT JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
    LEFT JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
    WHERE i.[object_id] = OBJECT_ID('big_table')

    DROP INDEX ix2 ON big_table
*/

------------------------------------------------------------------

DECLARE @t TABLE (A INT)

INSERT INTO @t
SELECT A
FROM big_table
WHERE B = 'Z'

SELECT *
FROM big_table
WHERE A IN (SELECT * FROM @t)