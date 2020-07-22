DECLARE @x1 XML = N'
<EVENT_INSTANCE>
    <EventType>CREATE_TABLE</EventType>
    <PostTime>2014-07-17T16:11:14.633</PostTime>
    <SPID>51</SPID>
    <ServerName>VCG-SCULLEY\SQL2014MULTI</ServerName>
    <LoginName>VCG\sculley</LoginName>
    <UserName>dbo</UserName>
    <DatabaseName>AdventureWorks2014</DatabaseName>
    <SchemaName>dbo</SchemaName>
    <ObjectName>ErrorLog</ObjectName>
    <ObjectType>TABLE</ObjectType>
</EVENT_INSTANCE>'

SELECT @x1.query('/EVENT_INSTANCE/*[local-name(.) = "EventType" or local-name(.) = "PostTime"]')
SELECT @x1.query('/EVENT_INSTANCE/*[(contains("EventType,PostTime", local-name(.)))]') -- Lazy spool

DECLARE @x2 XML = N'
<event>
    <data name="wait_type">CXPACKET</data>
    <data name="post_time">2017-02-04 21:48:22.320</data>
    <data name="duration">124</data>
    <data name="signal_duration">0</data>
    <data name="delay">100</data>
</event>'

SELECT @x2.query('event/data[@name = "wait_type" or @name = "duration" or @name = "signal_duration"]')
SELECT @x2.query('event/data[(contains("wait_type,duration,signal_duration", @name))]')

DECLARE @t TABLE (xpath VARCHAR(MAX), time_ms INT)
DECLARE @i INT = 1
      , @s DATETIME = GETUTCDATE()
      , @res XML
      , @runs INT = 10000

WHILE @i <= @runs
    SELECT @res = @x1.query('/EVENT_INSTANCE/*[local-name(.) = "EventType" or local-name(.) = "PostTime"]')
         , @i += 1
INSERT INTO @t
SELECT '[local-name(.) = "EventType" or local-name(.) = "PostTime"]', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x1.query('/EVENT_INSTANCE/*[(contains("EventType,PostTime", local-name(.)))]')
         , @i += 1
INSERT INTO @t
SELECT '[(contains("EventType,PostTime", local-name(.)))]', DATEDIFF(ms, @s, GETUTCDATE())

WHILE @i <= @runs
    SELECT @res = @x2.query('event/data[@name = "wait_type" or @name = "duration" or @name = "signal_duration"]')
         , @i += 1
INSERT INTO @t
SELECT '[@name = "wait_type" or @name = "duration" or @name = "signal_duration"]', DATEDIFF(ms, @s, GETUTCDATE())

SELECT @i = 1, @s = GETUTCDATE()
WHILE @i <= @runs
    SELECT @res = @x2.query('event/data[(contains("wait_type,duration,signal_duration", @name))]')
         , @i += 1
INSERT INTO @t
SELECT '[(contains("wait_type,duration,signal_duration", @name))]', DATEDIFF(ms, @s, GETUTCDATE())

SELECT * FROM @t

/*
    xpath                                                                      time_ms
    -------------------------------------------------------------------------- -----------
    [local-name(.) = "EventType" or local-name(.) = "PostTime"]                690
    [(contains("EventType,PostTime", local-name(.)))]                          2010
    [@name = "wait_type" or @name = "duration" or @name = "signal_duration"]   2010
    [(contains("wait_type,duration,signal_duration", @name))]                  804
*/