/*
    C:\ > OS
    D:\ > DATA    >> RAID 10 / 6* / 5*
    E:\ > LOG     >> RAID 10 / 1 / SSD
    F:\ > TEMPDB  >> RAID 0 / SSD
    G:\ > BACKUP  >> RAID 1 / NAS**

    * - poor write performance

    ----------------------------------------------------------------

    https://technet.microsoft.com/en-us/library/dd758814(v=sql.100).aspx

    cmd > fsutil fsinfo ntfsinfo D:

    NTFS Volume Serial Number :       0xfc666d79666d3594
    NTFS Version   :                  3.1
    LFS Version    :                  2.0
    Number Sectors :                  0x00000000493e3ff8
    Total Clusters :                  0x000000000927c7ff
    Free Clusters  :                  0x0000000006070c02
    Total Reserved :                  0x0000000000000000
    Bytes Per Sector  :               512
    Bytes Per Physical Sector :       4096
    Bytes Per Cluster :               4096 >>>>>>>> 64Kb
    Bytes Per FileRecord Segment    : 1024

    ----------------------------------------------------------------

    Server Power Configuration -> High Perfomance
    Optimized Visualization -> Optimized for Performance
    Server Manager -> Disable Auto-Start

    ----------------------------------------------------------------

    VW: Network -> Host-only adapter -> ipconfig/ping

    * Thick Provision Lazy Zeroed (default)
      Space required for the virtual disk is allocated during the creation of the disk file.
      Any data remaining on the physical device is not erased during creation,
      but is zeroed out on demand at a later time on first write from the virtual machine.
      The virtual machine does not read stale data from disk.

    * Thick Provision Eager Zeroed
      Space required for the virtual disk is allocated at creation time.
      In contrast to thick provision format, the data remaining on the physical device is zeroed out during creation.
      It might take much longer to create disks in this format than to create other types of disks.

    * Thin Provision
      Space required for the virtual disk is not allocated during creation,
      but is supplied and zeroed out, on demand at a later time.
*/