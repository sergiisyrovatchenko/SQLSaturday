USE tempdb
GO

SET NOCOUNT ON

IF OBJECT_ID('tbl') IS NOT NULL
	DROP TABLE tbl
GO
CREATE TABLE tbl (
	IR1 INT PRIMARY KEY IDENTITY,
	IR2 CHAR(10),
	IR3 DATETIME,
	IR4 BIT,
	IR5 DECIMAL(18,2),
	IR6 MONEY,
	RO1 VARCHAR(8000),
	RO2 NVARCHAR(4000),
	RO3 VARBINARY(8000),
	RO4 SQL_VARIANT,
	LOB1 NVARCHAR(MAX),
	LOB2 VARCHAR(MAX),
	LOB3 VARBINARY(MAX),
	LOB4 XML,
	LOB5 NTEXT,
	LOB6 IMAGE,
	LOB7 TEXT
)
GO

-------------------------------------------------------------------

INSERT INTO tbl(IR2) VALUES(DEFAULT)
GO 100

INSERT INTO tbl(RO1, RO2) VALUES(REPLICATE('t', 4000), REPLICATE('t', 4000))
GO 100

INSERT INTO tbl(LOB1) VALUES(REPLICATE('t', 10000))
GO 100

-------------------------------------------------------------------

SELECT p.[rows], a.type_desc, a.total_pages, a.used_pages, a.data_pages
FROM sys.partitions p
LEFT JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
WHERE p.[object_id] = OBJECT_ID('dbo.tbl')

-------------------------------------------------------------------

ALTER INDEX ALL ON tbl REBUILD WITH(ONLINE = ON)

SELECT *
FROM sys.dm_os_performance_counters
WHERE [object_name] = 'MSSQL$SQL_2012:Deprecated Features'
	AND cntr_value > 0
ORDER BY cntr_value DESC