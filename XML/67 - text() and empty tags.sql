DECLARE @x XML = '<Value1 /><Value2></Value2>'

SELECT @x.value('Value1[1]', 'INT')
     , @x.value('Value2[1]', 'INT')
     , @x.value('(Value1/text())[1]', 'INT')
     , @x.value('(Value2/text())[1]', 'INT')

SELECT @x.value('Value1[1]', 'VARCHAR(10)')
     , @x.value('Value2[1]', 'VARCHAR(10)')
     , @x.value('(Value1/text())[1]', 'VARCHAR(10)')
     , @x.value('(Value2/text())[1]', 'VARCHAR(10)')

SELECT @x.value('Value1[1]', 'VARBINARY(10)')
     , @x.value('Value2[1]', 'VARBINARY(10)')
     , @x.value('(Value1/text())[1]', 'VARBINARY(10)')
     , @x.value('(Value2/text())[1]', 'VARBINARY(10)')

GO

DECLARE @x XML = '<Value A="" />'

SELECT @x.value('(Value/@A)[1]', 'INT')
     , @x.value('Value[1]/@A', 'INT')
     , @x.value('(Value/@B)[1]', 'INT')
     , @x.value('Value[1]/@B', 'INT')