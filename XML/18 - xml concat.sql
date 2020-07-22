DECLARE @t TABLE (x XML)
INSERT INTO @t
VALUES ('<cell id="1" />'), ('<cell id="2" />')
     , ('<cell id="3" />'), ('<cell id="4" />')

/*
    <cell id="1" />
    <cell id="2" />
    <cell id="3" />
    <cell id="4" />
*/

SELECT x
FROM @t
FOR XML PATH(''), TYPE

SELECT (
    SELECT x
    FROM @t
    FOR XML PATH(''), TYPE
).query('//cell')

SELECT [*] = x
FROM @t
FOR XML PATH(''), TYPE