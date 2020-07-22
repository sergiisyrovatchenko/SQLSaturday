DECLARE @t TABLE (
      id INT PRIMARY KEY
    , a TINYINT NOT NULL
    , b TINYINT NOT NULL
    , c TINYINT NOT NULL
)

INSERT INTO @t
VALUES (1, 5, 3, 1), (2, 0, 8, 1), (3, 2, 4, 11)

SELECT * 
FROM @t
UNPIVOT (
    val FOR code IN (a, b, c)
) unpiv

SELECT id, val, code
FROM @t
CROSS APPLY (
    VALUES (a, 'a'), (b, 'b'), (c, 'c')
) t2 (val, code)

SELECT id
     , t.c.value('.', 'TINYINT')
     , t.c.value('local-name(.)', 'CHAR(1)')
FROM (
    SELECT id, x = (
            SELECT a, b, c
            FOR XML RAW('t'), TYPE
        )
    FROM @t
) p
CROSS APPLY x.nodes('t/@*') t(c)