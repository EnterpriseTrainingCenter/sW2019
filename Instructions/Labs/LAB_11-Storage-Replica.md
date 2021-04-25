# Lab 11: Storage Replica

## Required VMs

* DC1
* DHCP
* Router
* SR1
* SR2
* SRV2
* CL1

## Exercises

1. [Testing Storage Replica storage](#exercise-1-testing-storage-replica-storage)
1. [Create a stretched Hyper-V cluster](#exercise-2-create-a-stretched-hyper-v-cluster)
1. [Test stretched Hyper-V cluster failover](#exercise-3-test-stretched-hyper-v-cluster-failover)

## Exercise 1: Testing Storage Replica storage

### Introduction

In this exercise, you will test the underlying storage.

### Tasks

1. [Configure storage](#task-1-configure-storage)
1. [Install Storage Replica feature](#task-2-install-storage-replica-feature)
1. [Run the Storage Replica test](#task-3-run-the-storage-replica-test)
1. [Evaluate the Storage Replica test](#task-4-evaluate-the-storage-replica-test)

### Detailed Instructions

#### Task 1: Configure storage

Perform these steps on CL1.

1. Logon as **smart\administrator**
1. Open **Server Manager**.
1. Click **Manage**, **Add servers**.
1. Add **sr1** and **sr2**.
1. Click **File and Storage Services**.
1. Click **Disks**.
1. In **Disks**, under **SR1**, in the context menu of disk 1, click **Bring online** and confirm the warning message.
1. Repeat the previous step for disk 2.
1. From the context menu of disk 1 on **SR1**, select **Initialize** and confirm the warning message.
1. Repeat the previous step for disk 2.
1. On the disks of **SR1**, create ReFS formatted volumes using the maximum size. Refer to the table below to assign drive letters and labels ([figure 2] and [figure 3]).

   | Disk size | Drive letter | Label |
   |-----------|--------------|-------|
   | 36 GB     | D            | Data  |
   | 10 GB     | E            | Log   |

1. For server **SR2.smart.etc**, initialize the disks **Disk 1** and **Disk 2** as GPT disks. On the disks, create volumes like in the previous step.

#### Task 2: Install Storage Replica feature

Perform these steps on CL1.

1. In **Server Manager**, click Manage, **Add Role and Features**.
1. On page **Select destination server**, select **SR1.smart.etc**.
1. On page **Select features**, activate
   * **Failover Clustering**
   * **Storage Replica**
   * **Remote Server Administration Tools**, **Role Administration Tools**, **AD DS**, **AD LDS Tools**, **Active Directory module for Windows PowerShell**
1. Click on the **+ Install** button.
1. Activate the checkbox **Reboot the destination server automatically if required**
1. Install the same features on **SR2.smart.etc**.

#### Task 3: Run the Storage Replica test

Perform these steps on SR1.

1. Logon as **smart\administrator**.
1. Start Windows PowerShell.

   ````shell
   powershell
   ````

1. Create a new directory **C:\Temp**.

   ````powershell
   # Defining a variable 
   # helps reusing the same value in several commands consistently
   $resultPath = 'C:\Temp'
   md $resultPath
   ````

1. Evaluate Storage Replica. Wait for the command to complete.

   ````powershell
   # The back tick ` allows to split long commands into multiple lines

   Test-SRTopology `
       -SourceComputerName SR1 `
       -SourceVolumeName D: `
       -SourceLogVolumeName E: `
       -DestinationComputerName SR2 `
       -DestinationVolumeName D: `
       -DestinationLogVolumeName E: `
       -DurationInMinutes 2 `
       -ResultPath $resultPath
   ````

#### Task 4: Evaluate the Storage Replica test

Perform these steps on CL1.

1. From **\\\SR1\C$\Temp** open the report in a browser.

   > According to the report, will Storage Replica work in this environment?

   > Compare the results of the report with other students in the class.

## Exercise 2: Create a stretched Hyper-V cluster

### Introduction

In this exercise, you will create a stretched Hyper-V cluster and configure storage replica.

### Tasks

1. [Create a failover cluster](#task-1-create-a-failover-cluster)
1. [Configure storage replica](#task-2-configure-storage-replica)

### Detailed Instructions

#### Task 1: Create a failover cluster

Perform these steps on CL1.

1. On SR1 logon as **smart\administrator**
1. Start Windows PowerShell

   ````shell
   powershell
   ````

1. Install a new Failover Cluster. Ignore any warnings.

   ````powershell
   $cluster = 'SR'
   # Variables can store comma-separated lists of values, i. e. arrays
   $node = 'SR1', 'SR2'

   <#
   You can access the first element of an array by addressing it with 0 in
   brackets.
   #>
   $cluster = New-Cluster `
      -Name $clusterName `
      -Node $node[0] `
      -StaticAddress 10.1.1.83 `
      -NoStorage `
      -AdministrativeAccessPoint ActiveDirectoryAndDns
   ````

1. Add SR2 as the second node of the cluster.

   ````powershell
   # The second element in an array has the index number 1
   $cluster | Add-ClusterNode -Name $node[1] -NoStorage
   ````

1. Configure the cluster quorum settings to use a file share witness using \\dhcp\SR-fsw.

   ````powershell
   Set-ClusterQuorum -Cluster $cluster -FileShareWitness '\\Dhcp\SR-fsw'
   ````

1. Configure stretched cluster site awareness using PowerShell. Create two sites: primary and secondary.

   ````powershell
   # Using CIM sessions, you can run commands using the CIM interface remotely
   $cimSession = New-CimSession -ComputerName $node

   New-ClusterFaultDomain -CimSession $cimSession[0] -Name Primary -Type Site
   New-ClusterFaultDomain -CimSession $cimSession[0] -Name Secondary -Type Site
   ````

1. Add the nodes to their sites.

   ````powershell
   Set-ClusterFaultDomain `
      -CimSession $cimSession[0] `
      -Name $node[0] `
      -Parent Primary
   Set-ClusterFaultDomain `
      -CimSession $cimSession[0] `
      -Name $node[1] `
      -Parent Secondary
   ````

1. Set the preferred site to the first domain.

   ````powershell
   <#
   Get-Cluster returns the cluster object. PreferredSite is a property
   of the cluster object, that can be set. To see all properties of an object
   and whether they can be set or are read only, you can use the Get-Member
   cmdlet, e. g.
   $cluster | Get-Member

   Because Get-Cluster must be executed before you can access the properties of
   the returned object, you have to put it into braces.
   #>
   $cluster.PreferredSite = 'Primary'
   ````

1. Set the cluster resiliency period to 10 seconds.

   ````powershell
   $cluster.ResiliencyDefaultPeriod=10
   ````

1. Add all Disks to the cluster.

   ````powershell
   Get-ClusterAvailableDisk -Cluster $cluster -All | Add-ClusterDisk
   ````

1. Configure Kerberos Constrained Delegation to allow SSO from Windows Admin Center.

   ````powershell
   $gw = Get-ADComputer -Identity "srv2"
   Set-ADComputer $clusterName -PrincipalsAllowedToDelegateToAccount $gw 
   ````

#### Task 2: Configure storage replica

Perform these steps on CL1.

1. In the start menu, from **Administrative Tools**, start **Failover Cluster Manager**.
1. In **Failover Cluster Manager**, connect to cluster **SR.smart.etc**.
1. Navigate to **Storage**, **Disks**.
1. From the context menu of the 36GB data disk that is online, select **Add to Cluster Shared Volumes** ([figure 4]).
1. From the context menu of the disk you added to cluster shared volumes, select **Replication**, **Enable…** ([figure 5]).
1. In the wizard, select the disks as they appear and use the following options for the remaining pages. After the wizard completes, your storage should look similar to [figure 6].
   * **Overwrite destination volumes**
   * **Synchronous replication**
   * **Highest Performance**
1. Select the source disk.
1. At the bottom, activate the tab **Replication**. You should see the initial block copy state ([figure 7]).
1. Take a note of the volume number and the owner node of the source disk ([figure 8]).

## Exercise 3: Test stretched Hyper-V cluster failover

### Introduction

In this exercise, you create a new virtual machine within the Hyper-V stretched cluster. After replication has finished, you shut down one node to simulate a hardware failure. Finally, you test replication failover.

### Tasks

1. [Create a Nanoserver VM](#task-1-create-a-nanoserver-vm)
1. [Simulate a workload](#task-2-simulate-a-workload)
1. [Simulate a failure](#task-3-simulate-a-failure)
1. [Validate failover](#task-4-validate-failover)
1. [Simulate recovery](#task-5-simulate-recovery)
1. [Validate recovers](#task-6-validate-recovery)
1. [Reverse replication](task-7-reverse-replication)
1. [Simulate a replication failure](#task-8-simulate-a-replication-failure)

### Detailed Instructions

#### Task 1: Create a Nanoserver VM

Perform these steps on CL1.

1. Open **File Explorer**.
1. Copy **L:\NanoVHDX\Nanoserver.vhdx** to **\\SR1\C$\ClusterStorage\VolumeX** (where X is the number of the volume you took note in the previous exercise).
1. Switch to **Failover Cluster Manager**.
1. In **Failover Cluster Manager**, in the context menu of **Roles**, click **Virtual Machines...**, **New Virtual Machine...**
1. In **New Virtual Machine**, select the owner node of the disk you took note of in the previous exercise.
1. Create a new VM.
   * **Name:** Nanoserver
   * **Location:** C:\ClusterStorage\VolumeX (where X is the number of the volume you took note in the previous exercise)
   * **Generation:** **2**
   * **Startup memory:** 1024 MB
   * **Connection: Datacenter1**
   * **Use an existing virtual hard disk**: C:\ClusterStorage\VolumeX\nanoserver.vhdx
1. From the context menu of the virtual machine **Nanoserver**, click **Settings...**.
1. Increase the number of virtual processors to 2.
1. From the conect menu of the virtual machine **Nanoserver**, click **Start**.

#### Task 2: Simulate a workload

Perform these steps on CL1.

1. Open **Command Prompt**.
1. Ping the virtual server.

   ````shell
   ping -t 10.1.1.25
   ````

1. In **Failover Cluster Manager**, click on **Roles**
1. Take note of the node currently owning the VM.

#### Task 3: Simulate a failure

Perform these steps on the host computer.

1. In **Hyper-V Manager**, turn off the virtual machine you took note of in the previous task.

#### Task 4: Validate failover

Perform these steps on CL1.

1. In **Failover Cluster Manager**, click to **Roles**.
1. Click **Refresh**.

   > Is the VM running? On which node?

   > Is the ping command to the virtual machine successful?

1. Under **Storage**, click **Disks**.
1. Click the 36 GB disk, that is still online.
1. At the bottom pane, click on **Replication** and check the status.

#### Task 5: Simulate recovery

Perform these steps on the host computer.

1. In **Hyper-V Manager**, start the failed node.

#### Task 6: Validate recovery

Perform these steps on CL1.

1. In **Failover Cluster Manager**, check the health-state of the cluster, the disks, the availability of the cluster shared volumes and of storage replication. After a few minutes everything should be back to normal operations…

#### Task 7: Reverse replication

Perform these steps on CL1.

1. In **Failover Cluster Manager**, click on **Roles**.
1. Click on **Virtual Machines**, **Inventory**
1. On the context menu of the VM **Nanoserver**, click **Move**, **Live Migration**, **Select Node...**
1. Click **Disks**.
1. On the context menu of the 36 GB disk assigned to **Cluster Shared Volume**, click **Move**, **Select Node...**
1. Select the node you moved the VM to. Replication should be in the same state as before we turned off a node.

#### Task 8: Simulate a replication failure

Perform these steps on SR2.

1. Logon as **smart\administrator**
1. Start Windows PowerShell.

   ````shell
   powershell
   ````

1. Mount the Destination Disk with the following command:

   ````powershell
   $computerName = 'SR2'
   $name = 'Replication 2'
   Mount-SRDestination `
       -ComputerName $computername `
       -Name $name `
       -TemporaryPath T:\ `
       -Force

1. List the contents of the mounted volume. It should be completely identical to the source volume on SR1.

    ````powershell
    Get-ChildItem D:\
    Get-ChildItem C:\ClusterStorage\Volume1
    ````

1. Launch Notepad.

   ````powershell
   notepad
   ````

1. In **Notepad**, type some text
1. Save the file to **D:\\**.
1. Close **Notepad**.
1. List the contents of the mounted volume again.

    ````powershell
    Get-ChildItem D:\
    Get-ChildItem C:\ClusterStorage\Volume1
    ````

   > Are there any differences? Why?

1. Dismount the destination drive. All changes will be discarded.

   ````powershell
   Dismount-SRDestination -ComputerName $computerName -Name $name -Force
   ````

[figure 1]: images/Lab11/figure01.png
[figure 2]: images/Lab11/figure02.png
[figure 3]: images/Lab11/figure03.png
[figure 4]: images/Lab11/figure04.png
[figure 5]: images/Lab11/figure05.png
[figure 6]: images/Lab11/figure06.png
[figure 7]: images/Lab11/figure07.png
[figure 8]: images/Lab11/figure08.png
[figure 9]: images/Lab11/figure09.png
[figure 10]: images/Lab11/figure10.png
[figure 11]: images/Lab11/figure11.png
[figure 12]: images/Lab11/figure12.png
[figure 13]: images/Lab11/figure13.png