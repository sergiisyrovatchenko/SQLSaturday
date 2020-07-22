SET NOCOUNT ON

USE tempdb
GO

DROP TABLE IF EXISTS #NoSchema
DROP TABLE IF EXISTS #Schema
GO

CREATE TABLE #NoSchema (x XML)
CREATE TABLE #Schema   (x XML(EventSchema))
GO

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

SET STATISTICS TIME ON

INSERT INTO #NoSchema
SELECT TOP(100000) @x
FROM [master].dbo.spt_values s1
CROSS APPLY [master].dbo.spt_values s2
OPTION(MAXDOP 1)

INSERT INTO #Schema
SELECT TOP(100000) @x
FROM [master].dbo.spt_values s1
CROSS APPLY [master].dbo.spt_values s2
OPTION(MAXDOP 1)

SET STATISTICS TIME OFF

/*
    Table '#NoSchema' ...
        CPU time = 31 ms, elapsed time = 36 ms

    Table '#Schema' ...
        CPU time = 42 ms, elapsed time = 48 ms
*/

SELECT obj_name = OBJECT_NAME(p.[object_id])
     , a.[type_desc]
     , a.total_pages
     , total_mb = a.total_pages * 8 / 1024.
FROM sys.partitions p
JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
WHERE p.[object_id] IN (OBJECT_ID('#NoSchema'), OBJECT_ID('#Schema'))

------------------------------------------------------

DECLARE @val VARCHAR(100)

SET STATISTICS TIME, IO ON

SELECT @val = x.value('Events[1]/Event[1]/@Name', 'VARCHAR(100)')
FROM #NoSchema

SELECT @val = x.value('Events[1]/Event[1]/@Name', 'VARCHAR(100)')
FROM #Schema

SET STATISTICS TIME, IO OFF

/*
    Table '#NoSchema'. Scan count 1, logical reads 6250, ...
        CPU time = 578 ms, elapsed time = 671 ms

    Table '#Schema'. Scan count 1, logical reads 7143, ...
        CPU time = 594 ms, elapsed time = 695 ms
*/