# Lab 3: Windows Server Environment Basics

## Required VMs

* DC1
* Router
* DHCP
* HV1

## Exercises

1. [Active Directory Basics](#exercise-1-active-directory-basics)
1. [PowerShell Basics](#exercise-2-powershell-basics)

## Exercise 1: Active Directory Basics

### Introduction

In this exercise, you will create an Organizational Unit and a personalized Active Directory user account.

### Tasks

1. [Create a new Organizational Unit and a new AD User](#task-1-create-a-new-organizational-unit-and-a-new-ad-user)
1. [Create a new AD user](#task-2-create-a-new-ad-user)

### Detailed Instructions

#### Task 1: Create a new Organizational Unit and a new AD user

Perform these steps on DC1.

1. Logon as **smart\Administrator**.
1. Start **Server Manager**
1. In **Server Manager**, from the menu bar select **Tools, Active Directory Users and Computers**.
1. In **Active Directory Users and Computers**, in the context menu of the top node **smart.etc**, select **New, Organizational Unit**
1. In **New Object - Organizational Unit**, in **Name**, enter **Server2019** ([figure 1]) and click **OK**.
1. Select the new OU and try to delete it.

   > Can you delete the OU? Why? (Hint: see [figure 1])

1. Leave **Active Directory Users and Computers** open for the next task.

#### Task 2: Create a new AD user

Perform these steps on DC1.

1. In **Active Directory Users and Computers**, from the context menu of the new OU, select **New, User**.
1. Create a new user using your your personal first and last name. For the user logon name use the following format: **firstname.lastname**. For the password use **Pa$$w0rd** and deactivate **User must change password at next logon**.
1. Double-click the new user to open its properties.
1. Click on the tab **Member Of**.

   > Which groups is the new user member of?

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
   # Replace <firstname>.<lastname> with the name of the user, 
   # you created in exercise 1
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
   # The pipe symbol (|) sends the output from the left-hand command as input 
   # to the right-hand command. This is called a "pipeline".
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
   # Very often, you will encounter the aliases of Format-Table and Format-List:
   # ft and fl
   # CAUTION: Although aliases save some typing effort in the conole 
   # or terminal, it is considered bad style to use the in scripts.
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