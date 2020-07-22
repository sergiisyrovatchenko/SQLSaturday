/*
    <Setting>
      <SettingID ID="..." />
      <Name>...</Name> 
      <Rule>
         <Data> 
            <Type Name="..." />
            <CreatedBy>...</CreatedBy>
            <ChangedBy>...</ChangedBy>
            <OutputColumnRules />
         </Data>
      </Rule>
    </Setting>
*/

DECLARE @t TABLE (
      SettingID INT
    , [Name] VARCHAR(20)
    , TypeName VARCHAR(20)
    , CreatedBy DATETIME
    , ChangedBy DATETIME
)
INSERT INTO @t
VALUES (123, 'abc', 'xyz', GETDATE(), NULL)
     , (124, 'xyz', 'abc', GETDATE(), GETDATE())

SELECT (
    SELECT [SettingID/@ID] = SettingID
         , [Name] = [Name]
         , [Rule/Data/Type] = TypeName
         , [Rule/Data/CreatedBy] = CreatedBy
         , [Rule/Data/ChangedBy] = ChangedBy
         , [Rule/Data/OutputColumnRules] = ''
    FOR XML PATH('Setting'), TYPE
)
FROM @t

SELECT (
    SELECT [SettingID/@ID] = SettingID
         , [Name] = [Name]
         , [Rule/Data] = (
                SELECT [Type] = TypeName
                     , CreatedBy
                     , ChangedBy
                     , OutputColumnRules = ''
                FOR XML PATH(''), TYPE
           )
    FOR XML PATH('Setting'), TYPE
)
FROM @t

SELECT CAST('' AS XML).query(N'
    <Setting>
      <SettingID ID="{sql:column("SettingID")}" />
      <Name>{sql:column("Name")}</Name> 
      <Rule>
         <Data> 
            <Type Name="{sql:column("TypeName")}" />
            <CreatedBy>{sql:column("CreatedBy")}</CreatedBy>
            <ChangedBy>{sql:column("ChangedBy")}</ChangedBy>
            <OutputColumnRules />
         </Data>
      </Rule>
    </Setting>')
FROM @t