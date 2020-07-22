SET NOCOUNT ON

USE tempdb
GO

IF OBJECT_ID('dbo.lob', 'U') IS NOT NULL
    DROP TABLE dbo.lob
GO

CREATE TABLE dbo.lob (
      id INT IDENTITY(1,1) PRIMARY KEY
    , x XML
) 
GO

INSERT dbo.lob SELECT NULL
GO

------------------------------------------------------

BEGIN TRAN
    INSERT dbo.lob
    SELECT REPLICATE(CAST('<x>1</x>' AS VARCHAR(MAX)), 30000)
ROLLBACK TRAN
GO 10

------------------------------------------------------

SELECT p.[rows], a.type_desc, a.total_pages, a.used_pages, a.data_pages
FROM sys.partitions p
LEFT JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
WHERE p.[object_id] = OBJECT_ID('dbo.lob')

SELECT *
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.lob'), NULL, NULL, N'DETAILED')

------------------------------------------------------

DELETE FROM dbo.lob
TRUNCATE TABLE dbo.lob

------------------------------------------------------

DBCC CLEANTABLE('tempdb', 'dbo.lob') -- 2005/2008 RTM

DELETE FROM dbo.lob
TRUNCATE TABLE dbo.lob

-- Fixed: 2005 (SP3) / 2008 (SP2) / 2008R2 (SP1)