# Lab: Installing and Configuring Hyper-V

## Required VMs

* DC1
* DHCP
* Router
* HV1
* HV2
* SRV2

## Exercises

1. [Installing Hyper-V](#exercise-1-installing-hyper-v)
1. [Managing virtual networks](#exercise-2-managing-virtual-networks)
1. [Managing virtual hard disks](#exercise-3-managing-virtual-hard-disks)
1. [Hyper-V replica](#exercise-4-hyper-v-replica)

## Exercise 1: Installing Hyper-V

### Introduction

In this exercise, you will install the Hyper-V Role on HV2.

#### Tasks

1. [Install the Hyper-V role](#task-1-use-server-manager-to-install-the-hyper-v-role)

### Task 1: Install the Hyper-V role

#### Desktop Experience

Perform these steps on HV2.

1. Logon with **smart\Administrator**.
1. Start **Server Manager** from the Start Menu.
1. From the menu bar, select **Manage, Add Roles and features**.
1. Click on **Next** until you reach the page **Select server roles** page.
1. Select **Hyper-V**, and click on **Next** until you reach the page **Create Virtual Switches** page.
1. Select the adapter **Datacenter2**,  and click on **Next** twice.
1. On the page **Virtual Machine Migration**, click on **Next**.
1. On the page **Default Stores**, change both paths to **D:\\**, and click on **Next**.
1. Select the checkbox **Restart the destination server if required** and confirm with **Yes**.
1. Click on install. The system will reboot twice
1. After installation completes, logon with **smart\Administrator**.

#### Windows Admin Center

Perform these steps on CL1.

1. Logon with **smart\Administrator**.
1. Open **Google Chrome** and navigate to <https://admincenter>.
1. In **Windows Admin Center**, connect to **hv2.smart.etc**.
1. Connected to **hv2.smart.etc**, on the left, click **Role & features**.
1. In **Roles and features**, activate **Hyper-V**, and click **Install**.
1. In the pane **Install Role and Features**, activate the checkbox **Reboot the server automatically, if required**, and click **Yes**. The system will reboot twice.
1. Refresh **Windows Admin Center**, until ,you see **Virtual machines** on the left.
1. On the left, click **Settings**.
1. In **Settings**, on the left, under **Hyper-V Host Settings**, click **General**.
1. Change both paths to **D:\\**, and click **Save**.
1. Leave **Windows Admin Center** open for the next exercise.
1. On the left, click **Virtual switches**.
1. In the toolbar, click **New**.
1. In the pane **New virtual switch**, in **Switch name:**, type **Datacenter2**.
1. In **Switch type:**, select **External**.
1. In the list **Network adapters**, activate **Datacenter2**.
1. Make sure, the checkbox **Allow management OS to share these network adapters** is activated, and click **Save**.

You might receive an error message, telling you that the virtual switch could not be created, because of a lost connection. This error message is expected and can be ignored.

   > What is the effect of the option **Allow management OS to share these network adapters**? Why did you receive an error message?

#### PowerShell

Perform these steps on HV2.

1. Logon with **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Install the Hyper-V feature. The system will reboot twice.

   ````powershell
   Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
   ````

1. After installation completes, logon with **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Create a virtual switch.

   ````powershell
   $vMSwitchName = 'Datacenter 2 - Virtual Switch'
   New-VMSwitch `
      -Name $vMSwitchName `
      -NetAdapterName 'Datacenter2' `
      -AllowManagementOS $true
   ````

1. Set the default stores.

   ````powershell
   Set-VMHost -VirtualHardDiskPath D:\ -VirtualMachinePath D:\
   ````

1. Leave **Windows PowerShell** open for the next exercise.

## Exercise 2: Managing virtual networks

### Introduction

In this exercise, you will examine virtual networks, change the second octet of the dynamic MAC address range to 17, create an internal switch names Internal, and a private switch named Private.

#### Tasks

1. [Examine the switch that was created during installation](#task-1-examine-the-switch-that-was-created-during-installation)
1. [Change the dynamic MAC Address Range](#task-2-change-the-dynamic-mac-address-range)
1. [Create internal and private switches](#task-3-create-internal-and-private-switches)

### Task 1: Examine the switch that was created during installation

#### Desktop Experience

Perform these steps on HV2. Since the IP configuration has changed, use a Hyper-V Console connection for this task.

1. Logon as **smart\Administrator**.
1. Run **Hyper-V Manager** from start menu.
1. In the **Actions** Pane, click on **Virtual Switch Manager** ([figure 1]).
1. Examine the switch that has been created by the installation ([figure 2]).

   > What is the name of the switch? How was this name determined?

   > The option **Allow management operating system to share the network adapter**. What is the effect of this option?

1. Open **Network and Sharing Center**.

   > What is the name and description of the network card that is connected to the **Unidentified** network ([figure 3])?

1. Switch back to Hyper-V **Virtual Switch Manager**.
1. Rename the external switch to **Datacenter2**, and click on **Apply** to commit the changes.
1. Switch to **Network and Sharing Center**.

   > What is the name of the network card now?

1. In **Network and Sharing Center**, on the left, click on **Change adapter settings** ([figure 4]).
1. On the top-right corner of the toolbar, change the view to **Details** ([figure 5]).
1. Compare the two network adapters. One is the physical adapter (**Datacenter2**), which is bound to the Hyper-V virtual switch, the other is the management OS adapter (**vEthernet (Datacenter2)**).
1. From the context menu of the network adapter **vEthernet (Datacenter2)**, select **Status**.
1. Click on **Details**.

   > Which IP address does the adapter have? Why?

1. Click on **Close** and the click on **Properties**.
1. Change the IPv4 configuration to use a static IP Address with the following parameters.

   * **IP Address:** 10.1.2.30
   * **Subnet Mask:** 255.255.255.0
   * **Default Gateway:** 10.1.2.254
   * **Preferred DNS Server:** 10.1.1.1

1. From the context menu of the network adapter **Datacenter2**, select **Status**.
1. Click on **Details**.

   > Why is the dialog empty?

1. Click on **Close**.
1. Click on **Properties**.

   > Which protocols are bound to the physical network card?

1. Click on **Cancel** and then **Close**.
1. Close the Hyper-V Console Window. You can use RDP Manager for the next task again.

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, still connected to **hv2.smart.etc**, on the left, click **Networks**.

   > What is the name of the network, that has an IP address?

   > Why does the network **Datacenter2** not have an IP address? (Hint: You might want to sign in to HV2 directly and examine the properties of the **Datacenter2** network adapter.)

1. Leave **Windows Admin Center** open for upcoming tasks.

#### PowerShell

Perform these steps on HV2. Since the IP configuration has changed, use a Hyper-V Console connection for this task.

1. Examine the switch that has been created by the installation.

   ````powershell
   $VMSwitch = Get-VMSwitch $vMSwitchName
   $VMSwitch | Format-List
   ````

   > What is the name of the switch? How was this name determined?

   > The option AllowManagementOS is true. What is the effect of this option?

1. Get name and description of the network adapter associated with the virtual switch.

   ````powershell
   $vmNetworkAdapter = Get-VMNetworkAdapter `
      -ManagementOS `
      -SwitchName $vMSwitchName

   <#
      The format of the MAC address of vmNetworkAdapter and NetAdapter are
      different. The later contains dashes, which must be removed for
      comparison. This is easily be done with the -replace operator.
   #>
   $netAdapter = Get-NetAdapter |
      Where-Object {
         ($PSItem.MacAddress -replace '-','') -eq $vmNetworkAdapter.MacAddress
      } 
   $netAdapter = Select-Object Name, InterfaceDescription, ConnectorPresent
   ````

   > What is the name and description of the network card that is connected to the **Unidentified** network?

1. Rename the external switch to **Datacenter2**.

   ````powershell
   $vMSwitchName = 'Datacenter2'
   Rename-VMSwitch -VMSwitch $VMSwitch -NewName $vMSwitchName
   ````

1. Get name and description of the network adapters, again.

   ````powershell
   $netAdapter = Get-NetAdapter |
      Where-Object {
         ($PSItem.MacAddress -replace '-','') -eq $vmNetworkAdapter.MacAddress
      } 
   $netAdapter | Select-Object Name, InterfaceDescription, ConnectorPresent
   ````

   > What is the name of the network card now?

1. Get the ip address of the adapter.

   ````powershell
   Get-NetIpConfiguration -InterfaceIndex $netAdapter.ifIndex
   ````

   > Which IP address does the adapter have? Why?

1. Change the IPv4 configuration to use a static IP Address with the following parameters.

   * **IP Address:** 10.1.2.30
   * **Subnet Mask:** 255.255.255.0
   * **Default Gateway:** 10.1.2.254
   * **Preferred DNS Server:** 10.1.1.1

   ````powershell
   $netAdapter | New-NetIPAddress `
      -IPAddress 10.1.2.30 `
      -DefaultGateway 10.1.2.254 `
      -PrefixLength 24 `
      -AddressFamily IPv4
   $netAdapter | Set-DnsClientServerAddress -ServerAddresses 10.1.1.1
   ````

1. Get a list of net adapters.

   ````powershell
   Get-NetAdapter
   ````

   > Which is the physical net adapter, that provides the uplink for the virtual switch? (Hint: You might want to fefer to exercise 1).

1. Get the physical net adapter.

   ````powershell
   $netAdapter = Get-NetAdapter -Name 'Datacenter2'
   ````

1. Get the ip configuration of the physical net adapter connecting the virtual switch.

   ````powershell
   Get-NetIpConfiguration -InterfaceIndex $netAdapter.ifIndex
   ````

   > Why do you receive an error message? Hint: Continue to next step.

1. Get procotols bound to the physical network card.

   ````powershell
   $netAdapter | Get-NetAdapter-Binding -Name 'Datacenter2'
   ````

   > Which protocols are bound to the physical network card?

1. Leave **Windows PowerShell** open for the next task.

### Task 2: Change the dynamic MAC address range

#### Desktop Experience

Perform these steps on HV2.

1. Switch back to **Virtual Switch Manager**.
2. Click on **MAC Address Range**.
3. Change the second octet of the minimum and maximum range to **17** ([figure 12]).
4. Click on **OK** to commit the changes.

#### PowerShell

Perform these steps on HV2.

1. Change the second octet of the minimum and maximum range to **17** .

   ````powershell
   $secondOctet = '17'
   $vmHost = Get-VMHost
   $MacAddressMinimum = $vmHost.MacAddressMinimum
   $MacAddressMaximum = $vmHost.MacAddressMaximum

   # Substring(0, 2) retrieves 2 characters, starting from position 0,
   # i. e. the first octet
   # Substring(4, 8) retrieves 8 characters, starting from position 4,
   # i. e. the third and fourth octet.
   # This replaces only the second octet.
   $MacAddressMinimum = "$(
         $MacAddressMinimum.Substring(0, 2)
      )$SecondOctet$(
         $MacAddressMinimum.Substring(4, 8)
      )"
   
   # Same for maximum
   $MacAddressMaximum = "$($MacAddressMaximum.Substring(0, 2))$SecondOctet$($MacAddressMaximum.Substring(4, 8))"

   Set-VMHost `
      -MacAddressMinimum $MacAddressMinimum `
      -MacAddressMaximum $MacAddressMaximum
   ````

1. Leave **Windows PowerShell** open for the next exercise.

### Task 3:  Create internal and private switches

#### Desktop Experience

Perform these steps on HV2.

1. Switch back to **Virtual Switch Manager**.
1. Create a new internal switch ([figure 6]) with the name **Internal** ([figure 7]).
1. Click on **Apply** to commit the changes
1. Switch to **Network and Sharing Center**. A new network adapter has been created as management OS adapter for the internal switch ([figure 8]).
1. Click on the network adapter name and then click on **Details**.

   > What is the IP address of the new network adapter ([figure 9])? Why?

1. Switch back to **Virtual Switch Manager**.
1. Create a new private switch ([figure 10]) with the name **Private** ([figure 11]).
1. Click on **Apply** to commit the changes.
1. Switch to **Network and Sharing Center**.

   > Why is there no new network adapter shown?

#### Windows Admin Center

Perform these steps on CL1.

1. In **Windows Admin Center**, connected to **hv2.smart.etc**, on the left, click **Virtual switches**.
1. Create a new internal switch with the name **Internal**.
1. On the left, click **Networks**. A new network adapter has been created as management OS adapter for the internal switch.

   > What is the IP address of the new network adapter? Why?

1. Switch back to **Virtual switches**.
1. Create a new private switch ([figure 10]) with the name **Private**.
1. Navigate to **Networks**.

   > Why is there no new network adapter shown?

#### PowerShell

Perform these steps on HV2.

1. Create a new internal switch  with the name **Internal**.

   ````powershell
   $vmSwitchName = 'Internal'
   New-VMSwitch -Name $vmSwitchname -SwitchType Internal
   ````

1. Switch to **Network and Sharing Center**. A new network adapter has been created as management OS adapter for the internal switch ([figure 8]).

   ````powershell
   Get-NetAdapter
   ````

1. Get the IP address of the new network adapter.

   ````powershell
   $vmNetworkAdapter = Get-VMNetworkAdapter `
      -ManagementOS `
      -SwitchName $vMSwitchName

   $netAdapter = Get-NetAdapter |
      Where-Object {
         ($PSItem.MacAddress -replace '-','') -eq $vmNetworkAdapter.MacAddress
      } 
   Get-NetIpConfiguration -InterfaceIndex $netAdapter.ifIndex
   ````

   > What is the IP address of the new network adapter? Why?

1. Create a new private switch with the name **Private**.

   ````powershell
   New-VMSwitch -Name 'Private' -SwitchType Private
   ````

1. Retrieve the list of net adapters.

   ````powershell
   Get-NetAdapter
   ````

   > Why is there no new network adapter shown?

## Exercise 3: Managing virtual hard disks

### Introduction

In this exercise, you will create a dynamically expanding virtual disk D:\VHDs\Dynamic.vhdx with a size of 1000 GB. Then, you will create a fixed disk D:\VHDs\Fixed.vhdx with a size of 1 GB. Moreover, you will create a differencing disk D:\VHDs\Differencing.vhdx with the fixed disk as parent. You will convert the dynamic disk to the VHD format. Next, you will inspect the differencing disk, break the disk chain and fix it. Finally, you will expand the fixed disk to 2 GB and shrink it to 1 GB again.

#### Tasks

1. [Create a dynamic disk](#task-1-create-dynamic-disk)
1. [Create a fixed disk](#task-2-create-a-fixed-disk)
1. [Create a differencing disk](#task-3-create-a-differencing-disk)
1. [Convert disks](#task-4-convert-disks)
1. [Inspecting a disk](#task-5-inspecting-a-disk)
1. [Fixing a broken disk chain](#task-6-fixing-a-broken-disk-chain)
1. [Expand a disk](#task-7-expand-a-disk)
1. [Shring a disk](#task-8-shrink-a-disk)

### Task 1: Create dynamic disk

#### Desktop Experience

Perform these steps on HV2.

1. In **Hyper-V Manager**, on the left, from the context menu of the **HV2** node, select **New/Hard Disk…** ([figure 13]).
1. Create a new disk with the following settings.

   * **Disk format:** **VHDX**
   * **Disk Type:** **Dynamically expanding**
   * **Name:** Dynamic.vhdx
   * **Location:** D:\VHDs
   * **Size:** 1000 GB

#### PowerShell

Perform these steps on HV2.

1. Create a new disk with the following settings.

   * **Disk format:** **VHDX**
   * **Disk Type:** **Dynamically expanding**
   * **Name:** Dynamic.vhdx
   * **Location:** D:\VHDs
   * **Size:** 1000 GB

   ````powershell
   $PathDynamic = 'D:\VHDs\Dynamic.vhdx'
   New-VHD -Path $PathDynamic -Dynamic -SizeBytes 1000GB

1. Leave **Windows PowerShell** open for the next task.

### Task 2: Create a fixed disk

#### Desktop Experience

Perform these steps on HV2.

1. Create a new disk with the following settings:

   * **Disk format:** **VHDX**
   * **Disk Type:** **Fixed size**
   * **Name:** Fixed.vhdx
   * **Location:** D:\VHDs
   * **Size:** 1 GB

1. Open **File Explorer**.
1. Navigate to **D:\VHDs**, and examine the virtual hard disk files.

   > What is the size of the virtual hard disk files?

1. From the context menu of the start button, open **Disk Management**.
1. In **Disk Management**, from the menu, select **Actions, Attach VHD** ([figure 14]).
1. Browse for the **Fixed.vhdx** disk and attach it ([figure 15]).
1. From the context menu of the attached VHD, select **Initialize Disk** ([figure 16]).
1. On the attached VHD, create a new volume. Assign drive letter **E:**.
1. Switch to **File Explorer**. The new volume **E:** should be available there ([figure 17]).
1. On **E:**, create a new folder with the name **fixed disk**.
1. From the context menu of **E:**, select **Eject** to unmount the disk.

#### PowerShell

Perform these steps on HV2.

1. Create a new disk with the following settings:

   * **Disk format:** **VHDX**
   * **Disk Type:** **Fixed size**
   * **Name:** Fixed.vhdx
   * **Location:** D:\VHDs
   * **Size:** 1 GB

   ````powershell
   $PathFixed = 'D:\VHDs\Fixed.vhdx'
   New-VHD -Path $PathFixed -Fixed -SizeBytes 1GB
   ````

1. Examine the virtual hard disk files.

   ````powershell
   Get-ChildItem -Path D:\VHDs
   ````

   > What is the size of the virtual hard disk files?

1. Mount **Fixed.vhdx**.

   ````powershell
   # The -Passthru switch tells this command to return the mounted disk
   $VirtualHardDisk = Mount-VHD -Path $PathFixed -Passthru
   ````

1. Initialize the disk.

   ````powershell
   $VirtualHardDisk | Initialize-Disk -PartitionStyle GPT
   ````

1. On the mounted VHD, create a new volume. Assign drive letter **E:**.

   ````powershell
   New-Volume `
      -DiskNumber $VirtualHardDisk.Number `
      -FriendlyName 'Fixed' `
      -DriveLetter E
   ````

1. Check the availability of the new volume.

   ````powershell
   Get-Volume
   ````

1. On **E:**, create a new folder with the name **fixed disk**.

   ````powershell
   New-Item -Path "E:\fixed disk" -ItemType Directory
   ````

1. Unmount the disk.

   ````powershell
   Dismount-VHD -Path $PathFixed
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 3: Create a differencing disk

#### Desktop Experience

Perform these steps on HV2.

1. In **Hyper-V Manager**, create a new disk with the following settings:

   * **Disk format:** **VHDX**
   * **Disk Type:** **Differencing**
   * **Name:** Differencing.vhdx
   * **Location:** D:\VHDs
   * **Configure Disk:** D:\VHDs\Fixed.vhdx; this specifies the parent disk

1. Switch to file explorer and navigate to D:\VHDs.

   > What is the size of the **Differencing.vhdx** file?

1. Double-click on **Differencing.vhdx**. The disk is now available as drive in file explorer and should contain the folder **fixed disk**.
1. Rename the folder to **diff disk**.
1. Navigate back to **D:\VHDs** and examine the file size of **Differencing.vhdx**.

   > What is the size of the **Differencing.vhdx** file now?

1. In **File Explorer**, from the context menu of **E:**, select **Eject**.

#### PowerShell

Perform these steps on HV2.

1. Create a new disk with the following settings:

   * **Disk format:** **VHDX**
   * **Disk Type:** **Differencing**
   * **Name:** Differencing.vhdx
   * **Location:** D:\VHDs
   * **Parent Path:** D:\VHDs\Fixed.vhdx; this specifies the parent disk

   ````powershell
   $PathDifferencing = 'D:\VHDs\Differencing.vhdx'
   New-VHD -Path $PathDifferencing -Differencing -ParentPath $PathFixed
   ````

1. Examine the virtual hard disk files.

   ````powershell
   Get-ChildItem -Path D:\VHDs
   ````

   > What is the size of the **Differencing.vhdx** file?

1. Mount the differencing disk and retrieve its contents. It should contain the folder **fixed disk**.

   ````powershell
   Mount-VHD -Path $PathDifferencing
   Get-ChildItem -Path E:\
   ````

1. Rename the folder to **diff disk**.

   ````powershell
   Rename-Item -Path 'E:\fixed disk' -NewName 'E:\diff disk'
   ````

1. Examine the file size of **Differencing.vhdx**.

   ````powershell
   Get-ChildItem -Path E:\
   ````

   > What is the size of the **Differencing.vhdx** file now?

1. Unmount the disk.

   ````powershell
   Dismount-VHD -Path $PathDifferencing
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 4: Convert disks

#### Deskstop Experience

Perform these steps on HV2.

1. In **Hyper-V Manager**, in the **Actions** pane, click on **Edit Disk…**
1. Select the file **D:\VHDs\Dynamic.vhdx** ([figure 18]) and click **Next**.
1. Select **Convert** ([figure 19]) and click **Next**.
1. Select **VHD** ([figure 20]) and click **Next**.
1. Select **Dynamic** and click on **Next**.
1. Save the converted file as **D:\VHDs\Dynamic.vhd** ([figure 21]).

#### PowerShell

Perform these steps on HV2.

1. Convert the dynamic disk from VHDX to VHD.

   ````powershell
   Convert-VHD -Path $PathDynamic -DestinationPath 'D:\VHDs\Dynamic.vhd'
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 5: Inspecting a disk

#### Desktop Experience

Perform these steps on HV2.

1. In **Hyper-V Manager**, in the **Actions** pane, click on **Inspect Disk…**.
1. In the **Open** dialog navigate to **D:\VHDs** and select **Differencing.vhdx**.
1. A window opens showing the properties of the differencing disk including the chain ([figure 22]).

#### PowerShell

Perform these steps on HV2.

1. Inspect a VHD.

   ````powershell
   Get-VHD -Path $PathDifferencing
   Test-VHD -Path $PathDifferencing
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 6: Fixing a broken disk chain

#### Desktop Experience

Perform these steps on HV2.

1. Switch to file explorer and move the file **Fixed.vhdx** from **D:\VHDs** to **D:\\**
1. Inspect the disk **D:\VHDs\Differencing.vhdx** again.
1. The disk chain is broken because we moved the parent disk ([figure 23]) (although the error message is confusing).
1. In **Hyper-V Manager**, in the **Actions** pane click on **Edit Disk…**.
1. Select the file **D:\VHDs\Differencing.vhdx** and click **Next**.
1. On the page **Reconnect Virtual Hard Disk**, click on **Next** .
1. On the page **Reconnect to parent virtual hard disk** page, select the **Fixed.vhdx** from **D:\**
1. After the wizard finished, Inspect the disk **D:\VHDs\Differencing.vhdx** again. The disk chain should now be ok.

#### PowerShell

Perform these steps on HV2.

1. Move the file **Fixed.vhdx** from **D:\VHDs** to **D:\\**

   ````powershell
   Move-Item -Path $PathFixed -Destination 'D:\'
   ````

1. Inspect the disk **D:\VHDs\Differencing.vhdx** again. The disk chain is broken because we moved the parent disk.

   ````powershell
   Get-VHD -Path $PathDifferencing
   Test-VHD -Path $PathDifferencing
   ````

1. Reconnect the VHD.

   ````powershell
   $PathFixed = 'D:\Fixed.vhdx'
   Set-VHD -Path $PathDifferencing -ParentPath $PathFixed
   ````

1. **D:\VHDs\Differencing.vhdx** again. The disk chain should now be ok.

   ````powershell
   Get-VHD -Path $PathDifferencing
   Test-VHD -Path $PathDifferencing
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 7: Expand a disk

#### Desktop Experience

Perform these steps on HV2.

1. In **Hyper-V Manager**, in the **Actions** pane, click on **Edit Disk…**
1. Select the disk **D:\Fixed.vhdx** and click **Next**.
1. Select **Expand** and click **Next**.
1. Specify 2 GB as new size.
1. Click on **Finish**.

#### PowerShell

Perform these steps on HV2.

1. Expand the fixed disk to 2 GB.

   ````powershell
   Resize-VHD $PathFixed -SizeBytes 2GB
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 8: Shrink a disk

#### Desktop Experience

Perform these steps on HV2.

1. From start menu, run **PowerShell** as Administrator.
1. Enter the following command to shrink the fixed disk back to 1 GB.

   ````powershell
   Resize-VHD -Path D:\Fixed.vhdx -SizeBytes 1GB
   ````

#### PowerShell

Perform these steps on HV2.

1. Enter the following command to shrink the fixed disk back to 1 GB.

   ````powershell
   Resize-VHD -Path D:\Fixed.vhdx -SizeBytes 1GB
   ````

1. Leave **Windows PowerShell** open for the next exercise.

## Exercise 4: Hyper-V replica

### Introduction

In this exercise, you will use Hyper-V replica to replicate a VM from HV1 to HV2.

#### Tasks

1. [Enable Hyper-V replica](#task-1-enable-hyper-v-replica)
1. [Configure VM replication](#task-2-configure-vm-replication)
1. [Validate VM replication](#task-3-validate-vm-replication)
1. [Test planned failover](#task-4-test-planned-failover)
1. [Validate planned failover](#task-5-Validate-planned-failover)
1. [Simulate a failure](#task-6-simulate-a-failure)
1. [Recover from a failure](#task-7-recover-from-a-failure)

### Task 1: Enable Hyper-V replica

#### Desktop Experience

Perform these steps on HV1.

1. Logon as **smart\administrator**
1. Start **Hyper-V Manager** and select the node **HV1**.
1. In the **Actions** pane, click on **Hyper-V Settings**.
1. In **Hyper-V Settings for HV1**, click on **Replication Configuration**.
1. In **Replication Configuration**, activate the checkbox **Enable the computer as a Replica server**. Activate the checkbox **Use Kerberos (HTTP)**, and use the default configuration with port 80 ([figure 24]).
1. In **Replication Configuration**, configure **D:\\** as default path for replicated VMs and click on **Apply** ([figure 25]).
1. In the warning regarding firewall settings, click on **OK**.
1. From the start menu, open the **Windows Firewall with Advanced Security** console.
1. On the left, in the tree pane, select **Inbound Rules**.
1. Enable both **Hyper-V Replica Listener** rules ([figure 26]).
1. Open **Virtual Switch Manager**.
1. Rename the external network **Datacenter1** ([figure 27]) to **smart.etc** ([figure 28]).

Repeat all steps from this task on HV2. In the last step, the external network to be renamed is called **Datacenter2**.

#### PowerShell

Perform these steps on HV1.

1. Enable replication with Kerberos authentication and D:\ as default path.

   ````powershell
   Set-VMReplicationServer `
      -ReplicationEnabled $true `
      -AllowedAuthenticationType Kerberos `
      -ReplicationAllowedFromAnyServer $true `
      -DefaultStorageLocation D:\
   ````

1. Enable necessary inbound firewall rules for the Hyper-V Replica Listener.

   ````powershell
   Get-NetFirewallRule -DisplayName 'Hyper-V Replica*' | Enable-NetFirewallRule
   ````

1. Rename the external network **Datacenter1** to **smart.etc**.

   ````powershell
   Rename-VMSwitch -Name 'Datacenter1' -NewName 'smart.etc'
   ````

1. Leave **Windows PowerShell** open for the next task.

Repeat all steps from this task on HV2. In the last step, the external network to be renamed is called **Datacenter2**.

### Task 2: Configure VM replication

#### Desktop Experience

Perform these steps on HV1.

1. In **Hyper-V Manager** start the VM **WS2019**.
1. From the context menu of **WS2019**, select **Enable Replication**.
1. Click on **Next** to start the configuration.
1. In **Replica Server** enter **HV2**, and click on **Next**.
1. Keep the default parameters and click on **Next**.
1. Validate that the correct disk is selected and click on **Next**.
1. Set the replication frequency to 30 sec and click on **Next**.
1. On the page **Configure Additional Recovery Points**, select **Create additional hourly recovery points**. In **Coverage provided by additional recovery points (in hours)** enter 12. Activate **Volume Shadow Copy Service (VSS) snapshot frequency (in hours)** and enter 2 ([figure 29]).
1. Set to send the **initial copy immediately over the network** and click on **Finish** to start the replication.
1. At the bottom of **Hyper-V Manager**, select the tab **Replication** to check the state of the initial replication of the VM ([figure 30]). Wait until the initial replication has finished. This takes about 5 minutes.
1. From the context menu of **WS2019**, select **Replication**, **View Replication Health**. Validate the successful continuous replication progress.

#### PowerShell

Perform these steps on HV1.

1. Enable replication for **WS2019**. The replication frequency should be 30 seconds, the recovery history 12 hours, and the VSS snapshot frequency 2 hours.

   ````powershell
   $VMName='WS2019'
   Enable-VMReplication `
      -VMName $VMName `
      -ReplicaServerName HV2 `
      -ReplicaServerPort 80 `
      -AuthenticationType Kerberos `
      -ReplicationFrequencySec 30 `
      -RecoveryHistory 12 `
      -VSSSnapshotFrequencyHour 2
   ````

1. Send the initial copy immediately over the network and start the replication.

   ````powershell
   Start-VMInitialReplication -VMName $VMName
   ````

1. Check the state of the initial replication of the VM. Wait until the initial replication has finished. This takes about 5 minutes.

   ````powershell
   Get-VMReplication -VMName $VMName
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 3: Validate VM replication

#### Desktop Experience

Perform these steps on HV1.

1. Switch to Hyper-V Manager. You should see the VM **WS2019**.
1. From the context menu of **WS2019**, select **Replication**, **View Replication Health**. Validate the successful continuous replication progress.
1. Open **File Explorer** and navigate to **D:\\**. You should see a folder **Hyper-V Replica** – inside this folder Hyper-V creates all the replicas of VMs.

#### PowerShell

Perform these steps on HV1.

1. View replication health.

   ````powershell
   Get-VMReplication -VMName $VMName
   ````

1. Check the contents of **D:\\**. You should see a folder **Hyper-V Replica** – inside this folder Hyper-V creates all the replicas of VMs.

   ````powershell
   Get-ChildItem -Path D:\
   Get-ChildItem -Path 'D:\Hyper-V Replica' -Recurse
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 4: Test planned failover

#### Desktop Experience

Perform these steps on HV1.

1. From the context menu of the VM **WS2019**, select **Replication**, **Planned Failover**.
1. Activate **Reverse the replication** and activate **start the replicated VM**. Try to perform a planned failover.

   > Can you perform a planned failover? Why or why not?

1. Shut-down **WS2019**.
1. From the context menu of the VM **WS2019**, select **Replication**, **Planned Failover**.
1. Activate **Reverse the replication** and activate **start the replicated VM**. Try to perform a planned failover.

   > Can you perform a planned failover now? Why or why not?

#### PowerShell

Perform these steps on HV1.

1. Try to perform a planned failover.

   ````powershell
   Start-VMFailover -VMName $VMName -Prepare
   ````

   > Can you perform a planned failover? Why or why not?

1. Shut-down **WS2019**.

   ````powershell
   Stop-VM -VMName $VMName
   ````

1. Try to perform a planned failover again.

   ````powershell
   Start-VMFailover -VMName $VMName -Prepare
   Start-VMFailover -VMName $VMName -ComputerName HV2
   Set-VMReplication -Reverse -VMName $VMName -ComputerName HV2
   ````

   > Can you perform a planned failover now? Why or why not?

1. Reverse the replication and start the VM.

   ````powershell
   Set-VMReplication -Reverse -VMName $VMName -ComputerName HV2
   Start-VM -VMName $VMName -ComputerName HV2
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 5: Validate planned failover

#### Desktop Experience

Perform these steps on HV2.

1. Verify, that the VM **WS2019** has started and the replication is working.

#### PowerShell

Perform these steps on HV2.

1. Verify, that the VM **WS2019** has started and the replication is working.

   ````powershell
   Get-VM -VMName $VMName
   Get-VMReplication -VMName $VMName

1. Leave **Windows PowerShell** open for the next task.

### Task 6: Simulate a failure

#### Desktop Experience

Perform these steps on the host computer or the hosting cloud service.

1. Turn off **HV2** to simulate a failure of HV2 (do not shut down!).

#### PowerShell

Perform these steps on the host computer or the hosting cloud service.

1. Turn off **HV2** to simulate a failure of HV2 (do not shut down!).

   ````powershell
   Stop-VM -Name HV2 -Force
   ````

1. Leave **Windows PowerShell** open for the next task.

### Task 7: Recover from a failure

#### Desktop Experience

Perform these steps on HV1.

1. On HV1 verify, that the VM **WS2019** is powered off. From the context menu of the VM **WS2019**, select **Replication** and click on **Failover**.
1. Select **Latest Recovery Point** and click on **Failover**.
1. Wait until the failover is finished and the VM is started.

#### PowerShell

Perform these steps on HV1.

1. On HV1 verify, that the VM **WS2019** is powered off.

   ````powershell
   Get-VM -VMName $VMName -ComputerName HV1
   ````

1. Start the failover and start the VM.

   ````powershell
   Start-VMFailover $VMName -ComputerName HV1
   Start-VM -Name $VMName -ComputerName HV1
   Get-VM -Name $VMName -ComputerName HV1
   Complete-VMFailover -VMName $VMName -ComputerName $hv1
   ````powershell

Bonus: After HV is available again, you could execute these commands to enable replication again.

````powershell
Stop-VM -VMName $VMName -ComputerName $hv2
Set-VMReplication -VMName $VMName -AsReplica -ComputerName $hv2
Set-VMReplication `
    -VMName $VMName `
    -Reverse `
    -ReplicaServerName $hv2 `
    -ComputerName $hv1
Start-VMInitialReplication -VMName $VMName -ComputerName $hv1
````

[figure 1]: images/hyperv-manager-virtual-switch-manager.png
[figure 2]: images/hyperv-virtual-switch-manager.png
[figure 3]: images/Explorer-virtual-network-adapter.png
[figure 4]: images/Network-and-sharing-center-change-adapter-settings.png
[figure 5]: images/Explorer-view-details.png
[figure 6]: images/hyperv-virtual-switch-manager-create-internal-switch.png
[figure 7]: images/hyperv-virtual-switch-properties-internal.png
[figure 8]: images/Explorer-virtual-network-adapters.png
[figure 9]: images/Network-connection-details.png
[figure 10]: images/hyperv-virtual-switch-manager-create-private-switch.png
[figure 11]: images/hyperv-virtual-switch-properties-private.png
[figure 12]: images/hyperv-mac-address-range.png
[figure 13]: images/hyperv-manager-new-hard-disk.png
[figure 14]: images/disk-management-attach-vhd.png
[figure 15]: images/disk-management-attach-vhd-path.png
[figure 16]: images/disk-management-initialize-disk-vhd.png
[figure 17]: images/Explorer-new-volume.png
[figure 18]: images/hyperv-edit-vhd-locate.png
[figure 19]: images/hyperv-edit-vhd-action.png
[figure 20]: images/hyperv-edit-vhd-format.png
[figure 21]: images/hyperv-edit-vhd-configure.png
[figure 22]: images/hyperv-vhd-properties.png
[figure 23]: images/hyperv-vhd-differencing-broken.png
[figure 24]: images/hyperv-replication-configuration.png
[figure 25]: images/hyperv-replication-configuration-location.png
[figure 26]: images/hyperv-replication-firewall-rules.png
[figure 27]: images/hyperv-virtual-switch-properties-datacenter1.png
[figure 28]: images/hyperv-virtual-switch-manager-smart-etc.png
[figure 29]: images/hyperv-configure-recovery-points.png
[figure 30]: images/hyperv-replication-status.png
