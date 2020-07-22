USE tempdb
GO

IF OBJECT_ID('t') IS NOT NULL
	DROP TABLE t
GO

SELECT TOP(20000)
	  ID = ROW_NUMBER() OVER(ORDER BY 1/0)
	, t1.*
	, LOB = CAST(REPLICATE('test', 2500) AS NVARCHAR(MAX))
INTO t
FROM [master].dbo.spt_values t1
CROSS JOIN [master].dbo.spt_values t2
GO

CREATE CLUSTERED INDEX pk ON t (ID)

SELECT a.*
FROM sys.allocation_units a
JOIN sys.partitions p ON p.[partition_id] = a.container_id
WHERE p.[object_id] = OBJECT_ID('t')
GO

ALTER INDEX pk ON t REBUILD WITH (FILLFACTOR = 50)

SELECT a.*
FROM sys.allocation_units a
JOIN sys.partitions p ON p.partition_id = a.container_id
WHERE p.[object_id] = OBJECT_ID('t')