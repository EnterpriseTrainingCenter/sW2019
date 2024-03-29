# Lab: Installing and Configuring Windows Server 2019

## Required VMs

* DC1
* DHCP
* HV1
* Router
* SRV2

## Exercises

1. [Authoring an Unattend.xml file](#exercise-1-authoring-an-unattendxml-file)
1. [Building a new Windows Server DVD](#exercise-2-building-a-new-windows-server-dvd)
1. [Installing Windows Server 2019 unattended](#exercise-3-installing-windows-server-2019-unattended)
1. [Configuring Windows Server](#exercise-4-configuring-windows-server)
1. [Install windows features using Server Manager](#exercise-5-install-windows-features-using-server-manager-and-windows-powershell)

## Exercise 1: Authoring an Unattend.xml File

### Introduction

In this exercise, you prepare an Unattend.xml file to automate the deployment of Windows Server 2019. The file should automate InputLocale, SystemLocale, and UserLocale settings. Moreover, it should set the comptuer name to WS2019, set the administrator password to Pa$$w0rd, and set the time zone to your current time zone.

#### Tasks

1. [Install Windows System Image Manager](#task-1-install-windows-system-image-manager)
1. [Author an Unattend.xml file using Windows System Image Manager](#task-2-author-an-unattendxml-file-using-windows-system-image-manager)

### Task 1: Install Windows System Image Manager

Perform these steps on **HV1**.

1. Open Windows Explorer
1. Navigate to **L:\ADK**
1. Launch **adksetup.exe**.
1. On the **Specify a location** page, click on **Next**.
1. On the **Windows Kits privacy** page, click on **Next**.
1. Click on **Accept**.
1. On the **Select the features you want to install** page, clear the checkboxes beside all components. Select the checkbox beside **Deployment tools** ([figure 1]).
1. Click on **Install** and wait for the install to complete. Then, click on **Close**.

### Task 2:  Author an Unattend.xml file using Windows System Image Manager

Perform these steps on **HV1**.

1. From the start menu, launch **Windows System Image Manager**.
1. In the top middle, in section **Answer file**, in the context menu of **Create or open an answer file**, select **New answer file…** ([figure 2]).
1. Click **Yes** to open a Windows image now ([figure 3]).
1. Navigate to **D:\Deployment**
1. Open the file **install_Windows Server 2019 SERVERDATACENTER.clg**.
1. In the **Windows Image** section, expand the **Components** tree ([figure 4]).
1. In the context-menu of the component **amd64_Microsoft-Windows-International-Core__neutral** select **Add Setting to Pass 4 specialize** ([figure 5]). The component should now appear in the answer file's **4 specialize** Pass ([figure 6]).
1. On the right-hand top, in section **Microsoft-Windows-International-Core**, fill out the settings with the following values ([figure 7]):

   * **InputLocale**: Use your native language locale (Press F1 or ask your trainer for help)
   * **SystemLocale**: Use your native language locale
   * **UserLocale**: Use your native language locale

1. In the **Windows Image** section, add the component **amd64_Microsoft-Windows-Shell-Setup…** to pass 4 specialize.
1. Expand the component in the answer file
1. Delete all sub nodes (you can also use the DEL key) ([figure 8]). The resulting settings node should look like [figure 9].
1. In the **Microsoft-Windows-Shell-Setup** component, in  the setting **ComputerName**, type **WS2019** ([figure 10]).
1. Open Windows PowerShell.
1. List the name of your current time zone using one of the following commands.

   ````shell
   tzutil /g
   ````

   ````powershell
   Get-TimeZone
   ````

1. Copy the output value or the **ID** of the current time zone.
1. In the answer file, in the **Microsoft-Windows-Shell-Setup** component, in the **TimeZone** setting, paste the copied time zone.
1. In the **Windows Image** section, expand the component **amd64_Microsoft-Windows-Shell-Setup …**
1. Navigate to **UserAccounts/AdministratorPassword**
1. Add the **AdministratorPassword** component to **Pass 7 oobeSystem** ([figure 11]).
1. In the **Administrator Password** setting, type **Pa$$word**.
1. On the toolbar, click the **Save** icon and save the unattended file to **D:\Deployment\unattend.xml**.

## Exercise 2: Building a new Windows Server DVD

### Introduction

In this exercise, you will build a new Windows Server 2019 DVD that contains your unattended file from exercise 1.

#### Tasks

1. [Inject the Unattend.xml file into the original Install.wim file](#task-1-inject-the-unattendxml-file-into-the-original-installwim-file)
1. [Build a new ISO file which contains the modified Install.wim file](#task-2-build-a-new-iso-file-which-contains-the-modified-installwim-file)

### Task 1: Inject the Unattend.xml file into the original Install.wim file

Perform these steps on HV1.

1. Run a Command Prompt as Administrator.
1. Change directory to **L:\Deployment**

   ````shell
   L:
   cd Deployment
   ````

1. Execute the **InjectUnattend.cmd** to inject the unattend.xml file into the Install.wim.

   ````shell
   InjectUnattend.cmd
   ````

1. Leave the command prompt open for the next task.

### Task 2: Build a new ISO file which contains the modified Install.wim file

Perform these steps on HV1.

1. Run **makeiso.cmd** to build a new bootable ISO File.

   ````shell
   Makeiso.cmd
   ````

## Exercise 3: Installing Windows Server 2019 unattended

### Introduction

In this exercise, you will use the Unattend.xml file from exercise 1 to install a new Windows Server 2019 Server. First you create a new generation 2 VM named WS2019 with 1 GB of startup memory, connected to the Datacenter1 switch. Then, you will install Windows Server 2019 with your custom ISO image and validate the settings from the unattended file.

#### Tasks

1. [Create a VM for Windows Server 2019](#task-1-create-a-vm-for-windows-server-2019)
1. [Install Windows Server 2019 unattended](#task-2-install-windows-server-2019-unattended)

### Task 1: Create a VM for Windows Server 2019

#### Desktop Experience

Perform these steps on HV1.

1. Open Hyper-V Manager from the task bar ([figure 12])
1. In **Hyper-V Manager** from the context menu of your computer's object, select **New, Virtual Machine...** to create a new virtual machine ([figure 13]).
1. Go through the steps of the wizard entering the following information:

   * **Name:** WS2019
   * **Store the virtual machine in a different location D:\\**
   * **Generation: 2**
   * **Startup Memory:** 1024 MB
   * **Connection: Datacenter1**
   * **Create a virtual Hard Disk**
   * **Name:** WS2019.vhdx
   * **Location:** D:\WS2019\Virtual Hard Disks
   * **Install an operating system from a bootable image file**
   * **Media:** D:\ISO\WS2019-RTM-Unattend.iso
1. From the context menu of the newly created virtual machine, select **Settings...** ([figure 14]).
1. In section **Hardware**, select **Processor** ([figure 15]) and increase the **Number of virtual processors** to 4 .
1. Click **OK** to commit the changes.
1. Double-Click on the VM to open the VM Console window.
1. Click on **Start** to start WS2019

#### Windows Admin Center

Perform these steps on CL1.

1. Login as **smart\Administrator**.
1. Open **Google Chrome**.
1. Navigate to <https://admincenter>.
1. In **Windows Admin Center***, connect to **hv1.smart.etc**.
1. On the left, click **Virtual machines**.
1. In **Virtual machines**, click **Add**, **New**.

   * **Name** WS2019
   * **Generation**: **Generation 2 (Recommended)**
   * **Path**: D:\
   * **Virtual processors**
      * **Count**: 4
   * **Startup Memory:** 1 GB
   * **Use dynamic memory** activated
   * **Virtual switch"**: **Datacenter1**
   * **Storage**: Click **+ Add**
      Under **New disk 1**
      * **Create an empty virtual hard disk**
      * **Size (GB)**: 127
   * **Install an operating system from an image fille (.iso)**
   * **Path**: D:\ISO\WS2019-RTM-Unattend.iso

#### PowerShell

Perform these steps on HV1.

1. Run **Window PowerShell** as Administrator.
1. Create a new virtual machine. You do not need to type the comments.

   ````powershell

   <#
   It is a good idea to store values, that are used more than one time in 
   variables. In PowerShell Variables are preceeded by a $ sign.
   #>
   $vMName = 'WS2019'
   $vMPath = 'D:\'

   <#
   If a string is surounded by double quotes, variables are auto-expanded.
   This is a simple version to build a path. A better way to build paths is the
   Join-Path cmdlet, which is platform-independent. Remember, that on Unixoid
   platforms (Linux, MacOS, ...) directories are separated by a forward slash
   in contrast to Windows' backslash.
   #>
   $NewVHDPath = "$vMPath\$vMName)\Virtual Hard Disks\$VMName.vhdx"

   # The back tick ` can be used to split long command lines and make them more readable

   New-VM `
      -Name $vMName `
      -Path $vmPath `
      -Generation 2 `
      -MemoryStartupBytes 1GB `
      -SwitchName Datacenter1 `
      -NewVHDPath $NewVHDPath `
      -NewVHDSizeBytes 127GB

   $vMDvdDrive = Add-VMDvdDrive -VMName $vMName -Path 'D:\ISO\WS2019-RTM-Unattend.iso' -Passthru
   Set-VMFirmware -VMName $vMName -FirstBootDevice $vMDvdDrive
   ````

1. For the newly created VM increase the processor count to 4.

   ````powershell
   Set-VM -Name $vMName -ProcessorCount 4
   ````

1. Start the VM.

   ````powershell
   Start-VM -Name $vmName
   ````

### Task 2: Install Windows Server 2019 unattended

Perform these steps on WS2019.

1. Select your time and currency format and keyboard layout and click on **Next**
1. Click on **Install now**
1. Open the file **L:\Deployment\Key.txt** and copy the product key.
1. Switch back to the virtual machine console window.
1. Click into the **Product Key** field ([figure 17]).
1. In the console window menu bar click on **Clipboard, Type clipboard text** ([figure 18]). Then, click on **Next**.
1. Select **Windows Server 2019 Datacenter (Desktop Experience)**, and click on **Next**.
1. Accept the **End User License Agreement (EULA)** and click on **Next**.
1. Select **Custom: Install Windows only (advanced)** and on the next screen click on **Next**.
1. After the installation is finished, logon to the Server as **Administrator** and check if the following settings have been automatically configured:

   * The computername should be **WS2019**.
   * Your time zone
   * Your regional settings

## Exercise 4: Configuring Windows Server

### Introduction

In this exercise, you will configure the network settings and join the server to the domain. Set the IP address of WS2019 to 10.1.1.32/24, the default gateway to 10.1.1.254, and the DNS server to 10.1.1.1. Then, join the machine to the domain smart.etc.

#### Tasks

1. [Change network settings](#task-1-change-network-settings)
1. [Join the computer to the domain](#task-2-join-the-computer-to-the-domain)

### Task 1: Change networking settings

#### Desktop Experience

Perform these steps on WS2019.

1. Logon as **.\Administrator**.
1. Open **Network and Sharing Center**.
1. From the context menu of the network interface card (NIC) **Ethernet…**, select **Rename**.
1. Rename the NIC to **Datacenter1**
1. Open the properties of the NIC **Datacenter1**.
1. Open the properties of **Internet Protocol Version 4**.
1. Configure the following settings:

   * **IP Address:** 10.1.1.32
   * **Subnet Mask:** 255.255.255.0
   * **Default Gateway:** 10.1.1.254
   * **Preferred DNS Server:** 10.1.1.1

1. Click on **OK** twice to commit the changes.

#### PowerShell

Perform these steps on WS2019.

1. Logon as **.\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Rename network interface card (NIC) Ethernet to Datacenter1.

   ````powershell
   $interfaceAlias = 'Datacenter1'
   Rename-NetAdapter -Name 'Ethernet' -NewName $interfaceAlias
   ````

1. Configure Internet Procotol Version 4.

   ````powershell
   New-NetIPAddress `
      -AddressFamily IPv4 `
      -InterfaceAlias $interfaceAlias `
      -IPAddress 10.1.1.32 `
      -PrefixLength 24 `
      -DefaultGateway 10.1.1.254
   Set-DnsClientServerAddress `
      -InterfaceAlias $interfaceAlias `
      -ServerAddresses 10.1.1.1
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 2: Join the computer to the domain

#### Desktop Experience

Perform these steps on WS2019.

1. If not opened already, start **Server Manager**.
1. In **Server Manager**, in the left pane, click on **Local Server**.
1. In the middle pane, click on the **Workgroup** name.
1. In **System Properties**, click on **Change**.
1. Activate **Domain**, and in **Domain Name**, enter **smart.etc**.
1. Click on **OK**, and use the **smart\Administrator** credentials to join the computer to the domain.
1. Click on **OK** twice, and restart the computer.
1. Logon as **smart\user1**.

   > Can you logon? Why?

1. Logoff.

#### PowerShell

Perform these steps on WS2019.

1. Rename the computer and join it to the domain.

   ````powershell
   $domainName = 'smart.etc'

   # In PowerShell, commands in braces are executed first.
   # The result can then be used in a parameter of the surounding commmand.
   Add-Computer `
      -DomainName $domainName `
      -Credential (
         Get-Credential -Message "Credentials to join domain $domainName"
      ) `
      -Restart
   ````

1. In the dialog, that asks for credentails, use the credentials for **smart\Administrator** to join the computer to the domain.
1. Logon as **smart\user1**.

   > Can you logon? Why?

1. Logoff.

## Exercise 5: Install windows features using Server Manager and Windows PowerShell

### Introduction

In this exercise, you will install the Telnet Client feature by using Server Manager and the Hyper-V Management Console using PowerShell on WS2019.

#### Tasks

1. [Install the Telnet Client by using Server Manager](#task-1-install-the-telnet-client-by-using-server-manager)
1. [Install the Hyper-V Management Console from the RSAT Tools using PowerShell](#task-2-install-the-hyper-v-management-console-from-the-rsat-tools-using-powershell)

### Task 1: Install the Telnet Client by using Server Manager

Perform these steps on WS2019.

1. If it’s not already started, start **Server Manager** from the taskbar ([figure 19]).
1. Dismiss the **Windows Admin Center** invite.
1. From the menu bar select **Manage, Add Roles and features** ([figure 20]).
1. Click on **Next** until you reach the **Select features** page ([figure 21]).
1. On the **Select features** page, select **Telnet Client** ([figure 21]).
1. Click on **Next** and then **Install** to start the installation.
1. Click on **Close**. The installation will continue in the background.
1. On the toolbar click on the flag icon to display the status of the installation ([figure 22]).

### Task 2: Install the Hyper-V Management Console from the RSAT Tools using PowerShell

Perform these steps on WS2019.

1. Run **Windows PowerShell** as Administrator.
1. Enter the following command to list all available Windows Features (you have to press ENTER after each command).

   ````powershell
   Get-WindowsFeature
   ````

1. Hyper-V Console is a part of the Remote Server Administration Tools (RSAT) – so we must filter our output to only get those RSAT features. Enter the following command to list all available Windows features with a name that begins with **RSAT**.

   ````powershell
   # ? is an alias for Where-Object
   Get-WindowsFeature | ? Name -like 'RSAT*'
   ````

   The list should be shorter now
1. We want to install the Hyper-V Management Tools, so we will further filter our output. Enter the following command to list all available Windows Features with a Name that is like **RSAT\*Hyper\***.

   ````powershell
   Get-WindowsFeature | ? Name -like 'RSAT*Hyper*'
   ````

   Now, the list should contain one entry only.
1. Using the name of the Hyper-V Management Tools feature, we can now install this feature:

   ````powershell
   Install-WindowsFeature 'RSAT-Hyper-V-Tools'
   ````

1. Click on the start button and make sure that **Hyper-V Manager** is available.

[figure 1]: images/WAIK-features-deployment-tools.png
[figure 2]: images/WSIM-new-answer-file.png
[figure 3]: images/WSIM-prompt-open-windows-image.png
[figure 4]: images/WSIM-components.png
[figure 5]: images/WSIM-add-setting-to-pass-4-specialize.png
[figure 6]: images/WSIM-specialize-amd64_Microsoft-Windows-International-Core_neutral.png
[figure 7]: images/WSIM-specialize-amd64_Microsoft-Windows-International-Core_neutral-settings.png
[figure 8]: images/WSIM-autologon-delete.png
[figure 9]: images/WSIM-specialize-amd64_Microsoft-Windows-Shell-Setup_neutral.png
[figure 10]: images/WSIM-microsoft-windows-shell-setup-properties.png
[figure 11]: images/WSIM-add-setting-to-pass7-oobeSystem-AdministratorPassword.png
[figure 12]: images/hyperv-manager-icon.png
[figure 13]: images/hyperv-manager-new-virtual-machine.png
[figure 14]: images/hyperv-manager-vm-settings.png
[figure 15]: images/hyperv-vm-settings-processor.png
[figure 16]: images/hyperv-manager-vm-start.png
[figure 17]: images/Windows-setup-productkey.png
[figure 18]: images/hyperv-connection-type-clipboard-text.png
[figure 19]: images/server-manager-icon.png
[figure 20]: images/server-manager-add-roles-and-features.png
[figure 21]: images/server-manager-add-roles-and-features-telnet-client.png
[figure 22]: images/server-manager-feature-installation-progress.png
[figure 23]: images/Powershell-run-as-administrator.png
