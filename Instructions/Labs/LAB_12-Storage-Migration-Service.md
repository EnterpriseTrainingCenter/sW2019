# Lab 12: Storage Migration Service

## Required VMs

* DC1
* DHCP
* Router
* FS on HV1
* SRV2008R2
* SRV2
* SRV1903
* CL1

## Exercises

1. [Configure Prerequisites](#exercise-1-configure-prerequisites)

## Exercise 1: Configure Prerequisites

### Introduction

In this exercise, you will prepare all systems for storage migration.

### Tasks

1. [Prepare for the lab](#)
1. [Configure prerequisites on the source server](#task-1-configure-prerequisites-on-the-source-server)
1. [Configure prerequisites on the destination server](#task-2-configure-prerequisites-on-the-destination-server)
1. [Configure the orchestrator server](#task-3-configure-the-orchestrator-server)

### Detailed Instructions

#### Task 1: Configure prerequisites on the source server

Perform these steps on SRV2008R2.

1. Logon as **smart\administrator**
1. From start menu, in **Administrative Tools**, open the **Windows Firewall with Advanced Security**.
1. Click **Inbound Rules**.
1. From the context menu of **Inbound Rules**, select **Filter by Profile/Filter by Domain Profiles**.
1. Make sure, necessary rules are enabled.
   * File and Printer Sharing (SMB-In)
   * Netlogon Service (NP-In)
   * Windows Management Instrumentation (WMI-In)
   * Windows Management Instrumentation (DCOM-In)

#### Task 2: Configure prerequisites on the destination server

Perform these steps on CL1.

1. Logon as **smart\administrator**
1. Start Google Chrome.
1. In Google Chrome, navigate to <https://admincenter.smart.etc>.
1. Add a server connection to server **SRV1903.smart.etc**
1. Open the connection to **SRV1903.smart.etc**.
1. Click on **Roles & Features**.
1. Install the **Storage Migration Service Proxy** feature. This will install all necessary components on SRV1903.
1. Click **Firewall**.
1. On the tab **Incoming rules**, make sure, necessary rules are enabled.
   * File and Printer Sharing (SMB-In)
   * Netlogon Service (NP-In)
   * Windows Management Instrumentation (WMI-In)
   * Windows Management Instrumentation (DCOM-In)

#### Task 3: Configure the orchestrator server

Perform these steps on CL1.

1. In **Windows Admin Center**, add a connection to server **FS.smart.etc**.
1. Connect to **FS.smart.etc**.
1. In the tree on the left, click **Firewall**.
1. On the tab **Incoming rules**, make sure, that the **File and Printer Sharing (SMB-In)** rule is enabled
1. In the tree click **Storage Migration Service**.
1. Click **Install** to install the storage migration service components.
1. After installation finished, activate checkbox **Don’t show this again**, and click **Close**.

## Exercise 2: Perform a migration

### Introduction

In this exercise, you will inventory the source server and start the transfer. After the data transfer, you configure settings on the destination server, validate the configuration, and finally cutover to the new server.

### Tasks

1. [Create an inventory](#task-1-create-an-inventory)
1. [Transfer data](#task-2-transfer-data)
1. [Cutover services](#task-3-cutover-services)
1. [Validate migration](#task-4-validate-migration)

### Detailed Instructions

#### Task 1: Create an inventory

Perform these steps on CL1.

1. In **Windows Admin Center**, connect to **SRV1903.smart.etc**.
1. Click on **Storage Migration Service**.
1. Click **New Job**.
1. In **Job name**, type **SRV2008R2Migration**, and click on **OK**.
1. On the page **Enter credentials for the devices you want to migrate**, enter the credentials for **smart\administrator**. Do not include administrative shares.
1. On the page **Add and scan devices**, click **Add a device** and specify **SRV2008R2** as source server ([figure 1]).
1. Click **Start Scan**. Wait for the scan to complete ([figure 2]). This will take while.
1. Click on **Succeeded**.
1. Check the result of the scan at the bottom of the screen ([figure 4]). Then, click **Next**.

#### Task 2: Transfer data

Perform these steps on CL1.

1. If offered, use stored credentials, otherwise enter the credentials for **smart\administrator**.
1. As destination device, add **SRV1903.smart.etc**, and click **Scan**.
1. On the page **Add a destination device and mappings for srv2008r2.smart.etc**, section **Volume**, from the dropdown, select **C:** as destination volume for the migration ([figure 5]).
1. On the page **Adjust transfer settings**, in **Validation method (checksum) for transmitted files**, select **CRC64** ([figure 6]).
1. In the section **Migrate users and groups** section, select **Don't transfer users and groups**.
1. On the page **Validate source and destination devices**, click **Validate**.
1. Make sure the validation passed, then click on **Pass** ([figure 7]) to show the result of the validation check ([figure 8]).
1. Close the result screen, and click **Next**.
1. On the page **Start the transfer**, click on **Start Transfer**. This should only take a few minutes.
1. After the transfer finished, click on **Succeede** to open the details section at the bottom.
1. Click on **Transfer log**, and then click **Open** to open logfile in Excel.

#### Task 3: Cutover services

Perform these steps on CL1.

1. Click **Next**
1. If offered, use stored credentials, otherwise enter the **smart\administrator** credentials.
1. On the page **Configure cutover from…**, configure settings for the cutover ([figure 9]).
   * Enable the checkbox **Use DHCP**.
   * Select the network adapter **Ethernet** on the destination server.
   * Rename the source server to **SRV2008R2-OLD** after the cutover.
1. On the page **Adjust cutover settings**, leave the defaults.
1. On the **Validate source and destination devices** page click **Validate**.
1. Make sure the validation passed, then click on **Pass** to show the result of the validation check.
1. On the page **Cut over to the new servers**, click **Start cutover**. Wait for the cutover to complete. Review the status in the **State** column ([figure 11]).
1. After the cutover succeeded click **Finish**.
1. Select the **SRV2008R2Migration** job and click **Remove selected**. Confirm the deletion.
1. Click **Start/Run**
1. Enter the UNC Path **\\SRV2008R2** and press Enter. You should see all the file shares that were migrated.

#### Task 4: Validate migration

Perform these steps on SRV1903 (now SRV2008R2).

1. Logon as **smart\administrator**.
1. Open **File Explorer**.
1. On folder **D:\Data\HR**, open the properties.
1. Make sure it is shared as **HR** and that share and NTFS permissions exist.
   * **Perm_HR_FC**: Full Control
   * **Perm_HR_M**: Modify
   * **Perm_HR_R**: Read and Execute

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
