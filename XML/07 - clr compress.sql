SET NOCOUNT ON

USE tempdb
GO

EXEC sys.sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO

EXEC sys.sp_configure 'clr enabled', 1
GO
RECONFIGURE WITH OVERRIDE
GO

DROP FUNCTION IF EXISTS dbo.BinaryCompress_CLR
DROP FUNCTION IF EXISTS dbo.BinaryDecompress_CLR
DROP ASSEMBLY IF EXISTS Compress_CLR
GO

CREATE ASSEMBLY Compress_CLR FROM 'D:\PROJECT\XML\Compress_CLR\Compress_CLR.dll'
    WITH PERMISSION_SET = SAFE
GO

CREATE FUNCTION dbo.BinaryCompress_CLR (@input VARBINARY(MAX))
RETURNS VARBINARY(MAX)
    AS EXTERNAL NAME Compress_CLR.[Compress].BinaryCompress
GO

CREATE FUNCTION dbo.BinaryDecompress_CLR (@input VARBINARY(MAX))
RETURNS VARBINARY(MAX)
    AS EXTERNAL NAME Compress_CLR.[Compress].BinaryDecompress
GO

------------------------------------------------------

DROP TABLE IF EXISTS #Compress
DROP TABLE IF EXISTS #NoCompress
GO

SET STATISTICS TIME ON

SELECT DatabaseLogID, XmlEvent
INTO #NoCompress
FROM AdventureWorks2014.dbo.DatabaseLog

SELECT DatabaseLogID, XmlEvent = dbo.BinaryCompress_CLR(CAST(XmlEvent AS VARBINARY(MAX)))
INTO #Compress
FROM AdventureWorks2014.dbo.DatabaseLog

SET STATISTICS TIME OFF

/*
    Table '#NoCompress' ...
        CPU time = 2 ms, elapsed time = 9 ms

    Table '#Compress' ...
        CPU time = 235 ms, elapsed time = 155 ms
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

SELECT AVG(DATALENGTH(XmlEvent)) -- 695
FROM #Compress

------------------------------------------------------

SET STATISTICS TIME, IO ON

SELECT DatabaseLogID, XmlEvent
FROM #NoCompress

SELECT DatabaseLogID, XmlEvent = CAST(dbo.BinaryDecompress_CLR(XmlEvent) AS XML)
FROM #Compress

SET STATISTICS TIME, IO OFF

/*
    Table '#NoCompress'. Scan count 1, logical reads 448, ...
        CPU time = 15 ms, elapsed time = 215 ms

    Table '#Compress'. Scan count 1, logical reads 149, ...
        CPU time = 157 ms, elapsed time = 242 ms
*/

------------------------------------------------------

SET STATISTICS IO, TIME ON

SELECT *
FROM #NoCompress
WHERE XmlEvent.exist('EVENT_INSTANCE/EventType[. = "CREATE_TYPE"]') = 1

SELECT DatabaseLogID, XmlEvent = CAST(dbo.BinaryDecompress_CLR(XmlEvent) AS XML)
FROM #Compress
WHERE CAST(dbo.BinaryDecompress_CLR(XmlEvent) AS XML).exist('EVENT_INSTANCE/EventType[. = "CREATE_TYPE"]') = 1

SET STATISTICS IO, TIME OFF

/*
    Table '#NoCompress'. Scan count 1, logical reads 448, ...
       CPU time = 32 ms, elapsed time = 34 ms

    Table '#Compress'. Scan count 1, logical reads 149, ...
       CPU time = 484 ms, elapsed time = 524 ms
*/
