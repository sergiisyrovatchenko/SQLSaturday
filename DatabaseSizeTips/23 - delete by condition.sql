USE tempdb
GO

SET NOCOUNT ON

IF OBJECT_ID('t') IS NOT NULL
	DROP TABLE t
GO
CREATE TABLE t (
	A INT PRIMARY KEY,
	B INT
)
GO
INSERT INTO t
SELECT TOP(1000000) ID = ROW_NUMBER() OVER(ORDER BY 1/0), ISNULL(t1.number, 0)
FROM [master].dbo.spt_values t1
CROSS JOIN [master].dbo.spt_values t2
GO

SELECT COUNT(CASE WHEN B = 0 THEN 1 END) * 100. / COUNT_BIG(*)
FROM t

-------------------------------------------------------------------
-- < 20%
 
DECLARE @r INT
SET @r = 1
 
WHILE @r > 0 BEGIN

  DELETE TOP (100000) t
  WHERE B = 0
 
  SET @r = @@ROWCOUNT

END

-------------------------------------------------------------------
-- > 20%

IF OBJECT_ID('t1') IS NOT NULL
	DROP TABLE t1
GO
CREATE TABLE t1 (
	A INT PRIMARY KEY,
	B INT
)
GO
INSERT INTO t1
SELECT TOP(1000000) ID = ROW_NUMBER() OVER(ORDER BY 1/0), ISNULL(t1.number, 1)
FROM [master].dbo.spt_values t1
CROSS JOIN [master].dbo.spt_values t2
GO

IF OBJECT_ID('t2') IS NOT NULL
	DROP TABLE t2
GO
CREATE TABLE t2 (
	A INT PRIMARY KEY,
	B INT
)
GO

SELECT COUNT(CASE WHEN B != 0 THEN 1 END) * 100. / COUNT_BIG(*)
FROM t

INSERT INTO t2
SELECT *
FROM t1
WHERE B = 0

TRUNCATE TABLE t1

ALTER TABLE t2 SWITCH TO t1

SELECT * FROM t1
