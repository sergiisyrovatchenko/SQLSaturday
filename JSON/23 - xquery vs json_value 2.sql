SET NOCOUNT ON

DECLARE @jsonu NVARCHAR(MAX) = N'{"User":"JC Denton","Age":28}'
DECLARE @json VARCHAR(MAX) = @jsonu

DECLARE @xml_1 XML = N'<User Name="JC Denton" Age="28" />'
      , @xml_2 XML = N'<User><Name>JC Denton</Name><Age>28</Age></User>'

DECLARE @i INT
      , @int INT
      , @varchar VARCHAR(100)
      , @nvarchar NVARCHAR(100)
      , @s DATETIME
      , @runs INT = 500000

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
    SELECT @int = JSON_VALUE(@jsonu, '$.Age')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu', '$.Age', 'INT', DATEDIFF(ms, @s, GETUTCDATE())

--2----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @int = JSON_VALUE(@json, '$.Age')
         , @i += 1
INSERT INTO @t
SELECT '@json', '$.Age', 'INT', DATEDIFF(ms, @s, GETUTCDATE())

--3----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @int = @xml_1.value('(User/@Age)[1]', 'INT')
         , @i += 1
INSERT INTO @t
SELECT '@xml_1', '(User/@Age)[1]', 'INT', DATEDIFF(ms, @s, GETUTCDATE())

--4----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @int = @xml_2.value('(User/Age/text())[1]', 'INT')
         , @i += 1
INSERT INTO @t
SELECT '@xml_2', '(User/Age/text())[1]', 'INT', DATEDIFF(ms, @s, GETUTCDATE())

--5----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = JSON_VALUE(@jsonu, '$.User')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu', '$.User', 'NVARCHAR(100)', DATEDIFF(ms, @s, GETUTCDATE())

--6----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = JSON_VALUE(@json, '$.User')
         , @i += 1
INSERT INTO @t
SELECT '@json', '$.User', 'VARCHAR(100)', DATEDIFF(ms, @s, GETUTCDATE())

--7----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = @xml_1.value('(User/@Name)[1]', 'NVARCHAR(100)')
         , @i += 1
INSERT INTO @t
SELECT '@xml_1', '(User/@Name)[1]', 'NVARCHAR(100)', DATEDIFF(ms, @s, GETUTCDATE())

--8----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = @xml_1.value('(User/@Name)[1]', 'VARCHAR(100)')
         , @i += 1
INSERT INTO @t
SELECT '@xml_1', '(User/@Name)[1]', 'VARCHAR(100)', DATEDIFF(ms, @s, GETUTCDATE())

--9----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = @xml_2.value('(User/Name/text())[1]', 'NVARCHAR(100)')
         , @i += 1
INSERT INTO @t
SELECT '@xml_2', '(User/Name/text())[1]', 'NVARCHAR(100)', DATEDIFF(ms, @s, GETUTCDATE())

--10---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = @xml_2.value('(User/Name/text())[1]', 'VARCHAR(100)')
         , @i += 1
INSERT INTO @t
SELECT '@xml_2', '(User/Name/text())[1]', 'VARCHAR(100)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT * FROM @t

/*
    iter  data_type   path                    type             2016 SP1    2017 RTM
    ----- ----------- ----------------------- ---------------- ----------- -----------
    1     @jsonu      $.Age                   INT              3916        1160
    2     @json       $.Age                   INT              4430        1603

    3     @xml_1      (User/@Age)[1]          INT              5754        5984
    4     @xml_2      (User/Age/text())[1]    INT              5986        6176

    5     @jsonu      $.User                  NVARCHAR(100)    3727        1010
    6     @json       $.User                  VARCHAR(100)     4250        1447

    7     @xml_1      (User/@Name)[1]         NVARCHAR(100)    5863        6003
    8     @xml_1      (User/@Name)[1]         VARCHAR(100)     5950        6117
    9     @xml_2      (User/Name/text())[1]   NVARCHAR(100)    5797        5943
    10    @xml_2      (User/Name/text())[1]   VARCHAR(100)     5930        6070
*/