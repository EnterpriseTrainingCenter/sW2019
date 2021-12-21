# Lab: Storage Spaces & Storage Tiering

## Required VMs

* DC1
* DHCP
* HV1
* FS on HV1
* Router

## Exercises

1. [Storage Spaces](#exercise-1-storage-spaces)
1. [Storage Tiering](#exercise-2-storage-tiering)

## Exercise 1: Storage Spaces

### Introduction

In this exercise, you will create a local Storage Pool on FS using the five remaining 100 GB disks, create a three-way mirror virtual disk with 40 GB and create a ReFS volume G: on it. Finally, you will test the storage pool resilience by removing physical disks from the server, repair the virtual disk by adding a new phyical disk and remove the storage pool.

#### Tasks

1. [Creating a Storage Pool](#task-1-creating-a-storage-pool)
1. [Creating virtual disks](#task-2-creating-virtual-disks)
1. [Test Storage Pool resilience](#task-3-testing-storage-pool-resilience)
1. [Repairing a virtual disk](#task-4-repairing-a-virtual-disk)
1. [Removing a Storage Pool](#task-5-removing-a-storage-pool)

### Task 1: Creating a Storage Pool

#### Desktop Experience

Perform these steps on FS.

1. Open **Server Manager**.
1. Click on **File and Storage Services** and then click on **Storage Pools**.
1. From the tasks drop-down, select **New Storage Pool...** ([figure 1]).
1. Sort the view by **Chassis** ([figure 2]). Create a new Storage Pool **Pool1** using the five 100 GB disks. Do not use the disk on SCSI LUN2!

#### Powershell

Perform these steps on FS.

1. Run **Windows PowerShell** as administrator.
1. Create a new Storage Pool **Pool1** using the five 100 GB disks. Do not use the disk on SCSI LUN2!

   ````powershell
   $physicalDisks =  Get-PhysicalDisk -CanPool $true | 
      Where-Object { 
         $PSItem.Size -eq 100GB -and $PSItem.PhysicalLocation -notlike '*LUN 2' 
      }
   $storagePool = New-StoragePool `
      -FriendlyName Pool1 `
      -PhysicalDisks $physicalDisks `
      -StorageSubSystemFriendlyName 'Windows Storage*'
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 2: Creating virtual disks

#### Desktop Experience

Perform these steps on FS.

1. From the context menu of the new storage pool, select **New virtual disk…**.
1. Create a virtual disk. At the end of the wizard continue with the next wizard.

   * **Name:** Data
   * **Storage layout:** **Mirror**
   * **Resiliency:** **Three-way mirror**
   * **Provisioning type:** **Thin**
   * **Size:** 40GB

1. Create a new volume on the new virutal disk.
   * **Drive Letter:** G:
   * **File System:** **ReFS**
   * **Volume Label:** Data
   * **Deduplication:** disabled

#### PowerShell

Perform these steps on FS.

1. Create a virtual disk.

   * Name: Data
   * Storage layout: Mirror
   * Resiliency: Three-way mirror
   * Provisioning type: Thin
   * Size: 40GB

   ````powershell
   $virtualDisk = $storagePool | New-VirtualDisk `
      -FriendlyName Data `
      -ResiliencySettingName Mirror `
      -ProvisioningType Thin `
      -Size 40GB
   ````

1. Create a new volume on the new virutal disk.
   * Drive Letter: G:
   * File System: ReFS
   * Volume Label: Data
   * Deduplication: disabled

   ```powershell
   New-Volume `
      -FriendlyName Data `
      -FileSystem ReFS `
      -DriveLetter G `
      -DiskUniqueId $VirtualDisk.UniqueId
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 3: Testing Storage Pool resilience

#### Desktop Experience

Perform these steps on HV1.

1. Open **File Explorer**.
1. Start a copy process from **D:\ISO\WS2016.iso** to **\\\FS\G$**.
1. During the file copy process, in **Hyper-V Manger**, from the virtual machine **FS**, remove one of the 5 disks starting with LUN3.

   > Does the file copy process continue?

1. Wait for the file copy process to complete.
1. In **Hyper-V Manager**, from the virtual machine **FS**, remove another disk starting with LUN3.

   > On **FS**, what is the impact of the latest disk removal in **Server Manager**, **Storage Spaces** (press F5)? ([figure 3])

1. Reconnect one of the removed disks

#### PowerShell

Perform these steps on HV1.

1. Run **Windows PowerShell** as Administrator
1. Start a copy process from D:\ISO\WS2016.iso to \\FS\G$.

   ```powershell
   Copy-Item D:\ISO\WS2016.iso \\FS\G$
   ````

1. During the file copy process, remove one of the 5 disks starting with LUN3.

   ````powershell
   $hardDiskDrives = Get-VMHardDiskDrive -VMName FS | 
      Where-Object { $PSItem.ControllerLocation -ge 3 }

   # Save the disk's path, so we can easily reconnect it later.   
   $path0 = $hardDiskDrives[0].Path
   $hardDiskDrives[0] | Remove-VMHardDiskDrive
   ````

   > Does the file copy process continue?

   Wait for the file copy process to complete.

1. Remove another disk starting with LUN3.

   ````powershell
   $path1 = $hardDiskDrives[1].Path
   $hardDiskDrives[1] | Remove-VMHardDiskDrive
   ````

   > On **FS**, what is the impact of the latest disk removal in FS? Hint:

   ````powershell
   # Run these on FS
   Get-StoragePool -FriendlyName $StoragePool.FriendlyName
   Get-VirtualDisk -StoragePool $StoragePool
   Get-PhysicalDisk -StoragePool $StoragePool 
   ````

1. Reconnect one of the removed disks.

   ````powershell
   Add-VMHardDiskDrive -VMName FS -Path $path0
   ````

### Task 4: Repairing a virtual disk

#### Desktop Experience

Perform these steps on FS.

1. In **Server Manager**, on the left-hand menu tree, select **Disks**.
1. From the context menu of **Disk 2**, select **Reset Disk**.
1. Initialize Disk 2.
1. From the context menu of **Pool1**, select **Add Physical Disk...** ([figure 4]).
1. Configure the disk added in the previous step as **Hot Spare** ([figure 5]).
1. From the context menu of the virtual disk **Data**, select **Repair Virtual Disk** ([figure 6]).
1. From the context menu of the missing physical disk, select **Remove Disk** ([figure 7].
1. In **Server Manager**, refresh the view. All warnings should disappear.

#### PowerShell

Perform these steps on FS.

1. Reset the failed disk.

   ````powershell
   Remove-PhysicalDisk -StoragePool $StoragePool -PhysicalDisks $PhysicalDisks[0]
   `````

   It is not necessary to initialize the reconnected disk.

1. Add the reconnected disk and configure it as hot spare.

   ````powershell
   $PhysicalDisk = Get-PhysicalDisk -CanPool $true | 
      Where-Object { 
         $PSItem.Size -eq 100GB 
      }
   
   Add-PhysicalDisk `
      -StoragePool $StoragePool -PhysicalDisks $PhysicalDisk -Usage HotSpare
   ````

1. Repair the virtual disk Data.

   ````powershell
   Get-VirtualDisk -HealthStatus Warning | Repair-VirtualDisk
   ````

1. Remove the missing disk

   ````powershell
   $PhysicalDisksWarning = Get-PhysicalDisk `
      -StoragePool $StoragePool -HealthStatus Warning

   $PhysicalDisksWarning | Set-PhysicalDisk -Usage Retired
   
   Remove-PhysicalDisk `
      -StoragePool $StoragePool -PhysicalDisks $PhysicalDisksWarning
   ````

1. All warnings should disappear.

   ````powershell
   Get-StoragePool -FriendlyName $StoragePool.FriendlyName
   Get-VirtualDisk -StoragePool $StoragePool
   Get-PhysicalDisk -StoragePool $StoragePool
   ````

### Task 5: Removing a Storage Pool

#### Desktop Experience

Peform these steps on FS.

1. From the context menu of the volume, select **Delete volume**.
1. From the context menu of the virtual disk, select **Delete Virtual Disk**.
1. From the context menu of the storage pool, select **Delete Storage Pool**.

#### PowerShell

Peform these steps on FS.

1. Delete the volume

   ````powershell
   Remove-Partition -DriveLetter G
   ````

1. Delete the virtual disk.

   ````powershell
   Remove-VirtualDisk -FriendlyName Data
   ````

1. Delete the storage pool.

   ````powershell
   Remove-StoragePool -FriendlyName Pool1
   ````

## Exercise 2: Storage Tiering

### Introduction

In this exercise, you will first change the media type of the 50 GB physical disks of FS to SSD, and the media type of the 100 GB physical disks to HDD.  Then, you will create a new tiered Storage Pool using the 50 GB and 100 GB disks. Next, you will create a new mirror virtual disk in the Storage Pool with 45 GB in the faster tier, and 240 GB in the standard tier and create a volume with default settings.

#### Tasks

1. [Creating a tiered Storage Pool](#task-1-creating-a-storage-pool)
1. [Creating a tiered virtual disk](#task-2-creating-a-tiered-virtual-disk)
1. Testing Storage Pool resilience

Detailed Instructions

### Task 1: Creating a Storage Pool

#### Desktop Experience

Perform these steps on FS.

1. On FS open Server Manager
1. Run **Windows PowerShell** as Administrator.
1. In **Windows PowerShell**, execute:

   ````powershell
   Get-PhysicalDisk | Where Size -EQ 50GB | Set-PhysicalDisk -MediaType SSD
   Get-PhysicalDisk | Where Size -EQ 100GB | Set-PhysicalDisk -MediaType HDD
   ````

   This simulates our virtual disks being SSDs and HDDs.

1. Switch to **Server Manager**.
1. Click **File and Storage Services**, **Volumes**, **Storage Pools**,
1. In **Storage Pools**, refresh Server Manager, you should see the faked media types ([figure 8]).
1. In the drop-down **Tasks**, click **New Storage Pool...**.
1. Create a new storage pool with the name **TieredPool1** using all available physical disks.

#### PowerShell

Perform these steps on FS.

1. Run **Windows PowerShell** as Administrator.
1. In **Windows PowerShell**, execute:

   ````powershell
   Get-PhysicalDisk | Where Size -EQ 50GB | Set-PhysicalDisk -MediaType SSD
   Get-PhysicalDisk | Where Size -EQ 100GB | Set-PhysicalDisk -MediaType HDD
   ````

   This simulates our virtual disks being SSDs and HDDs.

1. Validate the media type of the physical disks.

   ````powershell
   Get-PhysicalDisk
   ````

1. Create a new storage pool with the name **TieredPool1** using all available physical disks.

   ````powershell
   $pooldisks = Get-PhysicalDisk | Where-Object { $PSItem.CanPool –eq $true }

   # The back tick ` allows to split long commands into multiple lines

   $storagePoolFriendlyName = 'TieredPool1'
   New-StoragePool `
      -StorageSubSystemFriendlyName 'Windows Storage*' `
      -FriendlyName $storagePoolFriendlyName `
      -PhysicalDisks $pooldisks
   New-StorageTier `
      -StoragePoolFriendlyName $storagePoolFriendlyName `
      -FriendlyName SSD_TIER `
      -MediaType SSD
   New-StorageTier `
      -StoragePoolFriendlyName $storagePoolFriendlyName `
      -FriendlyName HDD_TIER `
      -MediaType HDD
   ````

### Task 2: Creating a tiered virtual disk

#### Desktop Experience

Perform these steps on FS.

1. From the context menu of the storage pool, select **New virtual disk…**.
1. Create a virtual disk. At the end of the wizard continue with the next wizard.

   * **Name:** Tiered Disk 1
   * **Create storage tiers on this virtual disk**
   * **Storage layout:** **Mirror**
   * **Size:**
     * **Faster tier:** 45 GB
     * **Standard tier:** 240 GB

1. In the **New Volume Wizard**, create a standard volume with the name **Volume** using the default settings.

#### PowerShell

Perform these steps on FS.

1. Switch **Windows PowerShell ISE**
1. Create a virtual disk.

   * Name: Tiered Disk 1
   * Storage layout: Mirror
   * Size:
     * Faster tier: 45 GB
     * Standard tier: 240 GB

   ````powershell
   $VirtualDisk = New-VirtualDisk `
      -StoragePoolFriendlyName TieredPool1 `
      -FriendlyName 'Tiered Disk 1' `
      -StorageTiers $tier_ssd, $tier_hdd `
      -ResiliencySettingName Mirror `
      -StorageTierSizes 45GB, 220GB
   ````

1. Create a standard volume using the default settings.

   ````powershell
   New-Volume -DiskUniqueId $VirtualDisk.UniqueId -FriendlyName Volume
   ````

### Epilog

Note the scheduled tasks for **Storage Tier Management**.

![Scheduled tasks for storage Tiers Management: Storage Tiers Management Initialization, Storage Tiers Optimization][figure 9]

As our HDDs are simulated, we will not see any acceleration in this lab. Note that you could assign files permanently to the SSD tier, for example:

````powershell
$filePath = 'G:\VM1\Virtual hard Disks\VM1.vhdx'
Set-FileStorageTier `
    -FilePath $filePath `
    -DesiredStorageTierFriendlyName 'Tiered Disk 1_Microsoft_SSD_Template'
````

[figure 1]: images/S2-tasks-new-storage-pool.png
[figure 2]: images/S2-physical-disks-sortby-chassis.png
[figure 3]: images/S2-problem.png
[figure 4]: images/S2-add-physical-disk.png
[figure 5]: images/S2-add-physical-disk-hot-spare.png
[figure 6]: images/S2-repair-virtual-disk.png
[figure 7]: images/S2-remove-disk.png
[figure 8]: images/Storage-tiers-physical-disks-media-type.png
[figure 9]: images/Storage-tiers-scheduled-tasks.png
