SET NOCOUNT ON

USE AdventureWorks2014
GO

DROP TABLE IF EXISTS #DatabaseLog
CREATE TABLE #DatabaseLog (
      DatabaseLogID INT PRIMARY KEY
    , XmlData XML COLUMN_SET FOR ALL_SPARSE_COLUMNS
    , EventType VARCHAR(100) SPARSE NULL
    , TSQLCommand XML SPARSE NULL 
)

INSERT INTO #DatabaseLog(DatabaseLogID, XmlData)
SELECT DatabaseLogID
     , XmlEvent.query('/EVENT_INSTANCE/*[local-name(.) = "EventType" or local-name(.) = "TSQLCommand"]')
FROM dbo.DatabaseLog

SELECT DatabaseLogID
     , XmlData
     , EventType
     , TSQLCommand
FROM #DatabaseLog
GO

------------------------------------------------------

SELECT DatabaseLogID
FROM #DatabaseLog
WHERE EventType = 'CREATE_PROCEDURE'
--OPTION (QUERYTRACEON 9130)

------------------------------------------------------

/*
    DROP INDEX ix ON dbo.DatabaseLog
*/

CREATE NONCLUSTERED INDEX ix ON #DatabaseLog (EventType)
GO

------------------------------------------------------

SET STATISTICS IO, TIME ON

SELECT EventType, COUNT_BIG(*)
FROM #DatabaseLog WITH(INDEX(1))
GROUP BY EventType

SELECT EventType, COUNT_BIG(*)
FROM #DatabaseLog
GROUP BY EventType

SET STATISTICS IO, TIME OFF