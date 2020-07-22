DECLARE @x XML = N'
<fields>
    <field name="Id">
        <val>1</val>
    </field>
    <field name="ProductId">
        <val>5</val>
    </field>
    <field name="Product">
        <val>Chassis</val>
    </field>
    <field name="MarketId">
        <val>43</val>
    </field>
    <field name="Market">
        <val>USA</val>
    </field>
</fields>'

SELECT Id =        t.c.value('(field[@name="Id"]/val/text())[1]', 'INT')
     , ProductId = t.c.value('(field[@name="ProductId"]/val/text())[1]', 'INT')
     , Product =   t.c.value('(field[@name="Product"]/val/text())[1]', 'NVARCHAR(4000)')
     , MarketId =  t.c.value('(field[@name="MarketId"]/val/text())[1]', 'INT')
     , Market =    t.c.value('(field[@name="Market"]/val/text())[1]', 'NVARCHAR(4000)')
FROM @X.nodes('/fields') t(c)

SELECT *
FROM (
    SELECT col = t.c.value('@name', 'SYSNAME')
         , val = t.c.value('(val/text())[1]', 'NVARCHAR(4000)')
    FROM @x.nodes('fields/field') t(c)
) t
PIVOT (
    MAX(val)
    FOR col IN (Id, ProductId, Product, MarketId, Market)
) p
GO

------------------------------------------------------

DECLARE @x XML = N'
<event time="2017-02-04 22:00:01.990">
    <data name="wait_type">CXPACKET</data>
    <data name="duration">123</data>
    <data name="signal_duration">123</data>
    <data name="info">App</data>
</event>
<event time="2017-02-04 22:02:16.020">
    <data name="wait_type">WRITELOG</data>
    <data name="duration">3</data>
    <data name="signal_duration">0</data>
</event>
<event time="2017-02-04 22:02:58.970">
    <data name="wait_type">WRITELOG</data>
    <data name="duration">1</data>
    <data name="signal_duration">0</data>
</event>
'

SELECT wait_type
     , duration = SUM(duration)
     , signal_duration = SUM(signal_duration)
     , waiting_tasks_count = COUNT_BIG(*)
FROM (
    SELECT wait_type = c.value('(data[@name="wait_type"]/text())[1]', 'NVARCHAR(4000)')
         , duration = c.value('(data[@name="duration"]/text())[1]', 'BIGINT')
         , signal_duration = c.value('(data[@name="signal_duration"]/text())[1]', 'BIGINT')
    FROM @x.nodes('event') t(c)
) t
GROUP BY wait_type

SELECT wait_type
     , duration = SUM(duration)
     , signal_duration = SUM(signal_duration)
     , waiting_tasks_count = COUNT_BIG(*)
FROM (
    SELECT wait_type = MAX(CASE WHEN n = 'wait_type' THEN x.value('(data/text())[1]', 'NVARCHAR(4000)') END)
         , duration = MAX(CASE WHEN n = 'duration' THEN x.value('(data/text())[1]', 'BIGINT') END)
         , signal_duration = MAX(CASE WHEN n = 'signal_duration' THEN x.value('(data/text())[1]', 'BIGINT') END)
    FROM (
        SELECT n = c.value('@name', 'SYSNAME')
             , x = c.query('.')
             , rn = ROW_NUMBER() OVER (ORDER BY 1/0) - ISNULL(NULLIF(ROW_NUMBER() OVER (ORDER BY 1/0) % 3, 0), 3)
        FROM @x.nodes('event/data[(contains("wait_type,duration,signal_duration", @name))]') t(c)
    ) t
    GROUP BY rn
) t
GROUP BY wait_type
GO

------------------------------------------------------

DECLARE @x XML = N'
<row>
  <a>123</a>
  <a>124</a>
  <a>125</a>
  <a>28.08.1973</a>
  <a />
  <a>00821000086-0000</a>
  <a />
  <a />
  <a>2.1</a>
</row>
<row>
  <a>123</a>
  <a>124</a>
  <a>125</a>
  <a>22.12.1973</a>
  <a />
  <a>00821000087-0000</a>
  <a />
  <a />
  <a>2.2</a>
</row>
<row>
  <a>123</a>
  <a>124</a>
  <a>125</a>
  <a>30.04.1981</a>
  <a />
  <a>00821000088-0000</a>
  <a />
  <a />
  <a>2.1</a>
</row>'

DECLARE @a1 NVARCHAR(40)
      , @a2 NVARCHAR(40)
      , @a3 NVARCHAR(40)
      , @a4 NVARCHAR(40)
      , @a5 NVARCHAR(40)
      , @a6 NVARCHAR(40)
      , @a7 NVARCHAR(40)
      , @a8 NVARCHAR(40)
      , @a9 NVARCHAR(40)

SELECT @x = x
FROM (
    SELECT TOP(50000) @x AS [*]
    FROM [master].dbo.spt_values a
    CROSS JOIN [master].dbo.spt_values b
    FOR XML PATH (''), TYPE
) t(x)

SET STATISTICS TIME ON

SELECT @a1 = t.c.value('a[1]', 'NVARCHAR(40)')
     , @a2 = t.c.value('a[2]', 'NVARCHAR(40)')
     , @a3 = t.c.value('a[3]', 'NVARCHAR(40)')
     , @a4 = t.c.value('a[4]', 'NVARCHAR(20)')
     , @a5 = t.c.value('a[5]', 'NVARCHAR(40)')
     , @a6 = t.c.value('a[6]', 'NVARCHAR(40)')
     , @a7 = t.c.value('a[7]', 'NVARCHAR(40)')
     , @a8 = t.c.value('a[8]', 'NVARCHAR(40)')
     , @a9 = t.c.value('a[9]', 'NVARCHAR(40)')
FROM @x.nodes('row') t(c)

SELECT @a1 = MAX(CASE WHEN n = 0 THEN v END)
     , @a2 = MAX(CASE WHEN n = 1 THEN v END)
     , @a3 = MAX(CASE WHEN n = 2 THEN v END)
     , @a4 = MAX(CASE WHEN n = 3 THEN v END)
     , @a5 = MAX(CASE WHEN n = 4 THEN v END)
     , @a6 = MAX(CASE WHEN n = 5 THEN v END)
     , @a7 = MAX(CASE WHEN n = 6 THEN v END)
     , @a8 = MAX(CASE WHEN n = 7 THEN v END)
     , @a9 = MAX(CASE WHEN n = 8 THEN v END)
FROM (
    SELECT v = t.n.value('text()[1]', 'NVARCHAR(40)')
         , g = (ROW_NUMBER() OVER (ORDER BY 1 / 0) - 1) / 9
         , n = (ROW_NUMBER() OVER (ORDER BY 1 / 0) - 1) % 9
    FROM @x.nodes('row/a') t (n)
) t
GROUP BY g

SET STATISTICS TIME OFF

/*
    CPU time = 25703 ms, elapsed time = 25772 ms.
    CPU time = 5828 ms,  elapsed time = 7023 ms.
*/