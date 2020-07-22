DECLARE @t TABLE (ID INT, Val VARCHAR(10))

INSERT INTO @t
VALUES (1, 'Name'), (2, NULL)

SELECT ID
      , (
           SELECT Val AS '*'
           FOR XML PATH (''), TYPE
       ) AS Val
      , (
           SELECT Val AS '*'
           FOR XML PATH ('Val'), TYPE
       )
FROM @t
FOR XML PATH ('Item')

/*
    <Item>
        <ID>1</ID>
        <Val>Name</Val>
        <Val>Name</Val>
    </Item>
    <Item>
        <ID>2</ID>
        <Val></Val>
        <Val />
    </Item>
*/