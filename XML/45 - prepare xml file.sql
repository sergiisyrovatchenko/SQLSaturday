/*
    EXEC sys.sp_configure 'show advanced options', 1
    GO
    RECONFIGURE
    GO

    EXEC sys.sp_configure 'xp_cmdshell', 1
    GO
    RECONFIGURE WITH OVERRIDE
    GO
*/

USE AdventureWorks2014
GO

DROP TABLE IF EXISTS tempdb.dbo.xml_file_1
DROP TABLE IF EXISTS tempdb.dbo.xml_file_2
GO

SELECT x = (
    SELECT [@obj_id] = o.[object_id]
         , [@obj_name] = o.[name]
         , [@sch_name] = s.[name]
         , (
             SELECT i.[name]
                  , i.column_id
                  , i.user_type_id
                  , i.is_nullable
                  , i.is_identity
             FROM sys.all_columns i
             WHERE i.[object_id] = o.[object_id]
             FOR XML AUTO, TYPE
         )
    FROM sys.all_objects o
    JOIN sys.schemas s ON o.[schema_id] = s.[schema_id]
    WHERE o.[type] IN ('U', 'V')
    FOR XML PATH('obj'), ROOT('objs'), TYPE -- !!!
)
INTO tempdb.dbo.xml_file_1

SELECT x = CAST((
    SELECT [@obj_id] = o.[object_id]
         , [@obj_name] = o.[name]
         , [@sch_name] = s.[name]
         , (
             SELECT i.[name]
                  , i.column_id
                  , i.user_type_id
                  , i.is_nullable
                  , i.is_identity
             FROM sys.all_columns i
             WHERE i.[object_id] = o.[object_id]
             FOR XML AUTO, TYPE
         )
    FROM sys.all_objects o
    JOIN sys.schemas s ON o.[schema_id] = s.[schema_id]
    WHERE o.[type] IN ('U', 'V')
    FOR XML PATH('obj'), ROOT('objs') -- !!!
) AS XML)  -- !!!
INTO tempdb.dbo.xml_file_2

DECLARE @sql NVARCHAR(4000) = 'bcp "SELECT * FROM tempdb.dbo.xml_file_1" queryout "X:\sample_1.xml" -S ' + @@servername + ' -T -w -r -t'
EXEC sys.xp_cmdshell @sql

SET @sql = 'bcp "SELECT * FROM tempdb.dbo.xml_file_2" queryout "X:\sample_2.xml" -S ' + @@servername + ' -T -w -r -t'
EXEC sys.xp_cmdshell @sql

/*
    <objs>
      <obj obj_id="2098106515" obj_name="SalesTerritoryHistory" sch_name="Sales">
        <i name="BusinessEntityID" column_id="1" user_type_id="56" is_nullable="0" is_identity="0" />
        <i name="TerritoryID" column_id="2" user_type_id="56" is_nullable="0" is_identity="0" />
        <i name="StartDate" column_id="3" user_type_id="61" is_nullable="0" is_identity="0" />
        <i name="EndDate" column_id="4" user_type_id="61" is_nullable="1" is_identity="0" />
        <i name="ModifiedDate" column_id="6" user_type_id="61" is_nullable="0" is_identity="0" />
      </obj>
    </objs>
*/