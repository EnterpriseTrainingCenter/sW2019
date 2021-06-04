# Lab 12: Storage Migration Service

## Required VMs

* CL1
* DC1
* DHCP
* Router
* FS on HV1
* SRV2008R2
* SRV2
* SRV1903

## Exercises

1. [Configure Prerequisites](#exercise-1-configure-prerequisites)
1. [Perform a migration](#exercise-2-perform-a-migration)]

## Exercise 1: Configure Prerequisites

### Introduction

The goal for this lab is to migrate the file shares from WS2008R2 to FS. In this exercise, you will install the Storage Migration Service Proxy on FS and the Storage Migration Service on SRV1903, which will act as an orchestrator server during the migration.

#### Tasks

1. [Configure prerequisites on the destination server](#task-1-configure-prerequisites-on-the-destination-server)
1. [Configure the orchestrator server](#task-2-configure-the-orchestrator-server)

### Task 1: Configure prerequisites on the destination server

Perform these steps on CL1.

1. Logon as **smart\administrator**
1. Start Google Chrome.
1. In Google Chrome, navigate to <https://admincenter.smart.etc>.
1. Add a server connection to server **FS.smart.etc**
1. Open the connection to **FS.smart.etc**.
1. Click on **Roles & Features**.
1. Install the **Storage Migration Service Proxy** feature. This will install all necessary components on FS.

*Note:*

These steps should not be necessary. Although the Storage Migration Service should install all necessary features automatically, due to a bug, it is necessary to install the Storage Migration Service Proxy feature as a prerequisite, otherwise the validation during the phase **Transfer data** will generate a warning. It is possible to work round the warning by going back to **Inventory servers** and scan the source server again. However, in real world, this can take hours.

### Task 2: Configure the orchestrator server

Perform these steps on CL1.

1. In **Windows Admin Center**, add a connection to server **SRV1903.smart.etc**.
1. Connect to **SRV1903.smart.etc**.
1. In the tree on the left, click **Storage Migration Service**.
1. Click **Install** to install the storage migration service components.

## Exercise 2: Perform a migration

### Introduction

In this exercise, you will inventory the source server WS2008R2 and start the transfer to FS. After the data transfer, you configure settings on the destination server, validate the configuration, and finally cutover to the new server. As a last step, you will validate the migration.

#### Tasks

1. [Create an inventory](#task-1-create-an-inventory)
1. [Transfer data](#task-2-transfer-data)
1. [Cutover services](#task-3-cutover-services)
1. [Validate migration](#task-4-validate-migration)

### Task 1: Create an inventory

Perform these steps on CL1.

1. In **Windows Admin Center**, connect to **SRV1903.smart.etc**.
1. Click on **Storage Migration Service**.
1. Click **New Job**.
1. In **Job name**, type **SRV2008R2Migration**, make sure, **Windows servers and clusters is selected**, and click on **OK**.
1. On the page **Enter credentials**, enter the credentials for **smart\administrator**. Deactivate the checkboxes **Include administrative shares** and **Migrate from failover clusters**.
1. On the page **Add and scan devices**, click **Add a device**. In **Name**, type **SRV2008R2** ([figure 1]), and click **Add**.
1. Click **Start Scan**. Wait for the scan to complete ([figure 2]). This will take while.
1. Click on **Succeeded**.
1. Check the result of the scan at the bottom of the screen ([figure 4]). Then, click **Next**.

### Task 2: Transfer data

Perform these steps on CL1.

1. On page **Enter credentials**, if offered, use stored credentials, otherwise enter the credentials for **smart\administrator**.
1. On page **SRV2008R2.smart.etc**, make sure **Use an existing server or VM** is selected. In **Destination device**, type **fs.smart.etc**, and click **Scan**.
1. After the scan has completed, under **Map each source volume to a destination volume**, in column **Destination volume**, make sure, **C:** is selected ([figure 5]).
1. Under **Select the shared to transfer**, in column **Include in transfer**, make sure, the checkbox for each share is activated.
1. On page **Adjust settings**, in **Validation method (checksum) for transmitted files**, select **CRC64** ([figure 6]).
1. On page **Validate devices**, click **Validate**.
1. Make sure the validation passed, then click on **Pass** ([figure 7]) to show the result of the validation check ([figure 8]).
1. Close the result screen, and click **Next**.
1. On the page **Start the transfer**, click on **Start Transfer**. This should only take a few minutes.
1. After the transfer finished, click on **Succeeded** to open the details section at the bottom.
1. At the bottom pane, click **Transfer detail**.
1. Click on **Transfer log**, and open the logfile in Excel.

### Task 3: Cutover services

Perform these steps on CL1.

1. On page **Start the trasnfer**, click **Next** or, at the top, click **Cut over to the new servers**.
1. On page **Enter credentials**, if offered, use **Stored credentials**, otherwise enter the **smart\administrator** credentials.
1. On the page **srv2008r2.smart.etc**, configure settings for the cutover ([figure 9]).
   * Enable the checkbox **Use DHCP**.
   * Select the network adapter **Datacenter1** on the destination server.
   * Select **Chose a new name**.
   * In **New source computer name**, enter **SRV2008R2-OLD**.
1. On the page **Adjust settings**, leave the defaults.
1. On the **Validate devices** page click **Validate**.
1. Make sure the validation passed, then click on **Pass** to show the result of the validation check.
1. On the page **Start the cutover**, click **Start cutover**. Wait for the cutover to complete. Review the status in the **State** column ([figure 11]).
1. After the cutover succeeded click **Finish**.
1. Select the **SRV2008R2Migration** job and click **Remove selected**. Confirm the deletion.
1. Click **Start/Run**
1. Enter the UNC Path **\\SRV2008R2** and press Enter. You should see all the file shares that were migrated.

### Task 4: Validate migration

Perform these steps on FS (now SRV2008R2).

1. Logon as **smart\administrator**.
1. Open **File Explorer**.
1. On folder **D:\Data\HR**, open the properties.
1. Make sure it is shared as **HR** and that the following share and NTFS permissions exist.

   | Principal      | Permission       |
   | -------------- | ---------------- |
   | **PERM_HR_FC** | Full Control     |
   | **PERM_HR_M**  | Modify           |
   | **PERM_HR_R**  | Read and Execute |

[figure 1]: images/Lab12/figure01.png
[figure 2]: images/Lab12/figure02.png
[figure 3]: images/Lab12/figure03.png
[figure 4]: images/Lab12/figure04.png
[figure 5]: images/Lab12/figure05.png
[figure 6]: images/Lab12/figure06.png
[figure 7]: images/Lab12/figure07.png
[figure 8]: images/Lab12/figure08.png
[figure 9]: images/Lab12/figure09.png
[figure 10]: images/Lab12/figure10.png
[figure 11]: images/Lab12/figure11.png
