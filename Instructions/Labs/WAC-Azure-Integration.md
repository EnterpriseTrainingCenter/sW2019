# Lab: Windows Admin Center Azure Integration

## Required VMs

* CL1
* DC1
* DHCP
* Router
* FS on HV1
* SRV2

## Exercises

1. [Preparing the Azure environment](#exercise-1-preparing-the-azure-environment)
1. [Configure and use Azure Integration](#exercise-2-configure-and-use-azure-integration)
1. [Update management](#exercise-3-Update-management)

## Exercise 1: Preparing the Azure environment

### Introduction

In this exercise you may install the Azure PowerShell modules and create a resource group. Most importantly, you will create a virtual machine in Azure, which you will manage in Windows Admin Center later.

#### Tasks

1. [Install PowerShell modules for Azure (Optional)](#task-1-install-powershell-modules-for-azure-optional)
2. [Create a Resource Group (Optional)](#task-2-create-a-resource-group-optional)
3. [Prepare a VM in Azure](#task-3-prepare-a-vm-in-azure)

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

Perform these steps on CL1.

1. Sign in as **smart\Administrator**.
1. Open **Google Chrome**.
1. In Google Chrome, navigate to **http://portal.azure.com**.
1. Sign in with your Azure credentials.
1. At the top-left, click the hamburger menu ([figure 1]) and click **Create a resource**.
1. In **Search services and marketplace**, type **resource group**. When **Resource Group** appears below the input field, click on it.
1. On page **Resource Group** ([figure 2]), click **Create**.
1. On tab **Basics**, in **Subscription**, select the subscription, you want to use for this lab. In **Resource group**, enter **SRV1-** followed by your user name, e.g. *SRV1-Susi*. In **Region** select a region close to you, e. g. **North Europe**. Click **Review + create**.

    Your instructor will advise you selecting an appropriate region.

1. On tab **Review + create** ([figure 3]), if validation passed, click **Create**.

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

1. Create a resource group with the name **SRV1-** followed by your user name.

    ````powershell
    $resourceGroupName = 'SRV1-' # append your user name
    $resourceGroup = New-AzResourceGroup `
        -Name $resourceGroupName `
        -Location northeurope # You can replace the location, if you want.
    ````

### Task 3: Prepare a VM in Azure

#### Desktop experience

Perform these steps on CL1.

1. Sign in as **smart\Administrator**.
1. Open **Google Chrome**.
1. In Google Chrome, navigate to **http://portal.azure.com**.
1. Logon with your Azure credentials.
1. At the top-left, click the hamburger menu ([figure 1]) and click **Create a resource**.
1. In **Search services and marketplace**, type **virtual machine**. When **Virtual machine** appears below the input field, click on it.
1. On page **Virtual machine** ([figure 4]), click **Create**.
1. On page Create a virtual machine, on tab **Basics**, fill in the values from the table below. Leave all other default values unchanged. Click **Review + Create**

    | Label                                 | Value                                                        |
    |---------------------------------------|--------------------------------------------------------------|
    | **Subscription**                      | Select your susbscription                                    |
    | **Resource group**                    | Select **SRV1-** followed by your user name                  |
    | **Virtual machine name**              | **SRV1**                                                     |
    | **Region**                            | Select a region close to you, e.g. **(Europe) North Europe** |
    | **Image**                             | **Windows Server 2022 Datacenter: Azure Edition - Gen2**     |
    | **Size**                              | **Standard_B2s - 2 vcpus, 4GiB memory**                      |
    | **Username**                          | **localAdmin**                                               |
    | **Password** and **Confirm password** | **securePa$$w0rd**                                           |
    | **Public inbound ports**              | **Allow selected ports**                                     |
    | **Select inbound ports**              | Only **RDP (3389)** activated                                |

1. On tab **Review + Create** ([figure 5]), click **Create**.

The deployment will take some minutes. Do not wait for the deployment to complete, but rather continue with the next task.

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

1. In resource group **SRV1-** followed by your user name, create a virtual machine with the name **SRV1**. The VM should use the latest **Windows Server 2022 Datacenter** image. The size should be **Standard_B2s**. As administrative user set **localAdmin**. Make sure, TCP port **3389** ist open for RDP connections.

    ````powershell
    $resourceGroupName = 'SRV1-' # append your user name
    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName

    $vMName = 'SRV1'
    $credential = Get-Credential -Message 'Admin user and password for the new Azure VM' -UserName localAdmin

    New-AzVM `
        -ResourceGroupName $resourceGroupName `
        -Name $vMName `
        -Location $resourceGroup.Location `
        -ImageName 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:latest' `
        -Size 'Standard_B2s' `
        -Credential $credential `
        -OpenPorts 3389
    ````

    At the password prompt enter **securePa$$w0rd**.

The deployment will take some minutes. Do not wait for the deployment to complete, but rather continue with the next task.

## Exercise 2: Configure and use Azure Integration

### Introduction

In this exercise, you will register the Windows Admin Center Gateway in Azure Active Directory. Then, you will configure the Azure virtual machine for management in Windows Admin Center. Finally, you will add the Azure virtual machine to Windows Admin Center to manage it like an on-premises machine.

#### Tasks

1. [Register Windows Admin Center in Azure AD](#task-1-register-windows-admin-center-in-azure-ad)
1. [Connect to the virtual machine using RDP](#task-2-connect-to-the-virtual-machine-using-RDP)
1. [Configure the Windows Defender Firewall with Advanced Security for management by Windows Admin Center](#task-3-configure-the-windows-defender-firewall-with-advanced-security-for-management-by-windows-admin-center)
1. [Add the Azure VM to Windows Admin Center](#task-4-add-the-azure-vm-to-windows-admin-center)

### Task 1: Register Windows Admin Center in Azure AD

Perform these steps on CL1.

1. Sign in as **smart\Administrator**.
1. Open **Google Chrome**.
1. In Google Chrome, in a new tab, navigate to **https://admincenter.smart.etc**
1. In top-right corner, click the Settings icon.
1. On page Settings, under **Gateway**, click **Register**.
1. Under Register with Azure, click **Register**.
1. In the pane Get started with Azure in Windows Admin Center, under **Copy this code.**, click **Copy** ([figure 6]).
1. Click the link **Enter the code** ([figure 6]).

    A new tab will open.

1. Under **Enter code**, paste the code you copied and click **Next**.
1. If necessary, sign in with your Azure credentials.
1. On question **Are you trying to sign in to Windows Admin Center?**, click **Continue**.
1. On message **You have signed in to the Windows Admin Center application on your device. You may now close this window.**, close the tab.
1. Back in Windows Admin Center, on pane Get started with Azure in Windows Admin Center, click **Connect**.
1. Click **Sign in**.
1. On **Permissions requested**, click **Accept**.

    If you receive an error message after you clicked Sign in, click on **Account**, click on **Sign in** there and repeat the process.

**Note:** You have registered your Windows Admin Center in your Azure Active Directory (AAD) as an App. This allows you to read and change some settings in your Azure Subscription without logging on to Azure. This App registration is similar to a service account in an on-premises environment.

### Task 2: Connect to the virtual machine using RDP

#### Desktop experience

Perform these steps on CL1.

1. Switch to the tab with Azure Portal.
1. In Azure Portal, ensure the deployment of your VM completed successfully. Click **Go to resource**.
1. On blade **SRV1**, in **Overview**, click **Connect** ([figure 7]).
1. In Connect, click **Download RDP file**.
1. Open the downloaded file **SRV1.rdp**.
1. In **Remote Desktop Connection**, click **Connect**.
1. In **Enter your credentials**, click the link **More choices**.
1. Click **Use a different account**.
1. In **User name**, type **.\localAdmin**, in **Password**, type **securePa$$w0rd**, and click **OK**.
1. In **Remote Desktop Connection**, click **Yes**.

#### PowerShell

Perform these steps on FS.

1. In **Windows PowerShell**, connect to **SRV1** using RDP.

    ````powershell
    # $resourceGroupName = 'SRV1-' # append your user name
    # $vMName = 'SRV1'

    Get-AzRemoteDesktopFile `
        -ResourceGroupName $resourceGroupName `
        -Name $vMName `
        -Launch
    ````

1. In **Remote Desktop Connection**, click **Connect**.
1. In **Enter your credentials**, click the link **More choices**.
1. Click **Use a different account**.
1. In **User name**, type **.\localAdmin**, in **Password**, type **securePa$$w0rd**, and click **OK**.
1. In **Remote Desktop Connection**, click **Yes**.

### Task 3: Configure the Windows Defender Firewall with Advanced Security for management by Windows Admin Center

#### Desktop experience

Perform these steps on SRV1 (the Azure virtual machine).

1. Open **Windows Defender Firewall with Advanced Security**.
1. In Windows Defender Firewall with Advanced Security, click **Inbound Rules**.
1. In Inbound Rules, open the rule with the name **Windows Remote Management (HTTP-In)** and the **Profile** **Public** ([figure 8]).
1. In Windows Remote Management (HTTP-In) Properties, click tab **Scope**.
1. On tab Scope, under **Remote IP address**, click **Any IP address** and click **OK**.
1. Sign out from SRV1.

#### PowerShell

Perform these steps on SRV1 (the Azure virtual machine).

1. Run **Windows PowerShell** as Administrator.
1. Set the firewall rule **WINRM-HTTP-In-TCP-PUBLIC** to accept any remote address.

    ````powershell
    Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any
    ````

1. Sign out from SRV1.

### Task 3: Configure the Network Security Group

1. In **Google Chrome**, on page **SRV1**, under **Settings**, click **Networking**.
1. In Networking, click **Add inbound port rule**.
1. In pane Add inbound security rule, in **Destination port ranges**, type **5985**. Under **Protocol**, click **TCP**. In **Name**, type **WinRM-HTTP-In-TCP** ([figure 9]) and click **Add**.

#### PowerShell

1. In **Windows PowerShell**, get the network interface id of the VM.

    ````powershell
    $vM = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vMName
    $networkInterfaceId = $vM.NetworkProfile.NetworkInterfaces.Id
    ````

1. Get the network interface.

    ````powershell
    $networkInterface = Get-AzNetworkInterface -ResourceId $networkInterfaceId
    ````

1. Get the network security group associated with the network interface.

    ````powershell
    <#
        The NetworkSecurityGroup property of the network interface gives us
        an incomplete representation of the network security group, which
        leads to errors when trying to save rules.

        Therefore, we only use the ID to get the Azure resource and furthermore
        the network security group.
    #>
    $resource = Get-AzResource `
        -ResourceId $networkInterface.NetworkSecurityGroup.Id
    $networkSecurityGroup = Get-AzNetworkSecurityGroup `
        -ResourceGroupName $resource.ResourceGroupName `
        -Name $resource.Name
    ````

1. Set a rule to allow inbound traffic on port **5985**.

    ````powershell
    Add-AzNetworkSecurityRuleConfig `
        -NetworkSecurityGroup $networkSecurityGroup `
        -Direction Inbound `
        -Name 'WinRM-HTTP-In-TCP' `
        -SourceAddressPrefix * `
        -SourcePortRange * `
        -DestinationAddressPrefix * `
        -DestinationPortRange 5985 `
        -Protocol Tcp `
        -Access Allow `
        -Priority 1010
    Set-AzNetworkSecurityGroup -NetworkSecurityGroup $networkSecurityGroup
    ````

### Task 4: Add the Azure VM to Windows Admin Center

Perform these steps on CL1.

1. Switch to the tab of **Windows Admin Center**.
1. Click **Windows Admin Center** to return to the home page.
1. In Windows Admin Center, click **Add**.
1. In pane Add or create resources, under **Azure VMs**, click **Add**.
1. In pane Add an Azure VM, click **Sign In**.
1. In pane Add an Azure VM, under **Subscription**, select your Azure subcription. Under **Resource Group**, select **SRV1-** followed by your user name. Under **Virtual machine**, select **SRV1**. Under **IP address** select the public IP address ([figure 10]). Click **Add**.

    A new server with the public IP address was added.

1. Click the new server.
1. In pane **Specify your credentials**, in **Username**, type **localAdmin**, in **Password**, type **securePa$$w0rd**, and click **Continue**.

You see detailed information about the server and can manage it just like an on-premises server.

## Exercise 3: Update management

### Introduction

In this exercise, you will integrate FS and SRV1 with Azure Update Management.

*Important:* To complete this exercise, you must have the Contribute role at subscription level at least. If you do not have the necessary permissions, your instructor will demonstrate this exercise to you.

#### Tasks

1. [Configure Update Management in Windows Admin Center](#task-1-configure-update-management-in-windows-admin-center)
1. [Add an Azure VM to Update Management](#task-2-add-an-azure-vm-to-update-management)
1. [Verify Update Management](#task-3-verify-update-management)

### Task 1: Configure Update Management in Windows Admin Center

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
1. Under **Tools**, click **Updates**.
1. In the banner **Centrally manage updates on all your servers by using Azure Update Management**, click **Update now**.
1. If necessary, sign in to your Azure subscription.
1. In pane **Set up Azure Update Management**, provide values according to the table below and click **Set up**.

    | Label                                                     |                                                                                         |
    |-----------------------------------------------------------|-----------------------------------------------------------------------------------------|
    | **Azure subscription**                                    | Select your Azure subscription                                                          |
    | **Log analytics workspace / Automation account location** | Select a location close to you, e.g. West Europe                                        |
    | **Log analytics workspace**                               | **Create new**, type **Log-** followed by your user name                                |
    | **Azure Automation account**                              | **Create new**, type **Automation-** followed by your user name                         |
    | **Resource Group**                                        | **Create new**, type **Management-** followed by your user name                         |
    | **Azure Location**                                        | Select the same location as in **Log analytics workspace /Automation account location** |

    Wait for the deployment to complete before continuing.

### Task 2: Add an Azure VM to Update Management

Perform these steps on CL1.

1. Switch to the tab with Azure Portal.
1. At the top, in **Search resources, services and docs (G + /)**, type **Automation-** followed by your user name. When **Automation-** followed by your username appears in the dropdown below, click on it.
1. In the blade **Automation-** followed by your user name, under **Update Management**, click **Update Management**.
1. In Update Management, on the toolbar, click **Add Azure VMs** [figure 11].
1. On blade **Enable Update Management**, **SRV1** is already activated. Click **Enable**.
1. Close **Enable Update Management**.

### Task 3: Verify Update Management

Perform these steps on CL1.

1. Back in Update Management, after a few minutes, both machines should appear automatically.
1. Switch to the tab with Windows Admin Center.
1. Click **Windows Admin Center**.
1. On Windows Admin Center home page, click **FS.smart.etc.**.
1. Connected to FS.smart.etc, under **Tools**, click **Updates**.

    Notice that your machine is managed by Azure Update Management ([figure 13]).

*Note:* In real environments you would start configuring update deployments and schedules for your machines. This is out of scope for this course…

[figure 1]: images/Azure-hamburger-menu.png
[figure 2]: images/Azure-resource-group.png
[figure 3]: images/Azure-Resource-Group-SRV1.png
[figure 4]: images/azure-virtual-machine.png
[figure 5]: images/Azure-VM-SRV1.png
[figure 6]: images/WAC-register-gateway-azure.png
[figure 7]: images/Azure-VM-SRV1-connect.png
[figure 8]: images/Firewall-WINRM-HTTP-In-TCP-PUBLIC.png
[figure 9]: images/Azure-NSG-WinRM-HTTP-In-TCP.png
[figure 10]: images/WAC-add-azure-vm.png
[figure 11]: images/Azure-automation-update-management-add-azurevm.png
[figure 12]: images/Azure-update-management.png
[figure 13]: images/WAC-Updates-Azure.png