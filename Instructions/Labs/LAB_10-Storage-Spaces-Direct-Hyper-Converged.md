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

1. [Storage Spaces Direct configuration](#exercise-1-storage-spaces-direct-configuration)
2. [Test Hyper-Converged Cluster failover](#exercise-2-test-hyper-converged-cluster-failover)

## Exercise 1: Storage Spaces Direct configuration

### Introduction

In this exercise, you will create the Hyper-Converged Cluster with two Cluster Shared Volumes using Storage Spaces Direct.

### Tasks

1. [Enable Storage Spaces Direct](#task-1-enable-storage-spaces-direct)
1. [Administering S2D with Windows Admin Center](#task-2-administering-s2d-with-windows-admin-center)
1. [Create storage pools and virtual disks](#task-3-create-storage-pools-and-virtual-disks)

### Detailed Instructions

#### Task 1: Enable Storage Spaces Direct

Peform these steps on S2D1.

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
   Enable-ClusterS2D -CacheState Disabled -SkipEligibilityChecks
   ````

1. List the storage pools in the cluster.

   ````powershell
   Get-StoragePool
   ````

   S2D automatically created a Storage Pool with all eligible disks ([figure 1]).

1. Set the cluster resiliency period to 10 seconds.

   ````powershell
   <#
   Get-Cluster returns the cluster object. ResiliencyDefaultPeriod is a property
   of the cluster object, that can be set. To see all properties of an object
   and whether they can be set or are read only, you can use the Get-Member
   cmdlet, e. g.
   Get-Cluster | Get-Member

   Because Get-Cluster must be executed before you can access the properties of
   the returned object, you have to put it into braces.
   #>
   (Get-Cluster).ResiliencyDefaultPeriod = 10 
   ````

#### Task 2: Administering S2D with Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\administrator**.
1. Open **Google Chrome** and navigate to <https://admincenter.smart.etc>.
1. Add a hyper-converged cluster connection to **s2d**. Add all nodes in the cluster ([figure 2]).
1. Connect to **S2D.smart.etc**. Make yourself familiar with the dashboard
1. Click on **Servers**, **Inventory**. Discover the different options available for S2D server management.
1. Leave **Windows Admin Center** open for the next task.

#### Task 3: Create storage pools and virtual disks

Peform these steps on CL2.

1. Click on **Drives**, **Inventory**. You should see 12 drives from 4 Servers
1. Click on **Volumes**, **Inventory**. Notice the **ClusterPerformanceHistory** volume.
1. Create a new three-way mirrored Volume **Volume01** with a Size of **40 GB**. Notice that you could also enable deduplication and compression for ReFS volumes ([figure 3]).
1. Create a second volume.
   * **Name**: Volume02
   * **Resiliency**: **Mirror-accelerated parity**
   * **Size on HDD**: 85 GB
1. Click on **Volume01**. Notice that new volumes are automatically added to cluster shared volumes and formatted using ReFS ([figure 4]).

## Exercise 2: Test Hyper-Converged Cluster failover

### Introduction

In this exercise, you will create a new virtual machine within the Hyper-converged cluster. After the replication has finished two nodes will be shutdown to simulate a hardware failure.

### Tasks

1. [Create a Nanoserver VM](#task-1-create-a-nanoserver-vm)
1. [Simulate a workload](#task-2-simulate-a-workload)
1. [Simulate a failure](#task-3-simulate-a-failure)
1. [Validate failover](#task-4-validate-failover)
1. [Simulate another failure](#task-5-simulate-another-failure)
1. [Validate failover again](#task-6-validate-failover-again)

### Detailed Instructions

#### Task 1: Create a Nanoserver VM

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

#### Task 2: Simulate a workload

Perform these steps on CL1.

1. Open a **Command Prompt**
1. Ping the virtual machine.

   ````shell
   ping -t 10.1.1.25
   ````

#### Task 3: Simulate a failure

Perform these steps on your host computer.

1. In **Hyper-V Manager**, turn off S2D1.

#### Task 4: Validate failover

Perform these steps on CL1.

1. In **Windows Admin Center**, reconnect to **S2D.smart.etc**.
1. Click on **Virtual Machines**, **Inventory**.

   > On which node does **Nanoserver** run now? Take a note.

1. Click on **Volumes**, **Inventory**. Notice that the volumes need a repair.
1. Click on **Drives**, **Inventory**. Notice the lost communication with drives from S2D1.

#### Task 5: Simulate another failure

Perform these steps on your host computer.

1. In **Hyper-V Manager**, turn off the VM **Nanoserver** currently runs on (you should have taken a note in the previous task).

#### Task 6: Validate failover again

Perform these steps on CL1.

1. In **Windows Admin Center**, reconnect to **S2D.smart.etc**. If the connection cannot be established wait a few minutes and try again.
1. Click on **Virtual Machines**, **Inventory**.

   > Does the VM still run? Why or why not?

1. Stop the VM **NanoServer**.

[figure 1]: images/Lab10/figure01.png
[figure 2]: images/Lab10/figure02.png
[figure 3]: images/Lab10/figure03.png
[figure 4]: images/Lab10/figure04.png
[figure 5]: images/Lab10/figure05.png