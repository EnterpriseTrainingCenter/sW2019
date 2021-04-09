# Lab 1: Installing and Configuring Windows Server 2019

## Required VMs

* DC1
* DHCP
* HV1
* Router

## Exercises

1. [Authoring an Unattend.xml file](#exercise-1-authoring-an-unattendxml-file)
1. [Building a new Windows Server DVD](#exercise-2-building-a-new-windows-server-dvd)
1. [Installing Windows Server 2019 unattended](#exercise-3-installing-windows-server-2019-unattended)
1. [Install windows features using Server Manager](#exercise-4-install-windows-features-using-server-manager-and-windows-powershell)

## Exercise 1: Authoring an Unattend.xml File

### Introduction

In this exercise, you prepare an Unattend.xml file to automate the deployment of Windows Server 2019.

### Tasks

1. [Install Windows System Image Manager](#task-1-install-windows-system-image-manager)
1. [Author an Unattend.xml file using Windows System Image Manager](#task-2-author-an-unattendxml-file-using-windows-system-image-manager)

### Detailed Instructions

#### Task 1: Install Windows System Image Manager

Perform these steps on **HV1**.

1. Open Windows Explorer
1. Navigate to **L:\ADK**
1. Launch **adksetup.exe**.
1. On the **Specify a location** page, click on **Next**.
1. On the **Windows Kits privacy** page, click on **Next**.
1. Click on **Accept**.
1. On the **Select the features you want to install** page, clear the checkboxes beside all components. Select the checkbox beside **Deployment tools** ([figure 1]).
1. Click on **Install** and wait for the install to complete. Then, click on **Close**.

#### Task 2:  Author an Unattend.xml file using Windows System Image Manager

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
1. Delete all sub nodes (you can also use the DEL key) ([figure 8]). The resulting settings node should look like [figure 9][figure 9].
1. In the **Microsoft-Windows-Shell-Setup** component, in  the setting **ComputerName**, type **WS2019** ([figure 10]).
1. Open a command prompt
1. List the name of your current time zone

   ````shell
   tzutil /g
   ````

1. Copy the output value of the current time zone.
1. In the answer file, in the **Microsoft-Windows-Shell-Setup** component, in the **TimeZone** setting, paste the copied time zone.
1. In the **Windows Image** section, expand the component **amd64_Microsoft-Windows-Shell-Setup …**
1. Navigate to **UserAccounts/AdministratorPassword**
1. Add the **AdministratorPassword** component to **Pass 7 oobeSystem** ([figure 11]).
1. In the **Administrator Password** setting, type **Pa$$word**.
1. On the toolbar, click the **Save** icon and save the unattended file to **D:\Deployment\unattend.xml**.

## Exercise 2: Building a new Windows Server DVD

### Introduction

In this exercise, you will build a new Windows Server 2019 DVD that contains your unattended file from exercise 1.

### Tasks

1. [Inject the Unattend.xml file into the original Install.wim file](#task-1-inject-the-unattendxml-file-into-the-original-installwim-file)
1. [Build a new ISO file which contains the modified Install.wim file](#task-2-build-a-new-iso-file-which-contains-the-modified-installwim-file)

### Detailed Instructions

#### Task 1: Inject the Unattend.xml file into the original Install.wim file

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

#### Task 2: Build a new ISO file which contains the modified Install.wim file

Perform these steps on HV1.

1. Run **makeiso.cmd** to build a new bootable ISO File.

   ````shell
   Makeiso.cmd
   ````

## Exercise 3: Installing Windows Server 2019 unattended

### Introduction

In this exercise, you will use the Unattend.xml file from exercise 1 to install a new Windows Server 2019 Server.

### Tasks

1. [Install Windows Server 2019 unattended](#task-1-install-windows-server-2019-unattended)

### Detailed Instructions

#### Task 1: Install Windows Server 2019 unattended

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

## Exercise 4: Install windows features using Server Manager and Windows PowerShell

### Introduction

In this exercise, you will install the Telnet Client feature by using Server Manager and the Hyper-V Management Console using PowerShell on WS2019.

### Tasks

1. [Install the Telnet Client by using Server Manager](#task-1-install-the-telnet-client-by-using-server-manager)
1. [Install the Hyper-V Management Console from the RSAT Tools using PowerShell](#task-2-install-the-hyper-v-management-console-from-the-rsat-tools-using-powershell)

### Detailed Instructions

#### Task 1: Install the Telnet Client by using Server Manager

Perform these steps on WS2019.

1. If it’s not already started, start **Server Manager** from the taskbar ([figure 19]).
1. Dismiss the **Windows Admin Center** invite.
1. From the menu bar select **Manage, Add Roles and features** ([figure 20]).
1. Click on **Next** until you reach the **Select features** page ([figure 21]).
1. On the **Select features** page, select **Telnet Client** ([figure 21]).
1. Click on **Next** and then **Install** to start the installation.
1. Click on **Close**. The installation will continue in the background.
1. On the toolbar click on the flag icon to display the status of the installation ([figure 22]).

#### Task 2: Install the Hyper-V Management Console from the RSAT Tools using PowerShell

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

[figure 1]: images/Lab01/figure01.png
[figure 2]: images/Lab01/figure02.png
[figure 3]: images/Lab01/figure03.png
[figure 4]: images/Lab01/figure04.png
[figure 5]: images/Lab01/figure05.png
[figure 6]: images/Lab01/figure06.png
[figure 7]: images/Lab01/figure07.png
[figure 8]: images/Lab01/figure08.png
[figure 9]: images/Lab01/figure09.png
[figure 10]: images/Lab01/figure10.png
[figure 11]: images/Lab01/figure11.png
[figure 12]: images/Lab01/figure12.png
[figure 13]: images/Lab01/figure13.png
[figure 14]: images/Lab01/figure14.png
[figure 15]: images/Lab01/figure15.png
[figure 16]: images/Lab01/figure16.png
[figure 17]: images/Lab01/figure17.png
[figure 18]: images/Lab01/figure18.png
[figure 19]: images/Lab01/figure19.png
[figure 20]: images/Lab01/figure20.png
[figure 21]: images/Lab01/figure21.png
[figure 22]: images/Lab01/figure22.png
[figure 23]: images/Lab01/figure23.png
