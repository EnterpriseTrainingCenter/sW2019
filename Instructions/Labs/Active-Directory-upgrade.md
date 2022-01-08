# Lab: Active Directory upgrade

## Required VMs

* DC2012R2
* DC2019
* DHCP
* Router

## Exercises

1. [Active Directory readiness checks](#exercise-1-Active-Directory-readiness-checks)
1. [Prepare Active Directory](#exercise-2-prepare-active-directory)
1. [Promote a Windows Server 2019 DC](#exercise-3-promote-a-windows-server-2019-dc)

## Exercise 1: Active Directory readiness checks

### Introduction

In this exercise, you will use DCDIAG and the Best Practices Analyzer to check the health status of the currently running domain controller to make sure the upgrade to Windows Server 2019 Active Directory will run smoothly.

#### Tasks

1. [Check Domain Controller health](#task-1-check-domain-controller-health)

### Task 1: Check Domain Controller health

#### Desktop experience

Perform these steps on DC2012R2.

1. Logon as “smart\Administrator”.
1. Open a Command Prompt as Administrator.
1. Check Domain Controller health with the following command:

    ````shell
    DCDIAG /Q
    ````

    *Note:* The ````/Q```` switch ensures that only errors are shown.

    Examine the output and make sure that no errors exist. Warnings are expected since the DC booted recently. If you recieve an error, try again a few minutes later.

1. Open **Server Manager**
1. In **Server Manager**, on the left select **AD DS**.
1. Scroll down to **Best Practice Analyzer**, click on **Tasks** and select **Start BPA Scan** ([Figure 1]).
1. Click **Start Scan** and wait until the scan is finished.
    Examine the results. In our case, there are some warnings and maybe even an error. This is expected, since we only have one DC, did not backup in a while, etc.

#### PowerShell

Perform these steps on DC2012R2.

1. Logon as “smart\Administrator”.
1. Run **Windows PowerShell** as Administrator.
1. Check Domain Controller health with the following command:

    ````powerhshell
    DCDIAG /Q
    ````

    *Note:* The ````/Q```` switch ensures that only errors are shown.

    Examine the output and make sure that no errors exist. Warnings are expected since the DC booted recently. If you recieve an error, try again a few minutes later.

1. Run the Best Practice Analyzer for Directory Services.

    ````powershell
    # The modelID can be found using Get-BpaModel
    # We store the modelId in a a variable, because we need it soon again
    $modelId = 'Microsoft/Windows/DirectoryServices'
    Invoke-BpaModel -ModelId $modelId
    ````

1. Retrieve the results of the Best Practice Analyzer scan.

    ````powershell
    Get-BpaResult -ModelId $modelId -Filter Noncompliant
    ````

    Examine the results. In our case, there are some warnings and maybe even an error. This is expected, since we only have one DC, did not backup in a while, etc.

## Exercise 2: Prepare Active Directory

### Introduction

In this exercise, you will use ADPREP to prepare Active Directory to support Windows Server 2019 DCs.

#### Tasks

1. [Use ADPREP to prepare Active Directory](#task-1-use-adprep-to-prepare-active-directory)

### Task 1: Use ADPREP to prepare Active Directory

Perform these steps on DC2012R2.

1. Switch to the Command Prompt or Windows PowerShell.
1. Change directory to path **C:\Adprep**

    ````shell
    C:
    Cd \adprep
    ````

1. Extend Active Directory schema.

    ````shell
    ADPREP /forestprep
    ````

1. Confirm by typing C and then press ENTER.
    Make sure this completed successfully. One of the last files being imported should be **sch88.ldf**.
1. Prepare the Active Directory domain.

    ````shell
    ADPREP /domainprep
    ````

    Make sure this step completed successfully.

## Exercise 3: Promote a Windows Server 2019 DC

### Introduction

In this exercise, you will first join DC2019 to the existing domain and install the Active Directory Domain Services role on DC2019. Then, you promote Windows Server 2019 to a domain controller in the existing domain. Afterwards, you will check the health of the promoted domain controller by search for event id 1128 in the Directory Services event log. Moreover, you will run DCDIAG again. Finally, on DC2019, you will set the DNS client's preferred DNS server address to 127.0.0.1 and the alternate DNS server address to 172.16.1.1.

*Note:* In a real-world scenario, it is recommended to set the preferred DNS server to another domain controller. The alternate DNS server may be set to a third domain controller or to 127.0.0.1. In this lab, the server 172.16.1.1 will be decomissioned soon and DC2019 will remain as the only domain controller. Therefore, we set the preferred domain controller to 127.0.0.1.

#### Tasks

1. [Join Windows Server 2019 to the domain](#task-1-join-windows-server-2019-to-the-domain)
1. [Install the Active Directory Domain Services role](#task-1-install-the-active-directory-domain-services-role)
1. [Promote Windows Server 2019 to a domain controller](#task-3-promote-windows-server-2019-to-a-domain-controller)
1. [Check health of the promoted domain controller](#task-4-check-health-of-the-promoted-domain-controller)
1. [Configure the DNS client on the promoted domain controller](#task-5-configure-the-dns-client-on-the-promoted-domain-controller)

### Task 1: Join Windows Server 2019 to the domain

#### Desktop experience

Perform these steps on DC2019.

1. Logon as **.\Administrator**.
1. For the network interface **Datacenter1**, set the **Preferred DNS Server** to **172.16.1.1**.
1. Join the computer to the domain **smart.etc** and restart

#### PowerShell

Perform these steps on DC2019.

1. Logon as **.\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. For the network interface **Datacenter1**, set the **Preferred DNS Server** to **172.16.1.1**.

    ````powershell
    Set-DnsClientServerAddress `
        -InterfaceAlias 'Datacenter1' `
        -ServerAddresses 172.16.1.1
    ````

1. Join the computer to the domain **smart.etc** and restart.

    ````powershell
    Add-Computer -DomainName smart.etc -Restart
    ````

1. Leave Windows PowerShell open for the next task.

### Task 2: Configure the DNS client for promotion of the domain controller

#### Desktop experience

Perform these steps on DC2019.

1. Logon as **smart\Administrator**.
1. Open **Server Manager**.
1. In **Server Manager**, click **Manage**, **Add Roles and Features**.
1. In the **Add Roles and Features Wizard**, go through alle necessary steps to install the role **Active Directory Domain Services**.

#### PowerShell

Perform these steps on DC2019.

1. Logon as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Install **AD Domain Services**.

    ````powershell
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    ````

1. Leave Windows PowerShell open for the next task.

### Task 3: Promote Windows Server 2019 to a domain controller

#### Desktop experience

Perform these steps on DC2019.

1. In Server Manager, click the notification flag with the warning triangle and click the link **Promote this server to a domain controller** ([figure 2]).
1. In the **Active Directory Domain Service Configuration Wizard**, on the page **Deployment Configuration**, click **Add a domain controller to an existing domain** and make sure, **Domain:** contains **smart.etc**. Under **Supply the credentials to perform this operation**, make sure **SMART\Administrator (Current user)** appears. Click **Next >**.
1. On the page **Domain Controller Options**, make sure **Domain Name System (DNS) server** and **Global Catalog (GC)** are selected. In **Password:** and **Confirm password:**, enter **Pa$$w0rd**. Click **Next >**.
1. Proceed to the page **Prerequisites Check** by clicking **Next >** several times.
1. On the page **Prerequisites Check**, click **Install**.
1. After the promotion has finished, restart the server.

#### PowerShell

Perform these steps on DC2019.

1. In Windows PowerShell, promote the server to a Domain Controller.

    ````powershell
    # Read-Host will prompt you for the password and save it as secure string
    # -Confirm:$false disables the confirmation prompt for this command
    # There must be a colon after -Confirm, because it is a switch parameter
    Install-ADDSDomainController `
        -DomainName smart.etc `
        -InstallDns `
        -SafeModeAdministratorPassword (
            Read-Host -AsSecureString 'Safe Mode Administrator password'
        ) `
        -Confirm:$false
    ````

1. On the prompt for the Safe Mode Administrator password, enter **Pa$$w0rd** and press Enter.

    Ignore any warnings…

### Task 4: Check health of the promoted domain controller

#### Desktop expericence

Perform these steps on DC2019.

1. After the computer reboots, wait 5 minutes and then logon again as **smart\administrator**.
1. Open Event Viewer and navigate to **Applications and Services Logs**, **Directory Service**
1. Filter the event log for EventId 1128 ([figure 3]).

    This ID indicates that AD has created replication connections and is replicating with DC2012R2.

    Wait for this ID to appear in event viewer.

1. Check the health of the domain controller with DCDIAG (see [Active Directory readiness checks](#exercise-1-Active-Directory-readiness-checks) for detailed instructions).

    You may see two or three warnings or error events with the EventID 0x00002710 regarding DFSREvent. If these events are older than about 10 minutes, you may safely ignore them. These should disappear after 24 hours.

#### PowerShell

Perform these steps on DC2019.

1. After the computer reboots, wait 5 minutes and then logon again as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. In the event log **Directory Service**, get events with the EventId 1128.

    This ID indicates that AD has created replication connections and is replicating with DC2012R2.

    ````powershell
    Get-EventLog -LogName 'Directory Service' | Where-Object EventId -eq 1128
    ````

    Wait for this ID to appear in event viewer.

1. Check the health of the domain controller with DCDIAG (see [Active Directory readiness checks](#exercise-1-Active-Directory-readiness-checks) for detailed instructions).

    You may see two or three warnings or error events with the EventID 0x00002710 regarding DFSREvent. If these events are older than about 10 minutes, you may safely ignore them. These should disappear after 24 hours.

1. Leave Windows PowerShell open for the next task.

### Task 5: Configure the DNS client on the promoted domain controller

#### Desktop Experience

Perform these steps on DC2019.

1. For the network interface **Datacenter1**, set the **Preferred DNS Server** to **127.0.0.1** and the **Alternate DNS Server** to **172.16.1.1**.

#### PowerShell

Perform these steps on DC2019.

1. For the network interface **Datacenter1**, set the DNS client's DNS servers to 127.0.0.1 and 172.16.1.1.

    ````powershell
    Set-DnsClientServerAddress `
        -InterfaceAlias 'Datacenter1' `
        -ServerAddresses 127.0.0.1, 172.16.1.1
    ````

1. Leave Windows PowerShell open for the next task.

#### Windows PowerShell

## Exercise 4: Transferring FSMO Roles

### Introduction

In this exercise, you will transfer all FSMO roles from DC2012R2 to DC2019 and initiate a full replication cacly.

#### Tasks

1. [Transfer all FSMO roles](#task-1-transfer-all-fsmo-roles)
2. [Initiate a full replication cycle](#task-2-initiate-a-full-replication-cycle)

### Task 1: Transfer all FSMO roles

#### Desktop experience

Perform these steps on DC2019.

1. Open **Active Directory Users and Computers**.
1. In Active Directory Users and Computers, in the context-menu of **smart.etc**, click **Operations Masters...**.
1. On the tab **RID**, make sure that **DC2019.smart.etc** appears in the second text box and click **Change...**.
1. Confirm the prompt by clicking **Yes**.
1. Confirm the information prompt by clicking **OK**.

    Verify, that in both text boxes, DC2019.smart.etc appears.

1. Click the tab **PDC**.
1. Repeat steps 3 - 5.
1. Click the tab **Infrastructure**.
1. Repeat steps 3 - 5.
1. Click **Close**.
1. Open **Active Directory Domains and Trusts**.
1. In Active Directory Domains and Trusts, in the context-menu of **Active Directory Domains and Trusts**, click **Operations Master...**
1. Repeat steps 3 - 5.
1. Click **Close**.
1. Run a **Command Prompt** or **Windows PowerShell** as Administrator.
1. Register the Active Directory Schema Snap-In by executing the following command.

    ````shell
    regsvr32 schmmgmt.dll
    ````

1. Open an empty Microsoft Management Console.

    ````shell
    mmc
    ````

1. In Console1, in the menu, click **File**, **Add/Remove Snap-In...**
1. In the dialog Add or Remove Snap-Ins, under **Available snap-ins**, select **Active Directory Schema**, click **Add >**, and click **OK**.
1. Click **Active Directory Schema**.
1. In the context-menu of **Active Directory Schema**, click **Change Active Directory Domain Controller...**
1. In the dialog **Change Directory Server**, select **DC2019.smart.etc** and click **OK**.
1. Confirm the information message by clicking **OK**.
1. In the context-menu of **Active Directory Schema**, click **Operations Master...**
1. Repeat steps 3 - 5.
1. Click **Close**.
1. Leave the command prompt open for the next task.

#### PowerShell

Perform these steps on DC2019.

1. Transfer all FSMO roles from DC2012R2 to DC2019.

    ````powershell
    Move-ADDirectoryServerOperationMasterRole `
        -Identity DC2019 `
        -OperationMasterRole `
            SchemaMaster, `
            DomainNamingMaster, `
            PDCEmulator, `
            RIDMaster, `
            InfrastructureMaster `
        -Confirm:$false 
    ````

1. Verify the FSMO Role transfer.

    ````powershell
    Get-ADForest | 
    Format-List -Property DomainNamingMaster, SchemaMaster
    
    Get-ADDomain | 
    Format-List -Property PDCEmulator, RIDMaster, InfraStructureMaster
    ````

    The output should show DC2019 as the owner of all roles.

1. Leave Windows PowerShell open for the next task.

### Task 2: Initiate a full replication cycle

Perform these steps on DC2019.

1. In command prompt or Windows PowerShell, initiate a full replication cycle for all directory partitions.

    *Note:* Command line options are case sensitive in this command.

    ````shell
    repadmin /syncall /A
    ````

## Exercise 5: Configure the NTP Server

### Introduction

In this exercise, you will configure the Windows Time Service on DC2019 to sync with 0.pool.ntp.org. Then, you will restart the service and verify the changes.

#### Tasks

1. [Configure Windows Time Service](#task-1-configure-windows-time-service)
2. [Restart Windows Time Service and verify the changes](#task-2-restart-windows-time-service-and-verify-the-changes)

### Task 1: Configure Windows Time Service

Perform these steps on DC2019.

1. Run a Command Prompt or Windows PowerShell as Administrator.
1. Configure the NTP Server to sync from an NTP source on the internet by executing this command.

    ````shell
    w32tm /config /manualpeerlist:0.pool.ntp.org /syncfromflags:manual
    ````

1. Verify that the change was successful by executing this command

    ````shell
    w32tm /dumpreg /subkey:parameters
    ````

1. Leave the Command Prompt or Windows PowerShell open for the next task.

### Task 2: Restart Windows Time Service and verify the changes

#### Desktop Experience

Perform these steps on DC2019.

1. In Command Prompt, restart the Windows Time Service with the following command.

    ````shell
    net stop w32time & net start w32time
    ````

1. Open **Event Viewer**
1. Expand the tree to **Windows Logs**, **System**.
1. Search for **Event ID 37** with **Source** **Time-Service**, which indicates that the NTP server successfully syncs with the NTP server on the internet.

#### PowerShell

1. In Windows PowerShell, restart the Windows Time Service with the following command.

    ````powershell
    Restart-Service w32time
    ````

1. In the System log, search for events with the source **Microsoft-Windows-Time-Service** and the EventId 37, which indicates that the NTP server successfully syncs with the NTP server on the internet.

    ````powershell
    Get-EventLog -LogName System -Source 'Microsoft-Windows-Time-Service' | 
    Where-Object EventId -eq 37 | 
    Format-Table TimeGenerated, Message
    ````

## Exercise 6: Decommission an old domain controller

### Introduction

In this exercise, you will demote DC2012R2 so that it will no longer act as a domain controller for the domain smart.etc. Next, you remove DC2012R2 from the domain and take it out of service.

#### Tasks

1. [Demote domain controller](#task-1-demote-domain-controller)
2. [Remove server from the domain and take it out of service](#task-2-remove-server-from-the-domain-and-take-it-out-of-service)

### Task 1: Demote domain controller

#### Desktop Experience

Perform these steps on DC2012R2.

1. Open **Server Manager**.
1. For the network interface **Datacenter1**, set the **Preferred DNS Server** to **172.16.1.2**.
1. In Server Manager, click **Manage**, **Remove Role and Features**.
1. In the Remove Role and Features Wizard, proceed to the page **Server Roles**.
1. On the page **Remove server roles**, clear the checkbox **Active Directory Domain Services**.
1. In the Remove Roles and Features Wizard, click **Remove Features**.
1. In **Validation Results**, click the link **Demote this Domain controller**.
1. In **Active Directory Domain Services Configuration Wizard**, click **Next >**.
1. On the page **Warnings**, active the checkbox **Proceed with removal** and click **Next >**.
1. On the page **New Administrator Password**, enter **Pa$$w0rd** in both fields and click **Next >**.
1. On the page **Review Options**, click **Demote**.

#### PowerShell

Perform these steps on DC2012R2.

1. Run **Windows PowerShell** as Administrator.
1. For the network interface **Datacenter1**, set the DNS client's DNS servers to 172.16.1.2.

    ````powershell
    Set-DnsClientServerAddress `
        -InterfaceAlias 'Datacenter1' `
        -ServerAddresses 172.16.1.2
    ````

1. Demote DC2012R2 as a domain controller.

    ````powershell
    Uninstall-ADDSDomainController `
    -LocalAdministratorPassword (
        Read-Host -AsSecureString 'New Administrator password'
    ) `
    –IgnoreLastDnsServerForZone –Confirm:$false
    ````

1. On the prompt **New Administrator password**, enter **Pa$$w0rd**.

### Task 2: Remove server from the domain and take it out of service

#### Desktop experience

Perform these steps on DC2012R2.

1. Logon as **smart\Administrator**.
1. Unjoin DC2012R2 from domain smart.etc and place it in the workgroup 
**RIP**. Do not restart the server.
1. Shutdown the server.

#### PowerShell

Perform these steps on DC2012R2.

1. Logon as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Unjoin DC2012R2 from domain smart.etc and place it in the workgroup 
**RIP**. Do not restart the server.

    ````powershell
    Remove-Computer -WorkgroupName RIP -Force
    ````

1. Shutdown the server.

    ````powershell
    Stop-Computer
    ````

[figure 1]: images/Server-Manager-ad-ds-bpa-start.png
[figure 2]: images/Server-Manager-notification-promote-dc.png
[figure 3]: images/Eventvwr-filter-eventid-1128.png