SET NOCOUNT ON

USE tempdb
GO

DROP TABLE IF EXISTS #Compress
DROP TABLE IF EXISTS #NoCompress
GO

CREATE TABLE #NoCompress (DatabaseLogID INT PRIMARY KEY, JSON_Val NVARCHAR(MAX))
CREATE TABLE #Compress   (DatabaseLogID INT PRIMARY KEY, JSON_CompressVal VARBINARY(MAX))
GO

SET STATISTICS IO, TIME ON

INSERT INTO #NoCompress
SELECT DatabaseLogID
     , JSON_Val = (
            SELECT PostTime, DatabaseUser, [Event], [Schema], [Object], [TSQL]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
FROM AdventureWorks2014.dbo.DatabaseLog
OPTION(MAXDOP 1)

INSERT INTO #Compress
SELECT DatabaseLogID
     , JSON_CompressVal = COMPRESS((
            SELECT PostTime, DatabaseUser, [Event], [Schema], [Object], [TSQL]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
         ))
FROM AdventureWorks2014.dbo.DatabaseLog
OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF

/*
    #NoCompress: CPU time = 15 ms,  elapsed time = 25 ms
    #Compress:   CPU time = 218 ms, elapsed time = 280 ms
*/

------------------------------------------------------

SELECT obj_name = OBJECT_NAME(p.[object_id])
     , a.[type_desc]
     , a.total_pages
     , total_mb = a.total_pages * 8 / 1024.
FROM sys.partitions p
JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
WHERE p.[object_id] IN (OBJECT_ID('#Compress'), OBJECT_ID('#NoCompress'))

------------------------------------------------------

SET STATISTICS IO, TIME ON

SELECT *
FROM #NoCompress
WHERE JSON_VALUE(JSON_Val, '$.Event') = 'CREATE_TABLE'

SELECT DatabaseLogID, [JSON] = CAST(DECOMPRESS(JSON_CompressVal) AS NVARCHAR(MAX))
FROM #Compress
WHERE JSON_VALUE(CAST(DECOMPRESS(JSON_CompressVal) AS NVARCHAR(MAX)), '$.Event') = N'CREATE_TABLE'

SET STATISTICS IO, TIME OFF

/*
    Table '#NoCompress'. Scan count 1, logical reads 187, ...
       CPU time = 16 ms, elapsed time = 37 ms

    Table '#Compress'. Scan count 1, logical reads 79, ...
       CPU time = 109 ms, elapsed time = 212 ms
*/

------------------------------------------------------

ALTER TABLE #Compress ADD EventType_Persisted
    AS CAST(JSON_VALUE(CAST(DECOMPRESS(JSON_CompressVal) AS NVARCHAR(MAX)), '$.Event') AS VARCHAR(200)) PERSISTED
GO

ALTER TABLE #Compress ADD EventType_NonPersisted
    AS CAST(JSON_VALUE(CAST(DECOMPRESS(JSON_CompressVal) AS NVARCHAR(MAX)), '$.Event') AS VARCHAR(200))
GO

CREATE INDEX ix ON #Compress (EventType_NonPersisted)
GO

------------------------------------------------------

SET STATISTICS TIME ON

SELECT DatabaseLogID, [JSON] = CAST(DECOMPRESS(JSON_CompressVal) AS NVARCHAR(MAX))
FROM #Compress
WHERE EventType_Persisted = 'CREATE_TABLE'

SELECT DatabaseLogID, [JSON] = CAST(DECOMPRESS(JSON_CompressVal) AS NVARCHAR(MAX))
FROM #Compress WITH(INDEX(ix))
WHERE EventType_NonPersisted = 'CREATE_TABLE'

SET STATISTICS TIME OFF

/*
    EventType_Persisted:            CPU time = 0 ms,  elapsed time = 36 ms
    EventType_NonPersisted + Index: CPU time = 16 ms, elapsed time = 129 ms
*/

------------------------------------------------------

SET STATISTICS TIME ON

SELECT DatabaseLogID
FROM #Compress
WHERE EventType_Persisted = 'CREATE_TABLE'

SELECT DatabaseLogID
FROM #Compress WITH(INDEX(ix))
WHERE EventType_NonPersisted = 'CREATE_TABLE'

SET STATISTICS TIME OFF

/*
    EventType_Persisted:            CPU time = 0 ms,  elapsed time = 0 ms
    EventType_NonPersisted + Index: CPU time = 0 ms,  elapsed time = 195 ms
*/

------------------------------------------------------

DECLARE @json NVARCHAR(MAX) = (
        SELECT t.[name]
             , t.[object_id]
             , [columns] = (
                     SELECT c.column_id, c.[name], c.system_type_id
                     FROM sys.all_columns c
                     WHERE c.[object_id] = t.[object_id]
                     FOR JSON AUTO
                 )
        FROM sys.all_objects t
        FOR JSON AUTO
    )

SELECT InitialSize = DATALENGTH(@json) / 1048576.
     , CompressSize = DATALENGTH(COMPRESS(@json)) / 1048576.