# Lab: WSUS

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

In this exercise, you will install and configure WSUS on NET1, approve an update, add a DNS record for WSUS, and add a Group Policy Object to the domain, which configures clients to use NET1 for Windows Updates. Then, you will install updates on CL1 using WSUS, generate Windows Update logs on the client and view the status of the client in WSUS.

#### Tasks

1. [Install and configure WSUS](#task-1-install-and-configure-wsus)
1. [Configure the Environment for WSUS](#task-2-configure-the-environment-for-wsus)
1. [Install updates using WSUS](#task-3-install-updates-using-WSUS)
1. [Generate Windows Update logs on a client](#task-4-generate-windows-update-logs-on-a-client)
1. [View the client status in WSUS](#task-5-view-the-client-status-in-WSUS)

### Task 1: Install and configure WSUS

#### Desktop Experience

Perform these steps on NET1.

1. Logon as **smart\administrator**
1. In **Server Manager**, install the WSUS server role.
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

#### PowerShell

Perform these steps on NET1.

1. Logon as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Install the WSUS server role.

   ````powershell
   # The back tick ` can be used to split long command lines and make them more readable
   Install-WindowsFeature `
      -Name UpdateServices, UpdateServices-Services, UpdateServices-WidDB `
      -IncludeManagementTools
   ````

1. Start the post-installation task.

   ````powershell
   Set-Location 'C:\Program Files\Update Services\Tools'
   .\WsusUtil.exe postinstall CONTENT_DIR=D:\WSUS
   ````

1. Set the upstream server to Microsoft Update.

   ````powershell
   Set-WsusServerSynchronization –SyncFromMU
   ````

1. Synchronize English only.

   ````powershell
   $wsus = Get-WSUSServer
   $wsusConfig = $wsus.GetConfiguration()
   $wsusConfig.AllUpdateLanguagesEnabled = $false
   $wsusConfig.SetEnabledUpdateLanguages("en")
   $wsusConfig.Save()
   ````

1. Perform initial synchronization.

   ````powershell
   $subscription = $wsus.GetSubscription()
   $subscription.StartSynchronizationForCategoryOnly()
   ````

1. Wait for the synchronization to complete. Repeat the command until it returns **NotProcessing**. This will take some time.

   ````powershell
   $subscription.GetSynchronizationStatus()
   ````

1. Configure WSUS to synchronize Windows 10 1903 updates only.

   ````powershell
   Get-WsusProduct | Set-WsusProduct -Disable
   $wsusProduct = Get-WsusProduct | 
      Where-Object { $PSItem.Product.Title -like 'Windows 10, version 1903*' }
   $wsusProduct | Set-WsusProduct
   ````

1. List the available classifications and find the name of the classification for security updates (e. g. Sicherheitsupdates for German).

   ````powershell
   Get-WsusClassification
   ````

1. Configure WSUS to synchronize security updates only. Replace Sicherheitsupdates with the title, you took note of in the previous step, if required.

   ````powershell
   Get-WsusClassification | Set-WsusClassification -Disable
   $wsusClassification = Get-WsusClassification |
      Where-Object { $PSItem.Classification.Title -eq 'Sicherheitsupdates' }
   Set-WsusClassification -Classification $wsusClassification
   ````

1. Configure WSUS to synchronize manually only.

   ````powershell
   $subscription.SynchronizeAutomatically = $false
   $subscription.Save()
   ````

   > What languages, products, and classifications would you select in a production environment?

1. Start the initial synchronization.

   ````powershell
   $subscription.StartSynchronization()
   ````

1. You can track the sync progress. Do not wait for the initial sync to complete.

   ````powershell
   $subscription.GetSynchronizationStatus()
   ````

1. Expand the console tree to **NET1**, **Options**
1. Double-click on **Computers**.
1. Configure WSUS to use Group Policy or registry settings on computers.

   ````powershell
   $wsusConfig.TargetingMode = 'Client'
   $wsusConfig.Save()
   ````

1. Create a new group with the name **Clients**.

   ````powershell
   $targetGroupName = 'Clients'
   $wsus.CreateComputerTargetGroup($targetGroupName)
   ````

1. Show any unapproved updates.

   ````powershell
   $wsusUpdate = Get-WsusUpdate -Approval Unapproved
   $wsusUpdate
   ````

1. Sort the updates by release date.

   ````powershell
   <#
   Some properties of the WSUS updates are not exposed directly, but rather
   properties of the embedded update object. To expose them, calculated
   properties can be used. These are written as hash tables with the syntax
   @{ n = 'Name of the new Property', e = { <Expression> } }.
   #>
   $wsusUpdate |
   Select-Object `
      *, `
      @{ n = 'Title'; e = {$PSItem.Update.Title}}, `
      @{ n = 'CreationDate'; e = { $PSItem.Update.CreationDate } } |
   Sort-Object CreationDate -Descending |
   Format-Table Title, CreationDate
   ````

1. Approve the latest update for the Clients computer group only.

   ````powershell
   $updateId = $wsusUpdate |
      Select-Object `
         UpdateId, `
         @{ n = 'CreationDate'; e = { $PSItem.Update.CreationDate } } |
      Sort-Object CreationDate -Descending |
      Select-Object -ExpandProperty UpdateId -First 1
   
   Get-WsusUpdate -UpdateId $updateId |
   Approve-WsusUpdate -Action Install -TargetGroupName $targetGroupName
   ````

### Task 2: Configure the Environment for WSUS

#### Desktop Experience

Perform these steps on DC1.

1. Logon as smart\Administrator.
1. On DC1 open the **DNS Management Console**.
1. In the zone **smart.etc**, add a new **A** record.

   * **Name:** Wsus
   * **IP Address:** 10.1.1.70

1. Open **Group Policy Management Console**.
1. In **Group Policy Management**, expand **Forest: smart.etc**, **Domains**, **smart.etc**.
1. In the context-menu of the domain **smart.etc**, click **Create a GPO in this domain and Link it here...** ([figure 8]).
1. In **New GPO**, in **Name:**, type **WSUS Clients**, and click **OK**.
1. Click on **smart.etc**
1. In the work pane select the tab **Linked Group Policy Objects**.
1. Select the GPO **WSUS clients**, and click the arrow up button to reorder it to **Link Order** **2** ([figure 9]).
1. In the context-menu of the GPO **WSUS Clients**, click **Edit**.
1. In the **Group Policy Management Editor**, navigate to **Computer Configuration**, **Policies**, **Administrative Templates**, **Windows Components**, **Windows Update**.
1. Double-click **Configure Automatic Updates**.
1. In **Configure Automatic Updates**, click **Enabled** and set the **Options:**. Then click **OK**.

   * **Configure automatic updating:** **4 – Auto download and schedule the install**
   * **Scheduled install time:** 16:00

1. Double-click **Enable client-side targeting**.
1. In **Enable client-side targeting**, click **Enabled**. In **Target group name for this computer**, type **Clients**. This is the name of the group, you created in the previous task. Click **OK**.

1. Double-click **Specify intranet Microsoft updates service location**.
1. In **Specify intranet Microsoft updates service location**, click **Enabled** and set the **Options:**. Then click **OK**.

   * **Intranet update service for detecting updates:** <http://wsus.smart.etc:8530>
   * **Intranet statistics server:** <http://wsus.smart.etc:8530>

1. Navigate to **Computer Configuration**, **Windows Settings**, **Security Settings**, **System Services**
1. Double-click on the service entry **Windows Update**.
1. Activate **Define this policy settings**, and set the service startup mode to **Automatic**.

#### Powershell

Perform these steps on DC1.

1. Logon as smart\Administrator.
1. Run **Windows PowerShell** as Administrator.
1. In the zone **smart.etc**, add a new **A** record for Wsus pointing to 10.1.1.70.

   ````powershell
   Add-DnsServerResourceRecordA `
      -Name wsus `
      -IPv4Address 10.1.1.70 `
      -ZoneName smart.etc
   ````

1. Create a new GPO with then name WSUS Clients

   ````powershell
   $gpo = New-GPO -Name 'WSUS Clients'
   $gpo
   ````

1. Link the new GPO to the domain.

   ````powershell
   $target = 'dc=smart, dc=etc'
   $gpLink = $gpo | New-GPLink -Target $target
   
   Get-GPInheritance -Target $target | 
   Select-Object -ExpandProperty gpolinks | 
   Format-Table
   ````

1. Set the link order of the new GPO to 2.

   ````powershell
   $gpLink | Set-GPLink -Order 2
   ````

1. Configure automatic updates to automatic download and scheduled install every day at 4 pm.

   ````powershell
   $key = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
   $gpo | Set-GPRegistryValue `
      -Key "$key\AU" `
      -ValueName 'NoAutoUpdate' `
      -Type DWord `
      -Value 0
   $gpo | Set-GPRegistryValue `
      -Key "$key\AU" `
      -ValueName 'AUOptions' `
      -Type DWord `
      -Value 4
   $gpo | Set-GPRegistryValue `
      -Key "$key\AU" `
      -ValueName 'ScheduledInstallDay' `
      -Type DWord `
      -Value 0
   $gpo | Set-GPRegistryValue `
      -Key "$key\AU" `
      -ValueName 'ScheduledInstallTime' `
      -Type DWord `
      -Value 16
   ````

1. Enable client-side targeting and set the group to Clients. This is the name of the group, you created in the previous task.

   ````powershell
   $gpo | Set-GPRegistryValue `
      -Key $key `
      -ValueName 'TargetGroupEnabled' `
      -Type DWord `
      -Value 1
   $gpo | Set-GPRegistryValue `
      -Key $key `
      -ValueName 'TargetGroup' `
      -Type String `
      -Value 'Clients'
   ````

1. Enable the use of an internal WU server and set the address.

   ````powershell
   $gpo | Set-GPRegistryValue `
      -Key "$key\AU" `
      -ValueName 'UseWUServer' `
      -Type DWord `
      -Value 1
   $gpo | Set-GPRegistryValue `
      -Key $key `
      -ValueName 'WUServer' `
      -Type String `
      -Value 'http://wsus.smart.etc:8530'
   $gpo | Set-GPRegistryValue `
      -Key $key `
      -ValueName 'WUStatusServer' `
      -Type String `
      -Value 'http://wsus.smart.etc:8530'
   ````

1. Open **Group Policy Management Console**.
1. In **Group Policy Management**, expand **Forest: smart.etc**, **Domains**, **smart.etc**.
1. In the context-menu of the GPO **WSUS Clients**, click **Edit**.
1. In the **Group Policy Management Editor**, navigate to **Computer Configuration**, **Windows Settings**, **Security Settings**, **System Services**.
1. Double-click on the service entry **Windows Update**.
1. Activate **Define this policy settings**, and set the service startup mode to **Automatic**.

### Task 3: Install updates using WSUS

Perform these steps on CL1.

1. Open **Command Prompt**.
1. Force a group policy update.

   ````shell
   gpupdate
   ````

1. In the **Settings** app, open **Updates and Security**, and click **Search for updates**.
1. Depending on the current patch status of your VM, the selected update may show up and you can install it ([figure 10]).
1. Install the desired update and reboot if necessary.

### Task 4: Generate Windows Update logs on a Client

Perform these steps on CL1.

1. Run **Windows PowerShell** as Administrator
1. Generate the Windows Upate log ([figure 11]).

   ````powershell
   Get-WindowsUpdateLog
   ````

1. Use Notepad to open the logfile.
1. Find the Windows Update process you initiated ([figure 12]).

### Task 5: View the client status in WSUS

#### Desktop Experience

Perform these steps on NET1.

1. In the WSUS console, expand **NET1**, **Computers**, **All Computers**, **Clients**
1. Select **Any** from the list of filters and refresh the view. CL1 should be shown in the list ([figure 13]).

#### PowerShell

1. In **Windows PowerShell**, list the clients synchronizing with WSUS. CL1 should be shown in the list.

   ````powershell
   Get-WsusComputer
   ````

[figure 1]: images/WSUS-installation-progress.png
[figure 2]: images/WSUS-overview.png
[figure 3]: images/WSUS-group-add.png
[figure 4]: images/WSUS-filter-status-any.png
[figure 5]: images/WSUS-columns-select-release-date.png
[figure 6]: images/WSUS-approve-updates.png
[figure 7]: images/WSUS-approve-updates-group-clients.png
[figure 8]: images/GPO-create-and-link-domain.png
[figure 9]: images/WSUS-linked-gpo-objects.png
[figure 10]: images/WU-updates-available.png
[figure 11]: images/WSUS-get-windowsupdatelog-response.png
[figure 12]: images/WSUS-log.png
[figure 13]: images/WSUS-group-clients.png
