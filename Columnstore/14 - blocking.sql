USE CCI
GO

DROP TABLE IF EXISTS dbo.CCI_Lock
CREATE TABLE dbo.CCI_Lock (
      ID INT IDENTITY
    , Val VARCHAR(50)
)

INSERT INTO dbo.CCI_Lock VALUES ('test1')
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI on dbo.CCI_Lock
GO

/*
    CREATE UNIQUE NONCLUSTERED INDEX IX ON dbo.CCI_Lock (ID)
*/


INSERT INTO dbo.CCI_Lock VALUES ('test2')
GO

BEGIN TRAN

    UPDATE dbo.CCI_Lock
    SET Val = 'test3'
    WHERE ID = 2

--COMMIT

---------------------------------------------------------------------------------------------------------

SELECT l.request_session_id
     , l.resource_database_id
     , DB_NAME(l.resource_database_id) AS dbname
     , IIF(resource_type = 'object', OBJECT_NAME(l.resource_associated_entity_id), OBJECT_NAME(p.[object_id]))
     , p.index_id
     , i.[name]
     , l.resource_type
     , l.resource_description
     , l.resource_associated_entity_id
     , l.request_mode
     , l.request_status
FROM sys.dm_tran_locks l
LEFT JOIN sys.partitions p ON p.hobt_id = l.resource_associated_entity_id
JOIN sys.indexes i ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
WHERE l.resource_associated_entity_id > 0
    AND l.resource_database_id = DB_ID()
ORDER BY l.request_session_id
       , l.resource_associated_entity_id