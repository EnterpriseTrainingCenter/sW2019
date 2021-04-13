# Lab 5: Installing and Configuring Hyper-V

## Required VMs

* DC1
* DHCP
* Router
* HV1
* HV2
* SRV2

## Exercises

1. [Installing Hyper-V](#exercise-1-installing-hyper-v)
1. [Managing virtual networks](#exercise-2-managing-virtual-networks)
1. [Managing virtual hard disks](#exercise-3-managing-virtual-hard-disks)
1. [Hyper-V replica](#exercise-4-hyper-v-replica)

## Exercise 1: Installing Hyper-V

### Introduction

In this exercise, you will install the Hyper-V Role.

### Tasks

1. [Use Server Manager to install the Hyper-V role](#task-1-use-server-manager-to-install-the-hyper-v-role)

### Detailed Instructions

#### Task 1: Use Server Manager to install the Hyper-V role

Perform these steps on HV2.

1. Logon with **smart\Administrator**.
1. Start **Server Manager** from the Start Menu.
1. From the menu bar, select **Manage, Add Roles and features**.
1. Click on **Next** until you reach the page **Select server roles** page.
1. Select **Hyper-V**, and click on **Next** until you reach the page **Create Virtual Switches** page.
1. Select the adapter **Datacenter2**,  and click on **Next** twice.
1. On the page **Virtual Machine Migration**, click on **Next**.
1. On the page **Default Stores**, change both paths to **D:\\**, and click on **Next**.
1. Select the checkbox **Restart the destination server if required** and confirm with **Yes**.
1. Click on install. The system will reboot twice
1. After installation completes, logon with **smart\Administrator**.

## Exercise 2: Managing virtual networks

### Introduction

In this exercise, you will create and manage virtual networks.

### Tasks

1. [Examine the switch that was created during installation](#task-1-examine-the-switch-that-was-created-during-installation)
1. [Change the dynamic MAC Address Range](#task-2-change-the-dynamic-mac-address-range)
1. [Create internal and private switches](#task-3-create-internal-and-private-switches)

### Detailed Instructions

#### Task 1: Examine the switch that was created during installation

Perform these steps on HV2. Since the IP configuration has changed, use a Hyper-V Console connection for this task.

1. Logon as **smart\Administrator**.
1. Run **Hyper-V Manager** from start menu.
1. In the **Actions** Pane, click on **Virtual Switch Manager** ([figure 1]).
1. Examine the switch that has been created by the installation ([figure 2]).

   > What is the name of the switch? How was this name determined?

   > The option **Allow management operating system to share the network adapter**. What is the effect of this option?

1. Open **Network and Sharing Center**.

   > What is the name and description of the network card that is connected to the **Unidentified** network ([figure 3])?

1. Switch back to Hyper-V **Virtual Switch Manager**.
1. Rename the external switch to **Datacenter2**, and click on **Apply** to commit the changes.
1. Switch to **Network and Sharing Center**.

   > What is the name of the network card now?

1. In **Network and Sharing Center**, on the left, click on **Change adapter settings** ([figure 4]).
1. On the top-right corner of the toolbar, change the view to **Details** ([figure 5]).
1. Compare the two network adapters. One is the physical adapter (**Datacenter2**), which is bound to the Hyper-V virtual switch, the other is the management OS adapter (**vEthernet (Datacenter2)**).
1. From the context menu of the network adapter **vEtherne (Datacenter2)**, select **Status**.
1. Click on **Details**.

   > Which IP address does the adapter have? Why?

1. Click on **Close** and the click on **Properties**.
1. Change the IPv4 configuration to use a static IP Address with the following parameters.

   * **IP Address:** 10.1.2.30
   * **Subnet Mask:** 255.255.255.0
   * **Default Gateway:** 10.1.2.254
   * **Preferred DNS Server:** 10.1.1.1

1. From the context menu of the network adapter **Datacenter2**, select **Status**.
1. Click on **Details**.

   > Why is the dialog empty?

1. Click on **Close**.
1. Click on **Properties**.

   > Which protocols are bound to the physical network card?

1. Click on **Cancel** and then **Close**.
1. Close the Hyper-V Console Window. You can use RDP Manager for the next task again.

#### Task 3: Change the dynamic MAC address range

Perform these steps on HV2.

1. Switch back to **Virtual Switch Manager**.
2. Click on **MAC Address Range**.
3. Change the second octet of the minimum and maximum range to **17** ([figure 12]).
4. Click on **OK** to commit the changes

#### Task 2:  Create internal and private switches

Perform these steps on HV2.

1. Switch back to **Virtual Switch Manager**.
1. Create a new internal switch ([figure 6]) with the name **Internal** ([figure 7]).
1. Click on **Apply** to commit the changes
1. Switch to **Network and Sharing Center**. A new network adapter has been created as management OS adapter for the internal switch ([figure 8]).
1. Click on the network adapter name and then click on **Details**.

   > What is the IP address of the new network adapter ([figure 9])? Why?

1. Switch back to **Virtual Switch Manager**.
1. Create a new private switch ([figure 10]) with the name **Private** ([figure 11]).
1. Click on **Apply** to commit the changes.
1. Switch to **Network and Sharing Center**.

   > Why is there no new network adapter shown?

## Exercise 3: Managing virtual hard disks

### Introduction

In this exercise, you will create and manage virtual hard disks.

### Tasks

1. [Create a dynamic disk](#task-1-create-dynamic-disk)
1. [Create a fixed disk](#task-2-create-a-fixed-disk)
1. [Create a differencing disk](#task-3-create-a-differencing-disk)
1. [Convert disks](#task-4-convert-disks)
1. [Inspecting a disk](#task-5-inspecting-a-disk)
1. [Fixing a broken disk chain](#task-6-fixing-a-broken-disk-chain)
1. [Expand a disk](#task-7-expand-a-disk)
1. [Shring a disk](#task-8-shrink-a-disk)

### Detailed Instructions

#### Task 1: Create dynamic disk

Perform these steps on HV2.

1. In **Hyper-V Manager**, on the left, from the context menu of the **HV2** node, select **New/Hard Disk…** ([figure 13]).
1. Create a new disk with the following settings.

   * **Disk format:** **VHDX**
   * **Disk Type:** **Dynamically expanding**
   * **Name:** Dynamic.vhdx
   * **Location:** D:\VHDs
   * **Size:** 1000 GB

#### Task 2: Create a fixed disk

Perform these steps on HV2.

1. Create a new disk with the following settings:

   * **Disk format:** **VHDX**
   * **Disk Type:** **Fixed size**
   * **Name:** Fixed.vhdx
   * **Location:** D:\VHDs
   * **Size:** 1 GB

1. Open **File Explorer**.
1. Navigate to **D:\VHDs**, and examine the virtual hard disk files.

   > What is the size of the virtual hard disk files?

1. From the context menu of the start button, open **Disk Management**.
1. In **Disk Management**, from the menu, select **Actions, Attach VHD** ([figure 14]).
1. Browse for the **Fixed.vhdx** disk and attach it ([figure 15]).
1. From the context menu of the attached VHD, select **Initialize Disk** ([figure 16]).
1. On the attached VHD, create a new volume. Assign drive letter **E:**.
1. Switch to **File Explorer**. The new volume **E:** should be available there ([figure 17]).
1. On **E:**, create a new folder with the name **fixed disk**.
1. From the context menu of **E:**, select **Eject** to unmount the disk.

#### Task 3: Create a differencing disk

Perform these steps on HV2.

1. In **Hyper-V Manager**, create a new disk with the following settings:

   * **Disk format:** **VHDX**
   * **Disk Type:** **Differencing**
   * **Name:** Differencing.vhdx
   * **Location:** D:\VHDs
   * **Configure Disk:** D:\VHDs\Fixed.vhdx; this specifies the parent disk

1. Switch to file explorer and navigate to D:\VHDs.

   > What is the size of the **Differencing.vhdx** file?

1. Double-click on **Differencing.vhdx**. The disk is now available as drive in file explorer and should contain the folder **fixed disk**.
1. Rename the folder to **diff disk**.
1. Navigate back to **D:\VHDs** and examine the file size of **Differencing.vhdx**.

   > What is the size of the **Differencing.vhdx** file now?

1. In **File Explorer**, from the context menu of **E:**, select **Eject**.

#### Task 4: Convert disks

Perform these steps on HV2.

1. In **Hyper-V Manager**, in the **Actions** pane, click on **Edit Disk…**
1. Select the file **D:\VHDs\Dynamic.vhdx** ([figure 18]) and click **Next**.
1. Select **Convert** ([figure 19]) and click **Next**.
1. Select **VHD** ([figure 20]) and click **Next**.
1. Select **Dynamic** and click on **Next**.
1. Save the converted file as **D:\VHDs\Dynamic.vhd** ([figure 21]).

#### Task 5: Inspecting a disk

Perform these steps on HV2.

1. In **Hyper-V Manager**, in the **Actions** pane, click on **Inspect Disk…**.
1. In the **Open** dialog navigate to **D:\VHDs** and select **Differencing.vhdx**.
1. A window opens showing the properties of the differencing disk including the chain ([figure 22]).

#### Task 6: Fixing a broken disk chain

Perform these steps on HV2.

1. Switch to file explorer and move the file **Fixed.vhdx** from **D:\VHDs** to **D:\\**
1. Inspect the disk **D:\VHDs\Differencing.vhdx** again.
1. The disk chain is broken because we moved the parent disk ([figure 23]) (although the error message is confusing).
1. In **Hyper-V Manager**, in the **Actions** pane click on **Edit Disk…**.
1. Select the file **D:\VHDs\Differencing.vhdx** and click **Next**.
1. On the page **Reconnect Virtual Hard Disk**, click on **Next** .
1. On the page **Reconnect to parent virtual hard disk** page, select the **Fixed.vhdx** from **D:\**
1. After the wizard finished, Inspect the disk **D:\VHDs\Differencing.vhdx** again. The disk chain should now be ok.

#### Task 7: Expand a disk

Perform these steps on HV2.

1. In **Hyper-V Manager**, in the **Actions** pane, click on **Edit Disk…**
1. Select the disk **D:\Fixed.vhdx** and click **Next**.
1. Select **Expand** and click **Next**.
1. Specify 2 GB as new size.
1. Click on **Finish**.

#### Task 8: Shrink a disk

Perform these steps on HV2.

1. From start menu, run **PowerShell** as Administrator.
1. Enter the following command to shrink the fixed disk back to 1 GB.

   ````powershell
   Resize-VHD -Path D:\Fixed.vhdx -SizeBytes 1GB
   ````

## Exercise 4: Hyper-V replica

### Introduction

In this exercise, you will use Hyper-V replica to replicate a VM from HV1 to HV2.

### Tasks

1. [Enable Hyper-V replica](#task-1-enable-hyper-v-replica)
1. [Configure VM replication](#task-2-configure-vm-replication)
1. [Validate VM replication](#task-3-validate-vm-replication)
1. [Test planned failover](#task-4-test-planned-failover)
1. [Validate planned failover](#task-5-Validate-planned-failover)
1. [Simulate a failure](#task-6-simulate-a-failure)
1. [Recover from a failure](#task-7-recover-from-a-failure)

### Detailed Instructions

#### Task 1: Enable Hyper-V replica

Perform these steps on HV1.

1. Logon as **smart\administrator**
1. Start **Hyper-V Manager** and select the node **HV1**.
1. In the **Actions** pane, click on **Hyper-V Settings**.
1. In **Hyper-V Settings for HV1**, click on **Replication Configuration**.
1. In **Replication Configuration**, activate the checkbox **Enable the computer as a Replica server**. Activate the checkbox **Use Kerberos (HTTP)**, and use the default configuration with port 80 ([figure 24]).
1. In **Replication Configuration**, configure **D:\\** as default path for replicated VMs and click on **Apply** ([figure 25]).
1. In the warning regarding firewall settings, click on **OK**.
1. From the start menu, open the **Windows Firewall with Advanced Security** console.
1. On the left, in the tree pane, select **Inbound Rules**.
1. Enable both **Hyper-V Replica Listener** rules ([figure 26]).
1. Open **Virtual Switch Manager**.
1. Rename the external network **Datacenter1** ([figure 27]) to **smart.etc** ([figure 28]).

Repeat all steps from this task on HV2. In the last step, the external network to be renamed is called **Datacenter2**.

#### Task 2: Configure VM replication

Perform these steps on HV1.

1. In **Hyper-V Manager** start the VM **WS2019**.
1. From the context menu of **WS2019**, select **Enable Replication**.
1. Click on **Next** to start the configuration.
1. In **Replica Server** enter **HV2**, and click on **Next**.
1. Keep the default parameters and click on **Next**.
1. Validate that the correct disk is selected and click on **Next**.
1. Set the replication frequency to 30 sec and click on **Next**.
1. On the page **Configure Additional Recovery Points**, select **Create additional hourly recovery points**. In **Coverage provided by additional recovery points (in hours)** enter 12. Activate **Volume Shadow Copy Service (VSS) snapshot frequency (in hours)** and enter 2 ([figure 29]).
1. Set to send the **initial copy immediately over the network** and click on **Finish** to start the replication.
1. At the bottom of **Hyper-V Manager**, select the tab **Replication** to check the state of the initial replication of the VM ([figure 30]). Wait until the initial replication has finished. This takes about 5 minutes.
1. From the context menu of **WS2019**, select **Replication**, **View Replication Health**. Validate the successful continuous replication progress.

#### Task 3: Validate VM replication

Perform these steps on HV1.

1. Switch to Hyper-V Manager. You should see the VM **WS2019**.
1. From the context menu of **WS2019**, select **Replication**, **View Replication Health**. Validate the successful continuous replication progress.
1. Open **File Explorer** and navigate to **D:\\**. You should see a folder **Hyper-V Replica** – inside this folder Hyper-V creates all the replicas of VMs.

#### Task 4: Test planned failover

Perform these steps on HV1.

1. From the context menu of the VM **WS2019**, select **Replication**, **Planned Failover**.
1. Activate **Reverse the replication** and activate **start the replicated VM**. Try to perform a planned failover.

   > Can you perform a planned failover? Why or why not?

1. Shut-down **WS2019**.
1. From the context menu of the VM **WS2019**, select **Replication**, **Planned Failover**.
1. Activate **Reverse the replication** and activate **start the replicated VM**. Try to perform a planned failover.

   > Can you perform a planned failover now? Why or why not?

#### Task 5: Validate planned failover

Perform these steps on HV2.

1. Verify, that the VM **WS2019** has started and the replication is working.

#### Task 6: Simulate a failure

Perform these steps on the host computer or the hosting cloud service.

1. Turn off **HV2** to simulate a failure of HV2 (do not shut down!).

#### Task 7: Recover from a failure

Perform these steps on HV1.

1. On HV1 verify, that the VM **WS2019** is powered off. From the context menu of the VM **WS2019**, select **Replication** and click on **Failover**.
1. Select **Latest Recovery Point** and click on **Failover**.
1. Wait until the failover is finished and the VM is started.

[figure 1]: images/Lab05/figure01.png
[figure 2]: images/Lab05/figure02.png
[figure 3]: images/Lab05/figure03.png
[figure 4]: images/Lab05/figure04.png
[figure 5]: images/Lab05/figure05.png
[figure 6]: images/Lab05/figure06.png
[figure 7]: images/Lab05/figure07.png
[figure 8]: images/Lab05/figure08.png
[figure 9]: images/Lab05/figure09.png
[figure 10]: images/Lab05/figure10.png
[figure 11]: images/Lab05/figure11.png
[figure 12]: images/Lab05/figure12.png
[figure 13]: images/Lab05/figure13.png
[figure 14]: images/Lab05/figure14.png
[figure 15]: images/Lab05/figure15.png
[figure 16]: images/Lab05/figure16.png
[figure 17]: images/Lab05/figure17.png
[figure 18]: images/Lab05/figure18.png
[figure 19]: images/Lab05/figure19.png
[figure 20]: images/Lab05/figure20.png
[figure 21]: images/Lab05/figure21.png
[figure 22]: images/Lab05/figure22.png
[figure 23]: images/Lab05/figure23.png
[figure 24]: images/Lab05/figure24.png
[figure 25]: images/Lab05/figure25.png
[figure 26]: images/Lab05/figure26.png
[figure 27]: images/Lab05/figure27.png
[figure 28]: images/Lab05/figure28.png
[figure 29]: images/Lab05/figure29.png
[figure 30]: images/Lab05/figure30.png
