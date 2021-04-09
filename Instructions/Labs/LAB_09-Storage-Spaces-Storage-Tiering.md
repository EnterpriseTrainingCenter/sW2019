# Lab 9: Storage Spaces & Storage Tiering

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

In this exercise, you will create a local Storage Space, configure some virtual disks and test what happens if you remove one or more disks.

### Tasks

1. [Creating a Storage Pool](#task-1-creating-a-storage-pool)
1. [Creating virtual disks](#task-2-creating-virtual-disks)
1. [Test Storage Pool resilience](#task-3-testing-storage-pool-resilience)
1. [Repairing a virtual disk](#task-4-repairing-a-virtual-disk)
1. [Removing a Storage Pool](#task-5-removing-a-storage-pool)

### Detailed Instructions

#### Task 1: Creating a Storage Pool

Perform these steps on FS.

1. Open **Server Manager**.
1. Click on **File and Storage Services** and then click on **Storage Pools**.
1. From the tasks drop-down, select **New Storage Pool...** ([figure 1]).
1. Sort the view by **Chassis** ([figure 2]). Create a new Storage Pool **Pool1** using the five 100 GB disks. Do not use the disk on SCSI LUN2!

#### Task 2: Creating virtual disks

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

#### Task 3: Testing Storage Pool resilience

Perform these steps on HV1.

1. Open **File Explorer**.
1. Start a copy process from **D:\ISO\WS2016.iso** to **\\\FS\G$**.
1. During the file copy process, in **Hyper-V Manger**, from the virtual machine **FS**, remove one of the 5 disks starting with LUN3.

   > Does the file copy process continue?

1. Wait for the file copy process to complete.
1. In **Hyper-V Manager**, from the virtual machine **FS**, remove another disk starting with LUN3.

   > On **FS**, what is the impact of the latest disk removal in **Server Manager**, **Storage Spaces** (press F5)? ([figure 3])

1. Reconnect one of the removed disks

#### Task 4: Repairing a virtual disk

Perform these steps on FS.

1. In **Server Manager**, on the left-hand menu tree, select **Disks**.
1. From the context menu of **Disk 2**, select **Reset Disk**.
1. Initialize Disk 2.
1. From the context menu of **Pool1**, select **Add Physical Disk...** ([figure 4]).
1. Configure the disk added in the previous step as **Hot Spare** ([figure 5]).
1. From the context menu of the virtual disk **Data**, select **Repair Virtual Disk** ([figure 6]).
1. From the context menu of the missing physical disk, select **Remove Disk** ([figure 7].
1. In **Server Manager**, refresh the view. All warnings should disappear.

#### Task 5: Removing a Storage Pool

Peform these steps on FS.

1. From the context menu of the volume, select **Delete volume**.
1. From the context menu of the virtual disk, select **Delete Virtual Disk**.
1. From the context menu of the storage pool, select **Delete Storage Pool**.

## Exercise 2: Storage Tiering

### Introduction

In this exercise, you will create a new Storage Pool with Storage Tiering. This demonstrates how to make use of a fast SSD Cache in conjunction with slower HDDs.

### Tasks

1. [Creating a tiered Storage Pool](#task-1-creating-a-storage-pool)
1. [Creating a tiered virtual disk](#task-2-creating-a-tiered-virtual-disk)
1. Testing Storage Pool resilience

Detailed Instructions

#### Task 1: Creating a Storage Pool

Perform these steps on FS.

1. On FS open Server Manager
1. Run **Windows PowerShell ISE** as Administrator.
1. In **Windows PowerShell ISE**, open the script **L:\Storage Spaces Direct\StorageTiering.ps1**.
1. Press F5 to execute the script - this will create a tiered storage space, where the 50GB vhdx Files simulates SSDs.
1. Refresh Server Manager, you should see the faked media types ([figure 8]).

#### Task 2: Creating a tiered virtual disk

Perform these steps on FS.

1. From the context menu of the storage pool, select **New virtual disk…**.
1. Create a virtual disk. At the end of the wizard continue with the next wizard.

   * **Name:** Tiered Disk 1
   * **Storage layout:** **Mirror**
   * **Size:**
     * **Faster tier:** 45 GB
     * **Standard tier:** 240 GB

1. Create a standard volume using the default settings.

As our HDDs are simulated, we will not see any acceleration in this lab. Note that you can assign files permanently to the SSD tier, for example:

````powershell
$filePath = 'G:\VM1\Virtual hard Disks\VM1.vhdx'

# The back tick ` allows to split long commands into multiple lines
Set-FileStorageTier `
    -FilePath $filePath `
    -DesiredStorageTierFriendlyName 'Tiered Disk 1_Microsoft_SSD_Template'
````

Note that there are scheduled tasks for **Storage Tier Management**.

![Scheduled tasks for storage Tiers Management: Storage Tiers Management Initialization, Storage Tiers Optimization][figure 9]

[figure 1]: images/Lab09/figure01.png
[figure 2]: images/Lab09/figure02.png
[figure 3]: images/Lab09/figure03.png
[figure 4]: images/Lab09/figure04.png
[figure 5]: images/Lab09/figure05.png
[figure 6]: images/Lab09/figure06.png
[figure 7]: images/Lab09/figure07.png
[figure 8]: images/Lab09/figure08.png
[figure 9]: images/Lab09/figure09.png
