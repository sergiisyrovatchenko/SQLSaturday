DECLARE @x XML = N'
<Info>
    <Availability>Yes</Availability>
    <Rating Value="4.5" Reviews="2" />
    <Prices>
        <Price Value="4" />
        <Price Value="402" />
    </Prices>
    <Seller Name="Microsoft" />
</Info>'

SELECT @x.query(N'
    <Info>
        {/Info/Availability}
        <TotalRating>{/Info/Rating/@Value}</TotalRating>
        {
            if(not(empty(/Info/Seller/@Name)))
                then <Seller>{substring(string(data(/Info/Seller/@Name)[1]), 1, 5)}</Seller>
                else(xsi:nil)
        }
        <PricesInfo>
            {/Info/Prices/Price}
        </PricesInfo>
    </Info>')