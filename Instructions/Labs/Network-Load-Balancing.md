# Lab: Network Load Balancing

## Required VMs

* DC1
* CL1
* DHCP
* Router
* RDCB1
* RDCB2

## Exercises

1. [Network Load Balancing](#exercise-1-network-load-balancing)

## Exercise 1: Network Load Balancing

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
1. In **#Add/Edit Port Rule**, in **From** and **To**, enter **80**. Under Protocols, select TCP and click on **OK** ([figure 1]).
1. Back on page **New Cluster: Port Rules**, click on **Finish** to create the NLB cluster.
1. Open a **Command Prompt**.
1. Validate the IP configuration ([figure 2]).

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

[figure 1]: images/wlb-defined-port-rules.png
[figure 2]: images/wlb-ipconfig-result.png
