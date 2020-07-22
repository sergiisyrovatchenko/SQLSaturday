DECLARE @json NVARCHAR(MAX) = N'
    {
        "FirstName": "JC",
        "LastName": "Denton",
        "Age": 20,
        "Skills": ["SQL Server 2014"]
    }'

SET @json = JSON_MODIFY(@json, '$.Age', CAST(JSON_VALUE(@json, '$.Age') AS INT) + 2) -- 20 -> 22
SET @json = JSON_MODIFY(@json, '$.Skills[0]', 'SQL Server 2016') -- "SQL Server 2014" -> "SQL Server 2016"
SET @json = JSON_MODIFY(@json, 'append $.Skills', 'JSON')

SELECT * FROM OPENJSON(@json)

SELECT * FROM OPENJSON(JSON_MODIFY(@json, 'lax$.Age', NULL)) -- delete Age
SELECT * FROM OPENJSON(JSON_MODIFY(@json, 'strict$.Age', NULL)) -- set NULL
GO

------------------------------------------------------

DECLARE @json NVARCHAR(100) = N'{ "price": 105.90 }' -- rename
SET @json = 
    JSON_MODIFY( 
        JSON_MODIFY(@json, '$.Price',
            CAST(JSON_VALUE(@json, '$.price') AS NUMERIC(6,2))),
                '$.price', NULL)

SELECT @json