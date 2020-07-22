SET NOCOUNT ON

USE tempdb
GO

SELECT x
     , xml_size = DATALENGTH(x)
     , string_size = DATALENGTH(CAST(x AS NVARCHAR(MAX)))
     , sha1 = HASHBYTES('SHA1', CAST(x AS NVARCHAR(MAX)))
FROM dbo.xml_file_1

UNION ALL

SELECT x
     , DATALENGTH(x)
     , DATALENGTH(CAST(x AS NVARCHAR(MAX)))
     , HASHBYTES('SHA1', CAST(x AS NVARCHAR(MAX)))
FROM dbo.xml_file_2

SELECT DATALENGTH(CAST(BulkColumn AS XML))
FROM OPENROWSET(BULK 'X:\sample_1.xml', SINGLE_BLOB) x

UNION ALL

SELECT DATALENGTH(CAST(BulkColumn AS XML))
FROM OPENROWSET(BULK 'X:\sample_2.xml', SINGLE_BLOB) x

SELECT *
FROM sys.columns
WHERE [object_id] IN (OBJECT_ID('dbo.xml_file_1'), OBJECT_ID('dbo.xml_file_2'))

SELECT [type_desc], total_pages, used_pages, data_pages
FROM sys.allocation_units a
WHERE EXISTS(
        SELECT *
        FROM sys.partitions p
        WHERE p.[object_id] IN (OBJECT_ID('dbo.xml_file_1'), OBJECT_ID('dbo.xml_file_2'))
            AND p.[partition_id] = a.container_id
    )

------------------------------------------------------

SET STATISTICS PROFILE, TIME, IO ON

SELECT t.c.value('@obj_name', 'SYSNAME')
     , t2.c2.value('@name', 'SYSNAME')
FROM dbo.xml_file_1
OUTER APPLY x.nodes('objs/obj') t(c)
CROSS APPLY t.c.nodes('i') t2(c2)

SELECT t.c.value('@obj_name', 'SYSNAME')
     , t2.c2.value('@name', 'SYSNAME')
FROM dbo.xml_file_2
OUTER APPLY x.nodes('objs/obj') t(c)
CROSS APPLY t.c.nodes('i') t2(c2)

SET STATISTICS PROFILE, TIME, IO OFF

/*
    Table 'xml_file_1'. Scan count 1, logical reads 1, ..., lob logical reads 729990, ..., lob read-ahead reads 17400.
       CPU time = 28015 ms, elapsed time = 28311 ms

    Table 'xml_file_2'. Scan count 1, logical reads 1, ..., lob logical reads 818, ..., lob read-ahead reads 0.
       CPU time = 235 ms, elapsed time = 386 ms
*/

------------------------------------------------------

DECLARE @x1 XML = (
            SELECT ID = [object_id]
                 , (
                     SELECT ZZ = 'abc'
                     FOR XML PATH(''), TYPE
                 )
            FROM sys.all_columns
            FOR XML PATH('ITEM'), TYPE
        )
DECLARE @x2 XML = (
            SELECT ID = [object_id]
                 , (
                     SELECT ZZ = 'abc'
                     FOR XML PATH(''), TYPE
                 )
            FROM sys.all_columns
            FOR XML PATH('ITEM') --, TYPE
        )

SELECT DATALENGTH(@x1)
     , DATALENGTH(@x2)
     , @x1
     , @x2

/*
    ??.°.?.I.T.E.M.?...?
    .I.D.?...?.?...-.1.5
    .6.2.6.1.0.9.1.0.???
    ?.°.?.Z.Z.?...?...a.
    b.c.????.?...-.1.5.4
    .6.6.1.0.8.5.3.????.
    °.?.Z.Z.?...?...a.b.
    c.???

    ITEM ID -1562610910 ZZ abc -1546610853 ZZ abc

    ??.°.?.I.T.E.M.?...?
    .?.I.D.?...?...-.1.5
    .6.2.6.1.0.9.1.0.??.
    Z.Z.?...?...a.b.c.??
    ?.?...-.1.5.4.6.6.1.
    0.8.5.3.??...a.b.c.?
    ?

    ITEM ID -1562610910 ZZ abc -1546610853 abc
*/

SET STATISTICS TIME, IO ON

SELECT t.c.value('(ID/text())[1]', 'INT')
     , t.c.value('(ZZ/text())[1]', 'NCHAR(3)')
FROM @x1.nodes('ITEM') t(c)

SELECT t.c.value('(ID/text())[1]', 'INT')
     , t.c.value('(ZZ/text())[1]', 'NCHAR(3)')
FROM @x2.nodes('ITEM') t(c)

SET STATISTICS TIME, IO OFF

/*
    @x1: CPU time = 140 ms, elapsed time = 331 ms
    @x2: CPU time = 78 ms, elapsed time = 175 ms
*/