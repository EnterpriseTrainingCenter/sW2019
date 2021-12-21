# Lab: Server Core app compatibility features on demand

## Required VMs

* DC1
* DHCP
* Router
* SRV2

## Exercises

1. [Installing app compatibility features on demand](#exercise-1-installing-app-compatibility-features-on-demand)

## Exercise 1: Installing app compatibility features on demand

### Introduction

In this exercise, you will install Server Core app compatibility features on demand, including Internet Explorer, on SRV2, and test them.

#### Tasks

1. [Install the FOD package](#task-1-install-the-fod-package)
1. [Install the Internet Explorer FOD package](#task-2-install-the-internet-explorer-fod-package)

### Task 1: Install the FOD package

Perform these steps on SRV2.

1. Logon as **smart\Administrator** with password **Pa$$w0rd**.
1. Start Windows PowerShell by entering the following command.

   ````shell
   powershell
   ````

1. Mount the Server Core FOD Image.

   ````powershell
   Mount-DiskImage -ImagePath L:\ServerCore\FOD.iso
   ````

1. Retrieve a list of all volumes to get the drive letter of the image you mounted.

   ````powershell
   Get-Volume
   ````

1. Check if the Server Core App Compatibility package is installed.

   ````powershell
   Get-WindowsCapability -Online -Name Servercore*
   ````

1. Install the FOD package from drive E:.

   ````powershell
   Get-WindowsCapability -Online -Name Servercore* |
   Add-WindowsCapability -LimitAccess -Source E: -Online 
   ````

1. Restart the computer.

   ````powershell
   Restart-Computer 
   ````

1. Log back on as **smart\administrator**
1. Open Windows PowerShell.

   ````shell
   powershell
   ````

1. Query the install status of the FOD package.

   ````powershell
   Get-WindowsCapability -Online -Name Servercore*
   ````

### Task 2: Install the Internet Explorer FOD package

Perform these steps on SRV2.

1. Logon as “smart\Administrator”
1. Start Windows PowerShell by entering the following command.

   ````shell
   powershell
   ````

1. Mount the Server Core FOD Image.

   ````powershell
   Mount-DiskImage -ImagePath L:\ServerCore\FOD.iso
   ````

1. Retrieve a list of all volumes to get the drive letter of the image you mounted.

   ````powershell
   Get-Volume
   ````

1. Install the Internet Explorer package.

   ````powershell
   Add-WindowsPackage -Online -PackagePath 'E:\Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~~.cab'
   ````

1. When you are asked to restart the system, type y.

## Exercise 2: Testing app compatibility features on demand

### Introduction

In this exercise, you will test Server Core app compatibility features on demand.

#### Tasks

1. [Use GUI management tools](#task-1-use-gui-management-tools)
1. [Use Internet explorer](#task-2-use-internet-explorer)

### Task 1:  Use GUI management tools

Perform these steps on SRV2.

1. Logon as “smart\Administrator”
1. Start a Microsoft Management Console.

   ````shell
   mmc
   ````

1. Click **File, Add/Remove Snap-in…**
1. Examine the available Snap-ins.
1. Close **Console1** afterwards.
1. Start file explorer.

   ````shell
   explorer.exe
   ````

1. Start the network configuration control panel.

   ````shell
   Ncpa.cpl
   ````

### Task 2:  Use Internet explorer

Perform these steps on SRV2.

1. Start Internet Explorer.

   ````shell
   "C:\Program Files\internet explorer\iexplore.exe"
   ````

1. Try to open some pages
