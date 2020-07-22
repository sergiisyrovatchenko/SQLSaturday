DECLARE @x XML = N'
<Events>
    <Event ID="753">SQLSaturday Lviv #753</Event>
    <Event ID="780">SQLSaturday Kharkiv #780</Event>
    <Event />
</Events>'

SELECT Node =           t.c.query('.')
     , NodeExist =      t.c.exist('.')
     , NodeValueExist = t.c.exist('text()')
     , NodeValue =      t.c.value('.', 'VARCHAR(100)')
     , AttributeValue = t.c.value('@ID', 'INT')
FROM @x.nodes('*/*') t(c)
GO

------------------------------------------------------

DECLARE @x XML = N'
<Events>
    <Event ID="753">SQLSaturday Lviv #753</Event>
    <Event ID="780">SQLSaturday Kharkiv #780</Event>
    <Event />
</Events>
<Filter>
    <Parameter ID="param1">508</Parameter>
</Filter>'

SELECT t.c.value('@ID', 'INT') -- 'info1'
FROM @x.nodes('*/*') t(c)

SELECT t.c.value('@ID', 'INT')
FROM @x.nodes('Events/Event') t(c)