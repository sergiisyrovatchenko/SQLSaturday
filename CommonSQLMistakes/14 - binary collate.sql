USE AdventureWorks2014
GO

SELECT AddressLine1
FROM Person.[Address]
WHERE AddressLine1 LIKE '%100%'

------------------------------------------------------------------

USE [master]
GO

IF DB_ID('test') IS NOT NULL BEGIN
    ALTER DATABASE test SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE test
END
GO

CREATE DATABASE test COLLATE Latin1_General_100_CS_AS
GO
ALTER DATABASE test MODIFY FILE (NAME = N'test', SIZE = 64MB)
GO
ALTER DATABASE test MODIFY FILE (NAME = N'test_log', SIZE = 64MB)
GO

USE test
GO

CREATE TABLE t (
     ansi VARCHAR(100) NOT NULL
   , unicod NVARCHAR(100) NOT NULL
)
GO

;WITH
    E1(N) AS (
        SELECT * FROM (
            VALUES
                (1),(1),(1),(1),(1),
                (1),(1),(1),(1),(1)
        ) t(N)
    ),
    E2(N) AS (SELECT 1 FROM E1 a, E1 b),
    E4(N) AS (SELECT 1 FROM E2 a, E2 b),
    E8(N) AS (SELECT 1 FROM E4 a, E4 b)
INSERT INTO t
SELECT v, v
FROM (
    SELECT TOP(50000) v = REPLACE(CAST(NEWID() AS VARCHAR(36)) + CAST(NEWID() AS VARCHAR(36)), '-', '')
    FROM E8
) t
GO

------------------------------------------------------------------

ALTER TABLE t
    ADD ansi_bin AS UPPER(ansi) COLLATE Latin1_General_100_Bin2

ALTER TABLE t
    ADD unicod_bin AS UPPER(unicod) COLLATE Latin1_General_100_BIN2

CREATE NONCLUSTERED INDEX ansi ON t (ansi)
CREATE NONCLUSTERED INDEX unicod ON t (unicod)

CREATE NONCLUSTERED INDEX ansi_bin ON t (ansi_bin)
CREATE NONCLUSTERED INDEX unicod_bin ON t (unicod_bin)
GO

------------------------------------------------------------------

SET STATISTICS TIME, IO ON

SELECT COUNT_BIG(*)
FROM t
WHERE ansi LIKE '%AB%'

SELECT COUNT_BIG(*)
FROM t
WHERE unicod LIKE '%AB%'

SELECT COUNT_BIG(*)
FROM t
WHERE ansi_bin LIKE '%AB%' --COLLATE Latin1_General_100_BIN2

SELECT COUNT_BIG(*)
FROM t
WHERE unicod_bin LIKE '%AB%' --COLLATE Latin1_General_100_BIN2

SET STATISTICS TIME, IO OFF