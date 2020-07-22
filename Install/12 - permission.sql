/*
    NT Service\MSSQL$SQL_2017 -> to Administrator group ???
    NT SERVICE\SQLAgent$SQL_2017 -> network share for backup

    sa for all ???
    public with sysadmin ???

    ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT SERVICE\MSSQL$SQL_2017]
    ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT SERVICE\SQLAgent$SQL_2017]
*/

/*
    D:\PSTools\psexec.exe -s -i cmd
    -i - Interactive
    -s - Run as System

    whoami > nt authority\system

    sqlcmd -S HOMEPC\SQL_2012_EXP
*/

CREATE LOGIN hacker WITH PASSWORD = '1111'
EXEC sys.sp_addsrvrolemember @loginame = 'hacker', @rolename = 'sysadmin'
GO

SELECT IS_SRVROLEMEMBER('sysadmin', 'hacker')

/*
    2005..2012:

    ALTER LOGIN [NT AUTHORITY\SYSTEM] DISABLE
    ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT AUTHORITY\SYSTEM]
*/

/*
    DROP LOGIN hacker
*/