USE test
GO

SELECT COUNT(1) FROM big_table WHERE B = 'A'
UNION ALL
SELECT COUNT(1) FROM big_table WHERE B = 'B'
UNION ALL
SELECT COUNT(1) FROM big_table WHERE B = 'X'
UNION ALL
SELECT COUNT(1) FROM big_table WHERE B = 'Z'

/*
    20% + 500 rows
    DBCC SHOW_STATISTICS('dbo.big_table', 'ix') WITH HISTOGRAM

    For 2008R2 SP1+ use -T2371
    SQL Server 2016: ON

    < 25k   = 20%
    > 30k   = 18%
    > 40k   = 15%
    > 100k  = 10%
    > 500k  = 5%
    > 1000k = 3.2%
*/

SELECT ROUND(SQRT(COUNT_BIG(*)), 2) FROM big_table

SELECT COUNT(1) FROM big_table WHERE B = 'Z' OPTION(QUERYTRACEON 2312)
SELECT COUNT(1) FROM big_table WHERE B = 'Z' OPTION(QUERYTRACEON 9481)

/*
    ALTER INDEX ix ON big_table REBUILD
    or
    UPDATE STATISTICS big_table ix WITH FULLSCAN
*/