SET NOCOUNT ON

USE tempdb
GO

DROP TABLE IF EXISTS #temp
CREATE TABLE #temp (x XML) -- 2005 && size > 8060 ? LOB_DATA : IN_ROW_DATA
GO

/*
    IN_ROW_DATA
    ROW_OVERFLOW
    LOB_DATA -> EXEC sys.sp_tableoption '#temp', 'large value types out of row', 1
	
	NTEXT/TEXT/IMAGE always in LOB_DATA
*/

DECLARE @x XML = N'
<Product>
    <Manufacturer>Lenovo</Manufacturer>
    <Model>ThinkPad E460</Model>
</Product>'

SELECT DATALENGTH(@x)

INSERT INTO #temp VALUES (@x)

SELECT [type_desc], total_pages, used_pages, data_pages
FROM sys.allocation_units a
WHERE EXISTS(
        SELECT *
        FROM sys.partitions p
        WHERE p.[object_id] = OBJECT_ID('#temp')
            AND p.[partition_id] = a.container_id
    )

------------------------------------------------------

DBCC IND(tempdb, '#temp', 1) -- PagePID

------------------------------------------------------

DBCC TRACEON(3604)
DBCC PAGE (tempdb, 1, 5952 /* PagePID */, 3)
DBCC TRACEOFF(3604)

/*
    [BLOB Inline Data] = 122

    ßÿ.°.ð.P.r.o.d.u.c.t
    .ï...ø.ð.M.a.n.u.f.a
    .c.t.u.r.e.r.ï...ø..
    .L.e.n.o.v.o.÷ð.M.o.
    d.e.l.ï...ø...T.h.i.
    n.k.P.a.d. .E.4.6.0.
    ÷÷     
*/