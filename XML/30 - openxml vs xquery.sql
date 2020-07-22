SET NOCOUNT ON

/*
    <items>
      <item>
        <name>rpc</name>
        <number>1</number>
        <type>ABC</type>
        <status>0</status>
      </item>
      ...
    <items>
*/

DECLARE @x XML = (
        SELECT TOP(30000) t2.[name]
                        , t2.number
                        , t2.[type]
                        , t2.[status]
        FROM [master].dbo.spt_values t1
        CROSS JOIN [master].dbo.spt_values t2
        WHERE t1.[type] = 'P'
        FOR XML PATH('item'), ROOT('items')
    )

SET STATISTICS IO, TIME ON

PRINT 'OpenXML'

DECLARE @doc INT
EXEC sys.sp_xml_preparedocument @doc OUTPUT, @x

SELECT *
FROM OPENXML(@doc, '/items/item', 2)
    WITH (
          [name] NVARCHAR(35)
        , number INT
        , [type] NCHAR(3)
        , [status] INT
    )

EXEC sys.sp_xml_removedocument @doc

PRINT 'Wrong XQuery'

SELECT t.c.value('name[1]', 'NVARCHAR(35)')
     , t.c.value('number[1]', 'INT')
     , t.c.value('type[1]', 'NCHAR(3)')
     , t.c.value('status[1]', 'INT')
FROM @x.nodes('/items/item') t(c)

PRINT 'Correct XQuery'

SELECT t.c.value('(name/text())[1]', 'NVARCHAR(35)')
     , t.c.value('(number/text())[1]', 'INT')
     , t.c.value('(type/text())[1]', 'NCHAR(3)')
     , t.c.value('(status/text())[1]', 'INT')
FROM @x.nodes('/items/item') t(c)

SET STATISTICS IO, TIME OFF