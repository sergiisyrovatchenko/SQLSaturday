DROP TABLE IF EXISTS #t
DROP TABLE IF EXISTS #s
GO

CREATE TABLE #s (id CHAR(1) PRIMARY KEY)
INSERT #s VALUES ('1'), ('2'), ('4')

CREATE TABLE #t (x XML)
INSERT INTO #t
VALUES (N'
<items>
    <i id="0" value="10.5" />
    <i id="1" value="10" />
    <i id="2" value="9.8" />
    <i id="3" value="9.5" />
    <i id="4" value="9.3" />
    <i id="5" value="9.1" />
</items>')

/*
    <items>
        <i id="1" value="10" />
        <i id="2" value="9.8" />
        <i id="4" value="9.3" />
    </items>
*/

------------------------------------------------------

UPDATE #t
SET x.modify('insert <i id="6" value="9.1" /> into items[1]')

SELECT * FROM #t

UPDATE #t
SET x.modify('delete items/i[@id = "6"]')
GO

------------------------------------------------------

BEGIN TRANSACTION

DECLARE @id INT

DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
    SELECT ID FROM #s

OPEN cur

FETCH NEXT FROM cur INTO @id

WHILE @@FETCH_STATUS = 0 BEGIN

    UPDATE #t
    SET x.modify('delete /items/i[@id = sql:variable("@id")]');

    FETCH NEXT FROM cur INTO @id

END

CLOSE cur
DEALLOCATE cur

SELECT * FROM #t

ROLLBACK TRANSACTION
GO

------------------------------------------------------

SELECT t.c.query('.')
FROM #t
CROSS APPLY x.nodes('items/i') t(c)
WHERE t.c.value('@id', 'CHAR(1)') IN (SELECT * FROM #s)
FOR XML PATH(''), ROOT('items'), TYPE
GO

------------------------------------------------------

SELECT t.c.query('.')
FROM #t
CROSS APPLY x.nodes('items/i') t(c)
WHERE EXISTS(
        SELECT 1
        FROM #s s
        WHERE t.c.exist('.[@id = sql:column("s.ID")]') = 1
    )
FOR XML PATH(''), ROOT('items'), TYPE
GO

------------------------------------------------------

DECLARE @t VARCHAR(50) = ''
SELECT @t += ',' + Id FROM #s
SET @t += ','
/* ,1,2,4, */

SELECT t.c.query('.')
FROM #t
CROSS APPLY x.nodes('items/i[contains(sql:variable("@t"), concat(",", @id, ","))]') t(c)
FOR XML PATH(''), ROOT('items'), TYPE
GO

------------------------------------------------------

BEGIN TRANSACTION

DECLARE @t VARCHAR(50) = ''
SELECT @t += ',' + Id FROM #s
SET @t += ','

UPDATE #t
SET x.modify('delete /items/i[not(contains(sql:variable("@t"), concat(",", @id, ",")))]')

SELECT * FROM #t

ROLLBACK TRANSACTION

------------------------------------------------------

DECLARE @x XML = N'
<Orders>
    <Order ID="1" Value="0" />
    <Order ID="5" Value="0" />
</Orders>'

SELECT CAST(REPLACE(CAST(@x AS NVARCHAR(MAX)), 'ID="1"', 'ID="2"') AS XML)

SET @x.modify('replace value of (/Orders/Order/@ID)[1] with "3" ')
SELECT @x

SET @x.modify('replace value of (/Orders/Order[@ID = 3]/@Value)[1] with "1" ')
SELECT @x
GO

------------------------------------------------------

DECLARE @x XML = N'
<Order>
    <Book Name="SQL">
        <Param>
            <Customer Name="JC Denton" />
            <Customer Name="Paul Denton" />
        </Param>
    </Book>
    <Book Name="XML">
        <Param>
            <Customer Name="Maggie Cho" />
        </Param>
    </Book>
</Order>'

DECLARE @p INT = 1
      , @c INT = @x.value('count(//Param/Customer)', 'INT')
      , @id UNIQUEIDENTIFIER = NEWID()

WHILE @p <= @c BEGIN
    SET @x.modify('insert attribute Type {sql:variable("@id")} as last into (((//Param/Customer)[position() = sql:variable("@p")])[1])')
    SELECT @p += 1
         , @id = NEWID()
END

SELECT @x