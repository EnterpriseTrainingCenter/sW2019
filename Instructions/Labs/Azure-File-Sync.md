# Lab : Azure File Sync

## Required VMs

* DC1
* FS on HV1
* DHCP
* Router
* CL1

## Exercise

1. [Preparing the Azure environment](#exercise-1-preparing-the-azure-environment)
2. [Configuring Azure File Sync](#exercise-2-configuring-azure-file-sync)

## Exercise 1: Preparing the Azure environment

### Introduction

In this exercise you will create a Storage Account and an Azure file share.

#### Tasks

1. [Install PowerShell modules for Azure (Optional)](#task-1-install-powershell-modules-for-azure-optional)
1. [Create a Resource Group (Optional)](#task-2-create-a-resource-group-optional)
1. [Create a Storage Account](#task-3-create-a-storage-account)
1. [Create an Azure File share](#task-4-create-an-azure-file-share)

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
1. Logon with your Azure credentials.
1. At the top-left, click the hamburger menu ([figure 1]) and click **Create a resource**.
1. In **Search services and marketplace**, type **resource group**. When **Resource Group** appears below the input field, click on it.
1. On page **Resource Group**, click **Create**.
1. On tab **Basics**, in **Subscription**, select the subscription, you want to use for this lab. In **Resource group**, enter **AzFS-** followed by your user name, e. g. *AzFS-Susi*. In **Region** select a region close to you, e. g. **North Europe**. Click **Review + create**.

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

1. Create a resource group with the name **AzFS-** followed by your user name.

    ````powershell
    $resourceGroupName = 'AzFS-' # append your user name
    $resourceGroup = New-AzResourceGroup `
        -Name $resourceGroupName `
        -Location northeurope # You can replace the location, if you want.
    ````

### Task 3: Create a Storage Account

#### Desktop experience

Perform these steps on FS.

1. Sign in as **smart\Administrator**.
1. Open **Google Chrome**.
1. In Google Chrome, navigate to **https://portal.azure.com**.
1. Logon with your Azure credentials.

    If you are asked to provide more information about your account, you can skip the steps for 14 days.

1. At the top-left, click the hamburger menu ([figure 1]) and click **Create a resource**.
1. On page Create a resource, in **Search services and marketplace**, type **storage account**. When **Storage Account** is listed below the text box, click on it.
1. On page Storage account, click **Create**.
1. On page Create a storage account, on tab **Basics**, fill in the parameters according to the table below. Click **Review + Create**.

    | Label                    | Value                                                 |
    |--------------------------|-------------------------------------------------------|
    | **Subscription**         | Select a subscription you want to use                 |
    | **Resource Group**       | Select **AzFS-** followed by your user name           |
    | **Storage account name** | Your user name followed by **azfs** (lower-case only) |
    | **Region**               | A region close to you, e.g. **(Europe) North Europe** |
    | **Performance**          | **Standard**                                          |
    | **Redundancy**           | **Locally-redundant storage (LRS)**                   |

    **Storage account name** must be globally unique. If the name is already taken, append some numbers like the current year and month.

1. On tab **Review + create**, click **Create**.

    You will be sent to a deployment page. Wait for the deployment to complete. Leave the page open for the next task.

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

1. Create a standard storage account with locally redundant storage in resource group **AZFS-** followed by your user name.

    ````powershell
    $resourceGroup = Get-AzResourceGroup -Name 'AzFS-Susi'
    $resourceGroupName = $resourceGroup.ResourceGroupName
    $location = $resourceGroup.Location
    $storageAccountName = 'azfs'  # prefix with your user name in lower case

    $storageAccount = New-AzStorageAccount `
        -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName `
        -SkuName Standard_LRS `
        -Location $location
    ````

    If you receive an error message stating that your storage account name is not available, append some numbers to the string in ````$name = 'azfs'```` such as the current year an month and run that line again. Then, run the line starting with ````New-AzStorageAccount```again.

### Task 4: Create an Azure File share

#### Desktop experience

Perform these steps on FS.

1. In the Azure Portal, at the top-left, click the hamburger menu ([figure 1]) and click **Resource groups**.
1. In Resource groups, click on the resource group **AzFs-** followed by your user name.
1. In the Resource group, click on the Storage account (your user name followed by **azfs**).
1. On the Storage account pane, under **Data storage**, click **File Shares**.
1. In File shares, click **+ File share**.
1. In the New file share pane, in **Name**, type **azfs**. In **Tier**, select **Hot**. Click **Create**.

#### PowerShell

1. In **Windows PowerShell**, in the storage account created in the previous exercise, create a share with the name **azfs** and the access tier **Hot**.

    ````powershell
    # $resourceGroup = Get-AzResourceGroup -Name 'AzFS-Susi'
    # $resourceGroupName = $resourceGroup.ResourceGroupName
    # $storageAccountName = 'azfs'  # prefix with your user name in lower case

    $storageShareName = 'azfs'

    New-AzRmStorageShare `
        -ResourceGroupName $resourceGroupName `
        -StorageAccountName $storageAccountName `
        -Name $storageShareName `
        -AccessTier Hot
    ````

## Exercise 2: Configuring Azure File Sync

### Introduction

In this exercise, you will create an Azure File Sync service, register FS with the service and sync sample documents with it.

#### Tasks

1. [Add Azure File Sync Service](#task-1-add-azure-file-sync-service)
1. [Register the local server](#task-2-register-the-local-server)
1. [Test Azure File Sync](#task-3-test-azure-file-sync)

### Task 1: Add Azure File Sync Service

#### Desktop experience

Perform these steps on FS.

1. In the Azure Portal, at the top-left, click the hamburger menu ([figure 1]) and click **Create a resource**.
1. On page Create a resource, in **Search services and marketplace**, type **file sync**. When **Azure File Sync** is listed below the text box, click on it.
1. On page Azure File Sync, click **Create**.
1. On page Deploy Azure File Sync, on tab **Basics**, in **Subscription** select the same subscription you created the storage account in. In **Resource group** select **AzFS-** followed by your user name. In **Storage sync service name**, type **AzFSSvc**. In **Region**, select the same region as your storage account. Click **Review + Create**.
1. On tab **Review + create**, click **Create**.

Leave the browser open and proceed with the next task.

#### PowerShell

Perform this task on FS.

In **Windows PowerShell** create a new storage sync service in the same resource group and at the same location as your storage account.

````powershell
$storageSyncService = New-AzStorageSyncService `
    -ResourceGroupName $resourceGroupName `
    -Name AzFSSvc `
    -Location $location
````

### Task 2: Register the local server

#### Desktop experience

Perform these steps on FS.

1. On the Azure Portal, in **Search resources, services, and docs (G+/)**, type **AzFSSvc**. When the **Storage Sync Service** AzFSSvc appears below the search box, click on it.
1. On page **AzFSSvc** **Storage Sync Service**, under **Sync**, click **Getting Started**.
1. In Getting Started, click the link **Download the Azure File Sync agent**.
1. On page Download Center, click **Download**.
1. In **Choose the download you want**, activate **StorageSyncAgent_WS2019.msi** and click **Next**.
1. At the bottom of the Google Chrome windows, when the download has completed, click **StorageSyncAgend....msi**.
1. In Open File - Security Warning, click **Run**.
1. In Storage Sync Agent Setup, proceed through the wizard accepting the defaults.

    Wait for the installation to complete.

1. Switch to **Azure File Sync**.
1. In **Agent Update**, click **OK**.
1. Under **Azure Environment**, ensure **AzureCloud** is selected and click **Sign in**.
1. Sign in with your Azure credentials.
1. On page **Choose a Storage Sync Service**, make the selections to connect to your Storage Sync Service you created in the previous task. Click **Register**.
1. Switch to Azure Portal.
1. On page AzFSSvc, under **Sync**, click **Sync groups**.
1. In Sync groups, click **+ Sync group**.
1. On page Sync group, in Sync group name, type **SampleDocuments**. Select your subscription. Click **Select storage account**.
1. On page Choose storage account, click the storage account you created in the previous exercise.
1. Back on page Sync group, under **Azure File Share**, select the file share you created in previous task and click **Create**.

    After a few moments, the sync group appears in Sync groups.

1. Back in Sync groups, click **Sample Documents**.
1. On page Sample Documents, click **Add cloud endpoint**.

    Wait a moment until the cloud endpoint is created.

1. Click **Add server endpoint**.
1. In pane Add server endpoint, under **Registered Server**, select **FS.smart.etc**. In **Path**, type **C:\SampleDocuments**. Click **Create**.

    The directory C:\SampleDocuments will be created automatically on the local server.

#### PowerShell

Perform these steps on FS.

1. In **Windows PowerShell**, download the Azure File Sync agent  **StorageSyncAgent.ms** from **https://aka.ms/afs/agent/Server2019**.

    ```powershell
    $filePath = 'StorageSyncAgent.msi'
    Start-BitsTransfer `
        -Source https://aka.ms/afs/agent/Server2019 `
        -Destination $filePath
    ````

1. Install the File Sync agent.

    ````powershell
    <#
        Start-Process is used to PowerShell blocks until the operation is
        complete. Note that the installer currently forces all PowerShell 
        sessions closed - this is a known issue.
    #>
    Start-Process -FilePath $filePath -ArgumentList "/quiet" -Wait
    ````

1. Register Windows Server with Storage Sync service.

    ````powershell
    #region Execute these commands only, if the PowerShell session was closed

    Connect-AzAccount
    # Get-AzSubscription
    <# 
        Replace the SubscriptionId parameter value with the Id you copied to the
        clipboard.
    #>
    Select-AzSubscription -SubscriptionId 00000000-0000-0000-0000-000000000000
    $storageSyncService = Get-AzStorageSyncService `
        -ResourceGroupName $resourceGroupName
        -Name AzFsSvc
    $resourceGroup = Get-AzResourceGroup -Name 'AzFS-Susi'
    $resourceGroupName = $resourceGroup.ResourceGroupName
    $storageAccountName = 'azfs'  # prefix with your user name in lower case
    $storageAccount = Get-AzStorageAccount `
        -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName
    $storageShareName = 'azfs'

    #endregion Execute these commands only, if the PowerShell session was closed

    # Register the server

    $storageSyncServer = Register-AzStorageSyncServer `
        -ParentObject $storageSyncService

1. Create a sync group **SampleDocuments**.

    ````powershell
    $storageSyncGroupName = 'SampleDocuments'
    $storageSyncGroup = New-AzStorageSyncGroup `
        -ParentObject $storageSyncService `
        -Name $storageSyncGroupName
    ````

1. Register a cloud endpoint.

    ````powershell
    New-AzStorageSyncCloudEndpoint `
        -Name $storageShareName `
        -ParentObject $storageSyncGroup `
        -StorageAccountResourceId $storageAccount.Id `
        -AzureFileShareName $storageShareName

1. Create a server endpoint. The local path on the server should be **C:\SampleDocuments**.

    ````powershell
    $serverLocalPath = 'C:\SampleDocuments'
    New-AzStorageSyncServerEndpoint `
        -Name $storageSyncServer.FriendlyName `
        -SyncGroup $storageSyncGroup `
        -ServerResourceId $storageSyncServer.ResourceId `
        -ServerLocalPath $serverLocalPath `
    ````

    The directory C:\Sample Documents will be created automatically on the local server.

### Task 3: Test Azure File Sync

#### Desktop experience

Perform these tasks on FS.

1. Open **File Explorer**.
1. In File Explorer, navigate to **L:\SampleDocuments**.
1. Copy the contents of **L:\SampleDocuments** to **C:\SampleDocuments**.
1. Switch to **Google Chrome**.
1. On the Azure Portal, in **Search resources, services, and docs (G+/)**, type your username followed by azfs. When the **Storage Account** your user name **AzFSSvc** appears below the search box, click on it.
1. On page your user name **azfs**, under **Data storage**, click **File shares**.
1. In File shares, click **azfs**.

    You should see the files and folders you copied to the synced folder. If you do not see the files and folders, click **Refresh**. It can take up to 5 minutes for all the files and folders to sync.

#### PowerShell

Perform these tasks on FS.

1. In **Windows PowerShell**, copy the contents of **L:\SampleDocuments** to **C:\SampleDocuments**.

    ````powershell
    Copy-Item 'L:\SampleDocuments\*' 'C:\SampleDocuments\' -Recurse
    ````

1. List the contents of the Azure File Share.

    ```powershell
    Get-AzStorageFile -ShareName $storageShareName
    ````

    You should see the files and folders you copied to the synced folder. If you do not see the files and folders, wait up to 5 minutes before executing the command again.

[figure 1]: images/Azure-hamburger-menu.png
