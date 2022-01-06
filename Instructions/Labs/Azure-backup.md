# Lab: Azure Backup

## Required VMs

* DC1
* DHCP
* Router
* SRV2
* CL1
* FS on HV1

## Exercises

1. [Preparing the Azure environment (Optional)](#exercise-1-preparing-the-azure-environment-optional)
1. [Configure the backup infrastructure](#exercise-2-configure-the-backup-infrastructure)
1. [Back up data](#exercise-3-back-up-data)
1. [Restore data](#exercise-4-restore-data)

## Exercise 1: Preparing the Azure environment (Optional)

### Introduction

In this exercise you may install the Azure PowerShell modules and create a resource group.

#### Tasks

1. [Install PowerShell modules for Azure (Optional)](#task-1-install-powershell-modules-for-azure-optional)
2. [Create a Resource Group (Optional)](#task-2-create-a-resource-group-optional)

### Task 1: Install PowerShell modules for Azure (Optional)

*Note:* This task is only required, if you plan to use PowerShell to administer Azure and do not have installed the modules in an earlier lab.

Perform these steps on FS.

1. Sign in as **smart\Administrator**.
1. Open **Windows PowerShell**.
1. Install the latest version of the Azure PowerShell package in the scope of the current user.

    ````powershell
    Install-Package -Name Az
    ````

    Confirm all prompts.

    This will take a few minutes.

### Task 2: Create a Resource Group (Optional)

*Note:* Perform this task only, if you are using your own Azure account. With a shared Azure account, you will not have the permissions to perform this task.

#### Desktop experience

Perform these steps on FS.

1. Sign in as **smart\Administrator**.
1. Open **Google Chrome**.
1. In Google Chrome, navigate to **http://portal.azure.com**.
1. Sign in with your Azure credentials.
1. At the top-left, click the hamburger menu ([figure 1]) and click **Create a resource**.
1. In **Search services and marketplace**, type **resource group**. When **Resource Group** appears below the input field, click on it.
1. On page **Resource Group** ([figure 2]), click **Create**.
1. On tab **Basics**, in **Subscription**, select the subscription, you want to use for this lab. In **Resource group**, enter **Recovery-** followed by your user name, e.g. *Recovery-Susi*. In **Region** select a region close to you, e. g. **North Europe**. Click **Review + create**.

    Your instructor will advise you selecting an appropriate region.

1. On tab **Review + create**, if validation passed, click **Create**.

#### PowerShell

Perform these steps on FS.

*Note:* To perform this task, the installation of task 1 must be completed.

1. In **Windows PowerShell**, connect to you Azure account.

    ````powershell
    Connect-AzAccount
    ````

1. Logon with your Azure credentials.
1. List your Azure subscriptions.

    ````powershell
    Get-AzSubscription
    ````

    *Note:* If only one subscription gets listed, you can skip the next two steps.

1. Copy the **Id** of the Azure subscription, you want to use for this lab, to the clipboard.
1. Select the Azure subscription.

    ````powershell
    <# 
        Replace the SubscriptionId parameter value with the Id you copied to the
        clipboard.
    #>
    Select-AzSubscription -SubscriptionId 00000000-0000-0000-0000-000000000000
    ````

1. Create a resource group with the name **Recovery-** followed by your user name.

    ````powershell
    $resourceGroupName = 'Recovery-' # append your user name
    $resourceGroup = New-AzResourceGroup `
        -Name $resourceGroupName `
        -Location northeurope # You can replace the location, if you want.
    ````

## Exercise 2: Configure the backup infrastructure

### Introduction

In this exercise, you will first create a Recovery Service Vault in Azure. Then, you will register FS with the Backup Vault and enable bandwidth throttling with 1 MB/s during business hours and 10 MB/s outside of business hours. Finally, you will verify the server registration in Azure.

#### Tasks

1. [Create a Recovery Service Vault](#task-1-create-a-recovery-service-vault)
1. [Register a server with the Backup Vault](#task-2-register-a-server-with-the-backup-vault)
1. [Enable bandwidth throttling](#task-3-enable-bandwidth-throttling)
1. [Verify the backup infrastructure in Azure](#task-4-verify-the-backup-infrastructure-in-azure)

### Task 1: Create a Recovery Service Vault

#### Desktop experience

Perform these steps on FS.

1. Sign in as **smart\Administrator**.
1. Open **Google Chrome**.
1. In Google Chrome, navigate to **http://portal.azure.com**.
1. Logon with your Azure credentials.
1. At the top-left, click the hamburger menu ([figure 1]) and click **Create a resource**.
1. In **Search services and marketplace**, type **backup and site recovery**. When **Backup and Site Recovery** appears below the input field, click on it.
1. On page **Backup and Site Recovery** ([figure 2]), click **Create**.
1. On page **Create Recovery Services vault**, in **Subscription**, select your subscription. In **Resource Group**, select **Recovery-** followed by your user name, e.g. *Recovery-Susi*. In **Vault name** type **backup-vault-** and append your user name. In **Region** select a region close to you. Click **Review + Create**.
1. On tab **Review + Create** ([figure 3]), click **Create**.

    Wait for the deployment to complete.

1. On the deployment page, click **Go to resource**.
1. On the page **backup-vault-** followed by your user name, under **Settings**, click **Properties**.
1. In Properties, under **Backup**, **Security Settings**, click the link **Update**.1
1. In pane **Security Settings**, under **Soft Delete**, click **Disable**. Under **Security Features**, click **Disable**. Near the top, click **Save**.

    *Note:** In a real-world scenario, you would not disable these settings.

1. Close the pane **Security Settings**.

#### PowerShell

Perform these steps on FS.

1. Sign in as **smart\Administrator**.
1. Open **Windows PowerShell**.
1. In **Windows PowerShell**, connect to you Azure account.

    ````powershell
    Connect-AzAccount
    ````

1. Logon with your Azure credentials.
1. List your Azure subscriptions.

    ````powershell
    Get-AzSubscription
    ````

    *Note:* If only one subscription gets listed, you can skip the next two steps.

1. Copy the **Id** of the Azure subscription, you want to use for this lab, to the clipboard.
1. Select the Azure subscription.

    ````powershell
    <# 
        Replace the SubscriptionId parameter value with the Id you copied to the
        clipboard.
    #>
    Select-AzSubscription -SubscriptionId 00000000-0000-0000-0000-000000000000
    ````

1. In resource group **Recovery-** followed by your user name, create a recovery services vault with the name **backup-vault-** followed by your user name.

    ````powershell
    $resourceGroupName = 'Recovery-' # append your user name
    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName

    $recoveryServicesVault = New-AzRecoveryServicesVault `
        -ResourceGroupName $resourceGroupName `
        -Name 'backup-vault-' ` # append your user name
        -Location $resourceGroup.Location
    ````

1. Disable the soft delete feature in the Recovery Services vault.

    ````powershell
    Set-AzRecoveryServicesVaultProperty `
        -VaultId $recoveryServicesVault.ID `
        -SoftDeleteFeatureState Disable
    ````

    *Note:** In a real-world scenario, you would not disable these settings.

    *Note:** Currently it is not possible to update the enhanced security state using PowerShell.

### Task 2: Register a server with the Backup Vault

#### Desktop experience

Perform these steps on FS.

1. On the blade **backup-vault-** followed by your user name, under **Getting started**, click **Backup**.
1. In Backup, under **Where is your workload running?**, select **On-Premises**. Under **What do you want to backup?**, activate **Files and folders**. Click **Prepare infrastructure**.
1. On page Prepare infrastructure, click the link **Download Agent for Windows Server or Windows Client**.
1. Activate the checkbox **Already downloaded or using the latest Recovery Services Agent**. The button **Download** gets activated. Click the button **Download**.
1. Click on the downloaded file **MARSAgentinstaller.exe**.
1. In **Open File - Security Warning**, click **Run**.
1. In **Microsoft Azure Recovery Services Agent Setup Wizard**, proceed through the installation accepting the default values.
1. After installation has completed, click **Proceed to Registration**.
1. In **Register Server Wizard**, on page **Valut Identification**, click **Browse**.
1. From **Downloads**, open **VaultCredentials** file you downloaded during this task.

1. Back on page Vauld Identification, verify the **Backup Vault** and **Region**. They should match your Recovery Services Vault. Click **Next >**.
1. On page **Ecryption Settings**, click **Generate Passphrase**. Under **Enter a location to save the passphrase**, enter **D:\\**. Click **Finish**.
1. In the warning message, telling that you should not save the passphrase locally, click **Yes**.

    *Note:* In a real-world scenario you should store the file in a secure and reliable location.

1. After successful registration, click **Close**.

    Microsoft Azure Backup opens automatically.

#### Windows Admin Center

Perform these steps on CL1.

1. Sign in as **smart\Administrator**.
1. Open **Google Chrome**.
1. In Google Chrome, navigate to **https://admincenter.smart.etc**.
1. In Windows Admin Center, connect to **FS.smart.etc**.
1. Connected to FS.smart.etc, under **Tools**, click **Services**.
1. In Services, click **wuauserv** (**Windows Update**).
1. In the toolbar, click **Settings**.
1. In wuauserv Settings, in **Set Startup Mode**, select **Automatic** and click **Save**.
1. Click **Close**.
1. Back in Services, wuauserv still selected, in the toolbar, click **Start**.
1. Under **Tools**, click **Azure Backup**.
1. Under **Welcome to Azure Backup**, click **Set up Azure Backup**.
1. If necessary, under **Step 1: Login into Microsoft Azure portal**, login.
1. Beside **Step 2: Set up Azure Backup**, click **Show details**. Make the selections to use the Backup Vault you created in the previous exercise.
1. Under **Step 3: Select Backup Items and Schedule**, activate D:\

    Unfortunately, in Windows Admin Center, it is not possible to select single folders. But you can customize the selection in Microsoft Azure Backup, after the configuration in Windows Admin Center.

1. Under **Files and Folder Schdeule**, select **Daily, retain 6 months**.

    Again, more detailed selection can be done in Microsoft Azure Backup, afterwards.

1. Under **Step 4: Enter Encryption Passphrase**, in **Encryption passphrase** and **Confirm passphrase** enter a secure passphrase.

    *Important:* Take a note of the passphrase. You may need it for recovery.

1. Click **Apply**.

#### PowerShell

Perform these steps on FS.

1. Download the Microsoft Azure Recovery Services agent from **https://aka.ms/Azurebackup_Agent**.

    ````powershell
    $path = 'C:\MARS'
    $filePath = Join-Path -Path $path -ChildPath 'MARSAgentInstaller.exe'
    New-Item -Path $path -ItemType Directory
    Start-BitsTransfer `
        -Source 'https://aka.ms/Azurebackup_Agent' `
        -Destination $filePath
    ````

1. Install the Microsoft Azure Recovery services agent.

    ````powershell
    <# 
        The /nu switch disables updates and is necessary if Windows Update is
        disabled. Otherwise, setup will fail.
    #>
    Start-Process -FilePath $filePath -ArgumentList '/q /nu' -Wait
    ````

1. Download the Vault Settings file.

    ````powershell
    # We need to generate a simple certificate for encryption
    $cert = New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My

    # We need the certificate as base64 encoded string
    $certificate = [convert]::ToBase64String($cert.RawData)

    $CredsFilename = Get-AzRecoveryServicesVaultSettingsFile `
        -Vault $recoveryServicesVault `
        -Backup `
        -Certificate $certificate `
        -Path $path
    ````

    At the time of writing this lab, there was an issue with the API, resulting in an error (see [Get-AzRecoveryServicesVaultSettingsFile fails with "Unexpected character encountered while parsing value: E. Path '', line 0, position 0"](https://github.com/Azure/azure-powershell/issues/16636)). Therefore, follow these instruction for manually downloading the Vault Settings file.

    In **Google Chrome**, navigate to **https://portal.azure.com** and sign in. Search for **backup-vault-** followed by your user name. In **backup-vault-** followed by your user name, under **Getting started**, click **Backup**. In Backup, under **Where is your workload running?**, select **On-Premises**. Under **What do you want to backup?**, activate **Files and folders**. Click **Prepare Infrastructure**. On blade **Prepare infrastructure**, activate **Already downloaded or using the latest Recovery Services Agent** and click **Download**. Move the downloaded **.VaultCredentials** file to **C:\MARS**.

1. Update the environment variable PSModulePath to include the Microsoft Azure Recovery Services Agent PowerShell module.

    ````powershell
    $Env:PSModulePath += `
        ';C:\Program Files\Microsoft Azure Recovery Services Agent\bin\Modules'
    ````

1. Register the server with the backup vault.

    ````powershell
    $credsFilename = Get-ChildItem -Path $path -Filter '*.VaultCredentials'
    $vaultCredentials = $CredsFilename.FullName
    <# 
        Use the next command, if you sucessfully downloaded the vault
        credentials using PowerShell.
    #>
    # $vaultCredentials = $credFilename.FilePath
    Start-OBRegistration -VaultCredentials $vaultCredentials -Confirm:$false
    ````

    Verify the **ServiceResourceName** and **Region**. They should match your Recovery Services Vault.

1. Set the encryption passphrase.

    ````powershell
    $encryptionPassPhrase = Read-Host `
        -Prompt 'Type the encryption passphrase' `
        -AsSecureString
    Set-OBMachineSetting -EncryptionPassphrase $encryptionPassPrase
    ````

    At the prompt, enter a secure string.

    *Important*: Keep the passphrase information safe and secure once it's set. You can't restore data from Azure without this passphrase.

### Task 3: Enable bandwidth throttling

#### Desktop experience

Perform these steps on FS.

1. In **Microsoft Azure Backup**, in pane **Actions**, click **Change Properties**.
1. Click the tab **Throttling**.
1. Activate **Enable internet bandwidth usage throttling for backup operations**.
1. In **Work hours**, type **1**, and select **Mbps**. In **Non-work hours**, type **10**, and select **Mbps**. Click **OK**.
1. On message **Server properties updated successfully.**, click **OK**.

#### PowerShell

Perform these steps on FS.

1. In **Windows PowerShell**, limit the bandwidth used by Azure Backup during working hours to 1 MB/s and during non-working hours to 10 MB/s. Working hours are Monday to Friday from nine to five.

    ````powershell
    $workDay = `
        [System.DayOfWeek]::Monday, 
        [System.DayOfWeek]::Tuesday, 
        [System.DayOfWeek]::Wednesday, 
        [System.DayOfWeek]::Thursday, 
        [System.DayOfWeek]::Friday
    $startWorkHour = '09:00:00'
    $endWorkHour = '17:00:00'
    Set-OBMachineSetting `
        -WorkHourBandwidth 1MB `
        -NonWorkHourBandwidth 10MB `
        -WorkDay $workDay `
        -StartWorkHour $startWorkHour `
        -EndWorkHour $endWorkHour
    ````

### Task 4: Verify the backup infrastructure in Azure

#### Desktop experience

Perform these steps on FS.

1. Switch to **Google Chrome**.
1. On page **Prepare infrastructure**, in the top-right corner, click the icon **Close**.
1. Back on page **backup vault | Backup**, under **Manage**, click **Backup infrastructure**.
1. In **Backup Infrastructure**, click on the link **Azure Backup Agent** (the number 1 should be displayed beside the link).

    In **Protected Servers (Azure Backup Agent)**, you should see **FS.SMART.ETC**.

#### PowerShell

Perform this task on FS.

In **Windows PowerShell** list the backup containers for the vault of backup management type MAB and containertype windows.

````powershell
Get-AzRecoveryServicesBackupContainer `
    -VaultId $recoveryServicesVault.ID `
    -BackupManagementType MAB `
    -ContainerType Windows 
````

This should return an entry for fs.smart.etc.

## Exercise 3: Back up data

### Introduction

In this exercise you will create a backup schedule for C:\SampleDocuments on FS. Then, you will start the initial backup. Finally, you will review the backup in Azure Portal and delete the backed up folder.

#### Tasks

1. [Schedule a backup](#task-1-schedule-a-backup)
2. [Start the initial Backup](#task-2-start-the-initial-backup)
3. [Review backups in Azure Portal](#task-3-review-backups-in-azure-portal)


### Task 1: Schedule a Backup

#### Desktop experience

Perform these steps on FS.

1. Switch to **Microsoft Azure Backup**.
1. In the pane **Actions**, click **Schedule Backup**.
1. In Schedule Backup Wizard, on page **Getting started**, click **Next >**.
1. On page **Select Items to Backup**, click **Add Items**.
1. In **Select Items**, expand **C:** and activate **C:\SampleDocuments**. Click **OK**.

    If C:\SampleDocuments does not exist, in File Explorer, copy L:\SampleDocuments to C:\.

1. Back on page Select Items to Backup, click **Next >**.
1. On page **Specify Backup Schedule**, accept the defaults and click **Next >**.
1. On page **Select Retention Policy (Files and Folders)**, review the settings and click **Next >**.
1. On page **Choose Initial Backup Type (Files and Folders)**, click **Transfer over the network** and click **Next >**.
1. On page **Confirmation** [figure 5], click **Finish**.
1. On page **Modify Backup Progress**, click **Close**.

#### Windows Admin Center

*Note:* This task cannot be performened using Windows Admin Center. However, if you used Windows Admin Center to register the server for Azure Backup, refer to these, slightly different steps to complete this task.

Perform these steps on FS.

1. Switch to **Microsoft Azure Backup**.
1. In the pane **Actions**, click **Schedule Backup**.
1. In Schedule Backup Wizard, on page **Select Policy Item**, click **Modify a backup schedule for your files and folders** and click **Next >**.
1. On page **Modify or Stop a Scheduled Backup**, click **Make changes to backup items or times** and click **Next >**.
1. On page **Select Items to Backup**, click **D:\\** and click **Remove Items**.
1. Click **Add Items**.
1. In **Select Items**, expand **C:** and activate **C:\SampleDocuments**. Click **OK**.

    If C:\SampleDocuments does not exist, in File Explorer, copy L:\SampleDocuments to C:\.

1. Back on page Select Items to Backup, click **Next >**.
1. On page **Specify Backup Schedule**, accept the defaults and click **Next >**.
1. On page **Select Retention Policy (Files and Folders)**, review the settings and click **Next >**.
1. On page **Confirmation** [figure 5], click **Finish**.
1. On page **Modify Backup Progress**, click **Close**.

#### PowerShell

Perform these steps on FS.

1. In **Windows PowerShell**, Create a new backup policy.

    ````powershell
    $policy = New-OBPolicy
    ````

1. The folder C:\SampleDocuments should be backed up. If the folder does not exist on FS, copy it from L:\.

    ````powershell
    $fileSpec = New-OBFileSpec -FileSpec 'C:\'
    Add-OBFileSpec -Policy $policy -FileSpec $fileSpec
    ````

1. Create a new schedule for daily backup at 17:30 and associate it with the policy.

    ````powershell
    $timesOfDay = '17:30'
    $schedule = New-OBSchedule -TimesOfDay $timesOfDay
    Set-OBSchedule -Policy $policy -Schedule $schedule
    ````

1. Create a new retention policy. Daily backups shoul be retained for 180 days. Saturday's backup of each week should be retained for 104 weeks. The backup of the last Saturday of each month should be retained for 60 months. And the backup each March's last Saturday should be retained for 10 years.

    ````powershell
    $retentionPolicy = New-OBRetentionPolicy `
        -RetentionDays 180 `
        -RetentionWeeklyPolicy `
        -WeekDaysOfWeek Saturday `
        -WeekTimesOfDay 17:30 `
        -RetentionWeeks 104 `
        -RetentionMonthlyPolicy `
        -MonthWeeksOfMonth Last `
        -MonthDaysOfWeek Saturday `
        -MonthTimesOfDay 17:30 `
        -RetentionMonths 60 `
        -RetentionYearlyPolicy `
        -YearMonthsOfYear March `
        -YearWeeksOfMonth Last `
        -YearDaysOfWeek Saturday `
        -YearTimesOfDay 17:30 `
        -RetentionYears 10
    Set-OBRetentionPolicy -Policy $policy -RetentionPolicy $retentionPolicy
    ````

1. Save the policy

    ````powershell
    Set-OBPolicy $policy -Confirm:$false
    ````

### Task 2:  Start the initial Backup`

#### Desktop experience

Perform these steps on FS.

1. In **Microsoft Azure Backup**, in pane **Actions**, click **Backup Up Now**.
1. In **Back Up Now Wizard**, on page **Select Backup Item**, click **Next >**.
1. On page **Retain Backup Till**, select tomorrow's date and click **Next >**.
1. On page **Confirmation**, click **Back Up**.

    The first backup will take 2 - 3 minutes. A snapshot will be taken and the data will be copied to the Azure Recovery Services Vault. Wait for the backup to complete.

1. On page **Backup progress**, click **Close**.

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, connected to **FS.smart.etc**, in **Azure Backup**, at the bottom of the page, click **Backup Now**.
1. In the pane **Backup Now**, click **Backup**.
1. Back on page Azure Backup, click the tab **Jobs**.

    You can observe the status of your backup job here. Moreover, you can configure e-mail notifications by clicking **Alerts and Notifications**. Azure Portal will open with **Backup Alerts**. There, you must click **Configure notifications**.

1. In **Windows Admin Center**, connected to **FS.smart.etc**, under **Tools**, click **Files and file sharing**.
1. On tab **Files**, click  **(C:)**.
1. In the right pane, activate **Sample Documents** and click **Delete**.

    Depending on your screen size, you might have to click the elipsis (**...**) to see the Delete command.

1. In **Delete folder**, click **Yes**.

#### PowerShell

Perform this task on FS.

In **Windows PowerShell**, start the backup using the settings from your policy.

````powershell
Get-OBPolicy | Start-OBBackup
````

The first backup will take 2 - 3 minutes. A snapshot will be taken and the data will be copied to the Azure Recovery Services Vault. Wait for the backup to complete.

### Task 3: Review backups in Azure Portal

#### Desktop experience

Perform these steps on FS.

1. Switch to **Google Chrome**.
1. In the breadcrumb navigation, click **backup-vault-** followed by your user name ([figure 6]).
1. Back in **backup-vault-** followed by your user name, under **Protecte items**, click **Backup items**.
1. In **Backup items**, click **Azure Backup Agent** (there should be the number 1 displayed).
1. On page **Backup Items (Azure Backup Agent)**, click **C:\\**.

    Details about the backup are displayed.

1. Open **File Explorer**.
1. Delete **C:\SampleDocuments**.

#### PowerShell

Perform these steps on FS.

1. In **Windows PowerShell**, get the backup container and store it in a variable.

    ````powershell
    $resourceGroupName = 'recovery-' # append your user name
    $recoveryServicesVault = Get-AzRecoveryServicesVault `
        -ResourceGroupName $resourceGroupName `
        -Name 'backup-vault-' #append your user name
    $backupContainer = Get-AzRecoveryServicesBackupContainer `
        -VaultId $recoveryServicesVault.Id `
        -BackupManagementType MAB `
        -ContainerType Windows
    ````

1. Get details about the protected backup items.

    ````powershell
    Get-AzRecoveryServicesBackupItem `
        -VaultId $recoveryServicesVault.ID `
        -Container $backupContainer `
        -WorkloadType FileFolder |
    Format-List
    ````

    Details about the backup are displayed.

1. Delete **C:\SampleDocuments**

    ````powershell
    Remove-Item -Path 'C:\Sample Documents' -Recurse -Force
    ````

## Exercise 4: Restore data

### Introduction

In this exercise you will restore the previously delete folder.

#### Tasks

1. [Mount a backup volume](#task-1-mount-a-backup-volume)
1. [Restore a folder](#task-2-restore-a-folder)
1. [Unmount the backup volume](#task-3-unmount-the-backup-volume)

### Task 1: Mount a backup volume

#### Desktop experience

Perform these steps on FS.

1. Switch to **Microsoft Azure Backup**.
1. In Microsoft Azure Backup, in pane **Actions**, click **Recover Data**.
1. In **Recover Data Wizard**, on page **Getting Started**, click **This server (fs.smart.etc)** and click **Next >**.
1. On page **Select Recovery Mode**, click **Individual files and folders** and click **Next >**.
1. On page **Select Volume and Data**, in **Select the volume**, select **C:\\**. Click **Mount**.

    The date selector automatically selects the last backup date. If there are more than one backup available, you could select earlier backups.

    After a few moments, the recovery volume is mounted and the drive letter is displayed in the wizard.

1. On page **Browse And Recover Files**, click **Browse**.
1. On the **Tip: Use Robocopy**, click **OK**.

    A new **File Explorer** window will open and show the contents of the recovery volume.

#### PowerShell

Perform these steps on FS.

1. In **Windows PowerShell**, pick the source volume.

    ````powershell
    $recoverableSource = Get-OBRecoverableSource
    $recoverableSource
    ````

1. Choose a backup point from which to restore.

    ````powershell
    # We take the first source indicated by [0]
    $recoverableItem = Get-OBRecoverableItem $recoverableSource[0]
    $recoverableItem
    ````

1. Mount the latest backup.

    ````powershell
    Start-OBRecoveryMount -RecoverableItem $recoverableItem[0]
    ````

    After a few moments, you should receive a messages like:

    ````shell
    Recovery volume mounted as disk. Browse volume from file explorer to recover items.E:
    ````

### Task 2: Restore a folder

#### Desktop experience

1. From the mounted recovery volume, copy **SampleDocuments** to **C:\\**.

    Wait for the copy process to complete.

#### PowerShell

1. Run a new **Windows PowerShell** as Administrator.
1. From the mounted backup, copy SampleDocuments to C:\\.

    ````powershell
    # You might have to modify the drive letter E:
    Copy-Item -Path 'E:\Sample Documents\' -Destination C:\ -Recurse
    ````

1. Switch back to the **Windows PowerShell**, where you mounted the backup volume. Press CTRL + C to stop the process.

    Unfortunately, at the time of writing this lab, there was no way to unmount the backup volume using PowerShell.

### Task 3: Unmount the backup volume

Perform these steps on FS.

1. Switch or open **Microsoft Azure Backup**.
1. If the **Recover Data Wizard** is not open, in tab **Jobs**, open the message **Recovery volume mounted as disk. Browse volume from file explorer to recover items**.
1. Click **Unmount**.

[figure 1]: images/Azure-hamburger-menu.png
[figure 2]: images/Azure-backup-and-site-recovery.png
[figure 3]: images/Azure-create-recovery-services-vault-review.png
[figure 4]: images/Azure-recovery-service-vault-getting-started-backup.png
[figure 5]: images/Azure-backup-schedule-confirmation.png
[figure 6]: images/Azure-backup-infrastructure-breadcrumb.png