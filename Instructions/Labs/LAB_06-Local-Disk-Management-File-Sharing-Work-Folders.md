# Lab 6: Local Disk Management, File Sharing & Work Folders

## Required VMs

* DC1
* DHCP
* Router
* FS on HV1
* PKI
* CL1

## Exercises

1. [Working with local disks](#exercise-1-working-with-local-disks)
1. [File Sharing](#exercise-2-file-sharing)
1. [Work folders](#exercise-3-work-folders)

## Exercise 1: Working with local disks

### Introduction

In this exercise, you will create a few new VHD Disks on your host to simulate plugging in new hard drives to your server. Additionally, you will shrink and expand volumes.

### Tasks

1. [Start the virtual machine FS](#task-1-start-the-virtual-machine-fs)
1. [Working with disks and volumes](#task-2-working-with-disks-and-volumes)

### Detailed Instructions

#### Task 1: Start the virtual machine FS

Perform these steps on HV1.

1. Logon as **smart\administrator**.
2. Open **Hyper-V Manager** and start the virtual machine FS.

#### Task 2: Working with disks and volumes

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

## Exercise 2: File Sharing

### Introduction

In this exercise, you will create a file share and work with the AGDLP principles. You will also learn how to use Access Based Enumeration (ABE).

### Tasks

1. [Create Groups in Active Directory](#task-1-create-groups-in-active-directory)
1. [Configure file shares](#task-2-configure-file-shares)
1. [Test file shares](#task-3-test-file-shares)
1. [Modify permissions](#task-4-modify-permissions)
1. [Test modified permissions](#task-5-test-modified-permissions)

### Detailed Instructions

#### Task 1: Create groups in Active Directory

Perform these steps on DC1.

1. Open **Active Directory Administrative Center**.
1. Create the following **Domain Local** **Security** groups in the **Users** container ([figure 3]).

   * DL_Training
   * DL_Presentations

1. Create a **Global** group **G_Training** and add it as a member of group **DL_Training** ([figure 4]).
1. Add **User2** as a member to the **G_Training** global group.
1. Create a new **Global** group **G_Sales** and add it as a member to the group **DL_Presentations**.
1. Add user **User1** as a member to the **G_Sales** global group.

#### Task 2: Configure file shares

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

#### Task 3: Test file shares

Perform these steps on CL1.

1. Log on as **smart\User1**.
1. Open **File Explorer**
1. Connect to file share **\\\fs\Presentations** ([figure 10]).

   > Can you connect? Why? What content do you see?

#### Task 4: Modify permissions

Perfom these steps on FS.

1. Open the properties of one of the files in **D:\Presentations**.
1. On the tab **Permissions**, disable inheritance and convert permissions.
1. Remove the **DL_Presentations** group from the list.
1. Click on **OK** to commit the changes.

#### Task 5: Test modified permissions

Perform these steps on CL1.

1. In **File Explorer**, with **\\\fs\Presentations** open, hit F5 to refresh the file list.

   > Which files do you see? Why?

## Exercise 3: Work Folders

### Introduction

In this exercise, you will install and configure the Work Folders feature and try to sync user files across devices.

### Tasks

1. [Configure DNS](#task-1-configure-dns)
1. [Enroll a certificate](#task-2-enroll-a-certificate)
1. [Install and Configure Work Folders](#task-3-install-and-configure-work-folders)
1. [Test Work Folder access](#task-4-test-work-folder-access)

### Detailed Instructions

#### Task 1: Configure DNS

Perform these steps on DC1.

1. Open the **DNS** Management console
1. In the **smart.etc** zone, create a new A - Record **Workfolders** with IP Address **10.1.1.42**.

#### Task 2: Enroll a certificate

Perform these steps on FS.

1. From the context menu of the start button, select **Run**
1. Type **certlm.msc** and press ENTER.
1. From the context menu of **Personal**, select **All Tasks**, **Request New Certificate…**.
1. Click **Next** until you reach the page **Request Certificates** .
1. Select the **Web Server 2016** template and click on the embedded link to configure the certificate ([figure 12]).
1. Under **Subject name**, in **Type** select **Common name**, in **Value**, type **workfolders.smart.etc**, and click **Add >** ([figure 13]).
1. Under **Alternative name**, in **Type**, select **DNS**, in **Value**, type **workfolders.smart.etc** and click **Add >** ([figure 13]).
1. Repeat the previous step to add an alternative DNS name with a value of **fs.smart.etc** ([figure 13]).
1. Complete the wizard to request and install the certificate.

#### Task 3:  Install and Configure Work Folders

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

#### Task 4: Test Work Folder access

Perform these steps on CL1.

1. Logon as User2.
2. Open **Control Panel** and search for **Work Folders**.
3. Click on **Setup Work Folders** and enter the UPN of User1: **user2@smart.etc**.
4. Commit the default Work Folder location inside your user profile, and accept the security policies you have configured before ([figure 17]).
5. Work Folder Sync is now configured. Copy some files from the Labfiles Share **Sample Documents** folder into the Sync Share and check that the upload to server FS starts immediately ([figure 18], [figure 19]).

[figure 1]: images/Lab06/figure01.png
[figure 2]: images/Lab06/figure02.png
[figure 3]: images/Lab06/figure03.png
[figure 4]: images/Lab06/figure04.png
[figure 5]: images/Lab06/figure05.png
[figure 6]: images/Lab06/figure06.png
[figure 7]: images/Lab06/figure07.png
[figure 8]: images/Lab06/figure08.png
[figure 9]: images/Lab06/figure09.png
[figure 10]: images/Lab06/figure10.png
[figure 11]: images/Lab06/figure11.png
[figure 12]: images/Lab06/figure12.png
[figure 13]: images/Lab06/figure13.png
[figure 14]: images/Lab06/figure14.png
[figure 15]: images/Lab06/figure15.png
[figure 16]: images/Lab06/figure16.png
[figure 17]: images/Lab06/figure17.png
[figure 18]: images/Lab06/figure18.png
[figure 19]: images/Lab06/figure19.png
