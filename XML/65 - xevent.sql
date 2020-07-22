SET NOCOUNT ON

DROP TABLE IF EXISTS #temp
GO

SELECT x = (
    SELECT TOP(5000) [@name] = 'wait_info'
                   , [@package] = 'sqlos'
                   , [@timestamp] = '2017-02-17T13:01:40.524Z'
                   , (
                        SELECT [data/@name] = 'wait_type'
                             , [data/type/@name] = 'wait_types'
                             , [data/type/@package] = 'sqlos'
                             , [data/value] = 99
                             , [data/text] = 'CXPACKET'
                        FOR XML PATH(''), TYPE
                   )
                   , (
                        SELECT [data/@name] = 'opcode'
                             , [data/type/@name] = 'event_opcode'
                             , [data/type/@package] = 'sqlos'
                             , [data/value] = 1
                             , [data/text] = 'End'
                        FOR XML PATH(''), TYPE
                   ), (
                        SELECT [data/@name] = 'duration'
                             , [data/type/@name] = 'uint64'
                             , [data/type/@package] = 'package0'
                             , [data/value] = 1
                        FOR XML PATH(''), TYPE
                   ), (
                        SELECT [data/@name] = 'signal_duration'
                             , [data/type/@name] = 'uint64'
                             , [data/type/@package] = 'package0'
                             , [data/value] = 0
                        FOR XML PATH(''), TYPE
                   ), (
                        SELECT [data/@name] = 'wait_resource'
                             , [data/type/@name] = 'ptr'
                             , [data/type/@package] = 'package0'
                             , [data/value] = '0x0000000000000000'
                        FOR XML PATH(''), TYPE
                   ), (
                        SELECT [action/@name] = 'transaction_id'
                             , [action/@package] = 'sqlserver'
                             , [action/type/@name] = 'int64'
                             , [action/type/@package] = 'package0'
                             , [action/value] = 56775
                        FOR XML PATH(''), TYPE
                   )
    FROM sys.all_columns
    FOR XML PATH('event'), ROOT('RingBufferTarget')
)
INTO #temp

/*
    <RingBufferTarget>
        <event name="wait_info" package="sqlos" timestamp="2017-02-17T13:01:40.524Z">
            <data name="wait_type">
                <type name="wait_types" package="sqlos" />
                <value>99</value>
                <text>NETWORK_IO</text>
            </data>
            <data name="opcode">
                <type name="event_opcode" package="sqlos" />
                <value>1</value>
                <text>End</text>
            </data>
            <data name="duration">
                <type name="uint64" package="package0" />
                <value>34</value>
            </data>
            <data name="signal_duration">
                <type name="uint64" package="package0" />
                <value>0</value>
            </data>
            <data name="wait_resource">
                <type name="ptr" package="package0" />
                <value>0x0000000000000000</value>
            </data>
            <action name="transaction_id" package="sqlserver">
                <type name="int64" package="package0" />
                <value>56775</value>
            </action>
        </event>
    </RingBufferTarget>
*/

------------------------------------------------------

DECLARE @x XML = (SELECT * FROM #temp)

SET STATISTICS TIME ON

SELECT wait_type
     , duration = SUM(duration)
     , signal_duration = SUM(signal_duration)
FROM (
    SELECT wait_type = t.c.value('(data[@name="wait_type"]/text)[1]', 'NVARCHAR(4000)')
         , duration = t.c.value('(data[@name="duration"]/value)[1]', 'BIGINT')
         , signal_duration = t.c.value('(data[@name="signal_duration"]/value)[1]', 'BIGINT')
    FROM @x.nodes('RingBufferTarget/event') t(c)
) t
GROUP BY wait_type


SELECT wait_type
     , duration = SUM(duration)
     , signal_duration = SUM(signal_duration)
FROM (
    SELECT wait_type = t.c.value('(data[@name="wait_type"]/text/text())[1]', 'NVARCHAR(4000)')
         , duration = t.c.value('(data[@name="duration"]/value/text())[1]', 'BIGINT')
         , signal_duration = t.c.value('(data[@name="signal_duration"]/value/text())[1]', 'BIGINT')
    FROM @x.nodes('RingBufferTarget/event') t(c)
) t
GROUP BY wait_type

SELECT wait_type
     , duration = SUM(duration)
     , signal_duration = SUM(signal_duration)
FROM (
    SELECT wait_type = MAX(CASE WHEN name = 'wait_type' THEN x.value('(data/text/text())[1]', 'NVARCHAR(4000)') END)
         , duration = MAX(CASE WHEN name = 'duration' THEN x.value('(data/value/text())[1]', 'BIGINT') END)
         , signal_duration = MAX(CASE WHEN name = 'signal_duration' THEN x.value('(data/value/text())[1]', 'BIGINT') END)
    FROM (
        SELECT name = c.value('@name', 'SYSNAME')
             , x = c.query('.')
             , rn = ROW_NUMBER() OVER (ORDER BY 1/0) - ISNULL(NULLIF(ROW_NUMBER() OVER (ORDER BY 1/0) % 3, 0), 3)
        FROM @x.nodes('RingBufferTarget/event/data[(contains("wait_type,duration,signal_duration", @name))]') t(c)
    ) t
    GROUP BY rn
) t
GROUP BY wait_type

SET STATISTICS TIME OFF

/*
    SQL Server Execution Times:
       CPU time = 1218 ms, elapsed time = 1211 ms

    SQL Server Execution Times:
       CPU time = 1281 ms, elapsed time = 1291 ms

    SQL Server Execution Times:
       CPU time = 828 ms, elapsed time = 864 ms
*/