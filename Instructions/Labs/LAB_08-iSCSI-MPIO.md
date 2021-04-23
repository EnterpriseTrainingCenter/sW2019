# Lab 8: SCSI & MPIO

## Required VMs

* CL1
* DC1
* DHCP
* Router
* HV1
* FS on HV1
* WS2019 on HV1

## Exercises

1. [iSCSI and Multipath I/O](#exercise-1-iscsi-and-multipath-io)

## Exercise 1: iSCSI and Multipath I/O

### Introduction

In this exercise, you will create an iSCSI target and configure a multipath route to your storage. At the end, you will test a multipath failover.

### Tasks

1. [Configure network connections](#task-1-configure-network-connections)
1. [Configure TCP/IP](#task-2-configure-tcpip)
1. [Configure an iSCSI target](#task-3-Configure-an-iscsi-target)
1. [Configure the iSCSI initiator](#task-4-configure-the-iscsi-initiator)
1. [Test fault-tolerance of Multipath I/O](#task-5-test-fault-tolerance-of-multipath-io)
1. [Examine the performance gain of MPIO](#task-6-examine-the-performance-gain-of-mpio)

### Detailed Instructions

#### Task 1: Configure network connections

Perform these steps on HV1.

1. Logon as **smart\administrator**.
1. Open **Hyper-V Manager**.
1. Open the settings of VM **WS2019**.
1. Add two additional network interfaces and connect it to the Hyper-V Switches **iSCSI** and **iSCSI2**.
1. Close **Settings for WS2019 on HV1**.
1. Open the settings of VM **WS2019**.
1. Expand the **Network Adapter** connected to the switch **iSCSI**.
1. Click **Advanced Features**. Take a note of the MAC address.
1. Repeat the previous steps to take a note of the MAC address of the network adapter connected to **iSCSI2**.

#### Task 2: Configure TCP/IP

Perform these steps on WS2019.

1. Logon **smart\administrator**.
1. Open **Network and Sharing Center**.
1. In **Network and Sharing Center**, on the left, click **Change adapter settings**.
1. Open the properties of both additional network interfaces.
1. Open the details of both additional network interfaces and notice the MAC addresses.
1. Consult your notes from the previous task and rename the network interfaces according to the virtual switchs, they are connected to (**iSCSI** and **iSCSI2**).
1. In the **iSCSI** and **iSCSI2** network interfaces, disable all protocols except **Internet Protocol Version 4**.
1. In the **iSCSI** and **iSCSI2**  network interfaces, configure the properties of **Internet Protocol Version 4** settings.
   * **IP Address:**
     * **iSCSI**: 10.1.9.100
     * **iSCSI2**: 10.2.9.100
   * **Subnet mask:** 255.255.255.0
   * Disable DNS registration

#### Task 3: Configure an iSCSI target

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Server Manager**.
1. Dismiss the Windows Admin Center invite.
1. From the context menu of **All Servers**, select **Add Servers…**.
1. Add a connection to server **DHCP**.
1. Click on **File and Storage Services**, and then on **iSCSI**.
1. From the Tasks drop-down, select **New iSCSI Virtual Disk...** ([figure 1]).
1. Configure a new virtual disk.
   * **Drive:** I:
   * **Name:** MPIOTest
   * **Size:** 40GB, **dynamically expanding**
   * **Create a new iSCSI Target**
   * **Name:** **MPIOTest**
   * **Access servers:** Query initiator name of computer **WS2019**

#### Task 4: Configure the iSCSI initiator

Perform these steps on WS2019.

1. Run **Windows PowerShell** as Administrator.
1. Install the Multipath feature.

   ````powershell
   Install-WindowsFeature 'MultiPath-IO' –IncludeManagementTools
   ````

1. From the start menu, open **MPIO Configuration**.
1. On the tab **Discover Multi-Path**, activate the support for iSCSI devices.
1. Click on **Add** and then **OK**.
1. From the start, menu open **iSCSI Initiator**.
1. Click on **Yes** to accept the service auto start.
1. In the text box **Target**, enter **iscsi-target.smart.etc**, and click on **Quick Connect**.
1. After the connection has established, disconnect the connection and connect it again via the **Connect** and **Disconnect** buttons ([figure 2]).
1. In the dialog **Connect to Target**, activate **Enable multi-path** and click on **Advanced**.
1. Configure the first NIC with a matching subnet IP on the target ([figure 3]). You will see that the target is connected again.
1. Click on **Connect** again.
1. In the dialog **Connect to Target**, activate **Enable multi-path** and click on **Advanced**.
1. Configure the second NIC with a matching subnet IP on the target.
1. Open **Disk Management**, bring the new LUN online and initialize it as GPT.
1. Create and format a new volume with default settings and drive letter **E:**.

#### Task 5: Test fault-tolerance of MultiPath I/O

Perform these steps on HV1.

1. On HV1 open File Explorer
1. Start a copy process from **D:\ISO\WS2016_RTM.iso** to **\\\WS2019\E$**. If the copy process finishes during the next steps. Start it again.
1. While the copy process is running, disconnect one NIC.

   > Does the copy process continue?

1. Reconnect the NIC.
1. Disconnect the other NIC.

   > Does the copy process continue?

1. Reconnect the NIC.

#### Task 6: Examine the performance gain of MPIO

On HV1, make sure a copy process is still running.

Perform these steps on WS2019.

1. Open **Task Manager**.
1. In **Task manager**, examine the utilization of the Ethernet interfaces ([figure 4]).

   > How is the network traffic distributed?

[figure 1]: images/Lab08/figure01.png
[figure 2]: images/Lab08/figure02.png
[figure 3]: images/Lab08/figure03.png
[figure 4]: images/Lab08/figure04.png
