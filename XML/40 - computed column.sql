SET NOCOUNT ON

USE tempdb
GO

DROP TABLE IF EXISTS #DatabaseLog
CREATE TABLE #DatabaseLog (
      DatabaseLogID INT PRIMARY KEY
    , XmlData XML
)

INSERT INTO #DatabaseLog
SELECT DatabaseLogID
     , XmlEvent
FROM AdventureWorks2014.dbo.DatabaseLog

SELECT DatabaseLogID, XmlData
FROM #DatabaseLog

------------------------------------------------------

SELECT DatabaseLogID
FROM #DatabaseLog
WHERE XmlData.exist('EVENT_INSTANCE/EventType[. = "CREATE_TABLE"]') = 1

SELECT DatabaseLogID
     , XmlData.value('(EVENT_INSTANCE/EventType/text())[1]', 'VARCHAR(100)')
     , XmlData.value('(EVENT_INSTANCE/PostTime/text())[1]', 'DATETIME')
FROM #DatabaseLog

/*
    ALTER TABLE #DatabaseLog
        ADD EventType AS XmlData.value('(EVENT_INSTANCE/EventType)[1]', 'VARCHAR(100)')
*/

------------------------------------------------------

DROP FUNCTION IF EXISTS dbo.GetEventType
GO

CREATE FUNCTION dbo.GetEventType(@XmlEvent XML)
RETURNS VARCHAR(100)
BEGIN
   RETURN @XmlEvent.value('(EVENT_INSTANCE/EventType/text())[1]', 'VARCHAR(100)')
END
GO

ALTER TABLE #DatabaseLog
    ADD EventType AS dbo.GetEventType(XmlData) -- parallelism?
GO

------------------------------------------------------

SELECT DatabaseLogID, EventType
FROM #DatabaseLog

/*
    SQL Profiler: SQL:StmtStarting + SP:StmtCompleted
    XEvent:       sp_statement_starting + sp_statement_completed
*/

------------------------------------------------------

DROP FUNCTION IF EXISTS dbo.GetEventType2
GO

CREATE FUNCTION dbo.GetEventType2(@XmlEvent XML)
RETURNS VARCHAR(100)
    WITH SCHEMABINDING -- !!!
BEGIN
   RETURN @XmlEvent.value('(EVENT_INSTANCE/EventType/text())[1]', 'VARCHAR(100)')
END
GO

ALTER TABLE #DatabaseLog
    ADD EventType2 AS dbo.GetEventType2(XmlData) PERSISTED -- !!!
GO

------------------------------------------------------

SET STATISTICS TIME, IO ON

SELECT DatabaseLogID
FROM #DatabaseLog
WHERE EventType = 'CREATE_TABLE'

SELECT DatabaseLogID
FROM #DatabaseLog
WHERE EventType2 = 'CREATE_TABLE'

SET STATISTICS TIME, IO OFF

------------------------------------------------------

ALTER TABLE #DatabaseLog
    DROP COLUMN EventType2
GO

ALTER TABLE #DatabaseLog
    ADD EventType2 AS dbo.GetEventType2(XmlData)
GO

CREATE NONCLUSTERED INDEX ix ON #DatabaseLog (EventType2)
GO

------------------------------------------------------

SET STATISTICS TIME, IO ON

SELECT DatabaseLogID
FROM #DatabaseLog
WHERE XmlData.exist('EVENT_INSTANCE/EventType[. = "CREATE_TABLE"]') = 1

SELECT DatabaseLogID
FROM #DatabaseLog
WHERE EventType = 'CREATE_TABLE'

SELECT DatabaseLogID
FROM #DatabaseLog
WHERE EventType2 = 'CREATE_TABLE'

SET STATISTICS TIME, IO OFF