USE [master]
GO

SELECT DATABASEPROPERTYEX(DB_NAME(), 'collation')

DECLARE @a VARCHAR(10) = 'TEXT' 
      , @b VARCHAR(10) = 'text'

SELECT IIF(@a = @b, 'TRUE', 'FALSE')

SELECT IIF(@a = @b COLLATE Cyrillic_General_CS_AS, 'TRUE', 'FALSE')
GO

----------------------------------------------------

DECLARE @x XML = N'
<Databases>
    <Database>AdventureWorks2014</Database>
</Databases>'

DECLARE @db VARCHAR(100) = 'adventureworks2014'

SELECT @x.exist('Databases/Database[. = "AdventureWorks2014"]')
     , @x.exist('Databases/Database[. = "adventureworks2014"]')
     , @x.exist('Databases/Database[upper-case(.) = upper-case(sql:variable("@db"))]')

SELECT 1
WHERE @x.value('(Databases/Database/text())[1]', 'VARCHAR(100)') = @db --COLLATE Latin1_General_100_CS_AI