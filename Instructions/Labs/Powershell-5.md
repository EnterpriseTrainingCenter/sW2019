# Lab 7: PowerShell 5

## Required VMs

* DC1
* PKI
* DHCP
* Router
* SRV2
* CL1
* FS on HV1

## Exercises

1. [Using PowerShell Direct](#exercise-1-using-powershell-direct)
1. [PowerShell transcripts](#exercise-2-powerShell-transcripts)
1. [Deep script logging](#exercise-3-deep-script-logging)
1. [Protected event log](#exercise-4-protected-event-log)
1. [Just Enough Administration (JEA)](#exercise-5-just-enough-administration-jea)
1. [Package management](#exercise-6-package-management)

## Exercise 1: Using PowerShell Direct

### Introduction

In this exercise, you will remotely manage the VM FS via PowerShell Direct after you disconnected it from the network.

#### Tasks

1. [Disconnect a VM from the network](#task-1-disconnect-a-vm-from-the-network)
1. [Manage a virtual machine using PowerShell Direct](#task-2-manage-a-virtual-machine-using-powershell-direct)
1. [Reconnect a VM to the network](#task-3-reconnect-a-vm-to-the-network)

### Task 1: Disconnect a VM from the network

#### Desktop experience

Perform these steps on HV1.

1. Logon as **smart\Administrator**.
1. Open **Hyper-V Manager**
1. For the VM **FS**, open **Settings...**
1. In Settings for FS on HV1, click the network adapter **Datacenter1**.
1. Under Virtual switch, select **Not connected** and click **OK** ([figure 1]).

#### Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Google Chrome** and navigate to **https://admincenter.smart.etc**.
1. On the page Windows Admin Center, if the server **HV1** is not listed, click **Add**. Under **Servers**, click **Add**. In **Server name**, enter **HV1** and click **Add**.
1. On the page Windows Admin Center, connect to **HV1.smart.etc**.
1. Connected to HV1.smart.etc, under **Tools**, click **Virtual machines**.
1. In Virtual machines, beside **FS**, activate the checkbox.
1. Above the virtual machines, on the toolbar, click **Settings**. Depending on your screen resolution, you might have to click **...** first.
1. In Settings for FS, click **Networks**.
1. In Networks, under **Datacenter1**, under **Virtual switch**, select **Not connected** and click **Save network settings**.

    You might receive an error message stating that network settings could not be saved. However, the change normally works and you can ignore the error message.

1. Click **Close**.

    If you received an error message on the previous step, you have to click **Discard changes**. You can repeat steps 6 - 8 to verify whether the network adapter is disconnected.

#### PowerShell

Perform these steps on HV1.

1. Logon as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. For the VM **FS**, disconnect the network adapter **Datacenter1**.

    ````powershell
    # We store the parameter values in variables, because we will need it later
    # again
    $vMName = 'FS'
    $vMNetworkAdapterName = 'Datacenter1'
    Disconnect-VMNetworkAdapter -VMName $vMName -Name $vMNetworkAdapterName
    ````

### Task 2: Manage a virtual machine using PowerShell Direct

#### Windows Admin Center

Perform these steps on CL1.

1. In Windows Admin Center, connected to HV1.smart.etc, under **Tools**, click **PowerShell**.
1. Enter the password for SMART\Administrator.
1. Connect to FS using PowerShell Direct.

    ````powershell
    # (Get-Credential -Credential FS\Administrator) will prompt for the
    # credentials before Enter-PSSession is executed. This could be shortened to
    # Enter-PSSession –VMName FS -Credential FS\Administrator
    # However, the shortened version does not work under all circumstances, e.g.
    # in Windows Admin Center
    Enter-PSSession –VMName FS -Credential (Get-Credential)
    ````

    When prompted, enter the credentials for **FS\Administrator**. You should be able to connect, because PowerShell direct uses VMBus to connect.

1. Retrieve the list of services on FS.

    ````powershell
    Get-Service
    ````

1. Disconnect from FS Server.

    ````powershell
    Exit
    ````

1. Disconnect from the PowerShell session on HV1, by either clicking **Disconnect** or

    ````powershell
    Exit
    ````

#### PowerShell

Perform these steps on HV1.

1. Make sure, you have **Windows PowerShell** open as Administrator.
1. Connect to FS using PowerShell Direct.

    ````powershell
    # (Get-Credential -Credential FS\Administrator) will prompt for the
    # credentials before Enter-PSSession is executed. This could be shortened to
    # Enter-PSSession –VMName FS -Credential FS\Administrator
    # However, the shortened version does not work under all circumstances, e.g.
    # in Windows Admin Center
    Enter-PSSession –VMName FS -Credential (Get-Credential)
    ````

    When prompted, enter the credentials for **FS\Administrator**. You should be able to connect, because PowerShell direct uses VMBus to connect.

1. Retrieve the list of services on FS.

    ````powershell
    Get-Service
    ````

1. Disconnect from FS Server.

    ````powershell
    Exit
    ````

1. Leave Windows PowerShell open for the next task.

### Task 3: Reconnect a VM to the network

#### Desktop experience

Perform these steps on HV1.

1. For the VM **FS**, open **Settings...**
1. In Settings for FS on HV1, click the network adapter **Datacenter1**.
1. Under Virtual switch, select **Datacenter1** and click **OK**

#### Windows Admin Center

Perform these steps on CL1.

1. In Windows Admin Center, connected to HV1.smart.etc, under **Tools**, click **Virtual machines**.
1. In Virtual machines, beside **FS**, activate the checkbox.
1. Above the virtual machines, on the toolbar, click **Settings**. Depending on your screen resolution, you might have to click **...** first.
1. In Settings for FS, click **Networks**.
1. In Networks, under **Datacenter1**, under **Virtual switch**, select **Datacenter1** and click **Save network settings**.
1. Click **Close**.

#### PowerShell

Perform these steps on HV1.

1. In Windows PowerShell, for the VM **FS**, reconnect the network adapter **Datacenter1**.

    ````powershell
    # If you did not store the paramter values in variables before, execute the
    # next two commands in the comment.
    # $vMName = 'FS'
    # $vMNetworkAdapterName = 'Datacenter1'
    Connect-VMNetworkAdapter `
        -VMName $vMName `
        -Name $vMNetworkAdapterName `
        -SwitchName Datacenter1
    ````

## Exercise 2: PowerShell transcripts

### Introduction

In this exercise, you will create a user and add it to the DHCP Administrators group on DHCP. Then, you will create a share on DC1 to store PowerShell transcripts. You will enable PowerSehll transcription and script logging using a Group Policy Object. Finally, youl will login with the new user on DHCP, execute some PowerShell commands and view the automatically created transcripts.

#### Tasks

1. [Create a user allowed to administer DHCP](#task-1-create-a-user-allowed-to-administer-dhcp)
1. [Create a share for PowerShell transcripts](#task-2-create-a-share-for-powershell-transcripts)
1. [Enable PowerShell transcription and script logging](#task-3-enable-powershell-transcription-and-script-logging)
1. [Test PowerShell transcription](#task-4-test-powershell-transcription)
1. [View PowerShell transcripts](#task-5-view-powershell-transcripts)

### Task 1: Create a user allowed to administer DHCP

#### Desktop experience

Perform these steps on DC1.

1. Logon as **smart\administrator**.
1. Open **Active Directory Users and Computers**.
1. In Active Directory Users and Computers, in **Users**, create a new user named **dhcpadmin** with the password **Pa$$w0rd**. Clear the checkbox **User must change password at next logon**.
1. Open **Computer Management** and connect to **DHCP**.
1. In Computer Management on DHCP, add the user **dhcpadmin** to the local group **DHCP Administrators**.

#### Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Google Chrome** and navigate to **https://admincenter.smart.etc**.
1. On the page Windows Admin Center, if the server **DC1** is not listed, click **Add**. Under **Servers**, click **Add**. In **Server name**, enter **DC1** and click **Add**.
1. On the page Windows Admin Center, connect to **DC1.smart.etc**.
1. Connected to DC1.smart.etc, under **Tools**, click **Active Directory**.

    If you do not see Active Directory, install the extension from Windows Admin Center Settings.

1. In Active Directory Domain Services, click Create, User.
1. Complete the **Add User** pane, to create a user named **dhcpadmin** with the password **Pa$$w0rd** in the **Users** container.
1. Go back to the home page of **Windows Admin Center**.
1. On the page Windows Admin Center, if the server **DHCP** is not listed, click **Add**. Under **Servers**, click **Add**. In **Server name**, enter **DHCP** and click **Add**.

    You might have to add credentials manually.

1. On the page Windows Admin Center, connect to **dhcp.smart.etc**.
1. Connected to DHCP.smart.etc, under **Tools**, click **Local users & groups**.
1. In Local users and groups, click the tab **Groups**.
1. On the tab **Groups**, click DHCP Administrators.
1. In the pane **Details - DHCP Administrators**, click **Add user**.
1. In the pane **Add a user to the DHCP Administrators group**, in **Username**, enter **smart\dhcpadmin** and click **Submit**.

#### PowerShell

Perform these steps on DC1.

1. Logon as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Create a new user named **dhcpadmin** with the password **Pa$$w0rd** in the default users container.

    ````powershell
    $name = 'dhcpadmin'
    $domain = 'smart'

    # You can use variables in double-quoted strings
    New-ADUser `
        -Path "cn=users,dc=$domain,dc=etc" `
        -Name $name `
        -AccountPassword (Read-Host -Prompt 'Password' -AsSecureString) `
        -ChangePasswordAtLogon $false `
        -Enabled $true `
    ````

1. Add the user **dhcpadmin** to the local group **DHCP Administrators** on the server **dhcp**.

    ````powershell
    # Use Invoke-Command to remotely execute commands
    Invoke-Command `
        -ComputerName dhcp `
        -ScriptBlock {
            <#
                Variables defined locally are not available in the remote
                session by default. The $using syntax, allows to make those
                variables available in the remote session.
            #>
            Add-LocalGroupMember `
                -Group 'DHCP Administrators' `
                -Member "$using:domain\$using:name"
        }
    ````

1. Leave Windows PowerShell open for the next task.

### Task 2: Create a share for PowerShell transcripts

#### Desktop experience

Perform these steps on DC1.

1. Logon as **smart\administrator**.
1. Open **Server Manager**.
1. In Server Manager, on the left-hand side, click **File and Storage Services**.
1. Click **Shares**.
1. Under **Shares**, click **TASKS**, **New Share...**
1. In **New Share Wizard**, under **File share profile**, select **SMB Share - Quick** and click **Next >**.
1. On page **Select the server and path for this share**, ensure **DC1** is selected, click **Type a custom path**, and click **Browser...**
1. In **Select Folder**, click **(C:)**, click **New Folder**, and enter **PS-Transcripts**.
1. Ensure **PS-Transcripts** is selected and click **Select Folder**.
1. Back on page **Select the server and path for this share**, click **Next >**.
1. On page **Specify share name**, accept the defaults and click **Next >**.
1. On page **Configure share settings**, accept the defaults and click **Next >**.
1. On page **Specify permissions to control access**, click **Customize permissions...**
1. In **Advanced Security Settings for PS-Transcripts**, on tab **Permissions**, click **Disable inheritance** and click **Convert inherited permissions into explicit permissions on this object.**
1. Click the following entries and click **Remove**:
    * **Users (SMART\Users)** (both entries)
    * **CREATOR OWNER**
1. Click **Add**.
1. In **Permission Entry for PS-Transcripts**, beside **Principal**, click **Select a principal** and search and select **Authenticated Users**.
1. Click **Show advanced permissions**.
1. Under **Advanced permissions**, ensure that only the following checkboxes are activated ([figure 2]) and click **OK**.

    * Read attributes
    * Create files / write data
    * Create folders / append data
    * Write attributes
    * Write extended attributes

1. Back in **Advanced Security Settings for PS-Transcripts**, click on tab **Share**.
1. On tab Share, click the entry for **Everyone** and click **Edit**.
1. In **Permission Entry for PS-Transcripts**, clear the checkbox beside **Full Control**. Ensure, **Change** and **Read** remain activated and click **OK**.
1. Back in **Advanced Security Settings for PS-Transcripts**, click **OK**.
1. Back on page Specify permissions to control access, click **Next >**.
1. On page **Confirmation**, click **Create**.
1. On page **Results**, click **Close**.

#### PowerShell

Perform these steps on DC1.

1. In **Windows PowerShell**, create a folder for the PowerShell transcripts

   ````powershell
   $path = 'C:\PS-transcripts'
   New-Item -Path $path -ItemType Directory
   ````

1. Disable inheritance for the new folder.

   ````powershell
   $acl = Get-Acl -Path $path
   
   # You can call .NET methods on objects using the syntax .Method(parameter)
   # first parameter disables inheritance, second preserves existing ACEs
   $acl.SetAccessRuleProtection($true, $true)
   ````

1. Change the permissions, resulting in ([figure 2]):

    ````powershell
    # First, remove the Users group
    $acl.Access | 
    Where-Object { $PSItem.IdentityReference -eq 'BUILTIN\Users' } | 
    ForEach-Object { $acl.RemoveAccessRule($PSItem) }

    # Remove the CREATOR OWNER group
    $acl.Access | 
    Where-Object { $PSItem.IdentityReference -eq 'CREATOR OWNER' } |
    ForEach-Object { $acl.RemoveAccessRule($PSItem) }

    # ACLs are made up from access rules
    # Unfortunately, there is no native PowerShell command to build access rules
    # Therefore, we use .NET objects, which can be create with New-Object
    # For more information about the FileSystemAccessRule constructor used in
    # this example, see
    # https://docs.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemaccessrule.-ctor?view=net-5.0#System_Security_AccessControl_FileSystemAccessRule__ctor_System_String_System_Security_AccessControl_FileSystemRights_System_Security_AccessControl_InheritanceFlags_System_Security_AccessControl_PropagationFlags_System_Security_AccessControl_AccessControlType_
        
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        'Authenticated Users', 
        @(
          'ReadAttributes', 
          'CreateFiles', 
          'CreateDirectories', 
          'WriteAttributes', 
          'WriteExtendedAttributes'
        ),
        'ContainerInherit, ObjectInherit', 
        'None', 
        'Allow'
    )
    $acl.AddAccessRule($accessRule)
    $acl | Set-Acl -Path $path
    ````

1. Share the folder and set the share permissions for **Everyone** to **Change**.

    ````powershell
    New-SmbShare -Path $path -Name PS-Transcripts -ChangeAccess Everyone
    ````

1. Leave **Windows PowerShell** open for upcoming tasks.

### Task 3: Enable PowerShell transcription and script logging

#### Desktop Experience

Perform these steps on DC1.

1. Open **Group Policy Management console**.
1. In Group Policy Management Console, in the domain **smart.etc**, create a new Group Policy Object named **PowerShell Settings** and link it to the domain ([figure 3]).
1. In the context menu of **PowerShell Settings**, click **Edit...**.
1. In **Group Policy Management Editor**, navigate to **Computer Configuration**, **Policies**, **Administrative Templates**, **Windows Components**, **Windows PowerShell**.
1. Open the setting **Turn on PowerShell Transcription** policy.
1. In Turn on PowerShell Transcription, click **Enabled**. In **Transcript output directory**, enter **\\DC1.smart.etc\PS-Transcripts** ([figure 4]) and click **OK**.
1. Close the **Group Policy Management Editor**.

#### PowerShell

Perform these steps on DC1.

1. In **Windows PowerShell**, create a new Group Policy Object name **PowerShell Settings**.

    ````powershell
    $name = 'PowerShell Settings'
    New-GPO -Name $name
    ````

1. In the new GPO, configure the settings for PowerShell transcription.

    ````powershell
    $key = 'HKLM\Software\Policies\Microsoft\Windows\PowerShell\Transcription'
    Set-GPRegistryValue `
        -Name $name `
        -Key $key `
        -ValueName EnableTranscripting `
        -Type DWord `
        -Value 1
    Set-GPRegistryValue `
        -Name $name `
        -Key $key `
        -ValueName OutputDirectory `
        -Type String `
        -Value '\\DC1.smart.etc\PS-Transcripts'
    Set-GPRegistryValue `
        -Name $name `
        -Key $key `
        -ValueName EnableInvocationHeader `
        -Disable
    ````

1. Link the new GPO to the domain.

    ````powershell
    $target = 'dc=smart,dc=etc'
    New-GPLink -Name $name -Target $target
    ````

### Task 4: Test PowerShell transcription

Perform these steps on DHCP.

1. Logon as **smart\dhcpadmin**.

    If you cannot switch users, in **Virtual Machine Connection**, click **View** and disable **Enhanced session**.

2. Refresh Group Policy:

    ````shell
    gpupdate
    ````

3. Start PowerShell.

    ````shell
    powerShell.exe
    ````

4. List services:

    ````powershell
    Get-Service
    ````

5. Try to list the transcripts on DC1.

    ````powershell
    Get-ChildItem \\DC1\PS-Transcripts
    ````

    The command should fail with an “Access Denied” error…

### Task 5: View PowerShell transcripts

#### Desktop experience

Perform these steps on DC1.

1. In **File Explorer**, open the folder **C:\PS-Transcripts**.
1. Open the subfolder with named after of today’s date.
1. Open the file starting with **PowerShell_transcript.DHCP**.

    Examine the PowerShell transcript of server DHCP. The transcript should include the Get-Service cmdlet as well as the Get-ChildItem command.

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, connect to **dc1.smart.etc**.
1. Connected to dc1.smart.etc, under **Tools**, click **Files & file sharing**.
1. In tab **Files**, open the folder **C:\PS-Transcripts**.
1. Open the subfolder with named after of today’s date.
1. Click the file starting with **PowerShell_transcript.DHCP**.
1. On the toolbar, click **Download**.

    You might have to click the More icon first (**...**).

    Examine the downloaded PowerShell transcript of server DHCP. The transcript should include the Get-Service cmdlet as well as the Get-ChildItem command.

#### PowerShell

Perform these steps on DC1.

1. In **Windows PowerShell**, open the folder **C:\PS-Transcripts**.

    ````powershell
    Set-Location C:\PS-transcripts\
    Get-ChildItem
    ````

1. Open the subfolder with named after of today’s date.

    ````powershell
    Set-Location # append the folder name
    Get-ChildItem
    ````

1. Open the file starting with **PowerShell_transcript.DHCP**.

    ````powershell
    Get-Content # append the file name
    ````

    or

    ````powershell
    notepad # append the file name
    ````

    Examine the PowerShell transcript of server DHCP. The transcript should include the Get-Service cmdlet as well as the Get-ChildItem command.

## Exercise 3: Deep script logging

### Introduction

In this exercise, you will enable script logging to log all PowerShell activity to the Event Log by modifying the existing GPO. Then, you will test the logging.

#### Tasks

1. [Enable deep script logging using GPO](#task-1-enable-deep-script-logging-using-gpo)
2. [Test deep script logging](#task-2-test-deep-script-logging)

### Task 1: Enable deep script logging using GPO

#### Desktop Experience

Perform these steps on DC1.

1. Switch to **Group Policy Management Console** and edit the **PowerShell Settings** group policy object.
1. In **Group Policy Management Editor**, navigate to **Computer Configuration**, **Policies**,**Administrative Templates**, **Windows Components**, **Windows PowerShell**.
1. Open the setting **Turn on PowerShell Script Block Logging**, click **Enabled**, and activate the checkbox **Log Script block invocation start / stop events** ([figure 5]). Click **OK**.
1. Close **Group Policy Management Editor**.
1. Execute ````gpupdate```` to refresh group policies.

#### PowerShell

Perform these steps on DC1.

1. Run **Windows PowerShell** as Administrator.
1. On the GPO **PowerShell Settings**, turn on PowerShell script block logging.

    ````powershell
    $name = 'PowerShell Settings'
    $key = 'HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
    Set-GPRegistryValue `
        -Name $name `
        -Key $key `
        -ValueName EnableScriptBlockLogging `
        -Type DWord `
        -Value 1
    Set-GPRegistryValue `
        -Name $name `
        -Key $key `
        -ValueName EnableScriptBlockInvocationLogging `
        -Type DWord `
        -Value 1
    ````

1. Refresh group policies.

    ````powershell
    gpupdate
    ````

### Task 2: Test deep script logging

#### Desktop experience

Perform these steps on DC1.

1. Close and reopen **Windows PowerShell** as Administrator.
1. Execute a command.

    ````powershell
    Write-Host -ForegroundColor Green 'Hello World'
    ````

1. Open **Event Viewer**.
1. In Event Viewer, navigate to **Applications and Services Logs**, **Microsoft**, **Windows**, **PowerShell**, **Operational**.
1. Filter for events with the ID 4104.
1. Search and examine events which include **Hello World**.

#### PowerShell

Perform these steps on DC1.

1. Close and reopen **Windows PowerShell** as Administrator.
1. Execute a command.

    ````powershell
    Write-Host -ForegroundColor Green 'Hello World'
    ````

1. From the log **Microsoft-Windows-PowerShell/Operational**, get events with the id 4104 and the message containing **Hello World** as list.

    ````powershell
    Get-WinEvent -LogName Microsoft-Windows-PowerShell/Operational | 
    Where-Object { 
        $PSItem.Id -eq 4104 -and $PSItem.Message -like '*Hello World*' 
    } |
    Format-List
    ````

## Exercise 4: Protected event log

### Introduction

In this exercise you will first request a document-signing certificate for the Administrator. You will export the public key to share, that can be read by Everyone. Then, you will enable protected event logging using the certificate. Finally, you will execute powershell commands on DHCP, verify that the event message is encrypted, and decrypt it.

#### Tasks

1. [Request a document-signing certificate and share the public key](#task-1-request-a-document-signing-certificate-and-share-the-public-key)
2. [Enable Protected Event Log using GPO](#task-2-enable-protected-event-Log-using-gpo)
3. [Test event log encryption](#task-3-test-event-log-encryption)
4. [Verify event log encryption and decryption](#task-4-verify-event-log-encryption-and-decryption)

### Task 1: Request a document-signing certificate and share the public key

#### Desktop Experience

Perform these steps on DC1.

1. Open **File Explorer** and create a new Folder **C:\PEL**.
1. Open the properties of the folder and share it with the following parameters:
    * Share name: PEL$
    * Permission: Everyone – Read
1. Test file share access by opening the path **\\DC1.smart.etc\pel$** in File Explorer.
1. Execute **certmgr.msc** to open the Certificate MMC for the current user.
1. In **certmgr**, in the context-menu of **Personal**, click **All Tasks**, **Request New Certificate...**
1. In **Certificate Enrollment**, on page **Before You Begin**, click **Next**.
1. On the **Select Certificate Enrollment Policy** page, click **Next**.
1. On the **Request Certificates** page, active the checkbox beside the template **DocumentEncryption** and click **Enroll**.
1. On the page **Certificate Installation Results**, click **Finish**.
1. In **certmgr** navigate to **Certificates - Current User**, **Personal**, **Certificates**.
1. Find the certificate *Issued To* your username with the **Certificate Template** of **DocumentEncryption** and, in the context-menu, click **All Tasks**, **Export...**.
1. In the **Certificate Export Wizard**, on page **Welcome to the Certificate Export Wizard**, click **Next**.
1. On page **Export Private Key**, click **No, do not export the private key** and click **Next**.
1. On page **Export File Format**, click **Base-64 encoded X.509 (.CER)** anc click **Next**.
1. On page **File to Export**, set **File name** to **C:\PEL\PEL-Cert.cer** and click **Next**.
1. On page **Completing the Certificate Export Wizard**, click **Finish**.
1. In the message box **The export was successful.**, click **OK**.

#### PowerShell

Perform these steps on DC1.

1. Run **Windows PowerShell** as Administrator.
1. Create a new folder **C:\PEL**.

    ````powershell
    $path = 'C:\PEL'
    New-Item -Path $path -ItemType Directory
    ````

1. Share the folder as PEL$ with permissions for everyone to read.

    ````powershell
    New-SmbShare -Path $path -Name PEL$ -ReadAccess Everyone
    ````

1. Test file share access by listing the path **\\DC1.smart.etc\pel$**.

    ````powershell
    Get-ChildItem -Path $path
    ````

    This will not return anything, but should be executed without an error message.

1. Request a new certificate based on the template **DocumentEncryption** and store it in the the certificate store of the current user.

    ````powershell
    $enrollmentResult = Get-Certificate `
        -Template DocumentEncryption `
        -CertStoreLocation Cert:\CurrentUser\My
    ````

1. Export the certificate with type **CERT** to **C:\PEL\PEL-Cert.cer**

    ````powershell
    $enrollmentResult.Certificate | 
    Export-Certificate -Type CERT -FilePath "$path\PEL-Cert.cer"
    ````

1. Leave Windows PowerShell open for the next task.

### Task 2: Enable Protected Event Log using GPO

#### Desktop Experience

Perform these steps on DC1.

1. Open **Group Policy Management console**.
1. In the context menu of the GPO **PowerShell Settings**, click **Edit...**.
1. In **Group Policy Management Editor**, navigate to **Computer Configuration**, **Policies**, **Administrative Templates**, **Windows Components**, **Event Logging**.
1. Open the setting **Enable Protected Event Logging**.
1. In Turn on PowerShell Transcription, click **Enabled**. In the text field below, enter **\\DC1.smart.etc\pel$\Pel-cert.cer** ([figure 7]) and click **OK**.
1. Close the **Group Policy Management Editor**.

#### PowerShell

1. In **Windows PowerShell**, for the GPO **PowerShell Settings**, configure protected event logging.

    ````powershell
    # $name = 'PowerShell Settings'
    $key = 'HKLM\Software\Policies\Microsoft\Windows\EventLog\ProtectedEventLogging'
    Set-GPRegistryValue `
        -Name $name `
        -Key $key `
        -ValueName EnableProtectedEventLogging `
        -Type DWord `
        -Value 1
    Set-GPRegistryValue `
        -Name $name `
        -Key $key `
        -ValueName EncryptionCertificate `
        -Type MultiString `
        -Value '\\DC1.smart.etc\pel$\Pel-cert.cer'
    ````

### Task 3: Test event log encryption

Perform these steps on DHCP.

1. Logon as **smart\Administrator**.
1. Refresh Group Policy.

    ````shell
    gpupdate
    ````

1. Open PowerShell.

    ````shell
    powershell.exe
    ````

1. Execute a command.

    ````powershell
    Write-Host -ForegroundColor Green 'Hello World'
    ````

### Task 4: Verify event log encryption and decryption

#### Desktop experience

Perform these steps on DC1.

1. Open **Computer Management** and connect to server **DHCP**.
1. In Computer Management, navigate to **System Tools**, **Event Viewer**, **Applications and Services Logs**, **Microsoft**, **Windows**, **PowerShell**, **Operational**.
1. Find an event with the **ID 4104**. and open it.

    The event message should be encrypted ([figure 8]).

1. Run **Windows PowerShell** as Administrator.
1. Decrypt the message part of the events.

    ````powershell
    Get-WinEvent `
        -ComputerName DHCP
        –MaxEvents 20
        -LogName 'Microsoft-Windows-PowerShell/Operational' | 
    Where-Object { $PSItem.ID -eq 4104 } |
    <# 
        ForEach-Object iterates through the events and executes the scriptblock
        in bracelets for each event. The event is referenced with the variable
        $PSItem.
    #>
    ForEach-Object { Unprotect-CmsMessage -Content $PSItem.Message }
    ````

    Examine the output to find the command you executed on DHCP.

1. Switch to **Group Policy Management**.
1. From the context-menu of the GPO **PowerShell Settings**, click **Link Enabled** to disable the link.

1. On machines DC1 and DHCP refresh group policy.

    ````shell
    gpupdate
    ````

#### PowerShell

1. In Windows PowerShell, retrieve the **PowerShell** event log from server **DHCP**.

    ````powershell
    $computerName = 'DHCP'
    $maxEvents = 20
    $logName = 'Microsoft-Windows-PowerShell/Operational'
    $iD = 4104
    Get-WinEvent `
        -ComputerName $computername `
        –MaxEvents $maxEvents `
        -LogName $logName | 
    Where-Object { $PSItem.ID -eq $iD } |
    Format-List
    ````

1. Decrypt the message part of the events.

    ````powershell
    Get-WinEvent `
        -ComputerName $computername `
        –MaxEvents $maxEvents `
        -LogName $logName | 
    Where-Object { $PSItem.ID -eq $iD } |
    <# 
        ForEach-Object iterates through the events and executes the scriptblock
        in bracelets for each event. The event is referenced with the variable
        $PSItem.
    #>
    ForEach-Object { Unprotect-CmsMessage -Content $PSItem.Message }
    ````

    Examine the output to find the command you executed on DHCP.

1. Disable the link to GPO **PowerShell Settings** at domain level.

    ````powershell
    # $name = 'PowerShell Settings'
    # $target = 'dc=smart,dc=etc'

    Set-GPLink -Name $name -Target $target -LinkEnabled No
    ````

## Exercise 5: Just Enough Administration (JEA)

### Introduction

In this exercise, you will first create a user with the right to read properties of the DHCP server on DHCP. Then, you will create a JEA configuration allowing the group DHCP users to use the Get-cmdlets of the DhcpServer module only and register the session configuration on DHCP. Finally, you will test the capabilities of the user you created at the start of the lab on DHCP using explicit and implicit remoting.

#### Tasks

1. [Create a user allowed to read DHCP](#task-1-create-a-user-allowed-to-read-dhcp)
1. [Create a JEA Session configuration](#task-2-create-a-jea-session-configuration)
1. [Register JEA Session configuration](#task-3-register-a-jea-session-configuration)
1. [Test JEA](#task-4-test-jea)

### Task 1: Create a user allowed to read DHCP

#### Desktop experience

Perform these steps on DC1.

1. Logon as **smart\administrator**.
1. Open **Active Directory Users and Computers**.
1. In Active Directory Users and Computers, in **Users**, create a new user named **dhcpuser** with the password **Pa$$w0rd**. Clear the checkbox **User must change password at next logon**.
1. Open **Computer Management** and connect to **DHCP**.
1. In Computer Management on DHCP, add the user **dhcpuser** to the local group **DHCP Users**.

#### Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Google Chrome** and navigate to **https://admincenter.smart.etc**.
1. On the page Windows Admin Center, if the server **DC1** is not listed, click **Add**. Under **Servers**, click **Add**. In **Server name**, enter **DC1** and click **Add**.
1. On the page Windows Admin Center, connect to **DC1.smart.etc**.
1. Connected to DC1.smart.etc, under **Tools**, click **Active Directory**.

    If you do not see Active Directory, install the extension from Windows Admin Center Settings.

1. In Active Directory Domain Services, click Create, User.
1. Complete the **Add User** pane, to create a user named **dhcpuser** with the password **Pa$$w0rd** in the **Users** container.
1. Go back to the home page of **Windows Admin Center**.
1. On the page Windows Admin Center, if the server **DHCP** is not listed, click **Add**. Under **Servers**, click **Add**. In **Server name**, enter **DHCP** and click **Add**.

    You might have to add credentials manually.

1. On the page Windows Admin Center, connect to **dhcp.smart.etc**.
1. Connected to DHCP.smart.etc, under **Tools**, click **Local users & groups**.
1. In Local users and groups, click the tab **Groups**.
1. On the tab **Groups**, click DHCP Administrators.
1. In the pane **Details - DHCP Users**, click **Add user**.
1. In the pane **Add a user to the DHCP Administrators group**, in **Username**, enter **smart\dhcpuser** and click **Submit**.

#### PowerShell

Perform these steps on DC1.

1. Logon as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Create a new user named **dhcpuser** with the password **Pa$$w0rd** in the default users container.

    ````powershell
    $name = 'dhcpuser'
    $domain = 'smart'

    New-ADUser `
        -Path "cn=users,dc=$domain,dc=etc" `
        -Name $name `
        -AccountPassword (Read-Host -Prompt 'Password' -AsSecureString) `
        -ChangePasswordAtLogon $false
        -Enabled $true `
    ````

1. Add the user **dhcpuser** to the local group **DHCP Users** on the server **dhcp**.

    ````powershell
    Invoke-Command `
        -ComputerName dhcp `
        -ScriptBlock {
            Add-LocalGroupMember `
                -Group 'DHCP Users' `
                -Member "$using:domain\$using:name"
        }
    ````

1. Leave Windows PowerShell open for the next task.

### Task 2: Create a JEA Session configuration

#### Desktop experience

Perform these steps on DC1.

1. Open **File Explorer**.
1. In File Explorer, create a folder **C:\SessionConfigurations**.
1. Navigate to **L:\PowerShell\JEAHelperTool20**.
1. In the context-menu of **JEAHelperTool.ps1**, click **Run with PowerShell**.
1. In JEA Helper Tool, on tab **Create or Edit Role Capability**, enter this information ([figure 9]).

    | Label                    | Value             |
    |--------------------------|-------------------|
    | **Role Capability Name** | DHCPViewAdmin     |
    | **Module Name**          | JEA-DHCPViewAdmin |
    | **Author**               | Administrator     |
    | **Company**              | Smart             |

1. Click **Create** to create the new role capability file.
1. Click tab **Role Capabilities Design**.
1. On tab Role Capabilities Design, in the dropdown **Or you can add a full/partial module, or use it to filter the cmdlets list** , select **DhcpServer**.
1. Click **Add Get-* only** ([figure 10]).
1. Click the button **copy to clipboard**.
1. Click the tab **Create or Edit Role Capability**.
1. On the tab Create or Edit Role Capability, in the text field, find the text **Copyright = '(c) 202x Administrator. All rights reserved.** Paste the contents you copied in the previous step ([figure 12]).
1. Click the button **Save any changes**.
1. Click the tab **Configurations Listings, Mapping and Testing**.
1. On the tab Configuration Listing, Mapping and Testing, under **Create new Session Configuration**, in the text box **Name for new Session Configuration**, type **JEA-DHCPViewAdmin**.
1. In the text box **Session Configuration Files Location**, type **C:\SessionConfigurations**.
1. Click the button **Add Row**.
1. In the row you created, in **User or Group**, type **dhcp users**, in **Role Capability**, type **DHCPViewAdmin**.
1. Clear the checkbox **Register session on local machine** ([figure 13]).
1. Click **Create!**.
1. Close **JEA Helper Tool**.
1. Switch to **File Explorer**.
1. Navigate to **C:\Program Files\WindowsPowerShell\Modules**.

    You should find a folder **JEA-DHCPViewAdmin**. Examine the structure of the folder: it contains a module manifest file **JEA-DHCPViewAdmin.psd1** and a subfolder **RoleCapabilities** which contains our role capability file **DHCPViewAdmin.psrc**.

1. Copy the folder **JEA-DHCPViewAdmin** to **\\\dhcp\c$\Program Files\WindowsPowerShell\Modules**.

1. Navigate to **\\\dhcp\c$**.

1. Create a folder **\\\dhcp\c$\SessionConfigurations**.

1. Navigate to **C:\SessionConfigurations**.

    You should find the session configuration file **JEA-DHCPViewAdmin.pssc**.

1. Copy the file **C:\SessionConfigurations\JEA-DHCPViewAdmin.pssc** to **\\\dhcp\c$\SessionConfigurations**.

#### PowerShell

Perform these steps on CL1.

1. Open **Windows PowerShell ISE**.

    The commands in the next steps in this task should be executed in the command pane of Windows PowerShell ISE.

1. Create a folder for the role capabilities module.

    ````powershell
    $name = 'JEA-DHCPViewAdmin' # The name of the module
    <#
        Join-Path is the recommended command to create path strings.
        The environment variable PSModulePath contains the list of default
        module paths for PowerShell. The -split operator splits the semicolon
        separated string. The first entry usually points to the
        user's module directory. 
    #>
    $modulePath = Join-Path -Path ($env:PSModulePath -split ';')[0] -ChildPath $name
    New-Item -Path $modulePath -ItemType Directory
    ````

1. Create a module manifest for the role capabilities module.

    ````powershell
    $author = 'Administrator'
    $companyName = 'smart'
    New-ModuleManifest `
        -Path (Join-Path -Path $modulePath -ChildPath "$name.psd1") `
        -Author $author `
        -CompanyName $companyName
    ````

1. Create the directory for the role capabilities file.

    ````powershell
    $roleCapabilitiesPath = Join-Path -Path $path -ChildPath RoleCapabilities
    New-Item $roleCapabilitiesPath -ItemType Directory
    ````

    Take note of the path, where the directory was created.

1. Create a role capabilities file.

    ````powershell
    New-PSRoleCapabilityFile `
        -Path (
            Join-Path -Path $roleCapabilitiesPath -ChildPath DHCPViewAdmin.psrc
        ) `
        -Author $author `
        -CompanyName $companyName
    ````

1. Leave **Windows PowerShell** open.
1. Open **Windows PowerShell ISE**.
1. In Windows PowerShell ISE, open the role capabilities file **DHCPViewAdmin.psrc** created in a previous step (should be **Documents\WindowsPowerShell\Modules\JEA-DHCPViewAdmin\RoleCapabilities\DHCPViewAdmin.psrc**).
1. In the file DHCPViewAdmin.psrc, find the line starting with ````# VisibleCmdLets````.

    Notice the examples between the quotation marks in the line.

1. Replace the line making all cmdlets of the DhcpServer modules starting with Get- available.

    ````powershell
    VisibleCmdLets = 'DhcpServer\Get-*'
    ````

    The first lines of the file should now look like this (except for the GUID, which should be different, and the year of copyright, which might be different):

    ````powershell
    @{

    # ID used to uniquely identify this document
    GUID = '866baae3-d8ea-4b10-8cc2-30ab873746a2'

    # Author of this document
    Author = 'Administrator'

    # Description of the functionality provided by these settings
    # Description = ''

    # Company associated with this document
    CompanyName = 'smart'

    # Copyright statement for this document
    Copyright = '(c) 2021 Administrator. All rights reserved.'

    # Modules to import when applied to a session
    # ModulesToImport = 'MyCustomModule', @{ ModuleName = 'MyCustomModule'; ModuleVersion = '1.0.0.0'; GUID = '4d30d5f0-cb16-4898-812d-f20a6c596bdf' }

    # Aliases to make visible when applied to a session
    # VisibleAliases = 'Item1', 'Item2'

    # Cmdlets to make visible when applied to a session
    VisibleCmdlets = 'DhcpServer\Get-*'
    ````

    Instead of editing the role capablities file, you could have created it with the VisibleCmdlets parameter directly, like this:

    ````powershell
    New-PSRoleCapabilityFile `
        -Path (
            Join-Path -Path $roleCapabilitiesPath -ChildPath DHCPViewAdmin.psrc
        ) `
        -Author $author 
        -CompanyName $companyName 
        -VisibleCmdlets 'DhcpServer\Get-*'
    ````

1. Create a directory for session configurations.

    ````powershell
    $path = 'C:\SessionConfigurations'
    New-Item $path -ItemType Directory
    ````

1. In the new directory, create a session configuration file with the name JEA-DHCPViewAdmin.

    ````powershell
    $sessionConfigurationPath = Join-Path `
        -Path $path `
        -ChildPath 'JEA-DHCPViewAdmin.pssc'
    New-PSSessionConfigurationFile `
        -Path $sessionConfigurationPath `
        -Author $author `
        -CompanyName $companyName
    ````

1. In Windows PowerShell ISE, open the file **C:\SessionConfigurations\JEA-DHCPViewAdmin.pssc**.
1. In the file JEA-DHCPViewAdmin.psssc, find the line ````SessionType = 'Default'```` and change it to read:

    ````powershell
    SessionType = 'RestrictedRemoteServer'
    ````

1. Find the line ````# TranscriptDirectory = 'C:\Transcripts'```` and remove the number sign and the space at the beginning. The line should read:

    ````powershell
    TranscriptDirectory = 'C:\Transcripts\'
    ````

1. Find the line ````# RunAsVirtualSccount = $true```` and remove the number sign and the space at the beginning. The line should read:

    ````powershell
    RunAsVirtualAccount = $true
    ````

1. Find the line starting with ````# RoleDefinitions =````.

    Notice the examples between the bracelets.

1. Replace the line with

    ````powershell
    RoleDefinitions = @{ 
        'dhcp users' = @{ 'RoleCapabilities' = 'DHCPViewAdmin' } 
    }
    ````

    The file should now look like this (except for the GUID, which should be different):

    ````powershell
    @{

    # Version number of the schema used for this document
    SchemaVersion = '2.0.0.0'

    # ID used to uniquely identify this document
    GUID = '42ea2ed7-ac24-4622-9a23-8f7cbeb8c900'

    # Author of this document
    Author = 'Administrator'

    # Description of the functionality provided by these settings
    # Description = ''

    # Company associated with this document
    CompanyName = 'smart'

    # Session type defaults to apply for this session configuration. Can be 'RestrictedRemoteServer' (recommended), 'Empty', or 'Default'
    SessionType = 'RestrictedRemoteServer'

    # Directory to place session transcripts for this session configuration
    TranscriptDirectory = 'C:\Transcripts\'

    # Whether to run this session configuration as the machine's (virtual) administrator account
    RunAsVirtualAccount = $true

    # Scripts to run when applied to a session
    # ScriptsToProcess = 'C:\ConfigData\InitScript1.ps1', 'C:\ConfigData\InitScript2.ps1'

    # User roles (security groups), and the role capabilities that should be applied to them when applied to a session
    RoleDefinitions = @{
        'dhcp users' = @{ 'RoleCapabilities' = 'DHCPViewAdmin' }
    }

    }
    ````

    Alternatively, you could have created the session configuration file without the need for editing with this command:

    ````powershell
    New-PSSessionConfigurationFile `
        -Path $sessionConfigurationPath `
        -Author $author `
        -CompanyName $companyName `
        -SessionType RestrictedRemoteServer `
        -TranscriptDirectory C:\Transcripts `
        -RoleDefinitions @{ 
            'dhcp users' = @{ 'RoleCapabilities' = 'DHCPViewAdmin' }
        }
    ````

1. Copy the module directory to **\\dhcp\c$\Program Files\WindowsPowerShell\Modules**.

    ````powershell
    Copy-Item `
        -Path $modulePath `
        -Destination '\\dhcp\c$\Program Files\WindowsPowerShell\Modules\' `
        -Recurse
    ````

1. Create a directory **\\\dhcp\c$\SessionConfigurations**.

    ````powershell
    $destination = '\\dhcp\c$\SessionConfigurations'
    New-Item -Path $destination -ItemType Directory
    ````

1. Copy the session configuration file **\\\dhcp\c$\SessionConfigurations** to the directory created in the previous step.

    ````powershell
    Copy-Item $sessionConfigurationPath $destination
    ````

### Task 3:  Register a JEA Session configuration

Perform these steps on DHCP.

1. Logon as **smart\administrator**.
1. Run Windows PowerShell.

    ````shell
    powershell
    ````

1. Register the JEA session configuration.

    ````powershell
    Register-PSSessionConfiguration `
        -Name DHCPViewAdmin `
        -Path C:\SessionConfigurations\JEA-DHCPViewAdmin.pssc  
    ````

1. Log off.

### Task 4: Test JEA

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Windows PowerShell**.
1. Open a remote PowerShell session to server **DHCP** with user **smart\dhcpuser**.

    ````powershell
    Enter-PSSession `
        -ComputerName DHCP `
        -Credential smart\dhcpuser
    ````

    You should get an **Access denied** error.

1. Open a remote PowerShell session to server **DHCP** with user **smart\dhcpuser** and specify the configuration **DHCPViewAdmin**.

    ````powershell
    Enter-PSSession `
        -ComputerName DHCP `
        -Credential smart\dhcpuser `
        -ConfigurationName DHCPViewAdmin
    ````

1. List the available commands.

    ````powershell
    Get-Command
    ````

1. List the available IPv4 DHCP scopes.

    ````powershell
    Get-DHCPServerv4Scope
    ````

    *Note:* Tab completion is not available in interactive JEA configuration sessions.

1. Get a list of services.

    ````powershell
    Get-Service
    ````

    This will not work, because the command is not in the scope of the session configuration.

1. Exit the session.

    ````powershell
    exit
    ````

1. Use implicit remoting to use the session configuration **DHCPViewAdmin** on **DHCP** with the user **smart\dhcpuser**.

    ````powershell
    $session = New-PSSession `
        -ComputerName dhcp `
        -Credential smart\dhcpuser `
        -ConfigurationName DHCPViewAdmin
    $moduleInfo = Import-PSSession $session
    $moduleInfo
    ````

    This not only imports the session into our local PowerShell session, but also stores the information about the temporary created module in a variable. The last command shows info about this temporary module.

1. List imported commands.

    ````powershell
    Get-Command $moduleInfo
    ````

1. List the available IPv4 DHCP scopes. This time command completion using TAB should be available.

    ````powershell
    Get-DHCPServerv4Scope
    ````

    This command should return exactly the same result as in the previous step.

1. Get a list of services.

    ````powershell
    Get-Service
    ````

    Now, this command will work. But it will not return the services running on dhcp but rather the services of the local machine CL1.

1. Remove the imported session.

    ````powershell
    Remove-PSSession $session
    ````

## Exercise 6: Package Management

### Introduction

In this exercise, you will first discover package sources and set the PSGallery package source as trusted. Then, you will list the installed packages and install the nuget package provider. You will find, install and try the AutoRuns package. Finally you will download find the Azure Actve Directory Module by Microsoft in version 1. You will save the module for later install. Then you will install the module by copying it to the correct destination.

#### Tasks

1. [Discover packages and install NuGet](#task-1-discover-packages-and-install-nuget)
1. [Find packages and install a package](#task-2-find-modules-and-install-a-package)
1. [Save a package for later use](#task-3-save-a-package-for-later-use)

### Task 1: Discover packages and install NuGet

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Set the execution policy to **RemoteSigned**.

    ````powershell
    Set-ExecutionPolicy RemoteSigned -Confirm:$false
    ````

1. List all the package management cmdlets.

    ````powershell
    Get-Command -Module PackageManagement
    ````

1. List current package sources.

    ````powershell
    Get-PackageSource
    ````

1. Set package source **PSGallery** as trusted.

    ````powershell
    Set-PackageSource -Name PSGallery -Trusted
    ````

1. List all installed packages.

    ````powershell
    Get-Package
    ````

1. Install the **nuget** package provider.

    ````powershell
    Install-PackageProvider -Name nuget
    ````

### Task 2: Find modules and install a package

Perform these steps on CL1.

1. Find all modules in the repository.

    ````powershell
    Find-Module
    ````

    This will return many modules and run for a long time. You can break the the execution by pressing CTRL + C.

1. Find the module **AutoRuns**.

    ````powershell
    Find-Module AutoRuns
    ````

1. Install the module **Autoruns**.

    ````powershell
    Install-Package AutoRuns
    ````

1. List all installed packages.

    ````powershell
    Get-Mackage
    ````

    AutoRuns should be listed.

1. Get a list of available modules.

    ````powershell
    Get-Module -ListAvailable
    ````

    AutoRuns should be listed near the top.

1. Open **File Explorer** and navigate to **C:\Program Files\WindowsPowerShell\Modules**.

    A folder **AutoRuns** should exist. This is where the module was installed to.

1. Switch back to **Windows PowerShell**.
1. Load the module **AutoRuns**.

    ````powershell
    Import-Module AutoRuns
    ````

1. List the commands provided by the module **AutoRuns**.

    ````powershell
    Get-Command -Module AutoRuns
    ````

1. Use a cmdlet provided by the Autoruns module to query the boot execution list.

    ````powershell
    Get-PSAutorun -BootExecute
    ````

### Task 3: Save a package for later use

Perform these steps on CL1.

1. Find the module **Microsoft Azure Active Directory Version 1** in the repository.

    ````powershell
    Find-Module -Filter 'Azure Active' |
    Where-Object {
        $PSitem.Version -like '1.*' ` -and $PSItem.Author -like "Microsoft*"
    }
    ````

    This should return the module **MSOnline**.

1. Save the module **MSOnline**  for later use.

    ````powershell
    $path = 'C:\Modules'
    New-Item -Path $path -ItemType Directory
    Save-Module MSOnline -Path $path
    ````

1. Switch to **File Explorer**.
1. Navigate to **C:\Modules** and make sure the folder **MSOnline** exists.
1. Switch back to **Windows PowerShell**.
1. Get a list of available modules named **MSOnline**

    ````powershell
    Get-Module MSOnline -ListAvailable
    ````

    This should return nothing.

1. Copy the folder **C:\Modules\MSOnline** to **C:\Program Files\WindowsPowerShell\Modules**.

    ````powershell
    Copy-Item `
        -Path "$path\MSOnline" `
        -Destination "$($env:ProgramFiles)\WindowsPowerShell\Modules" `
        -Recurse
    ````

1. Get a list of available modules named **MSOnline**

    ````powershell
    Get-Module MSOnline -ListAvailable
    ````

    Now, MSOnline should be returned.

[figure 1]: images/hyperv-vm-settings-networkadapter.png
[figure 2]: images/Permission-Entry-PS-Transcripts.png
[figure 3]: images/GPO-create-and-link-domain.png
[figure 4]: images/GPO-turn-on-powershell-transcription.png
[figure 5]: images/GPO-turn-on-powershell-script-block-logging.png
[figure 6]: images/WAC-events-filter-icon.png
[figure 7]: images/GPO-enable-protected-event-logging.png
[figure 8]: images/Eventvwr-event-encrypted.png
[figure 9]: images/JEA-helper-tool-create-or-edit-role-capability.png
[figure 10]: images/JEA-helper-tool-role-capabilities-design.png
[figure 11]: images/JEA-helper-tool-role-capabilities-design-script.png
[figure 12]: images/JEA-helper-tool-create-or-edit-role-capability-script.png
[figure 13]: images/JEA-helper-tool-configurations-listings-mapping-and-testing.png