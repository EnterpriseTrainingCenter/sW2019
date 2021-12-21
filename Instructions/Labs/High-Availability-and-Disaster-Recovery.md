# Lab: High Availability and Disaster Recovery

## Required VMs

* DC1
* CL1
* DHCP
* Router
* Node1 on HV1
* Node2 on HV1
* RDCB1
* RDCB2

## Exercises

1. [Cluster Rolling Upgrade](#exercise-1-cluster-rolling-upgrade)
2. [Network Load Balancing](#exercise-2-network-load-balancing)

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

## Exercise 2: Network Load Balancing

### Introduction

In this exercise, you will create and test a network load balancing cluster. On RDCB1 and RDCB2, you will install IIS and Network Load Balancing, configure IIS with a sample site, configure the NLB cluster consisting of the two nodes, add a DNS record for the cluster, validate the cluster, and simulate a failure and its recovery.

#### Tasks

1. [Install IIS and Network Load Balancing](#task-1-install-iis-and-network-load-balancing)
1. [Configure IIS](#task-2-configure-iis)
1. [Create an NLB cluster](#task-3-create-an-nlb-cluster)
1. [Configure DNS](#task-4-configure-dns)
1. [Add a node to the NLB cluster](#task-5-add-a-node-to-an-NLB-cluster)
1. [Validate an NLB cluster](#task-6-validate-an-nlb-cluster)
1. [Simulate a failure](#task-7-simulate-a-failure)
1. [Validate failover](#task-8-validate-failover)
1. [Simulate recovery](#task-9-simulate-recovery)
1. [Validate recovery](#task-10-validate-recovery)

### Task 1: Install IIS and Network Load Balancing

Perform these steps on RDCB1 and RDCB2.

1. Logon as **smart\administrator**.
1. Open **Server Manager**.
1. In **Server Manager**, click **Manage**, **Add Roles and Features**.
1. In **Add Role and Features Wizard**, continue to the page **Select server roles**.
1. On page **Select server roles**, activate **Web Server (IIS)**.
1. On page **Select featues**, active **Network Load Balancing**.
1. Continue through the wizard to install Web Server (IIS) and Network Load Balancing.

Repeat the steps on RDCB2.

### Task 2: Configure IIS

Perform these steps on RDCB1.

1. Open Notepad.
1. Open file \\\\RDCB1\c$\Inetpub\wwwroot\iisstart.htm.
1. Find the stylesheet for body, change the **background-color** attribute to **red**, and save the file.

   ````css
   body {
       color:#000000;
       background-color:red;
       margin:0;
   }
   ````

1. Open file \\RDCB2\c$\Inetpub\wwwroot\iisstart.htm.
1. Find the stylesheet for body, change the **background-color** attribute to **blue**, and save the file.

   ````css
   body {
       color:#000000;
       background-color:blue;
       margin:0;
   }
   ````

1. Close **Notepad**.

### Task 3: Create an NLB cluster

Perform these steps on RDCB1.

1. Logon as **smart\Adminitrator**.
1. From the start menu, open **Network Load Balancing Manager**.
1. From the context menu of **Load Balancing Clusters**, select **New Cluster**.
1. On page **New Cluster: Connect**, in **Host**, enter **RDCB**, and click on **Connect**.
1. Under **Interfaces available for configuring a new cluster**, select the interface with the IP address **10.1.1.51**, and click on **Next**.
1. On page **New Cluster: Host Parameters**, keep the default settings, and click on **Next**.
1. On page **New Cluster: Cluster IP Addresses**, add the clustered IP **10.1.1.64/24**, and click on **Next**.
1. On page **New Cluster: Cluster Parameters**, in **Full Internet name**, enter the FQDN **www.smart.etc**, set the cluster operations mode to **Multicast**, and click on **Next**.
1. On page **New Cluster: Port Rules**, select the default port rule, and click on **Edit**.
1. In **#Add/Edit Port Rule**, in **From** and **To**, enter **80**. Under Protocols, select TCP and click on **OK** ([figure 10]).
1. Back on page **New Cluster: Port Rules**, click on **Finish** to create the NLB cluster.
1. Open a **Command Prompt**.
1. Validate the IP configuration ([figure 11]).

   ````shell
   ipconfig
   ````

### Task 4: Configure DNS

Perform these steps on DC1.

1. Open a web browser.
1. Navigate to <http://10.1.1.64>. You should see the default page with red background.
1. Open the **DNS Manager**.
1. Click the Forward Lookup Zone **smart.etc**.
1. If present, delete the A record **www**.
1. Create a new A record with the name **www** and the IP address **10.1.1.64**.
1. Run **Windows PowerShell** as Administrator.
1. Clear the DNS Cache.

   ````powershell
   Clear-DnsClientCache
   ````

1. In the web browser, navigate to www.smart.etc. You should see the default page with a red background.

### Task 5: Add a node to an NLB cluster

Perform these steps on RDCB1.

1. In **Network Load Balancing Manager**,  from the context menu of the cluster www.smart.etc, select **Add Host to Cluster**.
1. On page **Add Host to Cluster: Connect**, in **Host**, enter **RDCB2**.
1. Under **Interfaces available for configuring the cluster**, select the interface with the IP address **10.1.1.52**, and click on **Next**.
1. On page **Add Host to Cluster: Host Parameters**, keep the default settings, and click on **Next**.
1. On page **Add Host to Cluster: Port Rules**, keep the default configuration, and click on **Finish**. Wait until the node joins the cluster.

### Task 6: Validate an NLB cluster

Perform these steps on DC1.

1. In the web browser, refresh the page.

   > Which color does the background have? Which server serves your request?

   You may try to refresh the page several times.

### Task 7: Simulate a failure

Perform these steps on RDCB1.

1. In **Network Load Balancing manager**, From the context menu of node **RDCB1**, select **Control host**, **Suspend**.

### Task 8: Validate failover

Perform these steps on DC1.

1. In the web browser, refresh the page. You should see the default page with a blue background.

### Task 9: Simulate recovery

Perform these steps on RDCB1.

1. In **Network Load Balancing Manager**, from the context menu of node FS, select **Control Host**, **Resume**, then **Start**. Wait until the node joins the cluster.

### Task 10: Validate recovery

Perform these steps on DC1.

1. In the web browser, refresh the page.

   > Which color does the background have? Which server serves your request?

   You may try to refresh the page several times.

If time permits, you can repeat tasks 6 - 9 simulating a failure on RDCB2.

[figure 1]: images/Lab14/figure01.png
[figure 2]: images/Lab14/figure02.png
[figure 3]: images/Lab14/figure03.png
[figure 4]: images/Lab14/figure04.png
[figure 5]: images/Lab14/figure05.png
[figure 6]: images/Lab14/figure06.png
[figure 7]: images/Lab14/figure07.png
[figure 8]: images/Lab14/figure08.png
[figure 9]: images/Lab14/figure09.png
[figure 10]: images/Lab14/figure10.png
[figure 11]: images/Lab14/figure11.png
