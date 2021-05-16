# Lab 15: WDS Deployment

## Required VMs

* DC1
* DHCP
* Router
* WS2019 on HV1

## Exercises

1. [WDS Deployment](#exercise-1-wds-deployment)

## Exercise 1: WDS Deployment

### Introduction

In this exercise, you will install the WDS Services, create a reference server image and deploy this image unattended via multicast transmission.

### Tasks

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

### Detailed Instructions

#### Task 1: Install and configure WDS

Perform these steps on WS2019.

1. On WS2019 logon as **smart\administrator**.
1. Open **File Explorer**
1. Navigate to **D:\ISO**.
1. Double-click on the file **WS2019.iso** to mount it.
1. Run **Windows PowerShell** as Administrator.
1. Install the WDS role.

   ````powershell
   Install-Windowsfeature WDS -IncludeManagementTools 
   ````

1. From the start menu, open the **Windows Deployment Services** console.
1. Expand the tree to **WS2019.smart.etc**.
1. From the context menu of **WS2019.smart.etc**, select **Configure Your Server**.
   * **Integrated with Active Directory**
   * D:\Remoteinstall
   * Respond to all client computers
   * Activate **Add images to the server**.
1. Add an image using the **Add Image Wizard**.
   * **Image File path:** E:\
   * **Image group Name:** WindowsServer
1. Open the properties of the WDS Server.
1. In the tab **Boot**, in section **Unknown clients**, select the radio button **Always continue the PXE boot**.
1. Click on **OK** to confirm the changes.

#### Task 2: Create a master VM

Perform these steps on HV1.

1. Create a new VM.
   * **Name:** Master
   * **Storage location:** D:\
   * **Generation:** 2
   * **Memory:** 2GB
   * **Virtual Switch:** smart.etc
   * **Create a new disk:**
     * **Path:** D:\Master\Virtual Hard Disks\Master.vhdx
     * **Size:** 60 GB
   * **Install an OS from a network-based installation server**
1. Open the settings of VM **Master** and change the **CPU count** to **2**.
1. Double-click on VM **Master** to open the Hyper-V Console.
1. Start the VM.

#### Task 3: Create a master image

Perform these steps on Master.

1. Proceed with a standard installation. During the installation you need to specify certain parameters.
   * **Keyboard input method:** use one that matches your language
   * **Credentials for Image selection:** smart\user1
   * **Operating System:** Windows Server 2019 SERVERDATACENTER
   * **Disk drive:** use defaults
1. After Installation has completed, select your home country/region.
1. Skip the product key (click on **Do this later** on the left) and accept the license terms.
1. Set the local admin password to **Pa$$w0rd**.
1. Logon as **Administrator**. We will skip customization of the machine and assume that this has been done already.

1. Open **Command Prompt**.
1. Prepare the machine for cloning, and wait for the VM to shutdown.

   ````shell
   c:\windows\system32\sysprep\sysprep /generalize /oobe /shutdown
   ````

#### Task 4: Import the master image

Perform these steps on WS2019.

1. Switch to **WDS console**.
1. Create a new image group **WindowsServerVHDX**.
1. From the context menu of the new group, select **Add install image…**.
1. In the **File location:** box enter the path to the MASTER.vhdx on HV1 **\\\HV1\D$\Master\Virtual Hard Disks\Master.vhdx** ([figure 1]).
1. Use default settings to import the VHDX.
1. Open the properties of the imported image.
1. Take note of **Imagename** and **File Name**.

#### Task 5: Create an answer file for automated WDS deployment

Perform these steps on HV1.

1. On HV1 start **Windows System Image Manager**.
1. In the top middle, in section **Answer file**, from the context menu of **Create or open an answer file**, select **New answer file…**.
1. Click on **Yes** to open a Windows image now.
1. Navigate to **D:\Deployment**.
1. Select and open the file **install_Windows Server 2019 SERVERDATACENTER.clg**.
1. In the section **Windows Image**, expand the **Components** tree ([figure 2]).
1. From the context menu of the component **amd64_Microsoft-Windows-International-Core-WinPE__neutral**, select **Add Setting to Pass 1 WinPE**.
1. In the section **Answer file**, expand the component to **Setup UILanguage**.
1. On the right-hand top, in section **Microsoft-Windows-International-Core_WinPE**, in **UILanguage**, enter **en-us**.
1. In the **Components** add **amd64_Microsoft-Windows-Setup__neutral** to **Pass 1 WinPE**.
1. In the answer file sections expand the new component.
1. Delete all subcomponents except **Disk configuration** and **WindowsDeploymentServices** ([figure 3]).
1. From the context menu of **Disk Configuration**, select **Insert new disk**.
1. Select the new disk and configure it.

   * **DiskId:** 0
   * **WillWipeDisk:** true

1. Expand the disk
1. Delete the **ModifyPartitions** subcomponent
1. From the context menu of **Create Partitions**, select **Insert new CreatePartition** three times to inser three CreatePartition entries ([figure 4]).
1. Configure the **CreatePartition** entries.
   | Extend | Order | Size | Type   |
   |--------|------:|-----:|:------:|
   | false  | 1     | 200  | EFI    |
   | false  | 2     | 128  | MSR    |
   | true   | 3     |      | Primary|

1. In the section **Answer File**, fully expand the **WindowsDeploymentServices** component.
1. Select the **InstallImage** component, and configure it ([figure 5]).
   * **Filename:** the filename you took a note of in the previous task
   * **ImageGroup:** WindowsServerVHDX
   * **ImageName:** the image name you took a note of in the previous task
1. Select the **InstallTo** component, and configure it.
   * **DiskID:** 0
   * **PartitionID:** 3
1. Fully expand the **Login** component.
1. Select the **Credentials** component, and configure it
   * **Domain:** smart.etc
   * **Password:** Pa$$w0rd
   * **User:** user1
1. Save the file to **\\\WS2019\d$\Remoteinstall\WDSClientUnattend\uefi-wds.xml**.

#### Task 6: Configure WDS to use the answer file

Perform these steps on WS2019.

1. Open the properties of WDS
1. On the tab **Client**, enable the **Enable unattended installation** checkbox.
1. In the section **x64 (UEFI) architecture**, browse for the file **\WdsClientUnattended\uefi-wds.xml** ([figure 6]).
1. Click on **OK** to commit the changes.

#### Task 7: Create a multicast transmission

Perform these steps on WS2019.

1. From the context menu of **Multicast Transmissions**, select **Create Multicast Transmission**.
   * **Name:** WS2019VHDX
   * **Image selection:** Image from the **WindowsServerVHDX** group
   * **Multicast Type:** Autocast

#### Task 8: Deploy VMs using multicast

Perform these steps on HV1.

1. On HV1 open Windows PowerShell as Administrator
1. Execute a Script to create two Server VMs.

   ````powershell
   L:\WDS\CreateServerVMs.ps1
   ````

1. Start both VMs and boot to PXE. The installation should proceed automatically, except for the last OOBE steps.

#### Task 9: Monitor multicast transmissions

Perform these steps on WS2019.

1. In the WDS console select the multicast transmission your created before. Notice the multicast transmission monitoring in the WDS console. You can trace the installation there ([figure 7]).
1. To speed things up in our lab environment, you can bypass multicast ([figure 8]).

#### Task 10: Validate the deployment

Perform these steps on Server1 or Server2.

1. Logon as Administrator.
1. Open a **Command Prompt**.
1. View the bcd store. Note that Windows Server has been installed as boot-from-vhdx ([figure 9]).

   ````shell
   bcdedit /v
   ````

[figure 1]: images/Lab15/figure01.png
[figure 2]: images/Lab15/figure02.png
[figure 3]: images/Lab15/figure03.png
[figure 4]: images/Lab15/figure04.png
[figure 5]: images/Lab15/figure05.png
[figure 6]: images/Lab15/figure06.png
[figure 7]: images/Lab15/figure07.png
[figure 8]: images/Lab15/figure08.png
[figure 9]: images/Lab15/figure09.png
