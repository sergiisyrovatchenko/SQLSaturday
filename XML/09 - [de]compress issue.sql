SET NOCOUNT ON

USE tempdb
GO

DROP TABLE IF EXISTS #Compress
DROP TABLE IF EXISTS #NoCompress
GO

SET STATISTICS IO, TIME ON

SELECT DatabaseLogID, XmlEvent
INTO #NoCompress
FROM AdventureWorks2014.dbo.DatabaseLog

SELECT DatabaseLogID, XmlEvent = COMPRESS(CAST(XmlEvent AS NVARCHAR(MAX)))
INTO #Compress
FROM AdventureWorks2014.dbo.DatabaseLog

SET STATISTICS IO, TIME OFF

/*
    Table '#NoCompress' ...
        CPU time = 31 ms, elapsed time = 13 ms

    Table '#Compress' ...
        CPU time = 281 ms, elapsed time = 200 ms
*/

------------------------------------------------------

SELECT obj_name = OBJECT_NAME(p.[object_id])
     , a.[type_desc]
     , a.total_pages
     , total_mb = a.total_pages * 8 / 1024.
FROM sys.partitions p
JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
WHERE p.[object_id] IN (OBJECT_ID('#Compress'), OBJECT_ID('#NoCompress'))

/*
    obj_name     type_desc     total_pages  total_mb
    ------------ ------------- ------------ ---------
    #NoCompress  IN_ROW_DATA   466          3.640625
    #NoCompress  LOB_DATA      26           0.203125
    #Compress    IN_ROW_DATA   170          1.328125
    #Compress    LOB_DATA      9            0.070312
*/

SELECT AVG(DATALENGTH(XmlEvent)) -- 2002
FROM #NoCompress

SELECT AVG(DATALENGTH(XmlEvent)) -- 711
FROM #Compress

------------------------------------------------------

SET STATISTICS TIME, IO ON

SELECT DatabaseLogID, XmlEvent
FROM #NoCompress

SELECT DatabaseLogID, XmlEvent = CAST(CAST(DECOMPRESS(XmlEvent) AS NVARCHAR(MAX)) AS XML)
FROM #Compress

SET STATISTICS TIME, IO OFF

/*
    Table '#NoCompress'. Scan count 1, logical reads 448, ...
        CPU time = 31 ms, elapsed time = 238 ms

    Table '#Compress'. Scan count 1, logical reads 152, ...
        CPU time = 250 ms, elapsed time = 307 ms
*/

------------------------------------------------------

SET STATISTICS IO, TIME ON

SELECT *
FROM #NoCompress
WHERE XmlEvent.exist('EVENT_INSTANCE/EventType[. = "CREATE_TYPE"]') = 1

SELECT DatabaseLogID, XmlEvent = CAST(CAST(DECOMPRESS(XmlEvent) AS NVARCHAR(MAX)) AS XML)
FROM #Compress
WHERE CAST(CAST(DECOMPRESS(XmlEvent) AS NVARCHAR(MAX)) AS XML).exist('EVENT_INSTANCE/EventType[. = "CREATE_TYPE"]') = 1

SET STATISTICS IO, TIME OFF

/*
    Table '#NoCompress'. Scan count 1, logical reads 448, ...
       CPU time = 31 ms, elapsed time = 34 ms

    Table '#Compress'. Scan count 1, logical reads 152, ...
       CPU time = 610 ms, elapsed time = 707 ms
*/

------------------------------------------------------

ALTER TABLE #Compress ADD EventType
    AS CAST(CAST(CAST(DECOMPRESS(XmlEvent) AS NVARCHAR(MAX)) AS XML)
        .value('(EVENT_INSTANCE/EventType/text())[1]', 'VARCHAR(100)') AS VARCHAR(100)) PERSISTED
GO

------------------------------------------------------

DROP FUNCTION IF EXISTS dbo.GetEventType
GO

CREATE FUNCTION dbo.GetEventType(@XmlEvent VARBINARY(MAX))
RETURNS VARCHAR(100)
    WITH SCHEMABINDING -- !!!
BEGIN
   RETURN CAST(CAST(DECOMPRESS(@XmlEvent) AS NVARCHAR(MAX)) AS XML)
            .value('(EVENT_INSTANCE/EventType/text())[1]', 'VARCHAR(100)')
END
GO

ALTER TABLE #Compress ADD EventType
    AS dbo.GetEventType(XmlEvent) PERSISTED -- !!!
GO

------------------------------------------------------

SET STATISTICS IO, TIME ON

SELECT DatabaseLogID, XmlEvent = CAST(CAST(DECOMPRESS(XmlEvent) AS NVARCHAR(MAX)) AS XML)
FROM #Compress
WHERE EventType = 'CREATE_TYPE'

SET STATISTICS IO, TIME OFF

/*
    Table '#Compress'. Scan count 1, logical reads 225, ...
        CPU time = 0 ms, elapsed time = 2 ms
*/