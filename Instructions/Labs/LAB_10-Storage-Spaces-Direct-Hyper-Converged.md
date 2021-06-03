# Lab 10: Storage Spaces Direct Hyper-Converged

## Required VMs

* CL1
* DC1
* DHCP
* Router
* S2D1
* S2D2
* S2D3
* S2D4
* SRV2

## Exercises

1. [Storage Spaces Direct Configuration](#exercise-1-storage-spaces-direct-configuration)
2. [Test Hyper-Converged Cluster failover](#exercise-2-test-hyper-converged-cluster-failover)

## Exercise 1: Storage Spaces Direct Configuration

### Introduction

In this exercise, you will create a storage pool using all eligible disk on S2D1, S2D2, S2D3, and S2D4. You will set the cluster resiliency period to 10 seconds. Then, you will create a three-way mirrored volume with a size of 40 GB, and a mirror-accelerated parity volume with a size of 85 GB on the storage pool.

#### Tasks

1. [Enable Storage Spaces Direct](#task-1-enable-storage-spaces-direct)
1. [Administering S2D with Windows Admin Center](#task-2-administering-s2d-with-windows-admin-center)
1. [Create storage pools and virtual disks](#task-3-create-storage-pools-and-virtual-disks)

### Task 1: Enable Storage Spaces Direct

Peform these steps on CL1.

1. Logon as **smart\administrator**.
1. Run Windows PowerShell as Administrator.
1. Enable installation of S2D on non-certified hardware.

   ````powershell
   # Define a string array of computer names
   $computername = 'S2D1', 'S2D2', 'S2D3', 'S2D4'

   <#
   Invoke-Command allows a remote execution of the ScriptBlock 
   on a group of computers
   #>
   Invoke-Command -Computername $computername -ScriptBlock {
       
       # The back tick ` allows to split long commands into multiple lines
       New-ItemProperty `
        -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\ClusSvc\Parameters' `
        -Name S2D `
        -Value 1 `
        -PropertyType DWORD `
        -Force
    } 
   ````

1. Set the MediaType of all Disks to **HDD**

   ````powershell
   Invoke-Command -Computername $computername -ScriptBlock {
       Get-PhysicalDisk | Set-PhysicalDisk -MediaType HDD
   }
   ````

1. Activate Storage Spaces Direct

   ````powershell
   # A CIM session is necessary to run some commands remotely.
   # The first element of an array can be accessed by the [0] syntax.
   $cimSession = New-CimSession -ComputerName $computerName[0]

   Enable-ClusterS2D `
      -CimSession $cimSession `
      -CacheState Disabled `
      -SkipEligibilityChecks
   ````

1. List the storage pools in the cluster.

   ````powershell
   Get-StoragePool -CimSession $cimSession
   ````

   S2D automatically created a Storage Pool with all eligible disks ([figure 1]).

1. Set the cluster resiliency period to 10 seconds.

   ````powershell
   <#
   Get-Cluster returns the cluster object. ResiliencyDefaultPeriod is a property
   of the cluster object, that can be set. To see all properties of an object
   and whether they can be set or are read only, you can use the Get-Member
   cmdlet, e. g.
   $cluster | Get-Member
   #>
   $cluster.ResiliencyDefaultPeriod = 10 
   ````

### Task 2: Administering S2D with Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\administrator**.
1. Open **Google Chrome** and navigate to <https://admincenter.smart.etc>.
1. Add a hyper-converged cluster connection to **s2d**. Add all nodes in the cluster ([figure 2]).
1. Connect to **S2D.smart.etc**. Make yourself familiar with the dashboard
1. Click on **Servers**, **Inventory**. Discover the different options available for S2D server management.
1. Leave **Windows Admin Center** open for the next task.

### Task 3: Create storage pools and virtual disks

#### Windows Admin Center

Peform these steps on CL1.

1. Click on **Drives**, **Inventory**. You should see 12 drives from 4 servers.
1. Click on **Volumes**, **Inventory**. Notice the **ClusterPerformanceHistory** volume.
1. Create a new three-way mirrored Volume **Volume01** with a size of **40 GB**. Notice that you could also enable deduplication and compression for ReFS volumes ([figure 3]).
1. Create a second volume.
   * **Name**: Volume02
   * **Resiliency**: **Mirror-accelerated parity**
   * **Size on HDD**: 85 GB
1. Click on **Volume01**. Notice that new volumes are automatically added to cluster shared volumes and formatted using ReFS ([figure 4]).

#### PowerShell

Peform these steps on CL1.

1. In **Windows PowerShell**, list the drives in the Storage Pool. You should see 12 drives.

   ```powershell
   $cimSession = New-CimSession -ComputerName s2d
   $storagePool = Get-StoragePool -CimSession $cimSession -IsPrimordial $false
   $storagePool | Get-PhysicalDisk -CimSession $cimSession
   ````

1. List the nodes providing storage.

   ```powershell
   Get-StorageNode -CimSession $cimSession
   ````

1. List the virtual disks and volumes in the storage pool. Notice the **ClusterPerformanceHistory** volume.

   ````powershell
   $storagePool | Get-VirtualDisk -CimSession $cimSession

   $storagePool | Get-Volume -CimSession $cimSession
   ````

1. Create a new three-way mirrored Volume **Volume01** with a Size of **40 GB**.

   ````powershell
   $storagePool |
   New-Volume `
      -CimSession $cimSession `
      -FriendlyName "Volume01" `
      -FileSystem CSVFS_ReFS `
      -Size 40GB `
      -ResiliencySettingName Mirror
   ````

1. Create a second volume.
   * **Name**: Volume02
   * **Resiliency**: **Mirror-accelerated parity**
   * **Size on HDD**: 85 GB

   ````powershell
   $storagePool | 
   New-Volume `
      -CimSession $cimSession `
      -FriendlyName "Volume02" `
      -FileSystem CSVFS_ReFS `
      -Size 85GB `
      -ResiliencySettingName Parity
   ````

1. List cluster shared volumes. Notice that new volumes are automatically added to cluster shared volumes.

   ````powershell
   Get-ClusterSharedVolume -Cluster $cluster
   ````

1. Leave Windows PowerShell open for the next task.

## Exercise 2: Test Hyper-Converged Cluster failover

### Introduction

In this exercise, you will create a new virtual machine using the nanoserver VHDX file on L: within the Hyper-converged cluster. Then, you will simulate a workload and a failure by turning off the host machine of the VM. Next, you will validate the failover. Finally, you will simulate and validate the failure of a second node in the cluster.

#### Tasks

1. [Create a Nanoserver VM](#task-1-create-a-nanoserver-vm)
1. [Simulate a workload](#task-2-simulate-a-workload)
1. [Simulate a failure](#task-3-simulate-a-failure)
1. [Validate failover](#task-4-validate-failover)
1. [Simulate another failure](#task-5-simulate-another-failure)
1. [Validate failover again](#task-6-validate-failover-again)

### Task 1: Create a Nanoserver VM

#### Desktop Experience

Perform these steps on CL1.

1. Open **File Explorer**.
1. Copy **L:\NanoVHDX\Nanoserver.vhdx** to **\\\S2D1\C$\ClusterStorage\Volume01**
1. Open **Failover Cluster Manager**.
1. In **Failover Cluster Manager**, in the context menu of the node **Failover Cluster Manager**, click **Connect to Cluster...**
1. In **Select Cluster**, enter **s2d.smart.etc** and click **OK**.
1. Expand **s2d.smart.etc**.
1. In the context menu of **Role**, click **Virtual Machines...**, **New Virtual Machine..**.
1. In **New Virtual Machine**, select **S2D1** and click **OK**.
1. In the **New Virtual Machine Wizard**, on page **Before You Begin**, click **Next**.
1. On page **Specify name and Location**, in **Name**, enter **NanoServer**, activate **Store the virtual machine in a different location**, in **Location**, enter **C:\ClusterStorage\Volume01**, and click **Next**.
1. On page **Specify Generation**, click **Generation 2**, and click **Next**.
1. On page **Assign Memory**, leave **Startup memory** as **1024** MB, and click **Next**.
1. On page **Configure Networking**, in **Connection**, select **Datacenter1**, and click **Next**.
1. On page **Connect Virtual Hard Disk**, click **Use an existing virtual disk**, in **Location**, enter **C:\ClusterStorage\Volume01\nanoserver.vhdx**, and click **Next**.
1. Click **Finish**.
1. In the **High Availability Wizard**, on page **Summary**, click **Finish**.
1. In the context menu of the virtual machine **Nanoserver**, click **Start**.

#### Windows Admin Center

Perform these steps on CL1.

1. Open **File Explorer**.
1. Copy **L:\NanoVHDX\Nanoserver.vhdx** to **\\\S2D1\C$\ClusterStorage\Volume01**
1. Switch to **Windows Admin Center**.
1. Connected to **S2D.smart.etc**, click on **Virtual Machines**, **Inventory**
1. Create a new VM.
   * **Name**: NanoServer
   * **Location**: C:\ClusterStorage\Volume01
   * **Generation**: 2
   * **Host**: s2d1.smart.etc
   * **Processor** Count: 2
   * **Memory**: 1 GB
   * **Network**: Datacenter1
   * **Storage**: Use existing disk - C:\ClusterStorage\Volume01\nanoserver.vhdx
1. Refresh the **Virtual Machine Inventory** ([figure 5]).
1. Select the VM **Nanoserver** and start it.

#### PowerShell

Perform these steps on S2D1.

1. Copy **L:\NanoVHDX\Nanoserver.vhdx** to **\\\S2D1\C$\ClusterStorage\Volume01**

   ````powershell
   $vhdx = 'nanoserver.vhdx'
   $path = "L:\NanoVHDX\$vhdx"

   <#
   Get-ClusterSharedVolume returns the cluster shared volume object. Node
   is a property of the cluster sharev volume object. To see all properties of an object
   and whether they can be set or are read only, you can use the Get-Member
   cmdlet, e. g.
   Get-ClusterSharedVolume | Get-Member
   #>

   $clusterSharedVolumeOwnerNode = (Get-ClusterSharedVolume -Cluster $cluster -Name 'Cluster Virtual Disk (Volume01)').OwnerNode
   $clusterSharedFriendlyVolumeName = 'C:\ClusterStorage\Volume01'

   <#
   Strings in double-quotes can contain expressions such as variables.
   Variables can simply be written as $variableName. Expressions are written
   like $(expression).
   The -replace operator replaces a RegEx with a string. The RegEx ^C: matches
   with C: at the beginning of the string.
   #>
   $destination = `
      "\\$clusterSharedVolumeOwnerNode\$(
         $clusterSharedFriendlyVolumeName -replace '^C:', 'C$'
      )"

      Copy-Item -Path $path -Destination $destination
   ````

1. Create a new VM.
   * Name: NanoServer
   * Location: C:\ClusterStorage\Volume01
   * Generation: 2
   * Host: s2d1.smart.etc
   * Processor Count: 2
   * Memory: 1 GB
   * Network: Datacenter1
   * Storage: Use existing disk - C:\ClusterStorage\Volume01\nanoserver.vhdx

   ```powershell
   $vMName = 'NanoServer'
   $vM = New-VM `
      -ComputerName $clusterSharedVolumeOwnerNode `
      -Name $vMName `
      -Generation 2 `
      -Path $clusterSharedFriendlyVolumeName `
      -MemoryStartupBytes 1GB `
      -SwitchName Datacenter1 `
      -VHDPath "$clusterSharedFriendlyVolumeName\$vhdx"
   
   $vM | Set-VM -ProcessorCount 2
   $vM | Add-ClusterVirtualMachineRole -Cluster $cluster
   ````

1. Start Nanoserver.

   ````powershell
   $vM | Start-VM
   ````

1. Take a note of the **OwnerNode** for the virtual machine NanoServer.

   ````powershell
   Get-ClusterResource -Cluster $cluster |
   Select-Object Name, State, ResourceType, OwnerNode
   ````

1. Leave **Windows PowerShell** open for upcoming tasks.

### Task 2: Simulate a workload

Perform these steps on CL1.

1. Open a **Command Prompt**
1. Ping the virtual machine.

   ````shell
   ping -t 10.1.1.25
   ````

### Task 3: Simulate a failure

#### Desktop Experience

Perform these steps on your host computer.

1. In **Hyper-V Manager**, turn off S2D1.

#### PowerShell

Perform these steps on your host computer.

1. Open **Windows PowerShell**.
1. Turn off the owner node, you took note of in a previous task. Make sure, you change ````$vmName````.

   ````powershell
   # TODO: Enter the OwnerNode you took note of in a previous task.
   $vMName = 'S2D1'
   Stop-VM -VMName $vMName -TurnOff
   ````

### Task 4: Validate failover

#### Desktop Experience

Perform these steps on CL1.

1. In Failover Cluster Manager, in node **Roles**, check the **Status** of the virtual machine **Nanoserver**. Wait until it is **Running**.

   > On which node does **Nanoserver** run now? Take a note.

1. Expand **Storage** and click **Pools**.
1. Click **Cluster Pool 1**. In the bottom pane, on the **Summary** tab, notice the **Health Status** and the **Operational Status**.
1. Click the tab **Virtual Disks**. Notice the volumes' **Health Status** and **Operational Status**.
1. Click the tab **Physical Disks**. Notice that three drives are **MIssing**.

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, reconnect to **S2D.smart.etc**.
1. Click on **Virtual Machines**, **Inventory**.

   > On which node does **Nanoserver** run now? Take a note.

1. Click on **Volumes**, **Inventory**. Notice that the volumes need a repair.
1. Click on **Drives**, **Inventory**. Notice the lost communication with drives from S2D1.

#### PowerShell

Perform these steps on CL1.

1. In **Windows PowerShell**, validate the status of the virtual machine and the ping command. You might have to run the command several times to follow the change of state.

   ````powershell
   Get-ClusterResource -Cluster $cluster |
   Select-Object Name, ResourceType, State, OwnerNode
   ````

   > On which node does **Nanoserver** run now? Take a note.

1. List the virtual disks. Notice that the volumes need a repair.

   ````powershell
   # TODO: Enter the OwnerNode you took note of in a previous step.
   $cimSession = New-CimSession -ComputerName 'S2D2'
   Get-VirtualDisk -CimSession $cimSession
   Get-PhysicalDisk -CimSession $cimSession
   ````

1. List physical disks. Notice the lost communication with drives from the former owner node.

   ````powershell
   Get-PhysicalDisk -CimSession $cimSession
   ````

### Task 5: Simulate another failure

#### Desktop Experience

Perform these steps on your host computer.

1. In **Hyper-V Manager**, turn off the VM **Nanoserver** currently runs on (you should have taken a note in the previous task).

#### PowerShell

Perform these steps on your host computer.

1. In **Windows PowerShell**, turn off the owner node, you took note of in a previous task. Make sure, you change ````$vmName````.

   ````powershell
   # TODO: Enter the OwnerNode you took note of in a previous task.
   $vMName = 'S2D2'
   Stop-VM -VMName $vMName -TurnOff
   ````

### Task 6: Validate failover again

#### Desktop Experience

Perform these steps on CL1.

1. In Failover Cluster Manager, in node **Roles**, check the **Status** of the virtual machine **Nanoserver**.

   > Does the VM still run? Why or why not?

1. In the context menu of the virtual machine **Nanoserver**, click **Shut Down**.

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, reconnect to **S2D.smart.etc**. If the connection cannot be established wait a few minutes and try again.
1. Click on **Virtual Machines**, **Inventory**.

   > Does the VM still run? Why or why not?

1. Stop the VM **NanoServer**.

#### PowerShell

Perform these steps on CL1.

1. In **Windows PowerShell**, validate the status of the virtual machine and the ping command. You might have to run the command several times to follow the change of state.

   ````powershell
   Get-ClusterResource -Cluster $cluster |
   Select-Object Name, ResourceType, State, OwnerNode
   ````

   > Does the VM still run? Why or why not?

1. Stop the VM **Nanoserver**.

   ````powershell
   Stop-VM -ComputerName 'S2D' -VMName $vMName
   ````

[figure 1]: images/Lab10/figure01.png
[figure 2]: images/Lab10/figure02.png
[figure 3]: images/Lab10/figure03.png
[figure 4]: images/Lab10/figure04.png
[figure 5]: images/Lab10/figure05.png
