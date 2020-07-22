USE tempdb
GO

SET NOCOUNT ON

IF OBJECT_ID('tbl') IS NOT NULL
	DROP TABLE tbl
GO
CREATE TABLE tbl (
	  B1 BIT DEFAULT 0
	--, B2 BIT DEFAULT 1
	--, B3 BIT DEFAULT 0
	--, B4 BIT DEFAULT 1
	--, B5 BIT DEFAULT 0
	--, B6 BIT DEFAULT 1
	--, B7 BIT DEFAULT 0
	--, B8 BIT DEFAULT 1
	----, B9 BIT DEFAULT 1
)
GO

INSERT INTO tbl(B1)
SELECT TOP(10000) 1
FROM [master].dbo.spt_values t1
CROSS JOIN [master].dbo.spt_values t2
GO

-------------------------------------------------------------------

SELECT p.[rows], a.type_desc, a.total_pages, a.used_pages, a.data_pages
FROM sys.partitions p
LEFT JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
WHERE p.[object_id] = OBJECT_ID('dbo.tbl')