USE tempdb
GO

CREATE TABLE t (
	  ID INT PRIMARY KEY
	, ValueA CHAR(4000)
	, ValueB CHAR(4000)
	, ValueC CHAR(4000)
)
GO

-------------------------------------------------------------------

IF OBJECT_ID('t1') IS NOT NULL
	DROP TABLE t1
GO
CREATE TABLE t1 (
	  ID INT PRIMARY KEY
	, ValueA CHAR(4000)
	--, ValueA CHAR(8000)
)
GO
IF OBJECT_ID('t2') IS NOT NULL
	DROP TABLE t2
GO
CREATE TABLE t2 (
	  ID INT PRIMARY KEY
	, ValueB CHAR(4000)
	--, ValueC CHAR(50)
)
GO

-------------------------------------------------------------------

IF OBJECT_ID('v1') IS NOT NULL
	DROP VIEW v1
GO
CREATE VIEW v1
AS
	SELECT t1.ValueA, t2.ValueB, Cnt = COUNT_BIG(*)
	FROM t1
	JOIN t2 ON t1.ID = t2.ID
	GROUP BY t1.ValueA, t2.ValueB -- 8060 bytes
GO

SELECT * FROM v1
GO

-------------------------------------------------------------------

UPDATE STATISTICS t1 WITH ROWCOUNT = 1000000
UPDATE STATISTICS t2 WITH ROWCOUNT = 1000000
GO

SELECT *
FROM t1
JOIN t2 ON t1.ID = t2.ID
ORDER BY t1.ID DESC
OPTION(HASH JOIN)
GO





