DECLARE @x1 XML = N'<root>123</root>'
      , @x2 XML = N'<root>123</root>'
      , @x3 XML = N'<root></root>'
      , @x4 XML = N'<root/>'
      , @x5 XML = N'<root a="1" b="2" />'
      , @x6 XML = N'<root b="2" a="1" />'
      , @x7 XML = N'<i>ABC</i><i>ZXY</i>'
      , @x8 XML = N'<i>ZXY</i><i>ABC</i>'

/*
    SELECT IIF(@x1 = @x2, 1, 0)

    Msg 305, Level 16, State 1, Line 4
    The XML data type cannot be compared or sorted, except when using the IS NULL operator.
*/

SELECT x1x2 = IIF(CAST(@x1 AS NVARCHAR(MAX)) =  CAST(@x2 AS NVARCHAR(MAX)), 1, 0)
     , x1x2 = IIF(CAST(@x1 AS VARBINARY(MAX)) = CAST(@x2 AS VARBINARY(MAX)), 1, 0)
     , x3x4 = IIF(CAST(@x3 AS NVARCHAR(MAX)) =  CAST(@x4 AS NVARCHAR(MAX)), 1, 0)
     , x3x4 = IIF(CAST(@x3 AS VARBINARY(MAX)) = CAST(@x4 AS VARBINARY(MAX)), 1, 0)
     , x5x6 = IIF(CAST(@x5 AS NVARCHAR(MAX)) =  CAST(@x6 AS NVARCHAR(MAX)), 1, 0)
     , x5x6 = IIF(CAST(@x5 AS VARBINARY(MAX)) = CAST(@x6 AS VARBINARY(MAX)), 1, 0)
     , x7x8 = IIF(CAST(@x7 AS NVARCHAR(MAX)) =  CAST(@x8 AS NVARCHAR(MAX)), 1, 0)
     , x7x8 = IIF(CAST(@x7 AS VARBINARY(MAX)) = CAST(@x8 AS VARBINARY(MAX)), 1, 0)
GO

----------------------------------------------------

SET NOCOUNT ON

USE [master]
GO

IF DB_ID('db') IS NOT NULL BEGIN
    ALTER DATABASE db SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE db
END
GO

CREATE DATABASE db WITH TRUSTWORTHY ON
GO

USE db
GO

CREATE ASSEMBLY CompareXML_CLR FROM 'D:\PROJECT\XML\CompareXML_CLR\CompareXML_CLR.dll'
    WITH PERMISSION_SET = UNSAFE
GO

DROP FUNCTION IF EXISTS dbo.CompareXML_CLR
GO

CREATE FUNCTION dbo.CompareXML_CLR
(
      @xml1 XML
    , @xml2 XML
    , @ignoreOrder BIT
)
RETURNS BIT
    EXTERNAL NAME CompareXML_CLR.UserDefinedFunctions.CompareXML_CLR
GO

----------------------------------------------------

DROP FUNCTION IF EXISTS dbo.IsXMLEqual
GO

CREATE FUNCTION dbo.IsXMLEqual
(
      @x1 XML
    , @x2 XML
)
RETURNS BIT
AS BEGIN

    DECLARE @i BIGINT
          , @cnt1 BIGINT
          , @cnt2 BIGINT
          , @subx1 XML
          , @subx2 XML

    IF ISNULL(CAST(@x1 AS NVARCHAR(MAX)), '') = '' AND ISNULL(CAST(@x2 AS NVARCHAR(MAX)), '') = ''
        RETURN 1

    IF ISNULL(CAST(@x1 AS NVARCHAR(MAX)), '') = '' OR ISNULL(CAST(@x2 AS NVARCHAR(MAX)), '') = ''
        RETURN 0

    -- If more than one root - recurse for each element
    SELECT @cnt1 = @x1.query('count(/*)').value('.', 'INT')
         , @cnt2 = @x2.query('count(/*)').value('.', 'INT')

    IF @cnt1 != @cnt2 RETURN 0

    IF @cnt1 > 1 BEGIN

        SET @i = 1
        WHILE @i <= @cnt1 BEGIN

            SELECT @subx1 = @x1.query('/*[sql:variable("@i")]')
                 , @subx2 = @x2.query('/*[sql:variable("@i")]')

            IF dbo.IsXMLEqual(@subx1, @subx2) = 0
                RETURN 0

            SET @i += 1

        END

        RETURN 1

    END

    -- Comparing root data
    IF @x1.value('local-name(/*[1])', 'NVARCHAR(MAX)') != @x2.value('local-name(/*[1])', 'NVARCHAR(MAX)')
        OR
       @x1.value('/*[1]', 'NVARCHAR(MAX)') != @x2.value('/*[1]', 'NVARCHAR(MAX)')
    RETURN 0

    -- Comparing attributes
    SELECT @cnt1 = @x1.query('count(/*[1]/@*)').value('.', 'INT')
         , @cnt2 = @x2.query('count(/*[1]/@*)').value('.', 'INT')

    IF @cnt1 <> @cnt2
        RETURN 0

    IF EXISTS (
            SELECT *
            FROM (
                SELECT n = t.c.value('local-name(.)', 'NVARCHAR(MAX)')
                     , v = t.c.value('.', 'NVARCHAR(MAX)')
                FROM @x1.nodes('/*[1]/@*') t(c)
            ) x1
            FULL JOIN (
                SELECT n = t.c.value('local-name(.)', 'NVARCHAR(MAX)')
                     , v = t.c.value('.', 'NVARCHAR(MAX)')
                FROM @x2.nodes('/*[1]/@*') t(c)
            ) x2 ON x1.n = x2.n
            WHERE NOT(
                    x1.v IS NULL AND x2.v IS NULL
                OR
                    x1.v IS NOT NULL AND x2.v IS NOT NULL AND x1.v = x2.v
                )
        )
        RETURN 0

    -- Recursively running for each child
    SELECT @cnt1 = @x1.query('count(/*[1]/*)').value('.', 'INT')
         , @cnt2 = @x2.query('count(/*[1]/*)').value('.', 'INT')

    IF @cnt1 != @cnt2 RETURN 0

    SET @i = 1
    WHILE @i <= @cnt1 BEGIN

        SELECT @subx1 = @x1.query('/*/*[sql:variable("@i")]')
             , @subx2 = @x2.query('/*/*[sql:variable("@i")]')

        IF dbo.IsXMLEqual(@subx1, @subx2) = 0
            RETURN 0

        SET @i += 1

    END

    RETURN 1

END
GO

----------------------------------------------------

DECLARE @x1 XML = N'<root>123</root>'
      , @x2 XML = N'<root>123</root>'
      , @x3 XML = N'<root></root>'
      , @x4 XML = N'<root/>'
      , @x5 XML = N'<root a="1" b="2" />'
      , @x6 XML = N'<root b="2" a="1" />'
      , @x7 XML = N'<i>ABC</i><i>ZXY</i>'
      , @x8 XML = N'<i>ZXY</i><i>ABC</i>'

SELECT 'VARBINARY'
     , x1x2 = IIF(CAST(@x1 AS VARBINARY(MAX)) = CAST(@x2 AS VARBINARY(MAX)), 1, 0)
     , x3x4 = IIF(CAST(@x3 AS VARBINARY(MAX)) = CAST(@x4 AS VARBINARY(MAX)), 1, 0)
     , x5x6 = IIF(CAST(@x5 AS VARBINARY(MAX)) = CAST(@x6 AS VARBINARY(MAX)), 1, 0)
     , x7x8 = IIF(CAST(@x7 AS VARBINARY(MAX)) = CAST(@x8 AS VARBINARY(MAX)), 1, 0)

UNION ALL

SELECT 'VARCHAR'
     , x1x2 = IIF(CAST(@x1 AS NVARCHAR(MAX)) =  CAST(@x2 AS NVARCHAR(MAX)), 1, 0)
     , x3x4 = IIF(CAST(@x3 AS NVARCHAR(MAX)) =  CAST(@x4 AS NVARCHAR(MAX)), 1, 0)
     , x5x6 = IIF(CAST(@x5 AS NVARCHAR(MAX)) =  CAST(@x6 AS NVARCHAR(MAX)), 1, 0)
     , x7x8 = IIF(CAST(@x7 AS NVARCHAR(MAX)) =  CAST(@x8 AS NVARCHAR(MAX)), 1, 0)

UNION ALL

SELECT 'IsXMLEqual'
     , dbo.IsXMLEqual(@x1, @x2)
     , dbo.IsXMLEqual(@x3, @x4)
     , dbo.IsXMLEqual(@x5, @x6)
     , dbo.IsXMLEqual(@x7, @x8)

UNION ALL

SELECT 'CompareXML_CLR'
     , dbo.CompareXML_CLR(@x1, @x2, 1)
     , dbo.CompareXML_CLR(@x3, @x4, 1)
     , dbo.CompareXML_CLR(@x5, @x6, 1)
     , dbo.CompareXML_CLR(@x7, @x8, 1)

----------------------------------------------------

DROP TABLE IF EXISTS #temp

SELECT ID = DatabaseLogID * c
     , XmlEvent = (
             SELECT [Object]
                  , [Schema]
             FOR XML PATH('EventData'), TYPE
         )
INTO #temp
FROM AdventureWorks2014.dbo.DatabaseLog
CROSS JOIN (VALUES (1), (2), (3)) t(c)

DECLARE @x XML = N'
    <EventData>
        <Object>CreditCard</Object>
        <Schema>Sales</Schema>
    </EventData>'

DECLARE @d DATETIME = GETDATE()

DECLARE @Object SYSNAME = @x.value('(EventData/Object/text())[1]', 'SYSNAME')
      , @Schema SYSNAME = @x.value('(EventData/Schema/text())[1]', 'SYSNAME')

SELECT *
FROM #temp
WHERE XmlEvent.value('(EventData/Object/text())[1]', 'SYSNAME') = @Object
    AND XmlEvent.value('(EventData/Schema/text())[1]', 'SYSNAME') = @Schema

SELECT DATEDIFF(MILLISECOND, @d, GETDATE())
SET @d = GETDATE()

SELECT *
FROM #temp
WHERE dbo.IsXMLEqual(XmlEvent, @x) = 1

SELECT DATEDIFF(MILLISECOND, @d, GETDATE())
SET @d = GETDATE()

SELECT *
FROM #temp
WHERE dbo.CompareXML_CLR(XmlEvent, @x, 1) = 1

SELECT DATEDIFF(MILLISECOND, @d, GETDATE())
GO