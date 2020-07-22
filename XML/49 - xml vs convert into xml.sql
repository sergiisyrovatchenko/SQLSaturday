SET NOCOUNT ON

USE tempdb
GO

DECLARE @xml XML = (SELECT * FROM dbo.xml_file_2)
DECLARE @txt NVARCHAR(MAX) = CAST(@xml AS NVARCHAR(MAX))

SET STATISTICS PROFILE, TIME, IO ON

SELECT t.c.value('@obj_id', 'INT')
FROM (
    SELECT x = CONVERT(XML, @txt)--.query('.')
) r
CROSS APPLY r.x.nodes('objs/obj') t(c)

SELECT t.c.value('@obj_id', 'INT')
FROM @xml.nodes('objs/obj') t(c)

SET STATISTICS PROFILE, TIME, IO OFF

/*
    Table 'Worktable'. Scan count 0, logical reads 4605, ..., lob logical reads 526365, ...
        CPU time = 31578 ms, elapsed time = 31688 ms

    ...
        CPU time = 15 ms, elapsed time = 130 ms
*/