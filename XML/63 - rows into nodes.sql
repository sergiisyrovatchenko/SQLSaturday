DROP TABLE IF EXISTS #temp
GO

SELECT *
INTO #temp
FROM (
    VALUES ('A', 578), ('B', 300), ('C', 147)
         , ('D', 45), ('E', 8)
) t (Col, Val)

------------------------------------------------------

SELECT *
FROM #temp
PIVOT (
    MAX(Val)
    FOR Col IN ([A], [B], [C], [D], [E])
) p
FOR XML PATH ('')

SELECT CAST('<' + Col + '>' + CAST(Val AS VARCHAR(20)) + '</' + Col + '>' AS XML)
FROM #temp
FOR XML PATH('')

DECLARE @sql NVARCHAR(MAX)=
    'SELECT ' + (
        STUFF((
            SELECT ',' + CAST(Val AS VARCHAR(20)) + ' AS [' + Col + ']'
            FROM #temp
            FOR XML PATH('')
        ), 1, 1, '')
    ) + ' FOR XML PATH('''')'

EXEC sys.sp_executesql @sql

/*
    <A>578</A>
    <B>300</B>
    <C>147</C>
    <D>45</D>
    <E>8</E>
*/

------------------------------------------------------

SELECT [@name] = Col
     , [*] = Val
FROM #temp
FOR XML PATH('Tag')

/*
    <Tag name="A">578</Tag>
    <Tag name="B">300</Tag>
    <Tag name="C">147</Tag>
    <Tag name="D">45</Tag>
    <Tag name="E">8</Tag>
*/