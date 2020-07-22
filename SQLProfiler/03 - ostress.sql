/*
    RML Utilities for SQL Server (x64) CU4
    https://www.microsoft.com/en-us/download/confirmation.aspx?id=4511
*/

/*
    -n10                           -- number of connections
    -r25                           -- number of requests per connections
    -iD:\PROJECT\SQLProfiler\*.sql -- sql files
    -Q"SELECT @@VERSION"           -- query
    -dAdventureWorks2014           -- database
*/

EXEC sys.xp_cmdshell 'cmd /K "C:\Program Files\Microsoft Corporation\RMLUtils\ostress.exe" -SHOMEPC\SQL_2016 -E -q -N -n1 -r1 -QSELECT'''''