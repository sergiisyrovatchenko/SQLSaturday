USE AdventureWorks2014
GO

/*
    CREATE NONCLUSTERED INDEX IX_PostTime ON dbo.DatabaseLog (PostTime)
*/

UPDATE TOP(1) dbo.DatabaseLog
SET PostTime = '20140716 12:12:12'

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE PostTime = '20140716'
OPTION(RECOMPILE)

------------------------------------------------------------------

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE CONVERT(CHAR(8), PostTime, 112) = '20140716'

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE CAST(PostTime AS DATE) = '20140716'

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE PostTime BETWEEN '20140716' AND '20140716 23:59:59.997'

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE PostTime >= '20140716' AND PostTime < '20140717'

------------------------------------------------------------------

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE CONVERT(CHAR(8), PostTime, 112) LIKE '201407%'

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE DATEPART(YEAR, PostTime) = 2014
    AND DATEPART(MONTH, PostTime) = 7

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE YEAR(PostTime) = 2014
    AND MONTH(PostTime) = 7

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE EOMONTH(PostTime) = '20140731'

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE PostTime >= '20140701' AND PostTime < '20140801'

------------------------------------------------------------------

IF COL_LENGTH('dbo.DatabaseLog', 'MonthLastDay') IS NOT NULL
    ALTER TABLE dbo.DatabaseLog DROP COLUMN MonthLastDay
GO

ALTER TABLE dbo.DatabaseLog
    ADD MonthLastDay AS EOMONTH(PostTime) --PERSISTED
GO

CREATE INDEX IX_MonthLastDay ON dbo.DatabaseLog (MonthLastDay)
GO

------------------------------------------------------------------

SET STATISTICS IO ON

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE PostTime >= '20140701' AND PostTime < '20140801'

SELECT COUNT_BIG(*)
FROM dbo.DatabaseLog
WHERE MonthLastDay = '20140731'

SET STATISTICS IO OFF