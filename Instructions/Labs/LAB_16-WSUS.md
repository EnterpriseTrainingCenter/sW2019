# Lab 16: WSUS

## Required VMs

* CL1
* DC1
* DHCP
* Router
* NET1

## Exercises

1. [Patch Management with WSUS](#exercise-1-patch-management-with-wsus)

## Exercise 1: Patch management with WSUS

### Introduction

In this exercise, you will create a patch management solution with Windows Server Update Services (WSUS) and approve and download some updates to your Windows Client machines.

### Tasks

1. [Install and configure WSUS](#task-1-install-and-configure-wsus)
1. [Configure the Environment for WSUS](#task-2-configure-the-environment-for-wsus)
1. [Install updates using WSUS](#task-3-install-updates-using-WSUS)
1. [Generate Windows Update logs on a client](#task-4-generate-windows-update-logs-on-a-client)
1. [View the client status in WSUS](#task-5-view-the-client-status-in-WSUS)

### Detailed Instructions

#### Task 1: Install and configure WSUS

Perform these steps on NET1.

1. Logon as **smart\administrator**
1. Install the WSUS server role in Server Manager.
   * **Role Services**: **WID Connectivity**, **WSUS Services**
   * **Content location**: D:\WSUS
1. After installing completed successfully, start the post-installation task ([figure 1]). This may take a while.
1. Open the WSUS console from start menu.
1. Complete the configuration wizard.
   * **Upstream Server**: Synchronize from Microsoft Update
   * No Proxy
   * Start Connecting
   * **Languages**: English
   * **Products**: Windows 10 Version 1903
   * **Classifications**: Critical Updates
   * Synchronize manually

   > What languages, products, and classifications would you select in a production environment?

1. After the wizard is finished, click **Begin Initial Synchronization**.
1. In the **WSUS Console**, select **NET1**.
1. You can track the sync progress ([figure 2]). Do not wait for the initial sync to complete.
1. Expand the console tree to **NET1**, **Options**
1. Double-click on **Computers**.
1. Select **Use Group Policy or registry settings on computers** and click on **OK**.
1. Expand the console tree to **NET1**, **Computers**, **All Computers**.
1. From the context menu of **All Computers**, select **Add Computer Group…** ([figure 3]).
1. Create a new group with the name **Clients**.
1. Expand the console tree to **All Updates**.
1. Customize the view to show any unapproved updates ([figure 4]).
1. Add the **Release Date** column to the view. Then, sort the view by release date ([figure 5]).
1. From the context menu of the latest update, select **Approve** ([figure 6]).
1. In the **Approve Updates** dialog, approve the update only for the Clients computer group ([figure 7]).
1. WSUS will download the update now, you can track the download via the **Server Status** page.

#### Task 2: Configure the Environment for WSUS

Perform these steps on DC1.

1. On DC1 open the **DNS Management Console**.
1. In the zone **smart.etc**, add a new **A** record.

   * **Name:** Wsus
   * **IP Address:** 10.1.1.70

1. Open **Group Policy Management Console**.
1. From the context menu of the domain **smart.etc**, select **Create a GPO in this domain and Link it here...** ([figure 8]).
1. Name the GPO **WSUS Clients**.
1. Click on **smart.etc**
1. In the work pane select the tab **Linked Group Policy Objects**.
1. Select the GPO **WSUS clients**, and click the arrow up button to reorder it to **Link Order** **2** ([figure 9]).
1. Edit the GPO and navigate to **Computer Configuration**, **Policies**, **Administrative Templates**, **Windows Components**, **Windows Update**.
1. Enable the setting **Configure Automatic Updates**.

   * **Configure automatic updating:** **4 – Auto download and schedule the install**
   * **Scheduled install time:** 16:00

1. Enable the setting **Enable client-side targeting** with a value of **Clients**. This is the name of the group, you created in the previous task.
1. Enable the setting **Specify intranet Microsoft updates service location**.

   * **Intranet update service for detecting updates:** <http://wsus.smart.etc:8530>
   * **Intranet statistics server:** <http://wsus.smart.etc:8530>

1. Navigate to **Computer Configuration**, **Windows Settings**, **Security Settings**, **System Services**
1. Double-click on the service entry **Windows Update**.
1. Activate **Define this policy settings**, and set the service startup mode to **Automatic**.

#### Task 3: Install updates using WSUS

Perform these steps on CL1.

1. Open **Command Prompt**.
1. Force a group policy update.

   ````shell
   gpupdate /force
   ````

1. In the **Settings** app, open **Updates and Security**, and click **Search for updates**.
1. Depending on the current patch status of your VM, the selected update may show up and you can install it ([figure 10]).
1. Install the desired update and reboot if necessary.

#### Task 4: Generate Windows Update logs on a Client

Perform these steps on CL1.

1. Run **Windows PowerShell** as Administrator
1. Generate the Windows Upate log ([figure 11]).

   ````powershell
   Get-WindowsUpdateLog
   ````

1. Use Notepad to open the logfile.
1. Find the Windows Update process you initiated ([figure 12]).

#### Task 5: View the client status in WSUS

Perform these steps on NET1.

1. In the WSUS console, expand **NET1**, **Computers**, **All Computers**, **Clients**
1. Select **Any** from the list of filters and refresh the view. CL1 shoud be shown in the list ([figure 13]).

[figure 1]: images/Lab16/figure01.png
[figure 2]: images/Lab16/figure02.png
[figure 3]: images/Lab16/figure03.png
[figure 4]: images/Lab16/figure04.png
[figure 5]: images/Lab16/figure05.png
[figure 6]: images/Lab16/figure06.png
[figure 7]: images/Lab16/figure07.png
[figure 8]: images/Lab16/figure08.png
[figure 9]: images/Lab16/figure09.png
[figure 10]: images/Lab16/figure10.png
[figure 11]: images/Lab16/figure11.png
[figure 12]: images/Lab16/figure12.png
[figure 13]: images/Lab16/figure13.png
