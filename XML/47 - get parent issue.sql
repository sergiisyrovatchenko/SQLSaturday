SET NOCOUNT ON

USE tempdb
GO

SET STATISTICS PROFILE, TIME, IO ON

SELECT t.c.value('../@obj_name', 'SYSNAME')
     , t.c.value('@name', 'SYSNAME')
FROM dbo.xml_file_2
CROSS APPLY x.nodes('objs/obj/i') t(c)

SELECT t.c.value('@obj_name', 'SYSNAME')
     , t2.c2.value('@name', 'SYSNAME')
FROM dbo.xml_file_2
OUTER APPLY x.nodes('objs/obj') t(c)
CROSS APPLY t.c.nodes('i') t2(c2)

SET STATISTICS PROFILE, TIME, IO OFF

/*
    Table 'xml_file_2'. Scan count 1, logical reads 1, ..., lob logical reads 735414, ...
        CPU time = 106766 ms, elapsed time = 107048 ms

    Table 'xml_file_2'. Scan count 1, logical reads 1, ..., lob logical reads 818, ...
        CPU time = 250 ms, elapsed time = 360 ms
*/

------------------------------------------------------

USE AdventureWorks2014
GO

DECLARE @xml XML = (
    SELECT [@obj_name] = o.[name]
         , [columns] = (
             SELECT i.[name]
             FROM sys.all_columns i
             WHERE i.[object_id] = o.[object_id]
             FOR XML AUTO, TYPE
         )
    FROM sys.all_objects o
    WHERE o.[type] IN ('U', 'V')
    FOR XML PATH('obj')
)

SELECT t.c.value('../../@obj_name', 'SYSNAME')
     , t.c.value('@name', 'SYSNAME')
FROM @xml.nodes('obj/columns/*') t(c)
GO

------------------------------------------------------

USE tempdb
GO

DECLARE @xml XML = (SELECT x FROM dbo.xml_file_2)
      , @idoc INT

EXEC sys.sp_xml_preparedocument @idoc OUTPUT, @xml 

SELECT *
FROM OPENXML(@idoc, '/objs/obj/i') 
    WITH (
          [name]  SYSNAME '../@obj_name'
        , col     SYSNAME '@name'
    )

EXEC sys.sp_xml_removedocument @idoc