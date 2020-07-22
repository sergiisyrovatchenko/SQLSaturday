USE tempdb
GO

DROP TABLE IF EXISTS dbo.t40
DROP TABLE IF EXISTS dbo.t200
DROP TABLE IF EXISTS dbo.t1000
DROP TABLE IF EXISTS dbo.t4000
DROP TABLE IF EXISTS dbo.t8000
DROP TABLE IF EXISTS dbo.tMAX
GO

CREATE TABLE dbo.t40   (t VARCHAR(40))
CREATE TABLE dbo.t200  (t VARCHAR(200))
CREATE TABLE dbo.t1000 (t VARCHAR(1000))
CREATE TABLE dbo.t4000 (t VARCHAR(4000))
CREATE TABLE dbo.t8000 (t VARCHAR(8000))
CREATE TABLE dbo.tMAX  (t VARCHAR(MAX))
GO

------------------------------------------------------------------

SELECT * FROM dbo.t40   -- 20
SELECT * FROM dbo.t200  -- 100
SELECT * FROM dbo.t1000 -- 500
SELECT * FROM dbo.t4000 -- 2000
SELECT * FROM dbo.t8000 -- 4000
SELECT * FROM dbo.tMAX  -- 4000
GO

------------------------------------------------------------------

INSERT dbo.t40
SELECT TOP (30000) NEWID() /* 36 */
FROM sys.all_columns c
JOIN sys.all_objects o ON c.[object_id] = o.[object_id]
JOIN sys.all_columns c2 ON c.[object_id] = c2.[object_id]

INSERT INTO dbo.t200  SELECT t FROM dbo.t40
INSERT INTO dbo.t1000 SELECT t FROM dbo.t40
INSERT INTO dbo.t4000 SELECT t FROM dbo.t40
INSERT INTO dbo.t8000 SELECT t FROM dbo.t40
INSERT INTO dbo.tMAX  SELECT t FROM dbo.t40

------------------------------------------------------------------

SELECT o.[name], COUNT(p.[object_id])
FROM sys.objects o
CROSS APPLY sys.dm_db_database_page_allocations (DB_ID(), o.object_id, NULL, NULL, 'LIMITED') p
WHERE o.name LIKE N't%'
GROUP BY o.[name]

/*
    -------- -----
    t40      188
    t200     188
    t1000    188
    t4000    188
    t8000    188
    tMAX     188
*/

------------------------------------------------------------------

/*
    DBCC FREEPROCCACHE
*/

SET STATISTICS TIME ON
GO

SELECT /*t40*/ *, ROW_NUMBER() OVER (PARTITION BY t ORDER BY t)
FROM dbo.t40
GROUP BY REVERSE(t), t, SUBSTRING(t, 1, CHARINDEX('@', t))
ORDER BY REVERSE(t), t
GO

SELECT /*t200*/ *, ROW_NUMBER() OVER (PARTITION BY t ORDER BY t)
FROM dbo.t200
GROUP BY REVERSE(t), t, SUBSTRING(t, 1, CHARINDEX('@', t))
ORDER BY REVERSE(t), t
GO

SELECT /*t1000*/ *, ROW_NUMBER() OVER (PARTITION BY t ORDER BY t)
FROM dbo.t1000
GROUP BY REVERSE(t), t, SUBSTRING(t, 1, CHARINDEX('@', t))
ORDER BY REVERSE(t), t
GO

SELECT /*t4000*/ *, ROW_NUMBER() OVER (PARTITION BY t ORDER BY t)
FROM dbo.t4000
GROUP BY REVERSE(t), t, SUBSTRING(t, 1, CHARINDEX('@', t))
ORDER BY REVERSE(t), t
GO

SELECT /*t8000*/ *, ROW_NUMBER() OVER (PARTITION BY t ORDER BY t)
FROM dbo.t8000
GROUP BY REVERSE(t), t, SUBSTRING(t, 1, CHARINDEX('@', t))
ORDER BY REVERSE(t), t
GO

SELECT /*tMAX*/ *, ROW_NUMBER() OVER (PARTITION BY t ORDER BY t)
FROM dbo.tMAX
GROUP BY REVERSE(t), t, SUBSTRING(t, 1, CHARINDEX('@', t))
ORDER BY REVERSE(t), t
GO

SET STATISTICS TIME OFF

/*
    CPU time = 234 ms, elapsed time = 431 ms
    CPU time = 266 ms, elapsed time = 451 ms
    CPU time = 265 ms, elapsed time = 424 ms
    CPU time = 282 ms, elapsed time = 482 ms
    CPU time = 297 ms, elapsed time = 474 ms
    CPU time = 718 ms, elapsed time = 994 ms
*/

------------------------------------------------------------------

SELECT t.[text]
     , s.last_grant_kb
     , s.last_used_grant_kb
FROM sys.dm_exec_query_stats AS s
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) AS t
WHERE t.[text] LIKE N'%/*t%dbo.' + N't%'
ORDER BY s.last_grant_kb

/*
    table       last_grant_kb        last_used_grant_kb
    ----------- -------------------- -------------------
    t40         12928                7592
    t200        18544                7592
    t1000       62488                7592
    t4000       227288               7592
    t8000       447016               7592
    tMAX        451992               11288
*/

------------------------------------------------------------------

DROP TABLE IF EXISTS tMAX
DROP TABLE IF EXISTS t4000
DROP TABLE IF EXISTS t300
DROP TABLE IF EXISTS t700
GO

CREATE TABLE tMAX (t VARCHAR(8000))
CREATE TABLE t4000 (t VARCHAR(4000))
CREATE TABLE t300  (t VARCHAR(300))
CREATE TABLE t700  (t VARCHAR(700))

INSERT t4000
SELECT TOP (50000) REPLICATE('a', 300)
FROM [master].dbo.spt_values v1
   , [master].dbo.spt_values v2

INSERT t300 SELECT * FROM t4000
INSERT t700 SELECT * FROM t4000
INSERT tMAX SELECT * FROM t4000
GO

SELECT * FROM tMAX  ORDER BY t OPTION(MAXDOP 1) -- Memory Grant 247792 KB, Used Memory 17360 KB
SELECT * FROM t4000 ORDER BY t OPTION(MAXDOP 1) -- Memory Grant 125720 KB, Used Memory 17360 KB
SELECT * FROM t300  ORDER BY t OPTION(MAXDOP 1) -- Memory Grant 12800 KB,  Used Memory 12800 KB, Spill
SELECT * FROM t700  ORDER BY t OPTION(MAXDOP 1) -- Memory Grant 25008 KB,  Used Memory 17360 KB, No Spill
GO