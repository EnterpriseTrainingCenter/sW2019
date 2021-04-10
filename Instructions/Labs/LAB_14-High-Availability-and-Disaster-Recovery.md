# Lab 14: High Availability and Disaster Recovery

## Required VMs

* DC1
* CL1
* DHCP
* Router
* HV1
* FS on HV1
* WS2019 on HV1

## Exercises

1. [Cluster Rolling Upgrade](#exercise-1-cluster-rolling-upgrade)
2. [Network Load Balancing](#exercise-2-network-load-balancing)

## Exercise 1: Cluster Rolling Upgrade

### Introduction

In this exercise, you will upgrade a Windows Server 2012 R2 cluster to Windows Server 2019.

### Tasks

1. [Start cluster nodes](#task-1-start-cluster-nodes)
1. [Evict node from cluster](#task-2-evict-node-from-cluster)
1. [Prepare for reinstall](#task-3-prepare-for-reinstall)
1. [Reinstall node](#task-4-reinstall-node)
1. [Configure node](#task-5-configure-node)
1. [Add node to cluster](#task-6-add-node-to-cluster)
1. [Reinstall and configure subsequent nodes](#task-7-reinstall-and-configure-subsequent-nodes)
1. [Update cluster functional level](#task-8-update-cluster-functional-level)
1. [Clean up](#task-9-clean-up)

### Detailed Instructions

#### Task 1: Start cluster nodes

Perform these steps on HV1.

1. In **Hyper-V Manager**, select **Node1** and **Node2**.
1. From the context menu of **Node1** or **Node2**, select **Checkpoint** ([figure 1]).
1. From the context menu of **Node1** or **Node2**, select **Start**. Wait for the both VMs to boot and display the logon screen.

#### Task 2: Evict node from cluster

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Failover Cluster Manager**.
1. Select the **Don’t show this message again** checkbox, and close the **Windows Admin Center Info** window.
1. Connect to **cluster.smart.etc**.
1. Navigate to **Nodes**.
1. From the context menu of **Node1**, select **Pause**, **Drain Roles**.
1. From the context menu of **Node1**, select **More Actions**, **Evict** ([figure 2]).

#### Task 3: Prepare for reinstall

Perform these steps on HV1.

1. In **Hyper-V Manager**, shutdown **Node1**.
1. In **Hyper-V Manager**, open the settings of **Node1**.
1. In **Settings**, Mount **D:\Iso\WS2016-RTM.iso** as a DVD Drive. Change the boot order, so that the virtual DVD drive is first in the boot order.
1. Double-click **Node1** to open the Hyper-V console
1. Start **Node1** and boot from DVD.

#### Task 4: Reinstall node

Perform these steps on Node1.

1. Select your time and currency format.
1. Click **Install**.
1. Click **I don’t have a product key**.
1. Select **Windows Server 2016 Datacenter (Desktop Experience)**, and accept the license.
1. Select **Custom** as installation method.
1. Delete all volumes on the disk and start the installation. Wait for the installation to finish.
1. Set the local Administrator password as **Pa$$w0rd** and logon.

#### Task 5: Configure node

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
1. Logon as **smart\Administrator**
1. Run **Windows PowerShell** as Administrator.
1. Install the File Server role and the Failover Clustering feature.

   ````powershell
   Install-WindowsFeature 'FS-FileServer', 'Failover-Clustering' -IncludeManagementTools
   ````

1. From the start menu, open **iSCSI Initiator**.
1. When asked to start the service automatically, click on **Yes** .
1. In iSCSI Initiator Properties, in **Target:** enter **10.1.9.10** and click **Quick Connect...** ([figure 7]).
1. Run **certlm.msc**.
1. Navigate to **Personal**, **Certificates**. Verify that a certificate **CLIUSR** exists ([figure 8]). This certificate is used for authentication between cluster nodes.

#### Task 6: Add node to cluster

Perform these steps on CL1.

1. In **Failover Cluster Manager**, add **Node1** to the Cluster ([figure 8]).

   > In real world, what could be the next steps at this point?

#### Task 7: Reinstall and configure subsequent nodes

1. Refer to the steps in [Task 2: Evict first node from the cluster](#task-2-evict-first-node-from-the-cluster) to evict **Node2** from the cluster.
1. Refer to [Task 3: Prepare the reinstall of first node](#task-3-prepare-the-reinstall-of-first-node) to prepare the reinstall of **Node2**.
1. Refer to [Task 4: Reinstall first node](#task-4-reinstall-first-node) to reinstall **Node2**.
1. Refer to [Task 5: Configure first node](#task-5-configure-first-node) to configure **Node2**. Refer to the Table 1 below for the IP addresses. The computer name must be **Node2**.
1. Refer to [Task 6: Add first node to cluster](#task-6-add-first-node-to-cluster) to add **Node2** to the cluster again.

| Network adapter | IP Address |
|-----------------|------------|
| Datacenter1     | 10.1.1.62  |
| iSCSI           | 10.1.9.62  |

#### Task 8: Update cluster functional level

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

#### Task 9: Clean up

Perform these steps on HV1.

1. In **Hyper-V Manager**, shut down Node1 and Node 2.

## Exercise 2: Network Load Balancing

### Introduction

In this exercise, you will create and test a network load balancing cluster.

### Tasks

1. [Install and configure IIS](#task-1-install-and-configure-iis)
1. [Create an NLB cluster](#task-2-create-an-nlb-cluster)
1. [Configure DNS](#task-3-configure-dns)
1. [Add a node to the NLB cluster](#task-4-add-a-node-to-an-NLB-cluster)
1. [Validate an NLB cluster](#task-5-validate-an-nlb-cluster)
1. [Simulate a failure](#task-6-simulate-a-failure)
1. [Validate failover](#task-7-validate-failover)
1. [Simulate recovery](#task-8-simulate-recovery)
1. [Validate recovery](#task-9-validate-recovery)

### Detailed Instructions

#### Task 1: Install and configure IIS

Perform these tasks on CL1.

1. Logon as **smart\administrator**
1. Run **Windows PowerShell** as Administrator
1. Install Role Web Server (IIS) the feature Network Load Balancing.

   ````powershell
   # Invoke-Command allow to run the command in ScriptBlock
   # remotely on multiple computers
   Invoke-Command -Computername FS, WS2019 -ScriptBlock {
       Install-WindowsFeature 'Web-Server', 'NLB' -IncludeManagementTools
    }
   ````

1. Open Notepad.
1. Open file \\FS\c$\Inetpub\wwwroot\iisstart.htm.
1. Find the stylesheet for body, change the **background-color** attribute to **red**, and save the file.

   ````css
   body {
       color:#000000;
       background-color:red;
       margin:0;
   }
   ````

1. Open file \\WS2019\c$\Inetpub\wwwroot\iisstart.htm.
1. Find the stylesheet for body, change the **background-color** attribute to **blue**, and save the file.

   ````css
   body {
       color:#000000;
       background-color:blue;
       margin:0;
   }
   ````

#### Task 2: Create an NLB cluster

Perform these steps on FS.

1. Logon as **smart\Adminitrator**.
1. From the start menu, open **Network Load Balancing Manager**.
1. From the context menu of **Load Balancing Clusters**, select **New Cluster**.
1. Enter **FS**, and click on **Connect**.
1. Select the IP address **10.1.1.42**, and click on **Next**.
1. Keep the default settings, and click on **Next**.
1. Add the clustered IP **10.1.1.64/24**, and click on **Next**.
1. Enter the FQDN **www.smart.etc**, and set the cluster operations mode to **Multicast**.
1. Select the default port rules, and click on **Edit**.
1. Change the port range to **80:80/tcp** ([figure 10]).
1. Click on **Finish** to create the NLB cluster.
1. Open a **Command Prompt**.
1. Validate the IP configuration ([figure 11]).

   ````shell
   ipconfig
   ````

#### Task 3: Configure DNS

Perform these steps on DC1.

1. Open a web browser.
1. Navigate to <http://10.1.1.64>. You should see the default page with red background.
1. Open the **DNS Manager**.
1. From the zone **smart.etc**, delete the record **www**.
1. Create a new A record with the name **www** and the IP address **10.1.1.64**.
1. Run **Windows PowerShell** as Administrator.
1. Clear the DNS Cache.

   ````powershell
   Clear-DnsClientCache
   ````

1. In the web browser, navigate to www.smart.etc. You should see the default page with a red background.

#### Task 4: Add a node to an NLB cluster

Perform these steps on FS.

1. In **Network Load Balancing Manager**,  from the context menu of the cluster www.smart.etc, select **Add Host to Cluster**.
1. Enter **WS2019**.
1. Select the IP address **10.1.1.32**, and click on **Next**.
1. Keep the default configuration, and click on **Next**.
1. Keep the default port configuration, and click on **Finish**. Wait until the node joins the cluster.

#### Task 5: Validate an NLB cluster

Perform these steps on DC1.

1. In the web browser, refresh the page.

   > Which color does the background have? Which server serves your request?

   You may try to refresh the page several times.

#### Task 6: Simulate a failure

Perform these steps on FS.

1. In **Network Load Balancing manager**, From the context menu of node **FS**, select **Control host**, **Suspend**.

#### Task 7: Validate failover

Perform these steps on DC1.

1. In the web browser, refresh the page. You should see the default page with a blue background.

#### Task 8: Simulate recovery

Perform these steps on FS.

1. In **Network Load Balancing Manager**, from the context menu of node FS, select **Control Host**, **Resume and Start**. Wait until the node joins the cluster.

#### Task 9: Validate recovery

Perform these steps on DC1.

1. In the web browser, refresh the page.

   > Which color does the background have? Which server serves your request?

   You may try to refresh the page several times.

If time permits, you can repeat tasks 6 - 9 simulating a failure on WS2019.

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
