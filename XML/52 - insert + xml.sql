/*
    DBCC DROPCLEANBUFFERS
    DBCC FREEPROCCACHE
*/

DECLARE @x XML = (
        SELECT TOP(1000) a.number -- [@number] = a.number
        FROM [master].dbo.spt_values a
        CROSS JOIN [master].dbo.spt_values b
        FOR XML PATH('i')
    )

DECLARE @t TABLE (number INT) -- #, @, dbo, ...

DECLARE @s DATETIME = GETDATE()

INSERT INTO @t (number)
SELECT t.c.value('.', 'INT')
    -- t.c.value('(./text())[1]', 'INT')
    -- t.c.value('@number', 'INT')
FROM @x.nodes('i') t(c)
--OPTION (OPTIMIZE FOR (@x = NULL)) -- 2008 RTM+

SELECT @@version, DATEDIFF(ms, @s, GETDATE())
GO

-- Fixed: 2012 RTM

------------------------------------------------------

/*
    SET NOCOUNT ON

    IF OBJECT_ID('#temp', 'U') IS NOT NULL
        DROP TABLE #temp
    GO

    CREATE TABLE #temp (
          id INT
        , val INT
        , CONSTRAINT pk PRIMARY KEY (id)
    )
    CREATE NONCLUSTERED INDEX ix ON #temp (val)
    GO

    INSERT INTO #temp
    VALUES (1, 1), (2, 2), (3, 3)

    /*
        1,1 -> 1,3 | 2,2 -> 2,4 | 1,3 -> 1,5
        2,2        | 1,3        | 3,3
        3,3        | 3,3        | 2,4
    */

    UPDATE t
    SET val += 2
    FROM #temp t WITH (INDEX (pk))

    -- halloween protection

    -- table spool
    UPDATE t
    SET val += 2
    FROM #temp t WITH (INDEX (ix))

    -- sort
    UPDATE t
    SET id += 2
    FROM #temp t WITH (INDEX (pk))
*/