SET NOCOUNT ON

SET STATISTICS PROFILE, TIME, IO ON

;WITH cte AS
(
    SELECT x = CAST(BulkColumn AS XML)--.query('.')
    FROM OPENROWSET(BULK 'X:\sample_1.xml', SINGLE_BLOB) x
)
SELECT t.c.value('@obj_id', 'INT')
FROM cte
CROSS APPLY x.nodes('objs/obj') t(c)
GO

DECLARE @xml XML
SELECT @xml = BulkColumn
FROM OPENROWSET(BULK 'X:\sample_1.xml', SINGLE_BLOB) x

SELECT t.c.value('@obj_id', 'INT')
FROM @xml.nodes('objs/obj') t(c)

SET STATISTICS PROFILE, TIME, IO OFF

/*
    Table 'Worktable'. Scan count 0, logical reads 6918, ..., lob logical reads 3692250, ..., lob read-ahead reads 1233626.
        CPU time = 31078 ms, elapsed time = 31247 ms

    Table 'Worktable'. Scan count 0, logical reads 7, ..., lob logical reads 3206, ..., lob read-ahead reads 1069.
        CPU time = 31 ms, elapsed time = 28 ms
        CPU time = 16 ms, elapsed time = 96 ms
*/