DECLARE @x XML = N'
<items limit="65000" offset="0" total="1">
    <item id="157">
        <property name="id" type="int" primary-key="1">1575</property>
        <property name="emit" type="int">16445</property>
        <property name="inn" type="varchar">777</property>
    </item>
    <item id="158">
        <property name="id" type="int" primary-key="1">155</property>
        <property name="emit" type="int">16448</property>
        <property name="inn" type="varchar">788</property>
    </item>
</items>'

SELECT @x = t.x
FROM (
    SELECT TOP (1000) @x AS [*]
    FROM [master].dbo.spt_values a
    CROSS JOIN [master].dbo.spt_values b
    FOR XML PATH (''), TYPE, ROOT ('result')
) t (x)

DECLARE @id INT

SET STATISTICS TIME ON

DECLARE @h INT
EXEC sys.sp_xml_preparedocument @h OUTPUT, @x

SELECT @id = id
     , @id = [property/id]
     , @id = [property/name]
     , @id = [property/emit.em_inn]
FROM OPENXML(@h, '/result/items/item')
WITH (
        id INT '@id',
        [property/id] INT 'property[@name = "id"][1]',
        [property/name] INT 'property[@name = "emit"][1]',
        [property/emit.em_inn] INT 'property[@name = "inn"][1]'
    )

EXEC sys.sp_xml_removedocument @h

SELECT @id = [id]
     , @id = MAX(CASE WHEN nm = 'id' THEN val END)
     , @id = MAX(CASE WHEN nm = 'emit' THEN val END)
     , @id = MAX(CASE WHEN nm = 'inn' THEN val END)
FROM (
    SELECT id = t.c.value('@id', 'int')
         , nm = t2.c2.value('@name', 'SYSNAME')
         , val = t2.c2.value('text()[1]', 'SYSNAME')
    FROM @x.nodes('/result/items/item') t(c)
    CROSS APPLY t.c.nodes('property') t2(c2)
) t
GROUP BY id

SET STATISTICS TIME OFF

/*
    SQL Server 2008R2:
       CPU time = 78 ms,  elapsed time = 82 ms.
       CPU time = 62 ms,  elapsed time = 66 ms.

       CPU time = 12250 ms,  elapsed time = 12319 ms.

   SQL Server 2019:
       CPU time = 78 ms,  elapsed time = 81 ms.
       CPU time = 78 ms,  elapsed time = 79 ms.

       CPU time = 94 ms,  elapsed time = 94 ms.
*/