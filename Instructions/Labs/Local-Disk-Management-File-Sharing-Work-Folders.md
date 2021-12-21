# Lab: Local Disk Management, File Sharing & Work Folders

## Required VMs

* DC1
* DHCP
* Router
* FS on HV1
* PKI
* CL1
* SRV2

## Exercises

1. [Working with local disks](#exercise-1-working-with-local-disks)
1. [File Sharing](#exercise-2-file-sharing)
1. [Work folders](#exercise-3-work-folders)

## Exercise 1: Working with local disks

### Introduction

In this exercise, you will create a 10 GB and a 15 GB volume on Disk 2 of FS and format them with NTFS and ReFS. Then, you will change the size of the volume to 5 GB and 20 GB. Finally, you will create a symbolik link from F:\LabFiles to \\dc1\Labfiles

#### Tasks

1. [Working with disks and volumes](#task-1-working-with-disks-and-volumes)

### Task 1: Working with disks and volumes

#### Desktop Experience

Perform these steps on FS.

1. Logon as **smart\administrator**.
1. From the context menu of the start button, open **Disk Management**.
1. Bring **Disk2** online and initialize it as GPT disk.
1. Create two simple volumes ([figure 1]).

   * Volume 1: **10GB**, filesystem **NTFS**, drive letter **E:**
   * Volume 2: **15GB**, filesystem **ReFS**, drive letter **F:**

1. Change the size of the volumes to (use shrink/expand from the context menu):
   * Volume 1: 5 GB
   * Volume 2: 20 GB

   > Can you shrink volume 2?

1. Open a **Command Prompt**.
1. Create a new symbolic link on the ReFS Volume that points to the Labfiles share.

   ````shell
   mklink F:\Labfiles \\dc1\Labfiles /D
   ````

1. Open **File Explorer** and navigate to **F:\Labfiles** ([figure 2]). Compare the contents to that of drive **L:**. It should match.

#### Windows Admin Center

Perform these steps on CL1.

1. Return to the home page of **Windows Admin Center**.
1. Add a server connection to **FS**.
1. Connect to **FS**.
1. Click **Storage**.
1. In **Storage**, select **Disk 2**-
1. With **Disk 2** selected, on the toolbar, click **Initialize Disk**.
1. As **Partition style**, select **GPT (GUID Partition Table)**.
1. With **Disk 2** still selected, create two simple volumes.

   * Volume 1: **10GB**, filesystem **NTFS**, drive letter **E:**
   * Volume 2: **15GB**, filesystem **ReFS**, drive letter **F:**

1. Change the size of the volumes to (select volume and click **Resize** at the bottom).
   * Volume 1: 5 GB
   * Volume 2: 20 GB

   > Can you shrink volume 2?

1. On the left, click **Remote Desktop**.
1. Logon as **smart\Administrator**.
1. Open a **Command Prompt**.
1. Create a new symbolic link on the ReFS Volume that points to the Labfiles share.

   ```shell
   mklink F:\Labfiles \\dc1\Labfiles /D
   ````

   If you have trouble entering the back slash, use the on-screen keyboard.

1. Open **File Explorer** and navigate to **F:\Labfiles** ([figure 2]). Compare the contents to that of drive **L:**. It should match.

1. Logoff from the Remote Desktop session.

#### PowerShell

Perform these steps on FS.

1. Logon as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Bring Disk2 online and initialize it as GPT disk.

   ````powershell
   $diskNumber = 2
   Set-Disk -Number $diskNumber -IsOffline $false
   Initialize-Disk -Number $diskNumber -PartitionStyle GPT
   ````

1. Create two simple volumes ([figure 1]).
   * Volume 1: **10GB**, filesystem **NTFS**, drive letter **E:**
   * Volume 2: **15GB**, filesystem **ReFS**, drive letter **F:**

   ````powershell
   New-Partition -DiskNumber $diskNumber -Size 10GB -DriveLetter E
   Format-Volume -DriveLetter E -FileSystem NTFS
   New-Partition -DiskNumber $diskNumber -Size 15GB -DriveLetter F
   Format-Volume -DriveLetter F -FileSystem ReFS
   ````

1. Change the size of the volumes.
   * Volume 1: 5 GB
   * Volume 2: 20 GB

   ````powershell
   Resize-Partition -DriveLetter E -Size 5GB
   Resize-Partition -DriveLetter F -Size 20GB
   ````

   > Can you shrink volume 2?

1. Create a new symbolic link on the ReFS Volume that points to the Labfiles share.

   ````powershell
   # The back tick ` can be used to split long command lines and make them more readable
   New-Item `
      -ItemType SymbolicLink `
      -Path F:\ `
      -Name Labfiles `
      -Value \\dc1\Labfiles
   ````

1. Compare the contents to that of drive **L:**. It should match.

   ````powershell
   Get-ChildItem F:\Labfiles
   Get-ChildItem \\dc1\Labfiles
   ````

1. Leave **Windows PowerShell** open for the next exercise.

## Exercise 2: File Sharing

### Introduction

In this exercise, you will create the domain-local groups DL_Training and DL_Presentations, and the global groups G_Training and G_Sales in the domain. The group G_Sales will be a member of DL_Presentations, and G_Training will be a member of DL_Training. You will add User2 as a member of G_Training, and User1 as a member of G_Sales. Then you will install the file server role on FS, create two new folders on D: of FS and copy some documents from L:\Sampledocuments to them. Next, you will create shares with the new folders and give  DL_Training and DL_Presentations Modify permissions on them, repectively. After testing the file shares from CL1, you will remove DL_Presentations from the ACL of the Presentations share and test it again.

#### Tasks

1. [Create Groups in Active Directory](#task-1-create-groups-in-active-directory)
1. [Configure file shares](#task-2-configure-file-shares)
1. [Test file shares](#task-3-test-file-shares)
1. [Modify permissions](#task-4-modify-permissions)
1. [Test modified permissions](#task-5-test-modified-permissions)

### Task 1: Create groups in Active Directory

#### Desktop Experience

Perform these steps on DC1.

1. Open **Active Directory Administrative Center**.
1. Create the following **Domain Local** **Security** groups in the **Users** container ([figure 3]).

   * DL_Training
   * DL_Presentations

1. Create a **Global** group **G_Training** and add it as a member of group **DL_Training** ([figure 4]).
1. Add **User2** as a member to the **G_Training** global group.
1. Create a new **Global** group **G_Sales** and add it as a member to the group **DL_Presentations**.
1. Add user **User1** as a member to the **G_Sales** global group.

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, connect to **dc1.smart.etc**.
1. On the left, click **Active Directory**.
1. Create the following **Domain Local** **Security** groups in the **Users** container.

   * DL_Training
   * DL_Presentations

1. Create a **Global** group **G_Training** and add it as a member of group **DL_Training**.
1. Add **User2** as a member to the **G_Training** global group.
1. Create a new **Global** group **G_Sales** and add it as a member to the group **DL_Presentations**.
1. Add user **User1** as a member to the **G_Sales** global group.

#### PowerShell

Perform these steps on DC1.

1. Run **Windows PowerShell** as Administrator
1. Create the following **Domain Local** **Security** groups in the **Users** container.

   * DL_Training
   * DL_Presentations

   ````powershell
   $Path = 'CN=Users, DC=smart, DC=etc'
   New-ADGroup `
      -Name DL_Training `
      -Path $Path `
      -GroupCategory Security `
      -GroupScope DomainLocal
   New-ADGroup `
      -Name DL_Presentations `
      -Path $Path `
      -GroupCategory Security `
      -GroupScope DomainLocal
   ````

1. Create a **Global** group **G_Training** and add it as a member of group **DL_Training**.

   ````powershell
   New-ADGroup `
       -Name G_Training `
       -Path $Path `
       -GroupCategory Security `
       -GroupScope Global
   Add-ADGroupMember -Identity DL_Training -Members G_Training
   ````

1. Add **User2** as a member to the **G_Training** global group.

   ````powershell
   Add-ADGroupMember -Identity G_Training -Members User2
   ````

1. Create a new **Global** group **G_Sales** and add it as a member to the group **DL_Presentations**.

   ````powershell
   New-ADGroup `
      -Name G_Sales `
      -Path $Path `
      -GroupCategory Security `
      -GroupScope Global
   Add-ADGroupMember -Identity DL_Presentations -Members G_Sales
   ````

1. Add user **User1** as a member to the **G_Sales** global group.

   ````powershell
   Add-ADGroupMember -Identity G_Sales -Members User1
   ````

### Task 2: Configure file shares

#### Desktop Experience

Perform these steps on FS.

1. Open **Server Manager**.
1. Install the role **File Server** ([figure 5]).
1. Switch to File Explorer
1. Create two new folders on **D:\\**.
    * Presentations
    * Training
1. Copy some documents from **L:\SampleDocuments** to **D:\Presentations** and **D:\Training**.
1. Switch to Server Manager.
1. On the left, click on **File and Storage Services**.
1. Click on **Shares**.
1. Click **To create a file share, start the New Share Wizard** ([figure 6]).
1. Go through the wizard and providing these parameters.
   * **SMB Share – Quick**
   * Custom path **D:\Training**
   * Share name: **Training**
   * **Enable Access-based enumeration**
1. On the permissions wizard page, click on **Customize permissions**.
1. Disable inheritance ([figure 7]) and commit the changes with **Convert…** ([figure 8]).
1. Change the permissions, resulting in ([figure 9]):
   * DL_Training: **Modify**
   * SYSTEM: **Full Control**
   * Administrators: **Full Control**
1. Click the tab **Share**.
1. Modify Share Permissions to **Everyone:** **Change**.
1. Click **OK** to commit the changes.
1. Click **Next** and then create to create the share.
1. Create another share with the name **Presentations** with the path **D:\Presentations**. The group **DL_Presentations** must have **Modify** permissions (**SYSTEM** and **Administrators** must have **Full Control**).

#### PowerShell

Perform these steps on FS.

1. Install the role **File Server**.

   ````powershell
   Install-WindowsFeature -Name 'FS-FileServer'
   ````

1. Create two new folders on **D:\\**.
   * Presentations
   * Training

   ````powershell
   $presentationsPath = 'D:\Presentations'
   $trainingPath = 'D:\Training'
   New-Item -Path $presentationsPath -ItemType Directory
   New-Item -Path $trainingPath -ItemType Directory
   ````

1. Copy some documents from **L:\SampleDocuments** to **D:\Presentations** and **D:\Training**.

   ````powershell
   # In PowerShell commands can be combined using pipelines using the | symbol
   # The output from the left command servers as input for the right command
   Get-ChildItem -Path L:\SampleDocuments | 
   Select-Object -First 10 | 
   Copy-Item -Destination $PresentationsPath -Recurse

   Get-ChildItem -Path L:\SampleDocuments | 
   Select-Object -Last 10 | 
   Copy-Item -Destination $TrainingPath -Recurse
   ````

1. Create a share for the training folder.

   ````powershell
   New-SmbShare `
      -Path $TrainingPath `
      -Name Training `
      -FolderEnumerationMode AccessBased `
      -ChangeAccess Everyone
   ````

1. Disable inheritance.

   ````powershell
   $acl = Get-Acl -Path $TrainingPath
   
   # You can call .NET methods on objects using the syntax .Method(parameter)
   # first parameter disables inheritance, second preserves existing ACEs
   $acl.SetAccessRuleProtection($true, $true)
   ````

1. Change the permissions, resulting in ([figure 9]):
   * DL_Training: **Modify**
   * SYSTEM: **Full Control**
   * Administrators: **Full Control**

   ````powershell

   # First, remove the Users group
   $acl.Access | 
   Where-Object { $PSItem.IdentityReference -eq 'BUILTIN\Users' } | 
   ForEach-Object { $acl.RemoveAccessRule($PSItem) }

   # ACLs are made up from access rules
   # Unfortunately, there is no native PowerShell command to build access rules
   # Therefore, we use .NET objects, which can be create with New-Object
   # For more information about the FileSystemAccessRule constructor used in
   # this example, see https://docs.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemaccessrule.-ctor?view=net-5.0#System_Security_AccessControl_FileSystemAccessRule__ctor_System_String_System_Security_AccessControl_FileSystemRights_System_Security_AccessControl_InheritanceFlags_System_Security_AccessControl_PropagationFlags_System_Security_AccessControl_AccessControlType_
    
   $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
      'smart\DL_Training', 
      'Modify', 
      'ContainerInherit, ObjectInherit', 
      'None', 
      'Allow'
   )
   $acl.AddAccessRule($accessRule)
   $acl | Set-Acl -Path $trainingPath
   ````

1. Create another share with the name **Presentations** with the path **D:\Presentations**. The group **DL_Presentaions** must have **Modify** permissions (**SYSTEM** and **Administrators** must have **Full Control**).

   ````powershell
   New-SmbShare `
      -Path $PresentationsPath `
      -Name Presentations `
      -FolderEnumerationMode AccessBased `
      -ChangeAccess Everyone
   $acl = Get-Acl -Path $PresentationsPath
   $acl.SetAccessRuleProtection($true, $true)

   $acl.Access | 
   Where-Object { $PSItem.IdentityReference -eq 'BUILTIN\Users' } | 
   ForEach-Object { $acl.RemoveAccessRule($PSItem) }

   $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
      'smart\DL_Presentations', 
      'Modify', 
      'ContainerInherit, ObjectInherit', 
      'None', 
      'Allow'
   )
   $acl.AddAccessRule($accessRule)
   $acl | Set-Acl -Path $presentationsPath
   ````

1. Leave **Windows PowerShell** open for upcoming tasks.

### Task 3: Test file shares

Perform these steps on CL1.

1. Log on as **smart\User1**.
1. Open **File Explorer**
1. Connect to file share **\\\fs\Presentations** ([figure 10]).

   > Can you connect? Why? What content do you see?

### Task 4: Modify permissions

#### Desktop Experience

Perfom these steps on FS.

1. Open the properties of one of the files in **D:\Presentations**.
1. On the tab **Permissions**, disable inheritance and convert permissions.
1. Remove the **DL_Presentations** group from the list.
1. Click on **OK** to commit the changes.

#### PowerShell

Perfom these steps on FS.

1. Get one of the files in D:\Presentations.Take a note of the emitted path for the next task.

   ````powershell
   $path = Get-ChildItem -Path $presentionsPath -File |
      Select-Object -ExpandProperty Fullname -First 1

   $path # Take a note of the emitted path
   ````

1. Disable inheritance and convert permissions.

   ````powershell
   $acl = Get-Acl -Path $path
   $acl.SetAccessRuleProtection($true, $true)
   $acl | Set-Acl -Path $path
   ````

1. Remove the **DL_Presentations** group from the acl.

   ````powershell
   $acl.Access | 
   Where-Object { $PSItem.IdentityReference -eq 'smart\DL_Presentations' } | 
   ForEach-Object { $acl.RemoveAccessRule($PSItem) }

   $acl | Set-Acl -Path $path
   ````

### Task 5: Test modified permissions

Perform these steps on CL1.

1. In **File Explorer**, with **\\\fs\Presentations** open, hit F5 to refresh the file list.

   > Which files do you see? Why?

## Exercise 3: Work Folders

### Introduction

In this exercise, you will install and configure the Work Folders feature and try to sync user files across devices. First, you will create an A record Workfolders pointing to 10.1.1.42 in the smart.etc zone. Then, on FS, you will equest a web server certificate for workfolders.smart.etc. Next, you will install the role service Work folders and run the script L:\WorkFolders\ConfWorkFolderCert.ps1 to configure the certificate mapping. The next step will be to configure the Training share as work folder with the user aliases as folder structure. Finally, on CL1, you will test the work folders feature.

#### Tasks

1. [Configure DNS](#task-1-configure-dns)
1. [Enroll a certificate](#task-2-enroll-a-certificate)
1. [Install and Configure Work Folders](#task-3-install-and-configure-work-folders)
1. [Test Work Folder access](#task-4-test-work-folder-access)

### Task 1: Configure DNS

#### Desktop Experience

Perform these steps on DC1.

1. Open the **DNS** Management console
1. In the **smart.etc** zone, create a new A - Record **Workfolders** with IP Address **10.1.1.42**.

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, connect to **dc1.smart.etc.**.
1. On the left, click **DNS**.
1. In **DNS**, select the zone **smart.etc**.
1. At the bottom, click **+ Create a new DNS record**.
   * **DNS record type**: Host (A)
   * **Record name (uses FQDN if blank)**: Workfolders
   * **IP address**: 10.1.1.42

#### PowerShell

Perform these steps on DC1.

1. Run **Windows PowerShell** as Administrator.
1. In the **smart.etc** zone, create a new A - Record **Workfolders** with IP Address **10.1.1.42**.

   ````powershell
   Add-DnsServerResourceRecordA `
      -Name Workfolders -IPv4Address 10.1.1.42 -ZoneName smart.etc
   ````

### Task 2: Enroll a certificate

#### Desktop Experience

Perform these steps on FS.

1. From the context menu of the start button, select **Run**
1. Type **certlm.msc** and press ENTER.
1. From the context menu of **Personal**, select **All Tasks**, **Request New Certificate…**.
1. Click **Next** until you reach the page **Request Certificates** .
1. Select the **WebServer10Years** template and click on the embedded link to configure the certificate ([figure 12]).
1. Under **Subject name**, in **Type** select **Common name**, in **Value**, type **workfolders.smart.etc**, and click **Add >** ([figure 13]).
1. Under **Alternative name**, in **Type**, select **DNS**, in **Value**, type **workfolders.smart.etc** and click **Add >** ([figure 13]).
1. Repeat the previous step to add an alternative DNS name with a value of **fs.smart.etc** ([figure 13]).
1. Complete the wizard to request and install the certificate.

#### PowerShell

Perform these steps on FS.

1. Run **Windows PowerShell** as Administrator.
1. Enroll a certificate from the template.

   ````powershell
   $Request=Get-Certificate `
      -Template 'WebServer10Years' `
      -SubjectName cn='workfolders.smart.etc' `
      -DnsName 'workfolders.smart.etc', 'fs.smart.etc' `
      -CertStoreLocation Cert:\LocalMachine\My\
   ````

### Task 3:  Install and Configure Work Folders

#### Desktop Experience

Perform these steps on FS.

1. Open **Server Manager**.
1. Under **File and Storage Services**, **File and iSCSI Services**, install the role service **Work Folders**.
1. From the start menu, open **Windows PowerShell ISE**.
1. In **Windows PowerShell ISE**, open **L:\WorkFolders\ConfWorkFolderCert.ps1**. Examine the script.
1. Press F5 to execute the script. This should create a binding as shown in [figure 14].
1. Restart the server.
1. After the server has restarted, logon as **smart\administrator**.
1. Open **Server Manager**.
1. Click on **File and Storage Services**.
1. Click on **Work Folders**.
1. From the **Tasks** drop-down, start the **New Sync Share Wizard** ([figure 15]).
1. Use the following settings to create the sync share.
   * Use File Share **Training**
   * Structure for user folders: **user alias**
   * Accept default share name
   * Grant access to **G_Training** and disable inherited permissions.
   * Activate **Encrypt Work Folders**
   * Deactivate **Automatically lock screen, and require password** feature.
1. Check if **User2** has access to the sync share ([figure 16]).

#### PowerShell

Perform these steps on FS.

1. Run **Windows PowerShell** as Administrator
1. Install the Work Folders role-service.

   ````powershell
   Install-WindowsFeature 'FS-SyncShareService' -IncludeManagementTools 
   ````

1. From the start menu, open **Windows PowerShell ISE**.
1. In **Windows PowerShell ISE**, open **L:\WorkFolders\ConfWorkFolderCert.ps1**. Examine the script.
1. Press F5 to execute the script. This should create a binding as shown in [figure 14].
1. Restart the server.

   ````powershell
   Restart-Computer
   ````

1. After the server has restarted, logon as **smart\administrator**.
1. Create a new sync share

   ````powershell
   New-SyncShare `
      -Path D:\Training `
      -UserFolderName '[user]' `
      -Name Training `
      -User G_Training `
      -RequireEncryption $false `
      -RequirePasswordAutoLock $true
   ````

### Task 4: Test Work Folder access

Perform these steps on CL1.

1. Logon as User2.
2. Open **Control Panel** and search for **Work Folders**.
3. Click on **Setup Work Folders** and enter the UPN of User1: **user2@smart.etc**.
4. Commit the default Work Folder location inside your user profile, and accept the security policies you have configured before ([figure 17]).
5. Work Folder Sync is now configured. Copy some files from the Labfiles Share **Sample Documents** folder into the Sync Share and check that the upload to server FS starts immediately ([figure 18], [figure 19]).

[figure 1]: images/disk-management-disk2.png
[figure 2]: images/Explorer-mounted-volume.png
[figure 3]: images/AD-create-group-DL_TrainingData.png
[figure 4]: images/AD-group-members-DL_TrainingData.png
[figure 5]: images/Server-Manager-Add-Role-File-Server.png
[figure 6]: images/Server-Manager-Shares.png
[figure 7]: images/Explorer-Disable-Inheritance.png
[figure 8]: images/Explorer-block-inheritance-alert.png
[figure 9]: images/Explorer-permissions-TrainingData.png
[figure 10]: images/Explorer-content-presentations.png
[figure 11]: images/PKI-certificate-template-properties-permissions-fs.png
[figure 12]: images/PKI-request-certificate-web-server-2016.png
[figure 13]: images/PKI-request-certificate-properties-workfolders.png
[figure 14]: images/Workfolders-SSL-certificate-bindings.png
[figure 15]: images/Workfolders-new-sync-share.png
[figure 16]: images/Server-Manager-Workfolders.png
[figure 17]: images/Workfolders-security-policies.png
[figure 18]: images/Workfolders-explorer-status.png
[figure 19]: images/Workfolders-clients-status.png
