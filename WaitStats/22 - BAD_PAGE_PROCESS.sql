SELECT DB_NAME(database_id), *
FROM msdb.dbo.suspect_pages

------------------------------------------------------------------

DBCC CHECKDB ([AdventureWorks2014]) WITH ALL_ERRORMSGS

/*
    Msg 8946, Level 16, State 12, Line 1
    Table error: Allocation page (1:1002912) has invalid PFS_PAGE page header values. Type is 0. Check type, alloc unit ID and page ID on the page.

    Msg 8921, Level 16, State 1, Line 1
    Check terminated. A failure was detected while collecting facts. Possibly tempdb out of space or a system table is inconsistent. Check previous errors.

    Msg 8909, Level 16, State 1, Line 1
    Table error: Object ID 0, index ID -1, partition ID 0, alloc unit ID 0 (type Unknown), page ID (1:1002912) contains an incorrect page ID in its page header. The PageId in the page header = (0:0).

    Msg 8909, Level 16, State 1, Line 1
    Table error: Object ID 0, index ID -1, partition ID 0, alloc unit ID 0 (type Unknown), page ID (1:1002912) contains an incorrect page ID in its page header. The PageId in the page header = (0:0).

    Msg 8998, Level 16, State 2, Line 1
    Page errors on the GAM, SGAM, or PFS pages prevent allocation integrity checks in database ID 6 pages from (1:1002912) to (1:1010999). See other errors for cause.

    CHECKDB found 2 allocation errors and 1 consistency errors not associated with any single object.
    CHECKDB found 2 allocation errors and 1 consistency errors in database [AdventureWorks2014].
*/

------------------------------------------------------------------

ALTER DATABASE [AdventureWorks2014] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DBCC CHECKDB ([AdventureWorks2014], REPAIR_REBUILD)
GO

/*
    DBCC CHECKDB ([AdventureWorks2014], REPAIR_ALLOW_DATA_LOSS)
*/

------------------------------------------------------------------

BACKUP DATABASE [AdventureWorks2014]
    TO DISK = N'E:\AdventureWorks2014.bak'
    WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, CHECKSUM