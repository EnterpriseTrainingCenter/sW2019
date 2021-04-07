# Lab 3: Windows Server Environment Basics

## Required VMs

* DC1
* Router
* DHCP
* HV1
* WS2019

## Exercises

1. [Active Directory Basics](#exercise-1-active-directory-basics)
1. [PowerShell Basics](#exercise-2-powershell-basics)

## Exercise 1: Active Directory Basics

### Introduction

In this exercise, you will create an Organizational Unit and a personalized Active Directory User Account Additionally, you join a computer into the Domain smart.etc.

### Tasks

1. [Change networking settings](#task-1-change-networking-settings)
1. [Create a new Organizational Unit and a new AD User](#task-2-create-a-new-organizational-unit-and-a-new-ad-user)
1. [Join the computer to the domain](#task-3-join-the-computer-to-the-domain)

### Detailed Instructions

#### Task 1: Change networking settings

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

#### Task 2: Create a new Organizational Unit and a new AD User

Perform these steps on DC1.

1. Logon as **smart\Administrator**.
1. Start **Server Manager**
1. In **Server Manager**, from the menu bar select **Tools, Active Directory Users and Computers**.
1. In **Active Directory Users and Computer**, in the context menu of the top node **smart.etc**, select **New, Organizational Unit**
1. In **New Object - Organizational Unit**, in **Name**, enter **Server2019** ([figure 1]) and click **OK**.
1. Select the new OU and try to delete it.

   > Can you delete the OU?

   > Why? (Hint: see [figure 1])

1. From the context menu of the new OU, select **New, User**.
1. Create a new user using your your personal first and last name. For the user logon name use the following format: **firstname.lastname**. For the password use **Pa$$w0rd** and deactivate **User must change password at next logon**.
1. Double-click the new user to open its properties.
1. Click on the tab **Member Of**.

   > Which groups is the new user member of?

#### Task 3: Join the computer to the domain

Perform these steps on WS2019.

1. If not opened already, start **Server Manager**.
2. In **Server Manager**, in the left pane, click on **Local Server**.
3. In the middle pane, click on the **Workgroup** name.
4. In **System Properties**, click on **Change**.
5. Activate **Domain**, and in **Domain Name**, enter **smart.etc**.
6. Click on **OK**, and use the **smart\Administrator** credentials to join the computer to the domain.
7. Click on **OK** twice, and restart the computer.
8. Use the user account you created in task 2 to logon to the computer.

## Exercise 2: PowerShell Basics

### Introduction

In this exercise, you will perform some PowerShell basic tasks.

### Tasks

1. [Examine PowerShell functionality](#task-1-examine-powershell-functionality)

### Detailed Instructions

#### Task 1: Examine PowerShell functionality

Perform these steps on HV1.

1. Logon as **smart\Administrator** and open the PowerShell.
1. Start typing **Get-Com**, then press the TAB key. The command should automatically be completed to:

   ````powershell
   Get-Command
   ````

   Then press ENTER. This lists all available commands.

1. Search for a specific cmdlet.

   ````powershell
   Get-Command *-windowsFeat*
   ````

1. Display help for the **Get-WindowsFeature** cmdlet.

   ````powershell
   Get-Help Get-WindowsFeature
   ````

1. Use the arrow up key to recall the last command. At the end type a space, then type **-ex** and press the TAB key. The command should automatically be completed to:

   ````powershell
   Get-Help Get-WindowsFeature -Examples
   ````

1. Install the RSAT-AD-PowerShell feature.

   ````powershell
   Install-WindowsFeature RSAT-AD-PowerShell 
   ````

1. Use the AD PowerShell to display properties of the user, you created in exercise 1. You do not need to type the line after the hash character. The hash character precedes a comment.

   ````powershell
   # Replace <firstname>.<lastname> with the name of the user, you created in exercise 1
   Get-ADUser <firstname>.<lastname>  
   ````

1. Store values and PowerShell objects in a variable and display the content of the variable:

   ````powershell
   # It is a good idea to store often used values in variables
   $firstname = '<firstname>'
   $lastname = '<lastname>'
   # Variables in double-quoted strings are expanded automatically
   $user = Get-ADUser "$firstname.$lastname" 
   $user
   ````

1. Display the type and the members of the object stored in $user:

   ````powershell
   # The pipe symbol (|) sends the output from the left-hand command as input to the right-hand command. This is called a "pipeline".
   $user | Get-Member
   ````

1. Display all AD Attributes of a user object.

   ````powershell
   # By default only the most important properties of AD objects are returned
   Get-ADUser "$firstname.$lastname" -Properties *
   ````

1. Display a list of all Active Directory user objects.

   ````powershell
   # The format-* cmdlets modify the output format of objects.
   # The two most common are Format-Table and Format-List.
   Get-ADUser -Filter * | Format-Table 
   ````

1. Get a list of all PowerShell aliases and search for Format-Table:

   ````powershell
   Get-Alias
   ````

1. Use the Alias for Format-Table.

   ````powershell
   # Very often, you will encounter the aliases of Format-Table and Format-List: ft and fl
   # CAUTION: Although aliases save some typing effort in the conole or terminal, it is considered bad style to use the in scripts.
   Get-ADUser -Filter * | ft
   ````

1. Start PowerShell transcription and repeat the last command.

   ````powershell
   Start-Transcript 
   Get-ADUser -Filter * | ft
   ````

1. Stop PowerShell transcription and display the log file.

   ````powershell
   Stop-Transcript
   # Replace <filename> with the actual file name emitted by Stop-Transcript
   Get-Content '<filename>'
   ````

   > How to change the path and filename of the transcript file?

1. Change the display name of your user.

   ````powershell
   Get-ADUser "$firstname.$lastname" |
   Set-ADUser -DisplayName "$lastname, $firstname"
   Get-ADUser "$firstname.$lastname" -Properties DisplayName 
   ````

[figure 1]: images/Lab03/figure01.png