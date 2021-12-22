# Lab: Time limited group membership

## Required VMs

* DC1
* DHCP
* Router
* CL1

## Exercises

1. [Enable priviledge access management](#exercise-1-enable-privileged-access-management)
1. [Testing time limited group membership](#exercise-2-testing-time-limited-group-membership)

## Exercise 1: Enable privileged access management

### Introduction

In this exercise, you will raise the forest functional level of forest smart.etc to Windows Server 2016 and enable the Privileged Access Management feature.

#### Tasks

1. [Raise the forest functional level to Windows Server 2016](#task-1-raise-the-forest-functional-level-to-windows-server-2016)
1. [Enable the privileged access management feature in the forest](#task-2-enable-the-privileged-access-management-feature-in-the-forest)

### Task 1: Raise the forest functional level to Windows Server 2016

#### Desktop experience

Perform these steps on DC1.

1. Logon as **smart\Administrator**.
1. Open **Active Directory Domains and Trusts**.
1. In Active Directory Domains and Trusts, in the context-menu of **Active Directory Domains and Trusts**, click **Raise Forest Functional Level...**.
1. In the dialog **Raise forest functional level**, verify the **Current forest function level**. Probably, it is **Windows Server 2012 R2**. Under **Select an available forest functional level**, select **Windows Server 2016** and click **Raise**.
1. Confirm the change by clicking **OK**.
1. Confirm the information prompt by clicking **OK**.
1. In Active Directory Domains and Trusts, in the context-menu of **Active Directory Domains and Trusts**, click **Raise Forest Functional Level...**.
1. In the dialog **Raise forest functional level**, verify the **Current forest function level**. It should be **Windows Server 2016**. Click **OK**.

#### PowerShell

Perform these steps on DC1.

1. Logon as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Query the forest functional level.

    ````powershell
    # You can access properties of returned objects directly by surrounding the
    # cmdlet in braces.
    (Get-ADForest).ForestMode
    ````

    Examine the output – the forest mode probably shows **Windows2012R2Forest**.

1. Raise the forest functional level.

    ````powershell
    # Confirm:$false dismisses all confirmation prompts. The colon is required
    # because Confirm is a switch parameter
    Set-ADForestMode `
        -Identity smart.etc `
        -ForestMode Windows2016Forest `
        -Confirm:$false
    ````

1. Verify the new forest mode.

    ````powershell
    (Get-ADForest).ForestMode
    ````

    The result should be **Windows2016Forest**.

### Task 2: Enable the privileged access management feature in the forest

Perform these steps on DC1.

1. Run **Windows PowerShell** as Administrator.
1. Query for the privileged access management feature.

    ````powershell
    Get-ADOptionalFeature -filter {name -like 'Privileged*'}
    ````
  
    The **EnabledScopes** property should be empty (empty bracelets).

1. Enable the privileged access management feature.

    ````powershell
    Enable-ADOptionalFeature `
        -Target smart.etc `
        -Identity "Privileged Access Management Feature" `
        -Scope ForestOrConfigurationSet `
        -Confirm:$false
    ````

1. Query for the privileged access management feature.

    ````powershell
    Get-ADOptionalFeature -filter {name -like 'Privileged*'}
    ````
  
    The **EnabledScopes** property should now show information about the domain controller were the feature has been enabled for the forest ([figure 1]).
  
## Exercise 2: Testing time limited group membership

### Introduction

In this exercise, you make user1 member of the group **DelegatedAdmins** for 10 minutes. This group has delegated administrative rights in Active Directory. You will examine the group membership including the TTL on the DC. Then, you will logon as user1 to CL1 and examine the group membership there. You also will examin the lifetime of the Keberos TTL. Finally, you will test the privileges by resetting the password of user2 within the TTL of the group membership and after the TTL has expired.

#### Tasks

1. [Make a user a time limited member of a group](#task-1-make-a-user-a-time-limited-member-of-a-group)-
2. [Examine group membership in Actvive Directory](#task-2-examine-group-membership-in-active-directory)
3. [Test group membership on the client](#task-3-test-group-membership-on-the-client)

### Task 1: Make a user a time limited member of a group

Perform these steps on DC1.

1. Run **Windows PowerShell** as Administrator.
1. Store a time span of 10 minutes in a variable.

    ````powershell
    $timeSpan = New-TimeSpan -Minutes 10
    ````

1. Make the user a member of the group **DelegatedAdmins** and specify a time to live for the membership.

    ````powershell
    # We store the group identity in a variable because we need it more than 
    # once
    $identity = 'DelegatedAdmins'
    Add-ADGroupMember `
        -Identity $identity `
        -Members user1 `
        -MemberTimeToLive $timeSpan
    ````

1. Leave Windows PowerShell open for the next task.

### Task 2: Examine group membership in active Directory

Perform these steps on DC1.

1. In Windows PowerShell, query the members of the group **DelegatedAdmins** including the TTL for members.

    ````powershell
    Get-ADGroup -Identity $identity -Property member -ShowMemberTimeToLive
    ````

1. The output shows the membership TTL in seconds ([figure 2]).
1. Repeat step 2. The TTL value should decrease.

### Task 3: Test group membership on the client

Perform these steps on CL1.

1. Logon **smart\user1** and open a command prompt.
1. List the group membership of the logged-on user.

    ````shell
    whoami /groups
    ````

    Group membership should include **Smart\DelegatedAdmins**.

1. List the Kerberos tickets.

    ````shell
    klist
    ````

    The first two entries in the list are the ticket granting tickets (TGT). Note the lifetime of the delegation TGT ([figure 3]).

1. Open **Active Directory Users and Computers**.
1. Navigate to **smart.etc/Users**.
1. Reset the password of **User2** to **Pass@word1**. The password reset should be successful.
1. Wait until the TTL for the group membership has expired.
1. Repeat step 3. Te password change should be failing with an Access Denied error.

[figure 1]: images/PAM-enabled.png
[figure 2]: images/PAM-Get-ADGroup-TTL.png
[figure 3]: images/PAM-klist-lifetime.png