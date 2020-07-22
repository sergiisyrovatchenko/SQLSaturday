USE AdventureWorks2014 -- 2012 SP1
GO

EXEC sys.sp_db_selective_xml_index @dbname = NULL, @selective_xml_index = 'ON'
GO

/*
    ALTER TABLE dbo.DatabaseLog DROP CONSTRAINT PK_DatabaseLog_DatabaseLogID
    GO
    ALTER TABLE dbo.DatabaseLog ADD CONSTRAINT PK_DatabaseLog_DatabaseLogID
        PRIMARY KEY CLUSTERED (DatabaseLogID)
    GO

    DROP INDEX ix ON dbo.DatabaseLog
*/

/*
    <EVENT_INSTANCE>
      <EventType>CREATE_TABLE</EventType>
      <PostTime>2012-03-14T13:14:18.787</PostTime>
      <SPID>51</SPID>
      <ServerName>DERRICKVLAPTOP2</ServerName>
      <LoginName>REDMOND\derrickv</LoginName>
      <UserName>dbo</UserName>
      <DatabaseName>AdventureWorks2012</DatabaseName>
      <SchemaName>dbo</SchemaName>
      <ObjectName>ErrorLog</ObjectName>
      <ObjectType>TABLE</ObjectType>
      <TSQLCommand>
        <SetOptions ANSI_NULLS="ON" ANSI_NULL_DEFAULT="ON" ANSI_PADDING="ON" QUOTED_IDENTIFIER="ON" ENCRYPTED="FALSE" />
        <CommandText>...</CommandText>
      </TSQLCommand>
    </EVENT_INSTANCE>
*/

/*
    Optimization | More efficient storage | Improved performance
    ------------------------------------------------------------
    node()       | Yes                    | No
    SINGLETON    | No                     | Yes
    DATATYPE     | Yes                    | Yes
    MAXLENGTH    | Yes                    | Yes
*/

CREATE SELECTIVE XML INDEX ix ON dbo.DatabaseLog (XmlEvent)
FOR
(
      p1 = '/EVENT_INSTANCE/EventType' AS SQL NVARCHAR(30)
    , p2 = '/EVENT_INSTANCE/PostTime' AS XQUERY 'node()' SINGLETON
    , p3 = '/EVENT_INSTANCE/TSQLCommand/CommandText' AS XQUERY 'node()'
    , p4 = '/EVENT_INSTANCE/TSQLCommand/CommandText/text()' AS SQL VARCHAR(MAX) SINGLETON
    , p5 = '/EVENT_INSTANCE/SPID'
    , p6 = '/EVENT_INSTANCE/EventType/text()' AS XQUERY 'xs:string' MAXLENGTH(30) SINGLETON
) 
WITH(DROP_EXISTING=ON)

SELECT XmlEvent.value('(EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(30)')
FROM dbo.DatabaseLog

SELECT DatabaseLogID
FROM dbo.DatabaseLog
WHERE XmlEvent.exist('/EVENT_INSTANCE/PostTime') = 1

SELECT *
FROM (
    SELECT txt = t.c.value('text()[1]', 'VARCHAR(MAX)')
    FROM dbo.DatabaseLog
    CROSS APPLY XmlEvent.nodes('EVENT_INSTANCE/TSQLCommand/CommandText') t(c)
) t
WHERE txt LIKE '%dbo%'

SELECT DatabaseLogID
FROM dbo.DatabaseLog
WHERE XmlEvent.exist('/EVENT_INSTANCE/SPID[. = 51]') = 1

CREATE XML INDEX ix2 ON dbo.DatabaseLog(XmlEvent)
    USING XML INDEX ix FOR (p6) 
GO

SELECT DatabaseLogID
FROM dbo.DatabaseLog
WHERE XmlEvent.exist('/EVENT_INSTANCE/EventType/text()[. = "CREATE_TYPE"]') = 1

SELECT DatabaseLogID
FROM dbo.DatabaseLog
WHERE XmlEvent.exist('/EVENT_INSTANCE/EventType/text()[. = "CREATE_TABLE"]') = 1

------------------------------------------------------

USE AdventureWorks2014
GO

SELECT OBJECT_NAME(parent_object_id),  *
FROM sys.objects o
WHERE o.name LIKE 'xml_sxi_%'
    AND o.[type] = 'IT'

SELECT *
FROM sys.---

SELECT COL_NAME(i.[object_id], ic.column_id)
     , i.[name]
     , i.index_id
     , i.[type_desc]
FROM sys.index_columns ic
JOIN sys.indexes i ON ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id
WHERE i.[object_id] = OBJECT_ID('sys.---')