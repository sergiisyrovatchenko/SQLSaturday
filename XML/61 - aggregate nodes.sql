DECLARE @x XML = N'
<Array>
    <Item>0.49</Item>
    <Item>1</Item>
    <Item>2</Item>
    <Item>2.51</Item>
    <Item>Some text</Item>
</Array>'

SELECT @x.value('sum(/Array/Item)', 'FLOAT')
     , @x.value('max(/Array/Item)', 'FLOAT')
     , @x.value('min(/Array/Item)', 'FLOAT')
     , @x.value('avg(/Array/Item)', 'FLOAT')
     , @x.value('count(/Array/Item)', 'INT')

SELECT @x.value('sum(/Array/Item/text())', 'FLOAT')
     , @x.value('max(/Array/Item/text())', 'FLOAT')
     , @x.value('min(/Array/Item/text())', 'FLOAT')
     , @x.value('avg(/Array/Item/text())', 'FLOAT')
     , @x.value('count(/Array/Item/text())', 'INT')