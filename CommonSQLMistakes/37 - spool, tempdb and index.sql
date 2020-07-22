DROP TABLE IF EXISTS #Values
CREATE TABLE #Values (
      Key1 DATE
    , Key2 DATE
    , Val INT
    , PRIMARY KEY (Key1, Key2)
)
GO

INSERT INTO #Values
VALUES ('20170102', '20170103', 1)
     , ('20170204', '20170206', 2)
     , ('20170407', '20170408', 3)
GO

DECLARE @StartDate DATE
      , @EndDate DATE

SELECT @StartDate = MIN(Key1)
     , @EndDate = MAX(Key2)
FROM #Values

DROP TABLE IF EXISTS #Dates
--CREATE TABLE #Dates ([Date] DATE PRIMARY KEY)
CREATE TABLE #Dates ([Date] DATE)

INSERT INTO #Dates
SELECT TOP(DATEDIFF(DAY, @StartDate, @EndDate) + 1)
    DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY 1/0) - 1, @StartDate)
FROM [master].dbo.spt_values
GO

SELECT d.[Date], v.Val
FROM #Values v
JOIN #Dates d ON d.[Date] BETWEEN v.Key1 AND v.Key2
