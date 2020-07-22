USE tempdb
GO

IF EXISTS(
        SELECT *
        FROM sys.xml_schema_collections
        WHERE [name] = 'EventSchema'
    )
    DROP XML SCHEMA COLLECTION EventSchema
GO

CREATE XML SCHEMA COLLECTION EventSchema AS N'
<schema xmlns="http://www.w3.org/2001/XMLSchema">
    <element name="Events">
        <complexType>
            <sequence>
                <element name="Event" minOccurs="1" maxOccurs="unbounded">
                    <complexType>
                        <sequence>
                            <element name="Address" minOccurs="1" maxOccurs="1" />
                            <element name="Phone" minOccurs="0" maxOccurs="1" />
                        </sequence>
                        <attribute name="ID" type="string" use="required" />
                        <attribute name="Name" type="string" use="required" />
                        <attribute name="Year" type="string" />
                        <attribute name="IsActive" type="boolean" />
                    </complexType>
                </element>
            </sequence>
        </complexType>
    </element>
</schema>'
GO

DECLARE @x1 XML
      , @x2 XML(EventSchema) = N'
<Events>
    <Event ID="753" Name="SQL Saturday Lviv #753" Year="2018">
        <Address>Hotel Taurus, 5, Kn. Sviatoslava Sq.</Address>
    </Event>
    <Event ID="780" Name="SQL Saturday Kharkiv #780" Year="2018" IsActive="1">
        <Address>Fabrika, Blagovischenska str. 1</Address>
        <Phone>098-408-32-12</Phone>
    </Event>
</Events>'

SET @x1 = @x2

SELECT x1 = DATALENGTH(@x1)
     , x2 = DATALENGTH(@x2)