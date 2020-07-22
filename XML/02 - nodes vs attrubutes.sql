DECLARE @x1 XML = N'
<Product>
    <Manufacturer>Lenovo</Manufacturer>
    <Model>ThinkPad E460</Model>
</Product>'

DECLARE @x2 XML = N'
<Product
    Manufacturer="Lenovo"
    Model="ThinkPad E460" />'

SELECT x1 = DATALENGTH(@x1)
     , x2 = DATALENGTH(@x2)