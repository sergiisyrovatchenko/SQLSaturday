SET NOCOUNT ON

USE tempdb
GO

DROP TABLE IF EXISTS dbo.DatabaseLog
CREATE TABLE dbo.DatabaseLog (
      DatabaseLogID INT IDENTITY PRIMARY KEY
    , XmlData XML
)

INSERT INTO dbo.DatabaseLog(XmlData)
SELECT XmlEvent
FROM AdventureWorks2014.dbo.DatabaseLog
CROSS APPLY (VALUES (1),(1),(1),(1),(1),(1)) t(c)
GO

------------------------------------------------------

SET STATISTICS TIME ON

SELECT XmlData.value('(EVENT_INSTANCE/PostTime/text())[1]', 'DATETIME')
     , XmlData.value('(EVENT_INSTANCE/LoginName/text())[1]', 'VARCHAR(100)')
     , XmlData.query('EVENT_INSTANCE/TSQLCommand')
FROM dbo.DatabaseLog
WHERE XmlData.exist('EVENT_INSTANCE') = 1

------------------------------------------------------

CREATE PRIMARY XML INDEX ix_primary ON dbo.DatabaseLog (XmlData)
GO

------------------------------------------------------

CREATE XML INDEX ix_sec_path ON dbo.DatabaseLog (XmlData)
    USING XML INDEX ix_primary FOR PATH
GO

CREATE XML INDEX ix_sec_prop ON dbo.DatabaseLog (XmlData)
    USING XML INDEX ix_primary FOR PROPERTY
GO

CREATE XML INDEX ix_sec_value ON dbo.DatabaseLog (XmlData)
    USING XML INDEX ix_primary FOR VALUE
GO

------------------------------------------------------

SELECT i.[name]
     , d.index_type_desc
     , size_mb = SUM(d.page_count) * 8 / 1024.
     , record_count = MAX(d.record_count)
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.DatabaseLog'), NULL, NULL, 'DETAILED') d
JOIN sys.indexes i ON d.[object_id] = i.[object_id] AND i.index_id = d.index_id
GROUP BY i.[name]
       , d.index_type_desc
ORDER BY size_mb DESC

------------------------------------------------------

EXEC sys.sp_configure 'show advanced options', 1
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure 'remote admin connections', 1
RECONFIGURE WITH OVERRIDE
GO

-- connect as ADMIN:...

------------------------------------------------------

USE tempdb
GO

SELECT OBJECT_NAME(parent_object_id), *
FROM sys.objects o
WHERE o.[name] LIKE 'xml_%'
    AND o.[type] = 'IT'

SELECT *
FROM sys.---

SELECT COL_NAME(i.[object_id], ic.column_id)
     , i.[name]
     , i.index_id
     , i.[type_desc]
FROM sys.index_columns ic
JOIN sys.indexes i ON ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id
WHERE i.[object_id] = OBJECT_ID('sys.---')