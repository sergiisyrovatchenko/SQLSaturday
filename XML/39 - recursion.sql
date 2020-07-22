DECLARE @XML XML = '
<a name="a">
    <a name="a1">
        <a name="a2" />
        <b name="b2" />
    </a>
    <b name="b1" />
</a>'

;WITH cte AS 
(
    SELECT [name] = t.c.value('@name', 'NVARCHAR(10)')
         , [type] = t.c.value('local-name(.)', 'NCHAR(1)')
         , parent_name = CAST(NULL AS NVARCHAR(10))
         , x = t.c.query('./*')
    FROM @XML.nodes('*') t(c)

    UNION ALL

    SELECT t.c.value('@name', 'NVARCHAR(10)')
         , t.c.value('local-name(.)', 'NCHAR(1)')
         , cte.[name]
         , t.c.query('./*')
    FROM cte
    CROSS APPLY x.nodes('*') t(c)
)
SELECT * 
FROM cte