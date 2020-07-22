SET NOCOUNT ON

DECLARE @x XML = N'
<Books>
    <Book ISBN="1-8656-1257-6">The Catcher in the Rye</Book>
</Books>'

SELECT t.c.value('Book[1]', 'NVARCHAR(100)')
FROM @x.nodes('Books') t(c)

SELECT t.c.value('.[1]', 'NVARCHAR(100)')
FROM @x.nodes('Books') t(c)

SELECT t.c.value('(Book/text())[1]', 'NVARCHAR(100)')
FROM @x.nodes('Books') t(c)
GO

------------------------------------------------------

DECLARE @x XML = N'
<Books>
    <Book ISBN="1-8656-1257-6">The Catcher in the Rye</Book>
</Books>'

SELECT t.c.value('Book[1]/@ISBN', 'NVARCHAR(20)')
FROM @x.nodes('Books') t(c)

SELECT t.c.value('(Book/@ISBN)[1]', 'NVARCHAR(20)')
FROM @x.nodes('Books') t(c)
GO

------------------------------------------------------

DECLARE @t TABLE (xpath VARCHAR(100), datatype VARCHAR(100), time_ms INT)
DECLARE @i INT = 1
      , @s DATETIME = GETUTCDATE()
      , @res NVARCHAR(100)
      , @runs INT = 100000
      , @x XML = N'<Book ISBN="1-8656-1257-6">The Catcher in the Rye</Book>'

WHILE @i <= @runs
    SELECT @res = @x.value('Book[1]', 'NVARCHAR(100)')
         , @i += 1
INSERT INTO @t
SELECT 'Book[1]', 'NVARCHAR(100)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x.value('.[1]', 'NVARCHAR(100)')
         , @i += 1
INSERT INTO @t
SELECT '.[1]', 'NVARCHAR(100)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x.value('(Book/text())[1]', 'NVARCHAR(100)')
         , @i += 1
INSERT INTO @t
SELECT '(Book/text())[1]', 'NVARCHAR(100)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x.value('Book[1]', 'NVARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT 'Book[1]', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x.value('.[1]', 'NVARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT '.[1]', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x.value('(Book/text())[1]', 'NVARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT '(Book/text())[1]', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x.value('Book[1]/@ISBN', 'NVARCHAR(20)')
         , @i += 1
INSERT INTO @t
SELECT 'Book[1]/@ISBN', 'NVARCHAR(20)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x.value('(Book/@ISBN)[1]', 'NVARCHAR(20)')
         , @i += 1
INSERT INTO @t
SELECT '(Book/@ISBN)[1]', 'NVARCHAR(20)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x.value('Book[1]/@ISBN', 'NVARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT 'Book[1]/@ISBN', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x.value('(Book/@ISBN)[1]', 'NVARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT '(Book/@ISBN)[1]', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT * FROM @t
GO

/*
    xpath               datatype       time_ms
    ------------------- -------------- --------
    Book[1]             NVARCHAR(100)  2176
    .[1]                NVARCHAR(100)  1550
    (Book/text())[1]    NVARCHAR(100)  1237

    Book[1]             NVARCHAR(MAX)  2873
    .[1]                NVARCHAR(MAX)  2310
    (Book/text())[1]    NVARCHAR(MAX)  1924

    Book[1]/@ISBN       NVARCHAR(20)   1880
    (Book/@ISBN)[1]     NVARCHAR(20)   1206

    Book[1]/@ISBN       NVARCHAR(MAX)  2614
    (Book/@ISBN)[1]     NVARCHAR(MAX)  1903
*/

------------------------------------------------------

DECLARE @x XML = N'
<Items>
    <Item>123</Item>
</Items>'

SELECT CAST(CAST(@x.query('/Items/Item/text()') AS NVARCHAR(50)) AS INT)

SELECT @x.value('(/Items/Item/text())[1]', 'INT')
GO

------------------------------------------------------

DECLARE @x XML = (
        SELECT TOP(1000000) [*] = t1.number -- INT
        FROM [master].dbo.spt_values t1
        CROSS JOIN [master].dbo.spt_values t2
        FOR XML PATH('i')
    )

SET STATISTICS TIME ON

SELECT t.c.value('(./text())[1]', 'NVARCHAR(MAX)')
FROM @x.nodes('i') t(c)

SELECT t.c.value('(./text())[1]', 'VARCHAR(MAX)')
FROM @x.nodes('i') t(c)

SELECT t.c.value('(./text())[1]', 'NVARCHAR(10)')
FROM @x.nodes('i') t(c)

SELECT t.c.value('(./text())[1]', 'VARCHAR(10)')
FROM @x.nodes('i') t(c)

SELECT t.c.value('(./text())[1]', 'INT')
FROM @x.nodes('i') t(c)

SET STATISTICS TIME OFF
GO

/*
    NVARCHAR(MAX): CPU = 5265 ms, Time = 5689 ms
    VARCHAR(MAX):  CPU = 5578 ms, Time = 5705 ms
    NVARCHAR(10):  CPU = 3172 ms, Time = 4834 ms
    VARCHAR(10):   CPU = 2890 ms, Time = 4844 ms
    INT:           CPU = 3110 ms, Time = 4210 ms
*/

------------------------------------------------------

DECLARE @t TABLE (xpath VARCHAR(100), datatype VARCHAR(100), time_ms INT)
DECLARE @i INT = 1
      , @s DATETIME = GETUTCDATE()
      , @u_max NVARCHAR(MAX)
      , @a_max VARCHAR(MAX)
      , @u_4000 NVARCHAR(4000)
      , @a_8000 VARCHAR(8000)
      , @runs INT = 100000
      , @x XML = (
                SELECT ', ' + [name]
                FROM sys.objects
                FOR XML PATH(''), TYPE
            )

WHILE @i <= @runs
    SELECT @u_max = @x.value('.', 'NVARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT '.', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @u_4000 = @x.value('.', 'NVARCHAR(4000)')
         , @i += 1
INSERT INTO @t
SELECT '.', 'NVARCHAR(4000)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @a_max = @x.value('.', 'VARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT '.', 'VARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @a_8000 = @x.value('.', 'VARCHAR(8000)')
         , @i += 1
INSERT INTO @t
SELECT '.', 'VARCHAR(8000)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @u_max = @x.value('.[1]', 'NVARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT '.[1]', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @u_4000 = @x.value('.[1]', 'NVARCHAR(4000)')
         , @i += 1
INSERT INTO @t
SELECT '.[1]', 'NVARCHAR(4000)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @a_max = @x.value('.[1]', 'VARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT '.[1]', 'VARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @a_8000 = @x.value('.[1]', 'VARCHAR(8000)')
         , @i += 1
INSERT INTO @t
SELECT '.[1]', 'VARCHAR(8000)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @u_max = @x.value('(./text())[1]', 'NVARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT '(./text())[1]', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @u_4000 = @x.value('(./text())[1]', 'NVARCHAR(4000)')
         , @i += 1
INSERT INTO @t
SELECT '(./text())[1]', 'NVARCHAR(4000)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @a_max = @x.value('(./text())[1]', 'VARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT '(./text())[1]', 'VARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @a_8000 = @x.value('(./text())[1]', 'VARCHAR(8000)')
         , @i += 1
INSERT INTO @t
SELECT '(./text())[1]', 'VARCHAR(8000)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @u_max = @x.value('text()[1]', 'NVARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT 'text()[1]', 'NVARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @u_4000 = @x.value('text()[1]', 'NVARCHAR(4000)')
         , @i += 1
INSERT INTO @t
SELECT 'text()[1]', 'NVARCHAR(4000)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @a_max = @x.value('text()[1]', 'VARCHAR(MAX)')
         , @i += 1
INSERT INTO @t
SELECT 'text()[1]', 'VARCHAR(MAX)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @a_8000 = @x.value('text()[1]', 'VARCHAR(8000)')
         , @i += 1
INSERT INTO @t
SELECT 'text()[1]', 'VARCHAR(8000)', DATEDIFF(ms, @s, GETUTCDATE())

SELECT * FROM @t

/*
    xpath           datatype         time_ms
    --------------- ---------------- --------
    .               NVARCHAR(MAX)    2296
    .               NVARCHAR(4000)   1457
    .               VARCHAR(MAX)     2467
    .               VARCHAR(8000)    1593

    .[1]            NVARCHAR(MAX)    2240
    .[1]            NVARCHAR(4000)   1423
    .[1]            VARCHAR(MAX)     2434
    .[1]            VARCHAR(8000)    1553

    (./text())[1]   NVARCHAR(MAX)    1817
    (./text())[1]   NVARCHAR(4000)   1140
    (./text())[1]   VARCHAR(MAX)     2090
    (./text())[1]   VARCHAR(8000)    1283

    text()[1]       NVARCHAR(MAX)    1823
    text()[1]       NVARCHAR(4000)   1124
    text()[1]       VARCHAR(MAX)     2070
    text()[1]       VARCHAR(8000)    1270
*/