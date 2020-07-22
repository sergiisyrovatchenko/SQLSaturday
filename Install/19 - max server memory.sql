USE [master]
GO

EXEC sys.sp_configure N'min server memory (MB)', N'1024'
GO
EXEC sys.sp_configure N'max server memory (MB)', N'2048'
GO
RECONFIGURE WITH OVERRIDE
GO

/*
    Express edition?

    max server memory = 80Gb (90Gb on server)
    migrate on another VM
    70Gb total, but max server memory still the same
    what's happends?
*/

------------------------------------------------------------------

SELECT [object_name], cntr_value
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Manager%'
    AND [counter_name] = 'Page life expectancy'

/*
    PAGEIOLATCH_SH, RESOURCE_SEMAPHORE
*/

SELECT physical_memory_in_use_mb = physical_memory_in_use_kb / 1024
     , large_page_allocations_mb = large_page_allocations_kb / 1024
     , locked_page_allocations_mb = locked_page_allocations_kb / 1024
     , memory_utilization_percentage
     , available_commit_limit_mb = available_commit_limit_kb / 1024
     , process_physical_memory_low
     , process_virtual_memory_low
FROM sys.dm_os_process_memory WITH(NOLOCK)

SELECT physical_memory_mb = total_physical_memory_kb / 1024
     , available_memory_mb = available_physical_memory_kb / 1024
     , total_page_file_mb = total_page_file_kb / 1024
     , available_page_file_mb = available_page_file_kb / 1024
     , system_cache_mb = system_cache_kb / 1024
     , system_memory_state_desc
FROM sys.dm_os_sys_memory WITH(NOLOCK)