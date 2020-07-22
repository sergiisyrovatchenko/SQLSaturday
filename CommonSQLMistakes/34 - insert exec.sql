USE test
GO

DROP PROCEDURE IF EXISTS #proc
GO

CREATE PROCEDURE #proc
AS
    SELECT TOP(10000) A
    FROM big_table
GO

DROP TABLE IF EXISTS #t
CREATE TABLE #t (id INT)

INSERT INTO #t
EXEC #proc
GO

------------------------------------------------------------------

DROP TABLE IF EXISTS #t
CREATE TABLE #t (id INT)

INSERT INTO #t
SELECT TOP(10000) A
FROM big_table
GO

------------------------------------------------------------------

DECLARE @sql NVARCHAR(MAX) = '
SELECT TOP(10000) A
FROM big_table'

DROP TABLE IF EXISTS #t
CREATE TABLE #t (id INT)

INSERT INTO #t
EXEC(@sql)
GO

------------------------------------------------------------------

DECLARE @sql NVARCHAR(MAX) = '
INSERT INTO #t
SELECT TOP(10000) A
FROM big_table'

DROP TABLE IF EXISTS #t
CREATE TABLE #t (id INT)

EXEC(@sql)