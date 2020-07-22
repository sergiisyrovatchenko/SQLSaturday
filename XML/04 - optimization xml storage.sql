DECLARE @x1 XML = N'
<Product Name="Lenovo ThinkPad E460">
    <RatingInfo Value="4" ReviewCount="2">
        <Detail>
            <Rating Value="5" ReviewCount="1" />
            <Rating Value="3" ReviewCount="1" />
        </Detail>
    </RatingInfo>
</Product>'

DECLARE @x2 XML = N'
<Product Name="Lenovo ThinkPad E460">
    <RatingInfo Value="4" ReviewCount="2">
        <Rating Value="5" ReviewCount="1" />
        <Rating Value="3" ReviewCount="1" />
    </RatingInfo>
</Product>'

DECLARE @x3 XML = N'
<Product Name="Lenovo ThinkPad E460">
    <Ratings Value="4" ReviewCount="2">
        <Rating Value="5" ReviewCount="1" />
        <Rating Value="3" ReviewCount="1" />
    </Ratings>
</Product>'

SELECT x1 = DATALENGTH(@x1)
     , x2 = DATALENGTH(@x2)
     , x3 = DATALENGTH(@x3)

DECLARE @x4 XML = N'
<Product Name="Lenovo ThinkPad E460">
    <Ratings Value="4" ReviewCount="2">
        <Rating Value="5" Reviews="1" />
        <Rating Value="3" Reviews="1" />
    </Ratings>
</Product>'

DECLARE @x5 XML = N'
<Product Name="Lenovo ThinkPad E460">
    <Ratings Value="4" Reviews="2">
        <Rating Value="5" Reviews="1" />
        <Rating Value="3" Reviews="1" />
    </Ratings>
</Product>'

SELECT x4 = DATALENGTH(@x4)
     , x5 = DATALENGTH(@x5)