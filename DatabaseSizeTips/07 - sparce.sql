USE tempdb
GO

SET NOCOUNT ON

IF OBJECT_ID('t1') IS NOT NULL
	DROP TABLE t1
GO
CREATE TABLE t1 (
	ID INT IDENTITY(1,1),
	A INT,
	B VARCHAR(100),
	C DATETIME
)
GO
IF OBJECT_ID('t2') IS NOT NULL
	DROP TABLE t2
GO
CREATE TABLE t2 (
	ID INT IDENTITY(1,1),
	A BIGINT SPARSE,
	B VARCHAR(100) SPARSE,
	C DATETIME SPARSE
)
GO
IF OBJECT_ID('t3') IS NOT NULL
	DROP TABLE t3
GO
CREATE TABLE t3 (
	ID INT IDENTITY(1,1),
	A BIGINT SPARSE,
	B VARCHAR(100) SPARSE,
	C DATETIME SPARSE
)
GO

INSERT INTO t1
SELECT TOP(100000) CASE WHEN t1.number % 10 = 0 THEN 1 ELSE NULL END, NULL, NULL
FROM [master].dbo.spt_values t1
CROSS JOIN [master].dbo.spt_values t2
ORDER BY t1.number
GO

INSERT INTO t2
SELECT A, B, C FROM t1
GO

INSERT INTO t3
SELECT A, NULL, GETDATE() FROM t1
GO

SELECT
	  OBJECT_NAME([object_id])
	, reserved = reservedpages * 8. / 1024
	, data = pages * 8. / 1024
	, index_size = CASE WHEN usedpages > pages THEN usedpages - pages ELSE 0 END * 8. / 1024
FROM (
	SELECT
		  [object_id]
		, reservedpages = SUM(reserved_page_count)
		, usedpages = SUM(used_page_count)
		, pages = SUM(
			CASE
				WHEN (index_id < 2) THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)
				ELSE 0
			END)
	FROM sys.dm_db_partition_stats
	WHERE object_id IN (OBJECT_ID('t1'), OBJECT_ID('t2'), OBJECT_ID('t3'))
	GROUP BY [object_id]
) t
ORDER BY t.[object_id]

-------------------------------------------------------------------

SELECT 100 - COUNT_BIG(A) * 100. / COUNT_BIG(*)
FROM t1