DECLARE @x1 XML = '
<Product Nąme="Lenōvo ThinkPąd">
    <Mōdel>モデル E460</Mōdel>
</Product>'

DECLARE @x2 XML = /* -> */ N'
<Product Nąme="Lenōvo ThinkPąd">
    <Mōdel>モデル E460</Mōdel>
</Product>'

SELECT x = @x1
UNION ALL
SELECT @x2