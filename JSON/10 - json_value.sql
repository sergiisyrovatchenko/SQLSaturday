DECLARE @json NVARCHAR(MAX) = N'
    {
        "UserID": 1,
        "UserName": "JC Denton",
        "IsActive": true,
        "Date": "2016-05-31T00:00:00",
        "Settings": [
             {
                "Language": "EN"
             },
             {
                "Skin": "FlatUI"
             }
          ]
    }'

SELECT JSON_VALUE(@json, '$.UserID')
     , JSON_VALUE(@json, '$.UserName')
     , JSON_VALUE(@json, '$.Settings[0].Language')
     , JSON_VALUE(@json, '$.Settings[1].Skin')
     , JSON_QUERY(@json, '$.Settings')