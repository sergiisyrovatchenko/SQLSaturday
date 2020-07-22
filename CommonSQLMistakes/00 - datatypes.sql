DROP TABLE IF EXISTS #e1
DROP TABLE IF EXISTS #e2
GO

CREATE TABLE #e1 (
      EmployeeID BIGINT
    , FullName CHAR(100)
    , IsMale VARCHAR(3)
    , BirthDate VARCHAR(20)
)

CREATE TABLE #e2 (
      EmployeeID INT
    , FullName VARCHAR(100)
    , IsMale BIT
    , BirthDate DATE
)

INSERT INTO #e1 VALUES (123, 'Homer Simpson', 'YES', '2017-09-29')
INSERT INTO #e2 VALUES (123, 'Homer Simpson', 1,     '2017-09-29')

------------------------------------------------------------------

DECLARE @BirthDate DATE = '20170929'

SELECT * FROM #e1 WHERE BirthDate = @BirthDate
SELECT * FROM #e2 WHERE BirthDate = @BirthDate

------------------------------------------------------------------

DROP TABLE IF EXISTS #t1
GO
CREATE TABLE #t1 (
      ProductID INT PRIMARY KEY
    , ProductName VARCHAR(1000)
    , ProductPrice DECIMAL(12,2)
)

SELECT [type_desc]
     , total_pages
     , used_pages,data_pages
FROM tempdb.sys.allocation_units a
JOIN tempdb.sys.partitions p ON p.[partition_id] = a.container_id
WHERE p.[object_id] = OBJECT_ID('tempdb.dbo.#t1')

ALTER TABLE #t1 ADD ProductSummary NVARCHAR(4000)
GO

ALTER TABLE #t1 ADD ProductImage IMAGE
GO

/*
    BIGINT = 8
    INT = 4
    SMALLINT = 2
    TINYINT = 1
    BIT = 1
    CHAR(10) = 10
    DATETIME = 8
    SMALLDATETIME = 4
    DATE = 3
    VARCHAR(8000)
    NVARCHAR(4000)
    VARCHAR(MAX) = < 2Gb
    NVARCHAR(MAX) = < 2Gb

    IMAGE -> VARBINARY
    NTEXT -> NVARCHAR
    TEXT -> VARCHAR
*/

/*
    EXEC sys.sp_tableoption 'dbo.table', 'large value types out of row', 1
*/

------------------------------------------------------------------

CREATE TABLE #t (
      A INT PRIMARY KEY
    , B CHAR(4000)
    , C CHAR(4000)
    , D CHAR(4000)
)

------------------------------------------------------------------

DROP TABLE IF EXISTS #t1
GO
CREATE TABLE #t1 (
      ID INT PRIMARY KEY
    , A CHAR(4000)
    --, A CHAR(8000)
)
GO
DROP TABLE IF EXISTS #t2
GO
CREATE TABLE #t2 (
      ID INT PRIMARY KEY
    , B CHAR(4000)
)

------------------------------------------------------------------

SELECT t1.A
     , t2.B
     , COUNT_BIG(*)
FROM #t1 t1
JOIN #t2 t2 ON t1.ID = t2.ID
GROUP BY t1.A, t2.B -- 8060 bytes

------------------------------------------------------------------

DROP TABLE IF EXISTS #t2
GO
CREATE TABLE #t2 (
      ID INT PRIMARY KEY
    , B CHAR(4000)
    , C CHAR(50)
)

------------------------------------------------------------------

SELECT *
FROM #t1 t1
JOIN #t2 t2 ON t1.ID = t2.ID
ORDER BY t1.ID DESC
OPTION(HASH JOIN)