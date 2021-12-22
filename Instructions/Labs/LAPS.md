# Lab: LAPS

## Required VMs

* DC1
* DHCP
* Router
* SRV2

## Exercises

1. Installing and configuring LAPS

## Exercise 1: Installing and configuring LAPS

### Introduction

In this exercise, you will install Local Administrator Password Solution (LAPS). You need to configure the required attributes and GPO Settings.

#### Tasks

1. Install and configure LAPS on DC1
1. Install the LAPS Client on SRV2
1. Test LAPS

### Task 1: Install and configure LAPS on DC1

Perform these steps on DC1.

1. Logon as “smart\Administrator”.
1. Run **L:\LAPS\LAPS.x64.msi** and install Management Tools only ([figure 1]).
1. Run **Windows PowerShell** as Administrator.
1. Update the AD Schema.

    ````powershell
    Update-AdmPwdADSchema
    ````

1. Verify that only Domain Admins have the permission to read the local administrative password ([figure 2]).

    ````powershell
    $identity = 'cn=computers,dc=smart,dc=etc'
    Find-AdmPwdExtendedRights -Identity $identity
    ````

1. Add write permission for the ms-Mcs-AdmPwdExpirationTime and ms-Mcs-AdmPwd attributes of all computer accounts to the SELF built-in account:

    ````powershell
    Set-AdmPwdComputerSelfPermission -Identity $identity
    ````

1. Copy the **C:\Windows\PolicyDefinitions** folder to **C:\Windows\SYSVOL\domain\Policies**.

    ````powershell
    Copy-Item `
        -Path C:\Windows\PolicyDefinitions\ `
        -Destination \\smart.etc\sysvol\smart.etc\Policies\ `
        -Container `
        -Recurse
    ````

1. Open **Group Policy Management Console** (gpmc.msc) and, in **smart.etc**, edit the Computer-Base-Policy.
1. In **Group Policy Management Editor** for Computer-Base-Policy, navigate to **Computer Configuration**, **Policies**, **Administrative Templates**, **LAPS**
1. Double-click **Enable local admin password management** and set it to **Enabled**
1. Double-click **Password Settings**, set it to **Enabled**, and set **Password Length** to **20**. Accept the remaining defaults.

### Task 2:  Install the LAPS Client

Perform these steps on SRV2.

1. log on as **smart\Administrator**.
1. Install the LAPS Client.

    ````shell
    msiexec /i L:\LAPS\LAPS.x64.msi /qb+
    ````

1. Refresh group policies.

    ````shell
    gpupdate
    ````

### Task 3: Test LAPS

Perform these steps on DC1.

1. Open **LAPS UI** from start menu.
1. In **ComputerName**, enter **SRV2** and click **Search**. The new password is displayed ([figure 3]). Only computers with installed LAPS Client and enabled GPOs will appear in this tool.
 
Without LAPS UI installed, you can also retrieve the password using the **Attribute Editor** tab in **Active Directory Users and Computers** (enable **Advanced Features** in **View** menu) ([figure 4]).
 
[figure 1]: images/LAPS-setup-custom.png
[figure 2]: images/LAPS-find-admpwdextendedrights-response.png
[figure 3]: images/LAPS-ui.png
[figure 4]: images/AD-users-computers-attribute-editor-ms-Mcs-AdmPwd.png