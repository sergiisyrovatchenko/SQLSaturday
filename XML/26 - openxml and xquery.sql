DECLARE @x XML = N'
<Events>
    <Event ID="753" Name="SQL Saturday Lviv #753" Year="2018">
        <Address>Hotel Taurus, 5, Kn. Sviatoslava Sq.</Address>
    </Event>
    <Event ID="780" Name="SQL Saturday Kharkiv #780" Year="2018" IsActive="1">
        <Address>Fabrika, Blagovischenska str. 1</Address>
        <Phone>098-408-32-12</Phone>
    </Event>
</Events>'

DECLARE @doc INT
EXEC sys.sp_xml_preparedocument @doc OUTPUT, @x

/*
    1 - nodes
    2 - attributes
    3 - all
*/

SELECT *
FROM OPENXML(@doc, '/Events/Event', 3)
    WITH (
          [Name] NVARCHAR(100)
        , ID INT
        , IsActive BIT
        , [Address] NVARCHAR(100)
        , Phone NVARCHAR(100)
    )

EXEC sys.sp_xml_removedocument @doc

SELECT [Name] =    t.c.value('@Name', 'NVARCHAR(100)')
     , ID =        t.c.value('@ID', 'INT')
     , IsActive =  t.c.value('@IsActive', 'BIT')
     , [Address] = t.c.value('Address[1]', 'NVARCHAR(100)')
     , Phone =     t.c.value('Phone[1]', 'NVARCHAR(100)')
FROM @x.nodes('/Events/Event') t(c)