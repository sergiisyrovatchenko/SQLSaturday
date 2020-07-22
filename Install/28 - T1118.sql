USE tempdb
GO

https://www.sqlskills.com/blogs/paul/misconceptions-around-tf-1118/

--DBCC TRACEON(1118, 3605, -1) WITH NO_INFOMSGS

IF OBJECT_ID('tempdb.dbo.#t') IS NOT NULL
    DROP TABLE #t
GO

CREATE TABLE #t (ID INT DEFAULT 1)
GO

CHECKPOINT
GO

INSERT #t DEFAULT VALUES
GO

--DBCC TRACEOFF(1118, 3605, -1) WITH NO_INFOMSGS
--GO


-- MixedExtent vs FullExtent

SELECT [Current LSN], Operation, Context, AllocUnitName, [Description]
FROM sys.fn_dblog(NULL, NULL)

/*
    SQL Server 2016: ON

    ALTER DATABASE db SET MIXED_PAGE_ALLOCATION OFF
*/

/*
    PAGELATCH_*
*/