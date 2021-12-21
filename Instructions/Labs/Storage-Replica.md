# Lab: Storage Replica

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

In this exercise, on SR1 and SR2, you will bring disks 1 and 2 online and format the 36 GB disk with the drive letter D and and the label Data, and the 10 GB disk with drive letter E and label Log. Then, on SR1 and SR2, you will install the storage replica feature. Finally, you will run and evaluate the storage replica test.

#### Tasks

1. [Configure storage](#task-1-configure-storage)
1. [Install Storage Replica feature](#task-2-install-storage-replica-feature)
1. [Run the Storage Replica test](#task-3-run-the-storage-replica-test)
1. [Evaluate the Storage Replica test](#task-4-evaluate-the-storage-replica-test)

### Task 1: Configure storage

#### Desktop Experience

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

#### Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\administrator**
1. Open **Google Chrome**, and navigate to <https://admincenter.smart.etc> to open the Windows Admin Center Management Portal.
1. Connect to **sr1.smart.etc**.
1. Navigate to **Storage**.
1. Select **Disk 1** and click **Initialize disk** ([figure 1]). Initialize it as GPT Disk.
1. Repeat the previous step for **Disk 2**.
1. Create ReFS formatted volumes using the maximum size. Refer to the table below to assign drive letters and labels ([figure 2] and [figure 3]).

   | Disk size | Drive letter | Label |
   |-----------|--------------|-------|
   | 36 GB     | D            | Data  |
   | 10 GB     | E            | Log   |

1. For server **SR2.smart.etc**, initialize the disks **Disk 1** and **Disk 2** as GPT disks. On the disks, create volume like in the previous step.

#### PowerShell

Perform these steps on CL1.

1. Logon as **smart\administrator**
1. Open **Windows PowerShell**.
1. Define a variable $node to run commands on both nodes.

   ````powershell
   # Variables can store comma-separated lists of values, i. e. arrays
   $node = 'SR1', 'SR2'
   ````

1. Create CIM sessions to both nodes, to run commands remotely.

   ````powershell
   $cimSession = New-CimSession -ComputerName $node
   ````

1. On SR1 and SR2, initialize disks as GPT disks.

   ````powershell
   # Parameters supporting arrays accept comma-separated lists
   # In this case Initialize-Disk accepts <uint32[]> for the parameter -Number
   # See Get-Help Initialize-Disk for more information.
   Initialize-Disk -CimSession $cimSession -Number 1, 2 
   ````

1. Create ReFS formatted volumes using the maximum size. Refer to the table below to assign drive letters and labels ([figure 2] and [figure 3]).

   | Number | Disk size | Drive letter | Label |
   |--------|-----------|--------------|-------|
   | 1      | 36 GB     | D            | Data  |
   | 2      | 10 GB     | E            | Log   |

   ````powershell
   <#
   New-Volume does not support multiple CimSessions. Therefore, $cimSession
   must be iterated using ForEach-Object. On each iteration, $PSItem contains
   one single CimSession object.
   #>
   $cimSession | ForEach-Object {
      New-Volume `
         -CimSession $PSItem `
         -DiskNumber 1 `
         -FriendlyName 'Data' `
         -FileSystem ReFS `
         -DriveLetter D
      New-Volume `
         -CimSession $PSItem `
         -DiskNumber 2 `
         -FriendlyName 'Log' `
         -FileSystem ReFS `
         -DriveLetter E
   }
   ````

1. Leave Windows PowerShell open for the next task.

### Task 2: Install Storage Replica feature

You can skip this task when using Windows Admin Center in the next exercise. The necessary features are installed when using them.

#### Desktop Experience

Perform these steps on CL1.

1. In **Server Manager**, click Manage, **Add Role and Features**.
1. On page **Select destination server**, select **SR1.smart.etc**.
1. On page **Select features**, activate
   * **Failover Clustering**
   * **Storage Replica**
1. Click on the **+ Install** button.
1. Activate the checkbox **Reboot the destination server automatically if required**
1. Install the same features on **SR2.smart.etc**.

#### PowerShell

Perform these steps on CL1.

1. Using **Windows PowerShell**, install necessary features on SR1 and SR2.
   * **Failover Clustering**
   * **Storage Replica**
   * **Active Directory module for Windows PowerShell**

   ````powershell
   # Install-WindowsFeature only supports single ComputerName
   # Therefore, $node must be interated
   $node | ForEach-Object {
      Install-WindowsFeature `
         -ComputerName $PSItem `
         -Name Failover-Clustering, Storage-Replica `
         -IncludeManagementTools `
         -Restart
   }
   ````

1. Leave Windows PowerShell open for upcoming tasks.

### Task 3: Run the Storage Replica test

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

### Task 4: Evaluate the Storage Replica test

Perform these steps on CL1.

1. From **\\\SR1\C$\Temp** open the report in a browser.

   > According to the report, will Storage Replica work in this environment?

   > Compare the results of the report with other students in the class.

## Exercise 2: Create a stretched Hyper-V cluster

### Introduction

In this exercise, you will first create a cluster with SR1 and SR2 as nodes with the NoStorage option. Then, you will create fault separate domains for the two nodes, set the preferred site to the first node, set the cluster resilience period to 10 seconds, and all eligible disks to the cluster. Finally, you will replicate the Data disk from SR1 to SR2 with the help of the Log disk.

#### Tasks

1. [Create a failover cluster](#task-1-create-a-failover-cluster)
1. [Configure storage replica](#task-2-configure-storage-replica)

### Task 1: Create a failover cluster

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, click on the gear icon to open settings.
1. In **Settings**, click **Extensions**.
1. When updates are available, install the updates for all extensions.
1. On the top-left, click **Windows Admin Center** to return to All connections.
1. In **All connections**, click **Add**.
1. In panel **Add or create resources**, under **Server clusters**, click **Create new**. Select the correct options and click **Create**.
   * **Choose the cluster type**: **Windows server**
   * **Select the workload type**: **Cluster-aware roles and apps**
   * **Select server locations**: **All servers in one site**
1. On **Check prerequisites**, click **Next**.
1. On **Add servers**, enter the credentials of **smart\Administrator**, then enter **sr1** and click **Add**.
1. Enter **sr2** and click **Add**, then click **Next**.
1. On **Join a domain**, click **Next**.
1. On **Install features**, click **Install features**, then click **Next**.
1. On **Install updates**, ignore any errors and click **Next**.
1. On **Restart servers**, click **Restart servers**, if required. Then, click **Next: Clustering**.
1. On **Validate the cluster**, click **Validate**.
1. In the message box **Credential Service Provider (CredSSP)**, click **Yes**.
1. Review the validation results and click **Next**.
1. On **Create the cluster**, enter the cluster parameters and click **Create cluster**.
   * **Cluster name**: SR
   * **IP address**: 10.1.1.83
1. After the cluster was created, click **Finish**.
1. Click **Go to the connections list**.
1. Open **Windows PowerShell**.
1. Configure the cluster quorum settings to use a file share witness using \\dhcp\SR-fsw.

   ````powershell
   $node = 'sr1', 'sr2'
   $clusterName = 'sr'
   $cluster = Get-Cluster -Name sr
   Set-ClusterQuorum -Cluster $cluster -FileShareWitness '\\Dhcp\SR-fsw'
   ````

1. Configure stretched cluster site awareness using PowerShell. Create two sites: primary and secondary.

   ````powershell
   <#
   CIM sessions are a way to run commands using the CIM interface on remote
   computers 
   #>
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

#### PowerShell

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

### Task 2: Configure storage replica

#### Desktop Experience

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

#### PowerShell

Perform these steps on SR1.

1. In **Windows PowerShell**, add the 36 GB data disk that is online as cluster shared volume.

   ````powershell
   # Get the data disk
   $dataDisk = Get-Disk -CimSession $cimSession[0] | Where-Object { 
      $PSItem.OperationalStatus -eq 'Online' -and $PSItem.Size -eq 36GB 
   }

   # Get the online cluster disks
   $clusterResource = $cluster | Get-ClusterResource | Where-Object {
       $PSItem.ResourceType -eq 'Physical Disk' `
       -and $PSItem.State -eq 'Online'
   }

   # Get the cluster parameter object containing the disk guid of the data disk
   $clusterParameter = $clusterResource | 
      Get-ClusterParameter DiskIdGUid | 
      Where-Object { $PSItem.Value -eq $dataDisk.Guid }

   # Add the cluster resource disk as cluster shared volume
   # The property ClusterObject references the clusterResource of the parameter
   $clusterSharedVolume = $clusterParameter.ClusterObject | 
      Add-ClusterSharedVolume
   
   ````

1. Enable replication.

   ````powershell
   # Make sure, SR1 owns the CSV
   $clusterSharedVolume | Move-ClusterSharedVolume -Node SR1

   # D: is now mounted to C:\ClusterStorage\Volumex
   # This command gets the exact path
   $sourceVolumeName = $ClusterSharedVolume.SharedVolumeInfo.FriendlyVolumeName
   New-SRPartnership `
      -SourceComputerName $node[0] `
      -SourceRGName 'Replication 1' `
      -SourceVolumeName $sourceVolumeName `
      -SourceLogVolumeName E: `
      -DestinationComputerName $node[1] $no `
      -DestinationRGName 'Replication 2' `
      -DestinationVolumeName D: `
      -DestinationLogVolumeName E: `
      -ReplicationMode 'Synchronous' `
      -Force

   ````

1. Get the initial block copy state. Take a note of the DataVolume property of the first replica ([figure 14]). Repeat the command until **ReplicationStatus** changes to **ContinouslyReplicating**.

   ````powershell
   (Get-SRGroup -ComputerName $node[0]).Replicas
   Get-SRPartnership -ComputerName $node[0]
   ````

1. Take a note of the DataVolume property.

   ````powershell
   $dataVolume = (
      Get-SRGroup -ComputerName $node[0] -Name 'Replication 1'
   ).Replicas.DataVolume

1. Take a note of the owner node of the source disk.

   ````powershell
   $ownerNode = $clusterSharedVolume.OwnerNode
   ````

## Exercise 3: Test stretched Hyper-V cluster failover

### Introduction

In this exercise, you create a new virtual machine within the Hyper-V stretched cluster using the nano server image from L:\NanoVHDX. After replication has finished, you will simulate a work load and shut down one node to simulate a hardware failure. Then, you will validate the failover, reverse the replication and test the recovery. As a last step, you will simulate a replication failure and test, how to revover from it.

#### Tasks

1. [Create a Nanoserver VM](#task-1-create-a-nanoserver-vm)
1. [Simulate a workload](#task-2-simulate-a-workload)
1. [Simulate a failure](#task-3-simulate-a-failure)
1. [Validate failover](#task-4-validate-failover)
1. [Simulate recovery](#task-5-simulate-recovery)
1. [Validate recovers](#task-6-validate-recovery)
1. [Reverse replication](task-7-reverse-replication)
1. [Simulate a replication failure](#task-8-simulate-a-replication-failure)

### Task 1: Create a Nanoserver VM

#### Desktop Experience

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

#### Windows Admin Center

Perform these steps on CL1.

1. Open **File Explorer**.
1. Copy **L:\NanoVHDX\Nanoserver.vhdx** to **\\\\SR1\C$\ClusterStorage\VolumeX** (where SR1 is the owner node, and X is the number of the volume you took note in the previous exercise).
1. In **Windows Admin Center**, connected to **SR.smart.etc**, click on **Virtual Machines**.
1. Click on **Add**, **new**, to create a new VM.
   * **Name**: Nanoserver
   * **Generation**: **Generation 2 (Recommended)**
   * **Host**: Owner node of the disk you took note of in the previous exercise
   * **Path**: **C:\ClusterStorage\Volume***x* (where *x* is the number of the volume you took note in the previous exercise)
   * **Virtual Processors**
      * **Count**: 2
   * **Memory**
      * **Startup memory**: 2 **GB**
   * **Network**
      * **Virtual switch**: **Datacenter1**
   * **Storage**: Click **Add**.
      * **New disk 1**
         * **Use an existing virtual hard disk**
            * **Path:** C:\ClusterStorage\Volume*x*\nanoserver.vhdx
1. Click the VM **Nanoserver**, and click **Power**, **Start**.

#### PowerShell

Perform these steps on CL1.

1. Copy **L:\NanoVHDX\Nanoserver.vhdx** to **\\SR1\C$\ClusterStorage\VolumeX** (where X is the number of the volume you took note in the previous exercise).

   ````powershell
   $vhdx = 'nanoserver.vhdx'
   $path = "L:\NanoVHDX\$Vhdx"

   <#
   Strings in double-quotes can contain expressions such as variables.
   Variables can simply be written as $variableName. Expressions are written
   like $(expression).
   The -replace operator replaces a RegEx with a string. The RegEx ^C: matches
   with C: at the beginning of the string.
   #>
   $destination = `
      "\\$ownerNode\$(
         $dataVolume -replace '^C:', 'C$'
      )"

   Copy-Item -Path $Path -Destination $Destination
   ````

1. Create a new VM.
   * **Name**: Nanoserver
   * **Generation**: **2**
   * **Host**: Owner node of the disk you took note of in the previous exercise
   * **Path**: C:\ClusterStorage\VolumeX (where X is the number of the volume you took note in the previous exercise)
   * **Processor Count**: 2
   * **Memory**: 1 GB
   * **Network**: **Datacenter1**
   * **Storage**: **Use existing disk** C:\ClusterStorage\VolumeX\nanoserver.vhdx

   ````powershell
   $vMName = 'NanoServer'
   $vHDPath = "$dataVolume\$vhdx"
   $vM = New-VM `
      -ComputerName $ownerNode.Name `
      -Name $vMName `
      -Generation 2 `
      -Path $dataVolume `
      -MemoryStartupBytes 1GB `
      -SwitchName 'Datacenter1' `
      -VHDPath $vHDPath
   Set-VM -VM $vM -ProcessorCount 2
   $vM | Add-ClusterVirtualMachineRole -Cluster $cluster
   ````

1. Start the VM **Nanoserver**.

   ````powershell
   Start-VM -VM $vM

1. Leave Windows PowerShell open for the next task.

### Task 2: Simulate a workload

#### Desktop Experience

Perform these steps on CL1.

1. Open **Command Prompt**.
1. Ping the virtual server.

   ````shell
   ping -t 10.1.1.25
   ````

1. In **Failover Cluster Manager**, click on **Roles**
1. Take note of the node currently owning the VM.

#### Windows Admin Center

Perform these steps on CL1.

1. Open **Command Prompt**.
1. Ping the virtual server.

   ````shell
   ping -t 10.1.1.25
   ````

1. In Windows Admin Center, connected to SR1.smart.etc click on **Virtual Machines, Inventory**
1. Take note of the node currently owning the VM.
1. Leave **Windows Admin Center** open for an upcoming task.

#### PowerShell

Perform these steps on CL1.

1. Open **Command Prompt**.
1. Ping the virtual server.

   ````shell
   ping -t 10.1.1.25
   ````

1. In Windows PowerShell, take a note of the node currently owining the VM.

   ````powershell
   Get-ClusterResource -Cluster $cluster |
   Select-Object Name, ResourceType, State, OwnerNode
   ````

1. Leave Command Prompt and Windows PowerShell open for the next task.

### Task 3: Simulate a failure

#### Desktop Experience

Perform these steps on the host computer.

1. In **Hyper-V Manager**, turn off the virtual machine you took note of in the previous task.

#### PowerShell

Perform these steps on the host computer.

1. Run **Windows PowerShell** as Administrator.
1. Stop the VM representing the node currently running Nanoserver.

   ````powershell
   # TODO: Enter the name of the node you took note of in the previous task
   $vMName = 'SR1'
   Stop-VM -VMName $vMName -TurnOff
   ````

### Task 4: Validate failover

#### Desktop Experience

Perform these steps on CL1.

1. In **Failover Cluster Manager**, click to **Roles**.
1. Click **Refresh**.

   > Is the VM running? On which node?

   > Is the ping command to the virtual machine successful?

1. Under **Storage**, click **Disks**.
1. Click the 36 GB disk, that is still online.
1. At the bottom pane, click on **Replication** and check the status.

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, refresh the page.

   > Is the VM running? On which node?

   > Is the ping command to the virtual machine successful?

1. Click on **Storage Replica** and check the status ([figure 10]).

#### PowerShell

Perform these steps on CL1.

1. In **Windows PowerShell**, validate the status of the virtual machine and the ping command. You might have to run the command several times to follow the change of state.

   ````powershell
   Get-ClusterResource -Cluster $cluster |
   Select-Object Name, ResourceType, State, OwnerNode
   ````

   > Is the VM running? On which node?

   > Is the ping command to the virtual machine successful?

1. Check the status of storage replica on the node that is still running ([figure 15]).

   ````powershell
   # TODO: Enter the name of the node still running
   $computerName = 'SR2'
   (Get-SRGroup -ComputerName $computerName).Replicas
   Get-SRPartnership -ComputerName $computerName
   ````

### Task 5: Simulate recovery

#### Desktop Experience

Perform these steps on the host computer.

1. In **Hyper-V Manager**, start the failed node.

#### PowerShell

erform these steps on the host computer.

1. In **Windows PowerShell**, start the failed node.

   ````powershell
   Start-VM -VMName $vMName
   ````

### Task 6: Validate recovery

#### Desktop Experience

Perform these steps on CL1.

1. In **Failover Cluster Manager**, check the health-state of the cluster, the disks, the availability of the cluster shared volumes and of storage replication. After a few minutes everything should be back to normal operations…

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, check the health-state of the cluster, the disks, the availability of the cluster shared volumes and of storage replication. After a few minutes everything should be back to normal operations…

#### PowerShell

Perform these steps on CL1.

1. In **Windows PowerShell**, check the health-state of the cluster, the disks, the availability of the cluster shared volumes and of storage replication. After a few minutes everything should be back to normal operations.

   ````powershell
   Get-ClusterNode -Cluster $cluster
   Get-ClusterResource -Cluster $cluster
   Get-ClusterSharedVolume -Cluster $cluster
   (Get-SRGroup -ComputerName $computerName).Replicas
   Get-SRPartnership -ComputerName $computerName
   ````

1. Leave Windows PowerShell open for the next task.

### Task 7: Reverse replication

#### Desktop Experience

Perform these steps on CL1.

1. In **Failover Cluster Manager**, click on **Roles**.
1. Click on **Virtual Machines**, **Inventory**
1. On the context menu of the VM **Nanoserver**, click **Move**, **Live Migration**, **Select Node...**
1. Click **Disks**.
1. On the context menu of the 36 GB disk assigned to **Cluster Shared Volume**, click **Move**, **Select Node...**
1. Select the node you moved the VM to. Replication should be in the same state as before we turned off a node.

#### Windows Admin Center

Perform these steps on CL1.

1. Click on **Virtual Machines**, **Inventory**
1. Select the VM **NanoServer**.
1. On the toolbar, click on **Manage**, **Move** ([figure 11]).
1. In blade **Move a virtual machine**, enter the parameters ([figure 16]) and click **Move**.
   * Select **VM and storage**
   * **Destination**
      * **Destination type**: **Failover Cluster**
      * **Member server**: **sr1.smart.etc (Recommended)**
      * **Path for the VM's files**: C:\ClusterStorage\Volume*x*
   * **Virtual switches**
      * **Datacenter1**: **Datacenter 1**
1. In the message box **Credential Security Service Provider (CredSSP)**, click **Yes**.
1. Click to **Storage Replica**.
1. Select the replication partnership.
1. On the toolbar, click on **Switch Direction** ([figure 12]). Wait for the switch to complete. The column **Destination node** should show **SR2**, and the column **Destination group name** should show Replication 2 ([figure 13]). Replication should be in the same state as before we turned off a node.

#### PowerShell

Perform these steps on CL1.

1. Move the VM **Nanoserver** back to its original node. Wait for the VM to move back.

   ````powershell
   Move-ClusterVirtualMachineRole `
      -Cluster $cluster `
      -Name $vMName `
      -Node $ownerNode
   ````

1. Reverse replication direction.

   ````powershell
   Set-SRPartnership `
      -NewSourceComputerName $node[0] `
      -SourceRGName Replication 1 `
      -DestinationComputerName $node[1] `
      -DestinationRGName Replication 2
   ````

1. Replication should be in the same state as before we turned off a node.

   ````powershell
   (Get-SRGroup -ComputerName $node[0]).Replicas
   Get-SRPartnership -ComputerName $node[0]
   ````

### Task 8: Simulate a replication failure

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

[figure 1]: images/WAC-initialize-disk.png
[figure 2]: images/WAC-create-volume-data.png
[figure 3]: images/WAC-create-volume-log.png
[figure 4]: images/Cluster-add-to-csv.png
[figure 5]: images/Cluster-disk-replication-enable.png
[figure 6]: images/Cluster-disk-disk3.png
[figure 7]: images/Cluster-disk-replication.png
[figure 8]: images/Cluster-disk-volume3.png
[figure 9]: images/WAC-inventory-host-server.png
[figure 10]: images/WAC-SR-status.png
[figure 11]: images/WAC-VM-move.png
[figure 12]: images/WAC-SR-switch-direction.png
[figure 13]: images/WAC-SR-partner-group-name.png
