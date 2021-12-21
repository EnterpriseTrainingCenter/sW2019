# Lab: Cluster Rolling Upgrade

## Required VMs

* DC1
* CL1
* DHCP
* Router
* Node1 on HV1
* Node2 on HV1

## Exercises

1. [Cluster Rolling Upgrade](#exercise-1-cluster-rolling-upgrade)

## Exercise 1: Cluster Rolling Upgrade

### Introduction

In this exercise, you will upgrade a Windows Server 2012 R2 cluster consisting of Node1 and Node2 to Windows Server 2016.

#### Tasks

1. [Evict node from cluster](#task-1-evict-node-from-cluster)
1. [Prepare for reinstall](#task-2-prepare-for-reinstall)
1. [Reinstall node](#task-3-reinstall-node)
1. [Configure node](#task-4-configure-node)
1. [Add node to cluster](#task-5-add-node-to-cluster)
1. [Validate the cluster communication certificate](#task-6-validate-the-cluster-communication-certificate)
1. [Reinstall and configure subsequent nodes](#task-7-reinstall-and-configure-subsequent-nodes)
1. [Update cluster functional level](#task-8-update-cluster-functional-level)

### Task 1: Evict node from cluster

#### Desktop Experience

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Failover Cluster Manager**.
1. Connect to **cluster.smart.etc**.
1. Navigate to **Nodes**.
1. From the context menu of **Node1**, select **Pause**, **Drain Roles**. Wait, until **Status** changes to **Paused**.
1. From the context menu of **Node1**, select **More Actions**, **Evict** ([figure 2]).

#### PowerShell

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Windows PowerShell**.
1. Stop cluster node Node1.

   ````powershell
   $cluster = 'cluster.smart.etc'
   $nodeName = 'node1.smart.etc'
   Stop-ClusterNode -Cluster $cluster -Name $nodeName
   ````

1. Evict Node1 from the cluster.

   ````powershell
   Remove-ClusterNode -Cluster $cluster -Name $nodeName
   ````

### Task 2: Prepare for reinstall

Perform these steps on HV1.

1. In **Hyper-V Manager**, shutdown **Node1**.
1. In **Hyper-V Manager**, open the settings of **Node1**.
1. In **Settings**, Mount **D:\Iso\WS2016-RTM.iso** as a DVD Drive. Change the boot order, so that the virtual DVD drive is first in the boot order.
1. Double-click **Node1** to open the Hyper-V console
1. Start **Node1** and boot from DVD.

### Task 3: Reinstall node

Perform these steps on Node1.

1. Select your time and currency format.
1. Click **Install now**.
1. Click **I don’t have a product key**.
1. Select **Windows Server 2016 Datacenter (Desktop Experience)**, and accept the license.
1. Select **Custom** as installation method.
1. Delete all volumes on the disk and start the installation. Wait for the installation to finish.
1. Set the local Administrator password as **Pa$$w0rd** and logon.

### Task 4: Configure node

#### Desktop Experience

Perform these steps on Node1.

1. Open **Network and Sharing Center**.
1. Open the properties of network adapter **Ethernet** and click **Configure** ([figure 3]).
1. On the **Advanced** tab, in the list of properties select **Hyper-V Network Adapter Name** ([figure 4]). Take a note of the value of the **Hyper-V Network Adapter Name** and then close all dialogs.
1. Rename the **Ethernet** network adapter using the value of **Hyper-V Network Adapter Name** you took note of in the previous step.
1. Repeat the previous steps for the **Ethernet 2** network adapter accordingly.
1. Open the properties of the **Datacenter1** network adapter and assign IP address settings.

   * **IP Address:** 10.1.1.61
   * **Subnet Mask:** 255.255.255.0
   * **Default Gateway:** 10.1.1.254
   * **DNS Server:** 10.1.1.1

1. Open the properties of the **iSCSI** network adapter and assign IP address settings.
   * **IP Address:** 10.1.9.61
   * **Subnet Mask:** 255.255.255.0
   * **Default Gateway:** leave empty
   * **DNS Server:** leave empty
   * Deactivate all other components except for **Internet Protocol Version 4 (TCP/IPv4)** (e.g. **Internet Protocol Version 6 (TCP/IPv6)** [figure 5])
1. Rename the computer to **Node1** and join it to the domain **smart.etc**. Reboot the computer.
1. Logon as **smart\Administrator**.
1. From the start menu, open **iSCSI Initiator**.
1. When asked to start the service automatically, click on **Yes** .
1. In iSCSI Initiator Properties, in **Target:** enter **10.1.9.10** and click **Quick Connect...** ([figure 6]).
1. Run **Windows PowerShell** as Administrator.

   > In real world, what could be the next steps at this point?

1. Open **Server Manager**.
1. In **Server Manager**, click **Manage**, **Add Roles and Features**.
1. Proceed to page **Server Roles**, expand **File and Storage Services**, **File and iSCSI Services**, and activate **File Server**.
1. Proceed to page **Features** and activate **Failover Clustering**. Add all required features.
1. Proceed to page **Confirmation**, activate **Restart the destination server automatically if required**, and click **Install**.

#### PowerShell

1. Run **Windows PowerShell** as Administrator.
1. Rename the network adapters according to their Hyper V network adapter names.

   ````powershell
   <#
   ForEach-Object loops through the pipeline. On each iteration, $PSItem
   contains the next element in the pipeline. $PSItem could  be written as $_ 
   also.
   #>
   Get-NetAdapterAdvancedProperty -RegistryKeyword 'HyperVnetworkAdapterName' | 
   ForEach-Object { 
      Rename-NetAdapter -Name $PSItem.Name -NewName $PSItem.DisplayValue 
   }
   ````

1. Change the IPv4 settings of the Datacenter1 network adapter.

   ````powershell
   $interfaceAlias = 'Datacenter1'
   New-NetIPAddress `
      -AddressFamily IPv4 `
      -InterfaceAlias $interfaceAlias `
      -IPAddress 10.1.1.61 `
      -PrefixLength 24 `
      -DefaultGateway 10.1.1.254
   Set-DnsClientServerAddress `
      -InterfaceAlias $interfaceAlias `
      -ServerAddresses 10.1.1.1
   ````

1. Change the IPv4 settings of the iSCSI network adapter and disable all service bindings except TCP/IP v4.

   ````powershell
   $interfaceAlias = 'iSCSI'
   New-NetIPAddress `
      -AddressFamily IPv4 `
      -InterfaceAlias $interfaceAlias `
      -IPAddress 10.1.9.61 `
      -PrefixLength 24
   
   Get-NetAdapterBinding -InterfaceAlias $interfaceAlias | 
   Where-Object ComponentID -ne ms_tcpip |
   Disable-NetAdapterBinding
   ````

1. Rename the computer to Node1 and reboot it.

   ````powershell
   Rename-Computer -NewName 'Node1' -Restart
   ````

1. Logon as **Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Join Node1 to the domain **smart.etc**. Reboot the computer.

   ````powershell
   # In PowerShell, commands in braces are executed first.
   # The result can then be used in a parameter of the surounding commmand.
   Add-Computer `
      -DomainName 'smart.etc' `
      -Credential (
         Get-Credential -Message 'Credentials to join domain'
      ) `
      -Restart
   ````

1. Logon as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Set the iSCSI service to auto start and start it.

   ````powershell
   $service = Get-Service -Name MSiSCSI
   $service | Set-Service -StartupType Automatic
   $service | Start-Service
   ````

1. Connect the iSCSI initiator to **10.1.9.10**.

   ````powershell
   $IscsiTargetPortal = New-IscsiTargetPortal `
      -TargetPortalAddress 10.1.9.10
   $IscsiTarget = Get-IscsiTarget -IscsiTargetPortal $IscsiTargetPortal
   $IscsiTarget | Connect-IscsiTarget -IsPersistent $true
   ````

   > In real world, what could be the next steps at this point?

1. Install the File Server role and the Failover Clustering feature.

   ````powershell
   Install-WindowsFeature 'FS-FileServer', 'Failover-Clustering' -IncludeManagementTools -Restart
   ````

### Task 5: Add node to cluster

#### Desktop Experience

Perform these steps on CL1.

1. In **Failover Cluster Manager**, add **Node1** to the Cluster ([figure 8]). Do not run validation tests.

#### PowerShell

Perform these steps on Node1.

1. In **Windows PowerShell**, add Node1 to the cluster.

   ````powershell
   Add-ClusterNode -Cluster cluster.smart.etc
   ````

### Task 6: Validate the cluster communication certificate

#### Desktop Experience

Perform these teps on Node1.

1. Run **certlm.msc**.
1. Navigate to **Personal**, **Certificates**. Verify that a certificate **CLIUSR** exists ([figure 7]). This certificate is used for authentication between cluster nodes.

#### PowerShell

Perform these teps on Node1.

1. Verify that a certificate **CLIUSR** exists. This certificate is used for authentication between cluster nodes.

   ````powershell
   Get-ChildItem Cert:\LocalMachine\My\
   ````

### Task 7: Reinstall and configure subsequent nodes

1. Refer to the steps in [Task 1: Evict first node from the cluster](#task-1-evict-first-node-from-the-cluster) to evict **Node2** from the cluster.
1. Refer to [Task 2: Prepare the reinstall of first node](#task-2-prepare-the-reinstall-of-first-node) to prepare the reinstall of **Node2**.
1. Refer to [Task 3: Reinstall first node](#task-3-reinstall-first-node) to reinstall **Node2**.
1. Refer to [Task 4: Configure first node](#task-4-configure-first-node) to configure **Node2**. Refer to the Table 1 below for the IP addresses. The computer name must be **Node2**.
1. Refer to [Task 5: Add first node to cluster](#task-5-add-first-node-to-cluster) to add **Node2** to the cluster again.
1. Refer to [Task 6: Validate the cluster communication certificate](#task-6-validate-the-cluster-communication-certificate) to validate the cluster communication certificate.

| Network adapter | IP Address |
|-----------------|------------|
| Datacenter1     | 10.1.1.62  |
| iSCSI           | 10.1.9.62  |

### Task 8: Update cluster functional level

Perform these steps on CL1.

1. Run **Windows PowerShell** as Administrator.
1. Retrieve the current cluster functional level.

   ````powershell
   $cluster = Get-Cluster -Name cluster.smart.etc
   
   # Select is an alias for Select-Object
   $cluster | Select ClusterFunctionalLevel
   ````

   > What is the original cluster funtional level?

1. Update the cluster functional level.

   ````powershell
   $cluster | Update-ClusterFunctionalLevel
   ````

1. Validate the cluster functional level.

   ````powershell
   $cluster | Select ClusterFunctionalLevel
   ````

   > What is the updated cluster functional level?

   > How would you upgrade the cluster to Windows Server 2019?


[figure 1]: images/hyperv-manager-vm-checkpoint.png
[figure 2]: images/cluster-evict.png
[figure 3]: images/Ethernet-properties-configure.png
[figure 4]: images/hyperv-network-adapter-name.png
[figure 5]: images/Ethernet-properties-ipv4-only.png
[figure 6]: images/iscsi-quick-connect.png
[figure 7]: images/certificates-cliusr.png
[figure 8]: images/cluster-add-node.png