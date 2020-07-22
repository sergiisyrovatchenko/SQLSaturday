SET NOCOUNT ON

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

DECLARE @xml XML = N'
<Users>
    <User Name="Sergey Syrovatchenko">
        <Age>28</Age>
        <Skills>
            <Skill>SQL Server</Skill>
            <Skill>T-SQL</Skill>
            <Skill>JSON</Skill>
            <Skill>XML</Skill>
        </Skills>
    </User>
    <User Name="JC Denton">
        <Skills>
            <Skill>Microfibral Muscle</Skill>
            <Skill>Regeneration</Skill>
            <Skill>EMP Shield</Skill>
        </Skills>
    </User>
    <User Name="Paul Denton">
        <Age>28</Age>
        <Skills>
            <Skill>Vision Enhancement</Skill>
        </Skills>
    </User>
</Users>'

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
    SELECT @int = @xml.value('(Users/User[1]/Age/text())[1]', 'INT')
         , @i += 1
INSERT INTO @t
SELECT '@xml', '(Users/User[1]/Age/text())[1]', 'INT', DATEDIFF(ms, @s, GETUTCDATE())

--6----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = JSON_VALUE(@jsonu, '$[1].User')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu', '$[1].User', 'NVARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

--7----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = JSON_VALUE(@jsonu_f, '$[1].User')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu_f', '$[1].User', 'NVARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

--8----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = JSON_VALUE(@json, '$[1].User')
         , @i += 1
INSERT INTO @t
SELECT '@json', '$[1].User', 'VARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

--9----------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = JSON_VALUE(@json_f, '$[1].User')
         , @i += 1
INSERT INTO @t
SELECT '@json_f', '$[1].User', 'VARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

--10---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = @xml.value('(Users/User[2]/@Name)[1]', 'NVARCHAR(100)')
         , @i += 1
INSERT INTO @t
SELECT '@xml', '(Users/User[2]/@Name)[1]', 'NVARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

--11---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = @xml.value('(Users/User[2]/@Name)[1]', 'VARCHAR(100)')
         , @i += 1
INSERT INTO @t
SELECT '@xml', '(Users/User[2]/@Name)[1]', 'VARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

--12---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = JSON_VALUE(@jsonu, '$[2].Skills[0]')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu', '$[2].Skills[0]', 'NVARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

--13---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @nvarchar = JSON_VALUE(@jsonu_f, '$[2].Skills[0]')
         , @i += 1
INSERT INTO @t
SELECT '@jsonu_f', '$[2].Skills[0]', 'NVARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

--14---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = JSON_VALUE(@json, '$[2].Skills[0]')
         , @i += 1
INSERT INTO @t
SELECT '@json', '$[2].Skills[0]', 'VARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

--15---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = JSON_VALUE(@json_f, '$[2].Skills[0]')
         , @i += 1
INSERT INTO @t
SELECT '@json_f', '$[2].Skills[0]', 'VARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

--16---------------------------------------------------

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @varchar = @xml.value('(Users/User[3]/Skills/Skill/text())[1]', 'VARCHAR(100)')
         , @i += 1
INSERT INTO @t
SELECT '@xml', '(Users/User[3]/Skills/Skill/text())[1]', 'VARCHAR', DATEDIFF(ms, @s, GETUTCDATE())

SELECT * FROM @t

/*
    iter   data_type  path                                    type      2016 SP1    2017 RTM
    ------ ---------- --------------------------------------- --------- ----------- -----------
    1      @jsonu     $[0].Age                                INT       830         273
    2      @jsonu_f   $[0].Age                                INT       853         300
    3      @json      $[0].Age                                INT       963         374
    4      @json_f    $[0].Age                                INT       987         413
    5      @xml       (Users/User[1]/Age/text())[1]           INT       23333       24717

    6      @jsonu     $[1].User                               NVARCHAR  1047        450
    7      @jsonu_f   $[1].User                               NVARCHAR  1153        567
    8      @json      $[1].User                               VARCHAR   1177        570
    9      @json_f    $[1].User                               VARCHAR   1303        693
    10     @xml       (Users/User[2]/@Name)[1]                NVARCHAR  18864       20070
    11     @xml       (Users/User[2]/@Name)[1]                VARCHAR   18913       20117

    12     @jsonu     $[2].Skills[0]                          NVARCHAR  1347        746
    13     @jsonu_f   $[2].Skills[0]                          NVARCHAR  1563        980
    14     @json      $[2].Skills[0]                          VARCHAR   1483        860
    15     @json_f    $[2].Skills[0]                          VARCHAR   1717        1094
    16     @xml       (Users/User[3]/Skills/Skill/text())[1]  VARCHAR   19510       20767
*/