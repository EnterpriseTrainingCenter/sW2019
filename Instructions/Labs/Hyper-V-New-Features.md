# Lab: New features in Hyper-V

## Required VMs

* DC1
* DHCP
* Router
* HV1
* CL1
* SRV2
* FS on HV1
* NODE1 on HV1
* NODE2 on HV1
* UBUNTU on HV1

## Exercises

1. [Hot-add/remove memory to a Linux VM](#exercise-1-hot-addremove-memory-to-a-linux-vm)
1. [Change secure boot templates for VMs](#exercice-2-change-secure-boot-templates-for-vms)
1. [Test storage resilience](#exercise-3-test-storage-resilience)
1. [Test ReFS VHDX performance](#exercise-4-test-refs-vhdx-performance)
1. [Hot add/remove network adapters](#exercise-5-hot-addremove-network-adapters)

## Exercise 1: Hot-add/remove memory to a Linux VM

### Introduction

In this exercise, you will add memory to the Linux VM Ubuntu while it is running. Then, you will try to remove memory while it is running.

#### Tasks

1. [Query memory of a Linux VM](#task-1-query-memory-of-a-linux-vm)
1. [Hot-add memory to a Linux VM](#task-2-hot-add-memory-to-a-linux-vm)
1. [Hot-remove memory of a Linux VM](#task-3-hot-remove-memory-of-a-linux-vm)

### Task 1: Query memory of a Linux VM

Perform these tasks on Ubuntu.

1. Sign in as **Lab** with the password **Pa$$w0rd**.
1. In the upper left corner, click on **Activities** and search for and start **Terminal**.
1. In Terminal, query the memory.

    ````shell
    free
    ````

    You should see a total memory of about 2 GB.

### Task 2: Hot-add memory to a Linux VM

#### Desktop experience

Perform these steps on HV1.

1. In **Ubuntu on HV1 - Virtual Machine Connection**, click on **File**, **Settings...**
1. In **Settings for ubuntu on HV1**, click **Memory**.
1. Under **Memory**, in **RAM**, type 4096 and click **OK**.

    If you receive an error message while increasing the RAM, temporary save some other virtual machines on HV1 and try again.

Repeat task 1. You should see a total memory of about 4 GB.

#### PowerShell

Perform these steps on HV1.

1. Run **Windows PowerShell** as Administrator.
1. Increase the startup memory of VM **Ubuntu** to **4 GB**.

    ````powershell
    $vMName = 'Ubuntu'
    Set-VMMemory -VMName $vMName -StartupBytes 4GB
    ````

    If you receive an error message while increasing the RAM, temporary save some other virtual machines on HV1 and try again.

Repeat task 1. You should see a total memory of about 4 GB.

### Task 3: Hot-remove memory of a Linux VM

#### Desktop experience

Perform these steps on HV1.

1. In **Ubuntu on HV1 - Virtual Machine Connection**, click on **File**, **Settings...**
1. In **Settings for ubuntu on HV1**, click **Memory**.
1. Under **Memory**, in **RAM**, type 2048 and click **OK**.

    > Could you remove the memory?

Repeat task 1.

> What is the memory used?

#### PowerShell

Perform this task on HV1.

In Windows PowerShell, decrease the startup memory of VM **Ubuntu** to **2GB**.

````powershell
# $vMName = 'Ubuntu'
Set-VMMemory -VMName $vMName -StartupBytes 2GB
````

> Could you remove the memory?

Repeat task 1.

> What is the memory used?

## Exercice 2: Change secure boot templates for VMs

### Introduction

In this exercise, you will change the secure boot template of the virtual machine Ubuntu to Microsoft Windows and observe the results. Then you will revert your changes.

#### Tasks

1. [Change secure boot templates for VMs](#task-1-change-secure-boot-templates-for-vms)

### Task 1: Change secure boot templates for VMs

#### Desktop experience

Perform these steps on HV1.

1. In **Hyper-V Manager**, in the context-menu of **Ubuntu**, click **Shut down...**

    Wait for the virtual machine to shut down.

1. In the context-menu of **Ubuntu**, click **Settings...**
1. In **Settings for Ubuntu on HV1**, click **Security**.
1. Under **Security**, **Template**, select **Microsoft Windows** and click **OK**.
1. In the context-menu of **Ubuntu**, click **Start**.
1. Double-click on **Ubuntu** to connect to the virtual machine.

    > Could Ubuntu boot? Why or why not?

1. In **Hyper-V Manager**, in the context-menu of **Ubuntu**, click **Turn Off...**
1. Repeat steps 2 - 4 to change the template back to **Microsoft UEFI Certificate Authority**.

#### PowerShell

Perform these steps on HV1.

1. Run **Windows PowerShell** as Administrator.
1. Shut down **Ubuntu**.

    ````powershell
    # $vMName = 'Ubuntu'
    Stop-VM -VMName $vMName
    ````

1. Change the secure boot template of the VM to **MicrosoftWindows**

    ````powershell
    Set-VMFirmware -VMName $vMName -SecureBootTemplate MicrosoftWindows
    ````

1. Start the VM.

    ````powershell
    Start-VM -VMName $vMName
    ````

1. Open or switch to **Hyper-V Manager**.
1. Double-click on **Ubuntu** to connect to the virtual machine.

    > Could Ubuntu boot? Why or why not?

1. Switch to **Windows PowerShell**
1. Turn off the VM.

    ````powershell
    Stop-VM -VMName $vMName -TurnOff
    ````

1. Change the secure boot template back to **MicrosoftUEFICertificateAuthority**.

    ````powershell
    Set-VMFirmware `
        -VMName $vMName `
        -SecureBootTemplate MicrosoftUEFICertificateAuthority
    ````

## Exercise 3: Test storage resilience

### Introduction

In this exercise, you will first create a new VM based on the Nanoserver image. The virtual hard disk will be located on the clustered file server VFS. You will simulate a storage failure by stopping VFS. You will verify the VM keeps running. Finally, you will restore the storage by restarting VFS.

#### Tasks

1. [Create and start a new virtual machine](#task-1-create-and-start-a-new-virtual-machine)
1. [Simulate a storage failure](#task-2-simulate-a-storage-failure)
1. [Check state of the virtual machine](#task-3-check-state-of-the-virtual-machine)
1. [Simulate storage recovery](#task-4-simulate-storage-recovery)

### Task 1: Create and start a new virtual machine

#### Desktop experience

Perform these steps on HV1.

1. Open **File Explorer**.
1. Copy the file **L:\NanoVHDX\Nanoserver.vhdx** to **\\\VFS\Data**.
1. In **Hyper-V Manager**, in the context-menu of **HV1**, click **New**, **Virtual Machine...**
1. In New Virtual Machine Wizard, on page **Specify Name and Location**, in **Name**, enter **NanoServer**. Activate **Store the virtual machine in a different location**. In **Location**, enter **\\\VFS\Data** and click **Next >**.
1. On page **Specify Generation**, click **Generation 2** and click **Next >**.
1. On page **Assign Memory**, ensure **Startup memory** is set to **1024** MB and click **Next >**.
1. On page **Configure Networking**, in **Connection**, select **Datacenter 1** and click **Next >**.
1. On page **Connect Virtual Hard Disk**, click **Use an existing virtual hard disk**. In **Location**, enter **\\\VFS\Data\NanoServer.vhdx** and click **Next >**.
1. On page **Completing the New Virtual Machine Wizard**, click **Finish**.
1. In the context-menu of **NanoServer**, click **Start**.

#### PowerShell

Perform these steps on HV1.

1. Run **Windows PowerShell** as Administrator.
1. Copy the file **L:\NanoVHDX\Nanoserver.vhdx** to **\\\VFS\Data**.

    ````powershell
    $destination = '\\VFS\Data'
    Copy-Item -Path L:\NanoVHDX\Nanoserver.vhdx -Destination $destination
    ````

1. Create a new generation 2 VM with the name **NanoServer** in path **\\\VFS\Data** with 1 GB startup memory connected to the Datacenter1 switch using the virtual hard disk you copied in the previous step.

    ````powershell
    $vMName = 'NanoServer'
    $vHDPath = Join-Path -Path $destination -ChildPath 'NanoServer.vhdx'
    New-VM `
        -Name $vMName `
        -Path \\VFS\Data`
        -Generation 2 `
        -MemoryStartupBytes 1GB `
        -SwitchName Datacenter1 `
        -VHDPath $vHDPath
    ````

1. Start the new virtual machine.

    ````powershell
    Start-VM -VMName $vMName
    ````

### Task 2: Simulate a storage failure

#### Desktop experience

Perform these steps on Node1.

1. Sign in as **smart\administrator**.
1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, navigate to **Failover Cluster Manager**, **Cluster.smart.etc**, **Roles**.
1. Under Roles, in the context-menu of **VFS**, click **Stop Role**.

    This simulates a storage failure.

#### PowerShell

1. Sign in as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Stop the cluster group **VFS**.

    ````powershell
    $name = 'VFS'
    Stop-ClusterGroup -Name $name
    ````

    This simulates a storage failure.

### Task 3: Check state of the virtual machine

#### Desktop experience

Perform this task on HV1.

In **Hyper-V Manager**, check the **State** of **NanoServer**.

For about 1 - 2 minutes it will show **Running-Critical**. After that period, it changes to **Paused-Critical**.

#### PowerShell

Perform this task on HV1.

In **Windows PowerShell**, display the virtual machine state.

````powershell
# $vMName = 'NanoServer'
Get-VM -VMName $vMName
````

For about 1 - 2 minutes it will show the **State** **Running-Critical**. After that period, this changes to **Paused-Critical**.

### Task 4: Simulate storage recovery

#### Desktop experience

Perform these steps on Node1.

1. Under Roles, in the context-menu of **VFS**, click **Start Role**.

Repeat task 3. **State** of **NanoServer** should be **Running** again.

#### PowerShell

Perform these steps on Node1.

1. In **Windows PowerShell**, start the cluster group **VFS**.

    ````powershell
    $name = 'VFS'
    Start-ClusterGroup -Name $name
    ````

Repeat task 3. **State** of **NanoServer** should be **Running** again.

## Exercise 4: Test ReFS VHDX performance

### Introduction

In this exercise, you will first create a 50 GB ReFS volume on HV1. Then, you will run the script AccelerateVHDX.ps1 to evaluate the performance of ReFS in comparison to NTFS.

#### Tasks

1. [Create ReFS volume](#task-1-create-refs-volume)
1. [Test VHDS performance on ReFS](#task-2-test-vhdx-performance-on-refs)

### Task 1: Create ReFS volume

#### Desktop experience

Perform these steps on HV1.

1. From the context-menu of the **Start** button, open **Disk Management**.
1. In Disk Management, in the context-menu of **VM (D:)**, click **Shrink Volume...**
1. In Shrink D:, In **Enter the amount of space to shrink in MB**, enter **51200** and click **Shrink**.
1. In the context-menu of the 50,00 GB unallocated space, click **New Simple Volume...**.
1. In New Simple Volume Wizard, on page **Welcome to the New Simple Volume Wizard**, click **Next >**.
1. On page **Specify Volume Size**, click **Next >**.
1. On page **Assign Drive Letter or Path**, in **Asign the following drive letter**, select **F:** and click **Next >**.
1. On page **Format Partition**, in **File system**, select **ReFS** and click **Next >**.
1. On page **Completing the New Simple Volume Wizard**, click **Finish**.

#### Windows Admin Center

Perform these steps on CL1.

1. Sign in as **smart\Administrator**.
1. Open **Google Chrome**.
1. In Google Chrome, navigate to **https://admincenter.smart.etc**.
1. In Windows Admin Center, click **hv1.smart.etc**.
1. Connected to HV1.smart.etc, in **Tools**, click **Storage**.
1. In **Storage**, click **Disk 1**.
1. Under **Details - Disk 1**, click **VM (D:)**.
1. Click **Resize**.
1. In the pane Resize volume (D:), in **New volume size (GB)**, enter 200 GB.
1. Back in **Storage**, click **Disk 1**.
1. Click **Create volume**.
1. In the pane Create volume, in **Drive letter**, select **F**. In **File system**, select **ReFS**. Activate **Use maximum size** and click **Submit**.

#### PowerShell

Perfom these steps on HV1.

1. Run **Windows PowerShell** as Administrator.
1. Shrink partition D by 50 GB.

    ````powershell
    $driveLetter = 'D'
    $partition = Get-Partition -DriveLetter $driveLetter
    $size = $partition.Size - 50GB
    Resize-Partition -DriveLetter $driveLetter -Size $size

    ````

1. On the free space, create a new partition and assign it the drive letter F.

    ````powershell
    $driveLetter = 'F'
    $partition = New-Partition `
        -DiskNumber $partition.DiskNumber `
        -UseMaximumSize `
        -DriveLetter $driveLetter
    ````

1. Format the new partition  with the file system ReFS.

    ```powershell
    Format-Volume -Partition $partition -FileSystem ReFS
    ````

### Task 2: Test VHDX performance on ReFS

Perform these steps on HV1.

1. Run **Windows PowerShell** as Administrator.
1. In Windows PowerShell, execute **L:\Hyper-V\AccelerateVHDX.ps1** and follow the instructions.

    This script creates one virtual disk on the VM (NTFS) volume, and one on the ReFS formatted volume. Note the difference in duration.

## Exercise 5: Hot add/remove network adapters

### Introduction

In this exercise, you will first add two additional network adapters to the running virtual machine FS. Then, you will verify the network adapter inside the virtual machine. Finally, you will remove the network adapters again.

#### Tasks

1. [Hot-add network adapters](#task-1-hot-add-network-adapters)
1. [Verify the added network adatpers](#task-2-verify-the-added-network-adapters)
1. [Hot-remove network adapters](#task-3-hot-remove-network-adapters)

### Task 1: Hot-add network adapters

#### Desktop experience

Perform these steps on HV1.

1. In **Hyper-V Manager**, ensure the virtual machine **FS** is running. In the context-menu of **FS**, click **Settings...**.
1. In Settings for FS on HV1, under **Add Hardware**, click **Network Adapter** and click **Add**.
1. Click **Add Hardware**.
1. Repeat step 2 to add another network adapter.
1. Click **OK**.

#### PowerShell

Perform these steps on HV1.

1. Run **Windows PowerShell** as Administrator.
1. Ensure, virtual machine **FS** is running.

    ````powershell
    $vMName = 'FS'
    Start-VM -VMName $vMName
    ````

1. Add two new network adapters to the virtual machine.

    ````powershell
    Add-VMNetworkAdapter -VMName $vMName
    Add-VMNetworkAdapter -VMName $vMName
    ````

1. Verify, the network adapters have been added.

    ````powershell
    Get-VMNetworkAdapter -VMName $vMName
    ````

### Task 2: Verify the added network adapters

Perform these steps on FS.

1. Sign in as **smart\Administrator**.
1. Open **Server Manager**.
1. In Server Manager, click **Local Server**.

    Confirm two new network adapters called **Ethernet 2** and **Ethernet 3** are listed.

### Task 3: Hot-remove network adapters

#### Desktop experience

Perform these steps on HV1.

1. In **Hyper-V Manager**, in the context-menu of **FS**, click **Settings...**.
1. In Settings for FS on HV1, click **Network Adapter**.
1. In Network Adapter, click **Remove**.
1. Repeat steps 2 and 3 for the second **Network Adapter**.
1. Click **OK**.

#### PowerShell

Perform this task on HV1.

In Windows PowerShell, remove the two network adapters you added in task 1.

    ````powershell
    Get-VMNetworkAdapter -VMName $vMName -Name 'Network Adapter' |
    Remove-VMNetworkAdapter
    ````