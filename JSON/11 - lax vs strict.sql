DECLARE @json NVARCHAR(MAX) = N'
    {
        "UserID": 1,
        "UserName": "JC Denton"
    }'

SELECT JSON_VALUE(@json, '$.IsActive')
     , JSON_VALUE(@json, 'lax$.IsActive')

SELECT JSON_VALUE(@json, 'strict$.UserName')

SELECT JSON_VALUE(@json, 'strict$.IsActive')