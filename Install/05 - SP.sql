/*
    http://sqlserverbuilds.blogspot.ca
    https://sqlserverupdates.com
*/

USE tempdb -- HOMEPC\SQL_2008R2_EXP
GO

SET NOCOUNT ON

IF OBJECT_ID('dbo.big_table', 'U') IS NOT NULL
    DROP TABLE dbo.big_table
GO

CREATE TABLE dbo.big_table (
      RecordID INT IDENTITY PRIMARY KEY
    , TextData VARCHAR(MAX) -- XML, NVARCHAR(MAX), IMAGE, TEXT
)
GO

INSERT dbo.big_table SELECT NULL
GO

------------------------------------------------------

BEGIN TRAN
    INSERT dbo.big_table
    SELECT REPLICATE(CAST('text' AS VARCHAR(MAX)), 30000)
ROLLBACK TRAN
GO 10

------------------------------------------------------

SELECT p.[rows]
     , a.[type_desc]
     , a.total_pages
     , a.used_pages
     , a.data_pages
FROM sys.partitions p
LEFT JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
WHERE p.[object_id] = OBJECT_ID('dbo.big_table')

------------------------------------------------------

DELETE FROM dbo.big_table
TRUNCATE TABLE dbo.big_table

DBCC CLEANTABLE('tempdb', 'dbo.big_table') -- ???

-- Fixed: 2005 (SP3) / 2008 (SP2) / 2008R2 (SP1)