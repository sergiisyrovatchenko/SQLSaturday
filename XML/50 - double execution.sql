SET NOCOUNT ON

USE tempdb
GO

SET STATISTICS TIME, IO ON

SELECT t.c.value('@obj_id', 'INT')
FROM dbo.xml_file_2
CROSS APPLY x.nodes('objs/obj') t(c)
WHERE t.c.value('@obj_id', 'INT') > 0

SELECT *
FROM (
    SELECT id = t.c.value('@obj_id', 'INT')
    FROM dbo.xml_file_2
    CROSS APPLY x.nodes('objs/obj') t(c)
) t
WHERE t.id > 0

SELECT t.c.value('@obj_id', 'INT')
FROM dbo.xml_file_2
CROSS APPLY x.nodes('objs/obj[@obj_id > 0]') t(c)

SET STATISTICS TIME, IO OFF

/*
    Table 'xml_file_2'. Scan count 1, logical reads 1, ..., lob logical reads 342, ...
        CPU time = 31 ms, elapsed time = 27 ms

    Table 'xml_file_2'. Scan count 1, logical reads 1, ..., lob logical reads 228, ...
        CPU time = 16 ms, elapsed time = 18 ms

    Table 'Worktable'. Scan count 0, logical reads 0, ..., lob logical reads 0, ...
    Table 'xml_file_2'. Scan count 1, logical reads 1, ..., lob logical reads 342, ...
        CPU time = 31 ms, elapsed time = 26 ms
*/