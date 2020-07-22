SET NOCOUNT ON

IF OBJECT_ID('tempdb.dbo.#temp') IS NOT NULL
    DROP TABLE #temp
GO

CREATE TABLE #temp (x XML)
INSERT INTO #temp
SELECT (
        SELECT TOP (3000) a1  = 1, b2  = 1, b3  = 1
                        , b4  = 1, b5  = 1, b6  = 1
                        , b7  = 1, b8  = 1, b9  = 1
                        , b10 = 1, b11 = 1, b12 = 1
                        , b13 = 1, b14 = 1, b15 = 1
                        , b16 = 1, b17 = 1, b18 = 1
                        , b19 = 1, b20 = 1, b21 = 1
                        , b22 = 1, b23 = 1, b24 = 1
                        , b25 = 1, b26 = 1, b27 = 1
                        , b28 = '', b29 = '', b30 = '' -- empty nodes
        FROM sys.all_columns
        FOR XML PATH ('row')
    )
GO

------------------------------------------------------

DECLARE @x XML = (SELECT * FROM #temp)

SET STATISTICS IO, TIME ON

    SET @x.modify('delete row/*[not(node())]')

SET STATISTICS IO, TIME OFF

SELECT @x
GO

/*
    Table 'Worktable'. Scan count 1, logical reads 5955369, ...
        CPU time = 355938 ms, elapsed time = 357984 ms
*/

------------------------------------------------------

DECLARE @x XML = (SELECT * FROM #temp)

SET STATISTICS IO, TIME ON

    DECLARE @t TABLE (x XML)
    INSERT INTO @t
    SELECT t.c.query('.')
    FROM @x.nodes('row') t(c)

    /*
        Table '#B17CF94C'. Scan count 0, logical reads 3214, ...
            CPU time = 250 ms, elapsed time = 242 ms
    */

    UPDATE @t
    SET x.modify('delete //*[not(node())]')

    /*
        Table '#B17CF94C'. Scan count 1, logical reads 3215, ...
        Table 'Worktable'. Scan count 3000, logical reads 366000, ...
            CPU time = 1016 ms, elapsed time = 1032 ms
    */

    SET @x = (SELECT [*] = x FROM @t FOR XML PATH (''))

    /*
        Table '#B17CF94C'. Scan count 1, logical reads 215, ...
        Table 'Worktable'. Scan count 0, logical reads 11, ..., lob logical reads 6918, ...
            CPU time = 93 ms, elapsed time = 97 ms
    */

SET STATISTICS IO, TIME OFF

SELECT @x
GO

------------------------------------------------------

DECLARE @x XML = (SELECT * FROM #temp)

SET STATISTICS IO, TIME ON

    DECLARE @t TABLE (x XML)
    INSERT INTO @t SELECT @x

    /*
        Table '#B54D8A30'. Scan count 0, logical reads 1, ..., lob logical reads 216, ...
            CPU time = 2 ms, elapsed time = 4 ms
    */

    UPDATE @t
    SET x.modify('delete //*[not(node())]')
    OPTION (QUERYTRACEON 8690) -- turn off table spool

    /*
        Table '#B54D8A30'. Scan count 1, logical reads 2, ..., read-ahead reads 0, lob logical reads 454, ...
        Table 'Worktable'. Scan count 0, logical reads 21, ..., read-ahead reads 754, lob logical reads 3169, ...
            CPU time = 500 ms, elapsed time = 508 ms
    */

    SELECT @x = x FROM @t

    /*
        Table '#B54D8A30'. Scan count 1, logical reads 1, ...
            CPU time = 0 ms, elapsed time = 1 ms
    */

SET STATISTICS IO, TIME OFF

SELECT @x
GO

------------------------------------------------------

DECLARE @x XML = (SELECT * FROM #temp)

SET STATISTICS IO, TIME ON

    SELECT [*] = t.c.query('*[node()]')
    FROM @x.nodes('row') t(c)
    FOR XML PATH ('row')

    /*
        CPU time = 735 ms, elapsed time = 776 ms
    */

SET STATISTICS IO, TIME OFF

SELECT @x