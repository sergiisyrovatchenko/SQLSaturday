/*
    .NET Framework 3.5 (Windows 8.1/10) *
    DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:C:\Sources\sxs

    * - must have for Database Mail to work, even in SQL 2016/2017
*/

/*
    net start MSSQL$SQL_2016
    net start SQLAgent$SQL_2016

    net stop SQLAgent$SQL_2016
    net stop MSSQL$SQL_2016
*/