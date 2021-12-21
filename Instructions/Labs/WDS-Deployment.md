# Lab: WDS Deployment

## Required VMs

* DC1
* DHCP
* Router
* WS2019 on HV1

## Exercises

1. [WDS Deployment](#exercise-1-wds-deployment)

## Exercise 1: WDS Deployment

### Introduction

In this exercise, you will install the WDS Services on WS2019, import a Windows boot and a Windows Server install image, create a master VM from the using WDS, import the VHDX file of the master VM as new master image into WDS, and configure answer files to automate the boot and the install process. Finally, you will create a multicast transmission and test the installation of two servers using multicast.

#### Tasks

1. [Install and configure WDS](#task-1-install-and-configure-wds)
1. [Create a master VM](#task-2-create-a-master-vm)
1. [Create a master image](#task-3-create-a-master-image)
1. [Import the master image](#task-4-import-the-master-image)
1. [Create an answer file for automated WDS deployment](#task-5-create-an-answer-file-for-automated-wds-deployment)
1. [Configure WDS to use the answer file](#task-6-configure-wds-to-use-the-answer-file)
1. [Create a multicast transmission](#task-7-create-a-multicast-transmission)
1. [Deploy VMs using WDS multicast](#task-8-deploy-vms-using-multicast)
1. [Monitor multicast transmissions](#task-9-monitor-multicast-transmissions)
1. [Validate the deployment](#task-10-validate-the-deployment)

### Task 1: Install and configure WDS

*Note:*
In this lab, the RemoteInstall folder is created on the operating system disk. In production environments, you should create this folder on a dedicated disk.

*Note:*
In this lab, the Variable Window Extension is deactivated because of a bug in KB4489920 (see <https://support.microsoft.com/en-us/topic/march-19-2019-kb4489920-preview-of-monthly-rollup-fd7fb89e-c803-a477-60d0-502270625f4a>). This was fixed in KB4503285 (see <https://support.microsoft.com/en-us/topic/june-11-2019-kb4503285-monthly-rollup-4890ac3b-dab4-65e5-47e7-e97118b2a996>).

#### Desktop Experience

Perform these steps on WS2019.

1. On WS2019 logon as **smart\administrator**.
1. Open **Server Manager**.
1. In **Server Manager**, click **Local Server**.
1. In **PROPERTIES for WS2019**, click on the IP address of the network adapter **Datacenter1** (10.1.1.32).
1. In **Network Connections**, open the **Properties** of the network connection **Datacenter1**.
1. In **Datacenter1 Properties**, deactivate **Client for Microsoft Networks** and click OK.
1. Close **Network Connections**.
1. In **Server Manager**, in the menu, click **Manage**, **Add Roles and Features**.
1. In **Add Roles and Features Wizard**, proceed to page **Server Roles**, activate **Windows Deployment Services**, and click **Add Features**.
1. Proceed to page **Confirmation**, activate **Restart the destination server auomatically if required**, and click **Install**.
1. From the start menu, open the **Windows Deployment Services** console.
1. Expand the tree to **WS2019.smart.etc**.
1. From the context menu of **WS2019.smart.etc**, select **Configure Your Server**.

   * **Integrated with Active Directory**
   * C:\Remoteinstall
   * Respond to all client computers
   * Activate **Add images to the server**.

1. Add an image using the **Add Image Wizard**.
   * **Image File path:** D:\
   * **Image group Name:** WindowsServer
1. Open the properties of the WDS Server.
1. On the tab **TFTP**, deactivate the checkbox **Enable Variable Window Extension**.
1. On the tab **Boot**, in section **Unknown clients**, select the radio button **Always continue the PXE boot**.
1. Click on **OK** to confirm the changes.

#### PowerShell

*Note:*
The PowerShell module for WDS is quite limited. Therefore, many tasks must be performed using the wdsutil.exe command line program.

Perform these steps on WS2019.

1. On WS2019 logon as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. On the network adapter Datacenter1, disable the Client for Microsoft Networks.

   ````powershell
   Disable-NetAdapterBinding -ifAlias Datacenter1 -ComponentID ms_msclient
   ````

1. Install the WDS role.

   ````powershell
   Install-Windowsfeature WDS -IncludeManagementTools 
   ````

1. Initialize Windows Deployment Services.

   ````shell
   wdsutil /Initialize-Server /RemInst:"C:\RemoteInstall" /Authorize
   wdsutil.exe /Set-Server /AnswerClients:All
   ````

1. Import a boot image.

   ````powershell
   Import-WdsBootImage -Path 'D:\sources\boot.wim'
   wdsutil /Set-Server /BootImage:Boot\x64\Images\boot.wim /Architecture:x64uefi
   ````

1. Create an image group.

   ````powershell
   $imageGroup = 'WindowsServer'
   New-WdsInstallImageGroup -Name $imageGroup
   ````

1. Import the install image.

   ````powershell
   # The back tick ` can be used to split long command lines and make them more readable
   Import-WdsInstallImage `
      -ImageGroup $imageGroup `
      -Path 'D:\sources\install.wim' `
      -ImageName 'Windows Server 2019 SERVERDATACENTER'
   ````

1. Disable the boot prompt for unknown clients and the Variable Window Extension.

   ````shell
   wdsutil /Set-TransportServer /EnableTftpVariableWindowExtension:No
   wdsutil /Set-Server /PxePromptPolicy /New:NoPrompt
   ````

### Task 2: Create a master VM

#### Desktop Experience

Perform these steps on HV1.

1. Create a new VM.
   * **Name:** Master
   * **Storage location:** D:\
   * **Generation:** 2
   * **Memory:** 2048MB
   * **Virtual Switch:** Datacenter1
   * **Create a new disk:**
     * **Path:** D:\Master\Virtual Hard Disks\Master.vhdx
     * **Size:** 60 GB
   * **Install an OS from a network-based installation server**
1. Open the settings of VM **Master** and change the **CPU count** to **2**.
1. Double-click on VM **Master** to open the Hyper-V Console.
1. Start the VM.

#### PowerShell

Perform these steps on HV1.

1. Run **Windows PowerShell** as Adminsitrator.
1. Create a new VM.

   ````powershell

   <#
   It is a good idea to store values, that are used more than one time in 
   variables. In PowerShell Variables are preceeded by a $ sign.
   #>
   $vMName = 'Master'
   $vMPath = 'D:\'

   <#
   If a string is surounded by double quotes, variables are auto-expanded.
   This is a simple version to build a path. A better way to build paths is the
   Join-Path cmdlet, which is platform-independent. Remember, that on Unixoid
   platforms (Linux, MacOS, ...) directories are separated by a forward slash
   in contrast to Windows' backslash.
   #>
   $NewVHDPath = "$vMPath\$vMName)\Virtual Hard Disks\$VMName.vhdx"

   # The back tick ` can be used to split long command lines and make them more readable

   New-VM `
      -Name $vMName `
      -Path $vmPath `
      -Generation 2 `
      -MemoryStartupBytes 2GB `
      -SwitchName Datacenter1 `
      -NewVHDPath $NewVHDPath `
      -NewVHDSizeBytes 60GB

   $vmNetworkAdapter = Get-VMNetworkAdapter -VMName $vMName
   Set-VMFirmware -VMName $vMName -FirstBootDevice $vmNetworkAdapter
   ````

1. Change the CPU count to 2.

   ````powershell
   Set-VM -Name $vMName -ProcessorCount 2
   ````

1. In **Hyper V-Manager**, double-click on VM **Master** to open the Hyper-V Console.
1. Start the VM.

### Task 3: Create a master image

Perform these steps on Master.

1. Proceed with a standard installation. During the installation you need to specify certain parameters.
   * **Locale:**: Use your native language locale.
   * **Keyboard input method:** Use your native language locale.
   * **Connect to WS2019.smart.etc** smart\user1
   * **Operating System:** Windows Server 2019 SERVERDATACENTER
   * **Disk drive:** use defaults
1. After Installation has completed, select your home country/region, preferred app language, and keyboard layout.
1. Skip the product key (on the left, click on **Do this later**) and accept the license terms.
1. Set the local admin password to **Pa$$w0rd**.
1. Logon as **Administrator**.

> In real world, what would you do next?

1. Open **Command Prompt**.
1. Prepare the machine for cloning, and wait for the VM to shutdown.

   ````shell
   c:\windows\system32\sysprep\sysprep /generalize /oobe /shutdown
   ````

### Task 4: Import the master image

#### Desktop Experience

Perform these steps on WS2019.

1. Switch to **WDS console**.
1. Create a new image group **WindowsServerVHDX**.
1. From the context menu of the new group, select **Add install image…**.
1. In the **File location:** box enter the path to the MASTER.vhdx on HV1 **\\\HV1\D$\Master\Virtual Hard Disks\Master.vhdx** ([figure 1]).
1. Use default settings to import the VHDX.
1. Open the properties of the imported image.
1. Take note of **Imagename** and **File Name**.

#### PowerShell

Perform these steps on WS2019.

1. In Windows PowerShell, create a new image group WindowsServerVHDX.

   ````powershell
   $imageGroup = 'WindowsServerVHDX'
   New-WdsInstallImageGroup -Name $imageGroup
   ````

1. Import the VHDX of the Master VM into the new image group.

   ````powershell
   <#
   The VHDX file must be copied to the WDS server first, because of a double-hop
   authentication issue when using PowerShell. The temporary file can be deleted
   afterwards.
   #>
   $fileName = 'Master.vhdx'
   Copy-Item `
      -Path "\\hv1\d$\Master\Virtual Hard Disks\$fileName" `
      -Destination c:\
   $wdsInstallImage = Import-WdsInstallImage `
      -ImageGroup $imageGroup `
      -Path "c:\$fileName"
   Remove-Item -Path "c:\$fileName"
   ````

1. Take note of **Imagename** and **File Name**.

   ````powershell
   $wdsInstallImage
   ````

### Task 5: Create an answer file for automated WDS deployment

Perform these steps on HV1.

1. On HV1 start **Windows System Image Manager**.
1. In the top middle, in section **Answer file**, from the context menu of **Create or open an answer file**, select **New answer file…**.
1. Click on **Yes** to open a Windows image now.
1. Navigate to **D:\Deployment**.
1. Select and open the file **install_Windows Server 2019 SERVERDATACENTER.clg**.
1. In the section **Windows Image**, expand the **Components** tree ([figure 2]).
1. From the context menu of the component **amd64_Microsoft-Windows-International-Core-WinPE__neutral**, select **Add Setting to Pass 1 WinPE**.
1. In the section **Answer file**, expand the component to **Setup UILanguage**.
1. On the right-hand top, in section **Microsoft-Windows-International-Core_WinPE**, in **UILanguage**, enter **en-US**.
1. In the **Components**, expand **amd64_Microsoft-Windows-Setup__neutral**, and add **DiskConfiguration** and **WindowsDeploymentServices** to **Pass 1 WinPE**.
1. From the context menu of **Disk Configuration**, select **Insert new disk**.
1. Select the new disk and configure it.

   * **Action** AddListItem
   * **DiskId** 0
   * **WillWipeDisk** true

1. Expand the disk
1. Delete the **ModifyPartitions** subcomponent
1. From the context menu of **Create Partitions**, select **Insert new CreatePartition** three times to inser three **CreatePartition** entries ([figure 4]).
1. Configure the **CreatePartition** entries.

   | Action      | Extend | Order | Size | Type    |
   |-------------|--------|------:|-----:|:-------:|
   | AddListItem | false  | 1     | 200  | EFI     |
   | AddListItem | false  | 2     | 128  | MSR     |
   | AddListItem | true   | 3     |      | Primary |

1. In the section **Answer File**, fully expand the **WindowsDeploymentServices** component.
1. Under **WindowsDeploymentServices**, **ImageSelection**, select the **InstallImage** component, and configure it ([figure 5]).

   * **Filename:** the filename you took a note of in the previous task
   * **ImageGroup:** WindowsServerVHDX
   * **ImageName:** the image name you took a note of in the previous task

1. Select the **InstallTo** component, and configure it.

   * **DiskID:** 0
   * **PartitionID:** 3

1. Fully expand the **Login** component.
1. Select the **Credentials** component, and configure it.

   * **Domain:** smart.etc
   * **Password:** Pa$$w0rd
   * **User:** user1

1. In the pane **Components**, in the context menu of **amd64_Microsoft-Windows-International-Core__neutral**, click **Add Setting to Pass 4 specialize**.
1. In the pane **Answer File**, under **4 specialize**, select the component **amd64_Microsoft-Windows-International-Core__neutral** , and configure it.

   * **InputLocale**: Use your native language locale (Press F1 or ask your trainer for help)
   * **SystemLocale**: Use your native language locale
   * **UserLocale**: Use your native language locale
1. In the pane **Components**, in the context menu of **amd64_Microsoft-Windows-Shell-Setup__neutral**, click **Add Setting to Pass 4 specialize**.
1. Open **Windows PowerShell**.
1. List the name of your current time zone using one of the following commands.

   ````shell
   tzutil /g
   ````

   ````powershell
   Get-TimeZone
   ````

1. Copy the output value or the **ID** of the current time zone.
1. In the pane **Answer File**, under **4 specialize**, select the component **amd64_Microsoft-Windows-Shell-Setup__neutral**, paste the copied value from the previous step into the property **TimeZone**.
1. Save the file to **\\\WS2019\c$\Remoteinstall\WDSClientUnattend\uefi-wds.xml**.

### Task 6: Configure WDS to use the answer file

#### Desktop Experience

Perform these steps on WS2019.

1. Open the properties of WDS
1. On the tab **Client**, enable the **Enable unattended installation** checkbox.
1. In the section **x64 (UEFI) architecture**, browse for the file **\WdsClientUnattended\uefi-wds.xml** ([figure 6]).
1. Click on **OK** to commit the changes.
1. Expand **Install Images** and click on the image group **Windows ServerVHDX**.
1. In the context-menu of the image you imported before, click **Properties**.
1. In the **Image Properties**, activate **Allow image to install in unattended mode**, click **Select File...**, and browse for  the file **\WdsClientUnattended\uefi-wds.xml**.
1. Confirm all open dialogs by clicking **OK**.

#### PowerShell

Perform these steps on WS2019.

1. Configure an unattend file for the Windows PE phase.

   ````shell
   wdsutil /Set-Server /WdsUnattend /Policy:Enabled /File:"WdsClientUnattend\uefi-wds.xml" /Architecture:x64uefi
   ````

1. Configure an unattend file for the imported image.

   ````powershell
   Set-WdsInstallImage `
      -ImageGroup $wdsInstallImage.ImageGroup `
      -FileName $wdsInstallImage.FileName `
      -ImageName $wdsInstallImage.ImageName `
      -UnattendFile 'C:\RemoteInstall\WdsClientUnattend\uefi-wds.xml'
   ````

### Task 7: Create a multicast transmission

#### Desktop Experience

Perform these steps on WS2019.

1. From the context menu of **Multicast Transmissions**, select **Create Multicast Transmission**.
   * **Name:** WS2019VHDX
   * **Image selection:** Image from the **WindowsServerVHDX** group
   * **Multicast Type:** Autocast

#### PowerShell

Perform these steps on WS2019.

1. Create a multicast transmission.

   ````powershell
   $imageName = $wdsInstallImage.ImageName
   $imageGroup = $wdsInstallImage.ImageGroup
   wdsutil /New-MulticastTransmission /Image:$imageName /FriendlyName:WS2019VHDX /TransmissionType:AutoCast /ImageType:Install /ImageGroup:$imageGroup
   ````

### Task 8: Deploy VMs using multicast

Perform these steps on HV1.

1. On HV1 open Windows PowerShell as Administrator
1. Execute a Script to create two Server VMs.

   ````powershell
   L:\WDS\CreateServerVMs.ps1
   ````

1. In **Hyper-V Manager**, open connections to both **Server1** and **Server2** and start them. The installation should proceed automatically, except for the last OOBE steps.

### Task 9: Monitor multicast transmissions

Perform these steps on WS2019.

1. In the WDS console select the multicast transmission you created before. Notice the multicast transmission monitoring in the WDS console. You can trace the installation there ([figure 7]).
1. To speed things up in our lab environment, you can bypass multicast ([figure 8]).

### Task 10: Validate the deployment

Perform these steps on Server1 or Server2.

1. Logon as Administrator.
1. Open a **Command Prompt**.
1. View the bcd store. Note that Windows Server has been installed as boot-from-vhdx ([figure 9]).

   ````shell
   bcdedit /v
   ````

[figure 1]: images/WDS-image-add.png
[figure 2]: images/WSIM-components.png
[figure 3]: images/WSIM-amd64_Microsoft-Windows-Setup_neutral.png
[figure 4]: images/WSIM-CreatePartitions.png
[figure 5]: images/WSIM-installimage-master-vhdx.png
[figure 6]: images/WDS-properties-client.png
[figure 7]: images/WDS-multicast-status.png
[figure 8]: images/WDS-multicast-bypass.png
[figure 9]: images/BCD-store-boot-from-vhdx.png
