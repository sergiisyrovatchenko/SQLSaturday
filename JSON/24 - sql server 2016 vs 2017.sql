SET NOCOUNT ON
SET STATISTICS TIME, IO OFF

DECLARE @jsonu NVARCHAR(MAX) = N'[
    {"User":"Sergey Syrovatchenko","Age":28,"Skills":["SQL Server","T-SQL","JSON","XML"]},
    {"User":"JC Denton","Skills":["Microfibral Muscle","Regeneration","EMP Shield"]},
    {"User":"Paul Denton","Age":32,"Skills":["Vision Enhancement"]}]'

DECLARE @jsonu_f NVARCHAR(MAX) = N'[
   {
      "User":"Sergey Syrovatchenko",
      "Age":28,
      "Skills":[
         "SQL Server",
         "T-SQL",
         "JSON",
         "XML"
      ]
   },
   {
      "User":"JC Denton",
      "Skills":[
         "Microfibral Muscle",
         "Regeneration",
         "EMP Shield"
      ]
   },
   {
      "User":"Paul Denton",
      "Age":32,
      "Skills":[
         "Vision Enhancement"
      ]
   }
]'

DECLARE @json VARCHAR(MAX) = @jsonu
      , @json_f VARCHAR(MAX) = @jsonu_f

DECLARE @i INT
      , @int INT
      , @varchar VARCHAR(100)
      , @nvarchar NVARCHAR(100)
      , @s DATETIME
      , @runs INT = 100000

DECLARE @t TABLE (
      iter INT IDENTITY PRIMARY KEY
    , data_type VARCHAR(100)
    , [path] VARCHAR(1000)
    , [type] VARCHAR(1000)
    , time_ms INT
)

--1----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @int = JSON_VALUE(@jsonu, '$[0].Age')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu', '$[0].Age', 'INT', DATEDIFF(ms, @s, GETUTCDATE())

--2----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @int = JSON_VALUE(@jsonu_f, '$[0].Age')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu_f', '$[0].Age', 'INT', DATEDIFF(ms, @s, GETUTCDATE())

--3----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @int = JSON_VALUE(@json, '$[0].Age')
         , @i += 1
INSERT INTO @t
SELECT '@json', '$[0].Age', 'INT', DATEDIFF(ms, @s, GETUTCDATE())

--4----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @int = JSON_VALUE(@json_f, '$[0].Age')
         , @i += 1
INSERT INTO @t
SELECT '@json_f', '$[0].Age', 'INT', DATEDIFF(ms, @s, GETUTCDATE())

--5----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = JSON_VALUE(@jsonu, '$[1].User')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu', '$[1].User', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

--6----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = JSON_VALUE(@jsonu_f, '$[1].User')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu_f', '$[1].User', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

--7----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = JSON_VALUE(@json, '$[1].User')
         , @i += 1
INSERT INTO @t
SELECT '@json', '$[1].User', 'VARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

--8----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = JSON_VALUE(@json_f, '$[1].User')
         , @i += 1
INSERT INTO @t
SELECT '@json_f', '$[1].User', 'VARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

--9---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = JSON_VALUE(@jsonu, '$[2].Skills[0]')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu', '$[2].Skills[0]', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

--10---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = JSON_VALUE(@jsonu_f, '$[2].Skills[0]')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu_f', '$[2].Skills[0]', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

--11---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = JSON_VALUE(@json, '$[2].Skills[0]')
         , @i += 1
INSERT INTO @t
SELECT '@json', '$[2].Skills[0]', 'VARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

--12---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = JSON_VALUE(@json_f, '$[2].Skills[0]')
         , @i += 1
INSERT INTO @t
SELECT '@json_f', '$[2].Skills[0]', 'VARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT * FROM @t

SET STATISTICS TIME, IO ON
GO

/*
    iter   data_type  path             type            2016 SP1    2017 RTM
    ------ ---------- ---------------- --------------- ----------- -----------
    1      @jsonu     $[0].Age         INT             846         190
    2      @jsonu_f   $[0].Age         INT             857         210
    3      @json      $[0].Age         INT             953         263
    4      @json_f    $[0].Age         INT             987         300

    5      @jsonu     $[1].User        NVARCHAR(MAX)   1047        370
    6      @jsonu_f   $[1].User        NVARCHAR(MAX)   1153        487
    7      @json      $[1].User        VARCHAR(MAX)    1177        460
    8      @json_f    $[1].User        VARCHAR(MAX)    1303        590

    9      @jsonu     $[2].Skills[0]   NVARCHAR(MAX)   1347        660
    10     @jsonu_f   $[2].Skills[0]   NVARCHAR(MAX)   1563        886
    11     @json      $[2].Skills[0]   VARCHAR(MAX)    1483        744
    12     @json_f    $[2].Skills[0]   VARCHAR(MAX)    1717        990
*/


------------------------------------------------------

SET STATISTICS TIME ON

DECLARE @JSON NVARCHAR(MAX)
SELECT @JSON = BulkColumn
FROM OPENROWSET(BULK 'X:\sample1.txt', SINGLE_NCLOB) x

SELECT *
FROM OPENJSON(@JSON)
WITH (
      ProductID INT
    , [Name] NVARCHAR(50)
    , ProductNumber NVARCHAR(25)
    , OrderQty SMALLINT
    , UnitPrice MONEY
    , ListPrice MONEY
    , Color NVARCHAR(15)
    , MakeFlag BIT
)

SET STATISTICS TIME OFF

/*
    2016 SP1: CPU time = 1469 ms, elapsed time = 1615 ms
    2017 RTM: CPU time = 1250 ms, elapsed time = 1342 ms
*/