DECLARE @XML_Unicode NVARCHAR(MAX) = N'
<Manufacturer Name="Lenovo">
  <Product Name="ThinkPad E460">
    <Model Name="20ETS03100">
      <CPU>i7-6500U</CPU>
      <Memory>16</Memory>
      <SSD>256</SSD>
    </Model>
    <Model Name="20ETS02W00">
      <CPU>i5-6200U</CPU>
      <Memory>8</Memory>
      <HDD>1000</HDD>
    </Model>
    <Model Name="20ETS02V00">
      <CPU>i5-6200U</CPU>
      <Memory>4</Memory>
      <HDD>500</HDD>
    </Model>
  </Product>
</Manufacturer>'

DECLARE @JSON_Unicode NVARCHAR(MAX) = N'
[
  {
    "Manufacturer": {
      "Name": "Lenovo",
      "Product": {
        "Name": "ThinkPad E460",
        "Model": [
          {
            "Name": "20ETS03100",
            "CPU": "Intel Core i7-6500U",
            "Memory": 16,
            "SSD": "256"
          },
          {
            "Name": "20ETS02W00",
            "CPU": "Intel Core i5-6200U",
            "Memory": 8,
            "HDD": "1000"
          },
          {
            "Name": "20ETS02V00",
            "CPU": "Intel Core i5-6200U",
            "Memory": 4,
            "HDD": "500"
          }
        ]
      }
    }
  }
]'

DECLARE @XML_Unicode_D NVARCHAR(MAX) = N'<Manufacturer Name="Lenovo"><Product Name="ThinkPad E460"><Model Name="20ETS03100"><CPU>i7-6500U</CPU><Memory>16</Memory><SSD>256</SSD></Model><Model Name="20ETS02W00"><CPU>i5-6200U</CPU><Memory>8</Memory><HDD>1000</HDD></Model><Model Name="20ETS02V00"><CPU>i5-6200U</CPU><Memory>4</Memory><HDD>500</HDD></Model></Product></Manufacturer>'
      , @JSON_Unicode_D NVARCHAR(MAX) = N'[{"Manufacturer":{"Name":"Lenovo","Product":{"Name":"ThinkPad E460","Model":[{"Name":"20ETS03100","CPU":"Intel Core i7-6500U","Memory":16,"SSD":"256"},{"Name":"20ETS02W00","CPU":"Intel Core i5-6200U","Memory":8,"HDD":"1000"},{"Name":"20ETS02V00","CPU":"Intel Core i5-6200U","Memory":4,"HDD":"500"}]}}}]'

DECLARE @XML XML = @XML_Unicode
      , @XML_ANSI VARCHAR(MAX) = @XML_Unicode
      , @XML_D XML = @XML_Unicode_D
      , @XML_ANSI_D VARCHAR(MAX) = @XML_Unicode_D
      , @JSON_ANSI VARCHAR(MAX) = @JSON_Unicode
      , @JSON_ANSI_D VARCHAR(MAX) = @JSON_Unicode_D

SELECT *
FROM (
    VALUES
          ('XML Unicode',  DATALENGTH(@XML_Unicode),  DATALENGTH(@XML_Unicode_D),  DATALENGTH(COMPRESS(@XML_Unicode)),                DATALENGTH(COMPRESS(@XML_Unicode_D)))
        , ('XML ANSI',     DATALENGTH(@XML_ANSI),     DATALENGTH(@XML_ANSI_D),     DATALENGTH(COMPRESS(@XML_ANSI)),                   DATALENGTH(COMPRESS(@XML_ANSI_D)))
        , ('XML',          DATALENGTH(@XML),          DATALENGTH(@XML_D),          DATALENGTH(COMPRESS(CAST(@XML AS NVARCHAR(MAX)))), DATALENGTH(COMPRESS(CAST(@XML_D AS NVARCHAR(MAX)))))
        , ('JSON Unicode', DATALENGTH(@JSON_Unicode), DATALENGTH(@JSON_Unicode_D), DATALENGTH(COMPRESS(@JSON_Unicode)),               DATALENGTH(COMPRESS(@JSON_Unicode_D)))
        , ('JSON ANSI',    DATALENGTH(@JSON_ANSI),    DATALENGTH(@JSON_ANSI_D),    DATALENGTH(COMPRESS(@JSON_ANSI)),                  DATALENGTH(COMPRESS(@JSON_ANSI_D)))
) t(DataType, Delimeters, NoDelimeters, CompressDelimeters, CompressNoDelimeters)

------------------------------------------------------

-- COMPRESS/DECOMPRESS (2016+) using the GZIP algorithm

DECLARE @t TABLE (val VARBINARY(MAX))
INSERT INTO @t
VALUES (COMPRESS('[{"Name":"ThinkPad E460"}]')) -- VARCHAR(8000)
     , (COMPRESS(N'[{"Name":"ThinkPad E460"}]')) -- NVARCHAR(4000)

SELECT val
     , DECOMPRESS(val)
     , CAST(DECOMPRESS(val) AS NVARCHAR(MAX))
     , CAST(DECOMPRESS(val) AS VARCHAR(MAX))
FROM @t