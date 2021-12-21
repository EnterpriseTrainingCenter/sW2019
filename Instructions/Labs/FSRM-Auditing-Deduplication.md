# Lab: FSRM, Auditing & Deduplication

## Required VMs

* DC1
* DHCP
* Router
* FS on HV1
* CL1

## Exercises

1. [File Server Resource Manager](#exercise-1-file-server-resource-manager)
1. [File Auditing](#exercise-2-file-auditing)
1. [Deduplication](#exercise-3-deduplication)

## Exercise 1: File Server Resource Manager

### Introduction

In this exercise, you will install File Server Resource Manager on FS, create and test a quota of 200 MB on the Presentations share, create and test a file screen to block executables from the Presentations share. Finally, you will create a report of file duplicates on D:\ of FS.

#### Tasks

1. [Install File Server Resource Manager](#task-1-install-file-server-resource-manager)
1. [Create a quota](#task-2-creating-a-quota)
1. [Test the quota](#task-3-testing-the-quota)
1. [Create and test a file screen](#task-4-create-and-test-a-file-screen)
1. [Using FSRM Reports](#task-5-using-fsrm-reports)

### Task 1: Install File Server Resource Manager

#### Desktop Experience

Perform these steps on FS.

1. Logon as **smart\Administrator**.
1. Open **Server Manager**.
1. In **Server Manager**, click **Manage**, **Add Roles and Features**.
1. In **Add Role and Features Wizard**, continue to the page **Select server roles**.
1. On page **Select server roles**, expand **File and storage Service**, **File and iSCSI Services**, then activate **File Server Resource Manager**.
1. Continue through the wizard to install File Server Resource Manager.

#### PowerShell

Perform these steps on FS.

1. Run **Windows PowerShell** as Administrator
1. Install the role service **File Server Resource Manager**.

   ````powershell
   Install-WindowsFeature 'FS-Resource-Manager' –IncludeManagementTools 
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 2: Create a quota

#### Desktop Experience

Perform these steps on FS.

1. Open the **File Server Resource Manager** console.
1. Expand **Quota Management**.
1. From the context menu of **Quotas**, select **Create Quota…**
1. Create a quota ([figure 1]).
   * **Quota Path:** D:\Presentations
   * **Quota Type:** Quota on Path
   * **Derive values from template**: 200MB Limit Reports to User

   You should see the used space in the **% Used** column in each subfolder of the presentations folder. If not, copy the Datasheets folder from **L:\SampleDocuments** to **D:\Presentations** and refresh the view.

#### PowerShell

Perform these steps on FS.

1. Create a quota.

   ````powershell
   New-FSRMQuota -Path D:\Presentations -Template '200 MB Limit Reports to User'
   ````

1. Validate the quota.

   ````powershell
   Get-FsrmQuota -Path D:\Presentations
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 3: Test the quota

Perform these steps on CL1.

1. Open **File Explorer**.
1. In the **Home** ribbon, select **Easy access**, **Map as drive** ([figure 2]).
1. Map **\\\fs\Presentations** to drive **P:**.
1. Open the properties of drive **P:**.

   > What is the capacity of drive P:? ([figure 3])

1. Copy the **L:\SampleDocuments** folder to **P:\\**.

   > Can you copy all content of SampleDocuments to P:? ([figure 4])

### Task 4: Create and test a file screen

#### Desktop Experience

Perform these steps on FS.

1. In **File Server Resource Manager**, expand **File Screen Management**.
1. From the context menu of **File Screens**, select **Create File Screen…**.
1. Create a file screen.
   * **File Screen Path:** D:\Presentations
   * **Derive values from template** **Block Executable files**
1. Open **File Explorer**.

   > What happens when you change the file extension of one of the files to **.exe**? ([figure 5])

#### PowerShell

Perform these steps on FS.

1. Create a file screen.

   ````powershell
   New-FsrmFileScreen -Path D:\Presentations -Template 'Block Executable Files'
   ````

1. Leave **Windows PowerShell** open for the next task.
1. Open **File Explorer**.

   > What happens when you change the file extension of one of the files to **.exe**? ([figure 5])

### Task 5: Using FSRM Reports

#### Desktop Experience

Perform these steps on FS.

1. Copy the **Sample Documents** folder from **L:\\** to **D:\\** drive.
1. Switch to **File Server Resource Manager** console.
1. From the context menu of **Storage Reports Management**, select **Generate Report Now**.
1. On the tab **Settings**, select the report **Duplicate files**.
1. On the tab **Scope**, add the folder **D:\SampleDocuments**.
1. Click on **OK** and wait for the report to be completed.
1. Open the report after it has been rendered and look for duplicates.

#### PowerShell

Perform these steps on FS.

1. Copy the **Sample Documents** folder from **L:\\** to **E:\\** drive.

   ````powershell
   Copy-Item -Path L:\SampleDocuments -Destination E:\SampleDocuments -Recurse
   ````

1. Generate a Storage Reports Management report. Wait for the report to be completed.

   ````powershell
   New-FsrmStorageReport `
      -Interactive `
      -Name "Interactive Report Task $(Get-Date)" `
      -Namespace 'E:\SampleDocuments' `
      -ReportType DuplicateFiles |
   Wait-FsrmStorageReport
   ````

1. On the tab **Settings**, select the report **Duplicate files**.
1. On the tab **Scope**, add the folder **E:\SampleDocuments**.
1. Click on **OK**.
1. Open the report after it has been rendered and look for duplicates.

   ````powershell
   explorer (Get-FsrmSetting).ReportLocationOnDemand
   ````

## Exercise 2: File Auditing

### Introduction

In this lab, you will create and test an audit rule to monitor file deletes on the Training share.

#### Tasks

1. [Configure auditing](#task-1-configure-auditing)
1. [Test auditing](#task-2-test-auditing)
1. [Review audit logs](#task-3-review-audit-logs)

### Task 1: Configure auditing

#### Desktop Experience

Perform these steps on FS.

1. Run **gpedit.msc** as administrator to open the **Local Group Policy** console.
1. Navigate to **Computer Configuration**, **Windows Settings**, **Security Settings**, **Advanced Audit Policy Configuration**, **System Audit Policies**, **Object Access** ([figure 6]).
1. Double-click on **Audit File System** and activate **Configure the following audit events** and **Success**.
1. Switch to **File Explorer**.
1. Open the properties of **D:\Training**.
1. On the tab **Security**, click on **Advanced**.
1. In the dialog **Advanced**, select the tab **Auditing**.
1. In the upper right corner, click **Show advanced permissions**.
1. Add an auditing entry ([figure 7]):
   * **Principal:** Everyone
   * **Type:** Success
   * **Applies to:** This folder, subfolders and files
   * **Advanced permissions:** Delete (In the upper right corner, click **Show advanced permissions**.)

#### PowerShell

Perform these steps on FS.

1. Run **gpedit.msc** as administrator to open the **Local Group Policy** console.
1. Navigate to **Computer Configuration**, **Windows Settings**, **Security Settings**, **Advanced Audit Policy**, **System Audit Policies**, **Object Access** ([figure 6]).
1. Double-click on **Audit File System** and activate **Success Auditing**.
1. Add an auditing entry.

   ````powershell
   $Acl = Get-Acl D:\Training
   $AuditRule = New-Object System.Security.AccessControl.FileSystemAuditRule(
      'Everyone', 'Delete', 'ContainerInherit, ObjectInherit', 'None', 'Success'
   )
   $Acl.AddAuditRule($AuditRule)
   $Acl | Set-Acl -Path D:\Training

### Task 2: Test auditing

Perform these steps on CL1.

1. Log on as user **User2**
1. Delete a file from the **\\\FS\Training** share.

### Task 3: Review audit logs

Perform these steps on FS.

1. Open the Event Viewer.
1. In **Security Log**, search and review entries with the IDs 4656 and 4659 ([figure 8]). These entries are logged when files are deleted, or someone tried to delete a file.

   > Can you determine, who deleted the file?

## Exercise 3: Deduplication

### Introduction

In this exercise, you will deduplicate the files on D: of FS to demonstrate deduplication efficiency.

#### Tasks

1. [Install and configure deduplication](#task-1-install-and-configure-deduplication)
1. [Test deduplication](#task-2-test-deduplication)

### Task 1: Install and configure deduplication

#### Desktop Experience

Perform these steps on FS.

1. In **Server Manager**, start the **Add Role and Features Wizard**.
1. On page **Select server roles**, under **File and Storage Services**, **File and iSCSI Services**, install **Data Deduplication**.
1. In **Server Manager**, on the left, click **Volumes**.
1. From the context menu of Volume **D:**, select **Configure Data Deduplication...** to enable data deduplication.
   * **Data deduplication:** **General purpose file server**
   * **Deduplicate files older than (in days):** 0
   * Configure a deduduplication schedule for throughput optimization to run Monday to Friday at 1:00 am for a duration of 6 hours.
1. Open **Task Scheduler**.
1. Review the tasks under **Microsoft**, **Windows**, **Deduplication**.
1. Leave **Task Scheduler** open for the next task.

#### PowerShell

Perform these steps on FS.

1. Run **PowerShell** as Administrator
1. Install the deduplication feature.

   ````powershell
   Install-WindowsFeature 'FS-Data-Deduplication' –IncludeManagementTools
   ````

1. Enable Deduplication on Volume D.

   ````powershell
   Enable-DedupVolume -Volume D:
   ````

1. Change the minimum file age of deduplicated files to zero.

   ````powershell
   Set-DedupVolume –Volume D: –MinimumFileAgeDays 0
   ````

1. Check and take a note of the current savings rate on drive **D:**.

   ````powershell
   Get-DedupVolume
   ````

1. Create a new schedule that automatically deduplicates your D: drive at night.

   ````powershell
   # The back tick ` allows to split long commands into multiple lines
   New-DedupSchedule `
       –Name 'DedupLabfiles' `
       –Type Optimization `
       -Days Mon, Tues, Wed, Thurs, Fri `
       –Start 01:00 `
       –DurationHours 6
   ````

1. Review the schedule

   ````powershell
   Get-DedupSchedule
   ````

### Task 2: Test deduplication

#### Desktop Experience

Perform these steps on FS.

1. In **Task Scheduler**, from the context menu of the job **ThroughputOptimization**, click **Run**. **Status** changes to **Running**. 
1. In pane **Actions**, click refresh until **Status** changes to **Ready**.
1. Switch to **Server Manager**.
1. Click the button **Refresh "Volumes**.
1. In **Volumes**, from the context menu of volume **D:**, click **Properties**.

   > What are your savings using deduplication?

#### PowerShell

Perform these steps on FS.

1. Start the deduplication process now.

   ````powershell
   Start-DedupJob –Volume D: –Type Optimization
   ````

1. Review the running deduplication process. Repeat until the job completes.

   ````powershell
   Get-DedupJob
   ````

1. Compare the savings rate to the previous task.

   ````powershell
   Get-DedupVolume
   ````

[figure 1]: images/Lab07/figure01.png
[figure 2]: images/Lab07/figure02.png
[figure 3]: images/Lab07/figure03.png
[figure 4]: images/Lab07/figure04.png
[figure 5]: images/Lab07/figure05.png
[figure 6]: images/Lab07/figure06.png
[figure 7]: images/Lab07/figure07.png
[figure 8]: images/Lab07/figure08.png
