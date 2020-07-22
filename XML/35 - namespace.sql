DECLARE @x XML = N'
<ProductInfo xmlns="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
    <Product>
        <ProductID>123</ProductID>
    </Product>
</ProductInfo>'

SELECT t.c.value('.', 'INT')
FROM @x.nodes('ProductInfo/Product/ProductID') t(c)

SELECT t.c.value('.', 'INT'), t.c.query('.')
FROM @x.nodes('*/*/*') t(c)

;WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/2003/10/Serialization/Arrays')
SELECT t.c.value('.', 'INT'), t.c.query('.')
FROM @x.nodes('ProductInfo/Product/ProductID') t(c) 
GO

------------------------------------------------------

DECLARE @x XML = N'
<Array xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
  <KeyValue>
    <Key>CoreAdmin</Key>
    <Value xmlns:d3p1="http://schemas.datacontract.org/2004/07/CC.CoreServices.DTO.ServiceMethodResponses">
      <d3p1:MenuPermissions xmlns:d4p1="http://schemas.datacontract.org/2004/07/CC.CoreServices.DTO">
        <d4p1:MenuItem>
          <d4p1:MenuId>ÓÐÀ!!!</d4p1:MenuId>
        </d4p1:MenuItem>
      </d3p1:MenuPermissions>
    </Value>
  </KeyValue>
</Array>'

;WITH XMLNAMESPACES(
    'http://schemas.microsoft.com/2003/10/Serialization/Arrays' AS p1,
    'http://schemas.datacontract.org/2004/07/CC.CoreServices.DTO.ServiceMethodResponses' AS d3p1,
    'http://schemas.datacontract.org/2004/07/CC.CoreServices.DTO' AS d4p1)
SELECT t.c.value('.', 'NVARCHAR(10)')
FROM @x.nodes('p1:Array/p1:KeyValue/p1:Value/d3p1:MenuPermissions/d4p1:MenuItem/d4p1:MenuId') t(c) 

SELECT t.c.value('.', 'NVARCHAR(10)')
FROM @x.nodes('*:Array/*:KeyValue/*:Value/*:MenuPermissions/*:MenuItem/*:MenuId') t(c)