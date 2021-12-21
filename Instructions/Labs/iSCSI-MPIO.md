# Lab: iSCSI & MPIO

## Required VMs

* CL1
* DC1
* DHCP
* Router
* HV1
* FS on HV1
* WS2019 on HV1

## Exercises

1. [iSCSI and Multipath I/O](#exercise-1-iscsi-and-multipath-io)

## Exercise 1: iSCSI and Multipath I/O

### Introduction

In this exercise, you will add two new additional network interfaces to WS2019 connecting to the virtual switches iSCSI and iSCSI2, configure them with the IP addresses 10.1.9.100 and 10.2.9.100 and disable DNS registration and all network protocol bindings except TCP/IPv4. Next, you will create a new iSCSI target on DHCP by adding a new iSCSI virtual Disk I:, a size of 40 GB giving the initiator of WS2019 access. Then, you will install the Multipath feature on WS2019 and connect to the iSCSI target using MPIO. Finally, you will test the fault-tolerance by disconnecting network connections on WS2019 and examine the performance gain of MPIO.

#### Tasks

1. [Configure network connections](#task-1-configure-network-connections)
1. [Configure TCP/IP](#task-2-configure-tcpip)
1. [Configure an iSCSI target](#task-3-Configure-an-iscsi-target)
1. [Configure the iSCSI initiator](#task-4-configure-the-iscsi-initiator)
1. [Test fault-tolerance of Multipath I/O](#task-5-test-fault-tolerance-of-multipath-io)
1. [Examine the performance gain of MPIO](#task-6-examine-the-performance-gain-of-mpio)

### Task 1: Configure network connections

#### Desktop Experience

Perform these steps on HV1.

1. Logon as **smart\administrator**.
1. Open **Hyper-V Manager**.
1. Open the settings of VM **WS2019**.
1. Add two additional network interfaces and connect it to the Hyper-V Switches **iSCSI** and **iSCSI2**.
1. Close **Settings for WS2019 on HV1**.
1. Open the settings of VM **WS2019**.
1. Expand the **Network Adapter** connected to the switch **iSCSI**.
1. Click **Advanced Features**. Take a note of the MAC address.
1. Repeat the previous steps to take a note of the MAC address of the network adapter connected to **iSCSI2**.

#### PowerShell

Perform these steps on HV1.

1. Logon as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Add two additional network interfaces and connect it to the Hyper-V Switches **iSCSI** and **iSCSI2**.

   ````powershell
   $vMName = 'WS2019'
   Add-VMNetworkAdapter -VMName $vMName -SwitchName iSCSI
   Add-VMNetworkAdapter -VMName $vMName -SwitchName iSCSI2
   ````

1. Retrieve the MAC addresses of the network interfaces.

   ````powershell
   Get-VMNetworkAdapter -VMName WS2019
   ````

1. Take a note of the MAC addresses corresponding to the switches **iSCSI** and **iSCSI2**.
1. Leave **Windows PowerShell** open for an upcoming task.

### Task 2: Configure TCP/IP

#### Desktop Experience

Perform these steps on WS2019.

1. Logon **smart\administrator**.
1. Open **Network and Sharing Center**.
1. In **Network and Sharing Center**, on the left, click **Change adapter settings**.
1. Open the properties of both additional network interfaces.
1. Open the details of both additional network interfaces and notice the MAC addresses.
1. Consult your notes from the previous task and rename the network interfaces according to the virtual switchs, they are connected to (**iSCSI** and **iSCSI2**).
1. In the **iSCSI** and **iSCSI2** network interfaces, disable all protocols except **Internet Protocol Version 4**.
1. In the **iSCSI** and **iSCSI2**  network interfaces, configure the properties of **Internet Protocol Version 4** settings.
   * **IP Address:**
     * **iSCSI**: 10.1.9.100
     * **iSCSI2**: 10.2.9.100
   * **Subnet mask:** 255.255.255.0
   * Disable DNS registration

#### PowerShell

Perform these steps on WS2019.

1. Logon **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Retrieve the net adapter connected to the iSCSI switch. Insert the MAC addresses of the virtual network adapters, you took note of in the previous task.

   ````powershell
   <#
   Insert the MAC addresses of the virtual network adapters, you noted in the
   previous task. Insert a dash between the octets, eg. 00-00-00-00-00-00
   #>
   $iSCSImacAddress = '00-00-00-00-00-00' # TODO: change MAC address
   $iSCSI2macAddress = '00-00-00-00-00-00' # TODO: change MAC address
   $iSCSInetAdapter = Get-NetAdapter | 
      Where-Object { $PSItem.MacAddress -eq $iSCSImacAddress }
   $iSCSI2netAdapter = Get-NetAdapter | 
      Where-Object { $PSItem.MacAddress -eq $iSCSI2macAddress }
   ````

1. Rename the net adapters to confirm to the virtual switch names.

   ````powershell
   $iSCSInetAdapter | Rename-NetAdapter -NewName iSCSI
   $iSCSI2netAdapter | Rename-NetAdapter -NewName iSCSI2

1. For the **iSCSI** and **iSCSI2** network interfaces, disable all protocols except **Internet Protocol Version 4**.

   ````powershell
   Get-NetAdapterBinding -ifAlias iSCSI | 
   Where-Object { $PSItem.ComponentID -ne 'ms_tcpip' } | 
   Disable-NetAdapterBinding

   Get-NetAdapterBinding -ifAlias iSCSI2 | 
   Where-Object { $PSItem.ComponentID -ne 'ms_tcpip' } | 
   Disable-NetAdapterBinding
   ````

1. For the **iSCSI** and **iSCSI2**  network interfaces, configure **Internet Protocol Version 4** settings.

   * IP Address:
     * iSCSI: 10.1.9.100
     * iSCSI2: 10.2.9.100
   * Subnet mask: 255.255.255.0
   * Disable DNS registration

   ````powershell
   Set-DnsClient `
      -InterfaceIndex $iSCSInetAdapter.ifIndex `
      -RegisterThisConnectionsAddress $false

   New-NetIPAddress `
      -InterfaceIndex $iSCSInetAdapter.ifIndex `
      -AddressFamily IPv4 `
      -IPAddress 10.1.9.100 `
      -PrefixLength 24
   
   Set-DnsClient `
      -InterfaceIndex $iSCSI2netAdapter.ifIndex `
      -RegisterThisConnectionsAddress $false

   New-NetIPAddress `
      -InterfaceIndex $iSCSI2netAdapter.ifIndex `
      -AddressFamily IPv4 `
      -IPAddress 10.2.9.100 `
      -PrefixLength 24
   ````

1. Take a note of the MAC addresses corresponding to the switches **iSCSI** and **iSCSI2**.

### Task 3: Configure an iSCSI target

#### Desktop Experience

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Server Manager**.
1. Dismiss the Windows Admin Center invite.
1. From the context menu of **All Servers**, select **Add Servers…**.
1. Add a connection to server **DHCP**.
1. Click on **File and Storage Services**, and then on **iSCSI**.
1. From the Tasks drop-down, select **New iSCSI Virtual Disk...** ([figure 1]).
1. Configure a new virtual disk.
   * **Drive:** I:
   * **Name:** MPIOTest
   * **Size:** 40GB, **dynamically expanding**
   * **Create a new iSCSI Target**
   * **Name:** **MPIOTest**
   * **Access servers:** Query initiator name of computer **WS2019**

#### PowerShell

Perform these steps on DHCP.

1. Logon as **smart\Administrator**.
1. Run **Windows PowerShell**.

   ````powershell
   powershell
   ````

1. Configure a new virtual disk and a new iSCSI target.
   * Drive: I:
   * Name: MPIOTest
   * Size: 40GB, dynamically expanding
   * iSCSI Target Name: **MPIOTest**
   * Access servers: Query initiator name of computer **WS2019**

   ````powershell
   $targetName = 'MPIOTest'
   $path = "I:\iSCSIVirtualDisks\$Targetname.vhdx"

   New-IscsiVirtualDisk -Path $path -SizeBytes 40GB
   New-IscsiServerTarget `
      -TargetName $TargetName `
      -InitiatorIds 'IQN:iqn.1991-05.com.microsoft:ws2019.smart.etc'
   Add-IscsiVirtualDiskTargetMapping -TargetName $targetname -Path $path
   ````

### Task 4: Configure the iSCSI initiator

#### Desktop Experience

Perform these steps on WS2019.

1. Run **Windows PowerShell** as Administrator.
1. Install the Multipath feature.

   ````powershell
   Install-WindowsFeature 'MultiPath-IO' –IncludeManagementTools
   ````

1. From the start menu, open **MPIO Configuration**.
1. On the tab **Discover Multi-Path**, activate the support for iSCSI devices.
1. Click on **Add** and then **OK**.
1. From the start, menu open **iSCSI Initiator**.
1. Click on **Yes** to accept the service auto start.
1. In the text box **Target**, enter **iscsi-target.smart.etc**, and click on **Quick Connect**.
1. After the connection has established, disconnect the connection and connect it again via the **Connect** and **Disconnect** buttons ([figure 2]).
1. In the dialog **Connect to Target**, activate **Enable multi-path** and click on **Advanced**.
1. Configure the first NIC with a matching subnet IP on the target ([figure 3]). You will see that the target is connected again.
1. Click on **Connect** again.
1. In the dialog **Connect to Target**, activate **Enable multi-path** and click on **Advanced**.
1. Configure the second NIC with a matching subnet IP on the target.
1. Open **Disk Management**, bring the new LUN online and initialize it as GPT.
1. Create and format a new volume with default settings and drive letter **E:**.

#### PowerShell

Perform these steps on WS2019.

1. Install the Multipath feature.

   ````powershell
   Install-WindowsFeature 'MultiPath-IO' –IncludeManagementTools
   ````

1. Activate the support for iSCSI devices.

   ````powershell
   Enable-MSDSMAutomaticClaim -BusType iSCSI
   ````

1. Set the service to auto start.

   ````powershell
   $service = Get-Service -Name MSiSCSI
   $service | Set-Service -StartupType Automatic
   $service | Start-Service
   ````

1. Quickly connect to  **iscsi-target.smart.etc**.

   ````powershell
   $IscsiTargetPortal = New-IscsiTargetPortal `
      -TargetPortalAddress iscsi-target.smart.etc
   $IscsiTarget = Get-IscsiTarget -IscsiTargetPortal $IscsiTargetPortal
   $IscsiTarget | Connect-IscsiTarget -IsPersistent $true
   ````

1. After the connection has established, disconnect the connection.

   ````powershell
   $IscsiTarget | Disconnect-IscsiTarget
   ````

1. Connect to the target again using multi-path and the first network adapter.

   ````powershell
   $IscsiTarget | 
   Connect-IscsiTarget `
      -IsMultipathEnabled $true `
      -InitiatorPortalAddress 10.1.9.100 `
      -TargetPortalAddress 10.1.9.10 `
      -IsPersistent $true
   ````

1. Connect to the target again using multi-path and the second network adapter.

   ````powershell
   $IscsiTarget |
   Connect-IscsiTarget `
      -IsMultipathEnabled $true `
      -InitiatorPortalAddress 10.2.9.100 `
      -TargetPortalAddress 10.2.9.10 `
      -IsPersistent $true
   ````

1. Bring the new LUN online and initialize it as GPT.

   ````powershell
   $PhysicalDisk = Get-PhysicalDisk |
   Where-Object { $PSItem.BusType -eq 'iSCSI' }
   Initialize-Disk -UniqueId $PhysicalDisk.UniqueId -PartitionStyle GPT
   ````

1. Create and format a new volume with default settings and drive letter E.

   ````powershell
   $DriveLetter = 'E'
   New-Partition `
      -DiskId $PhysicalDisk.UniqueId `
      -DriveLetter $DriveLetter `
      -UseMaximumSize
   Format-Volume -DriveLetter $DriveLetter -FileSystem NTFS
   ````

### Task 5: Test fault-tolerance of MultiPath I/O

#### Desktop Experience

Perform these steps on HV1.

1. On HV1 open File Explorer
1. Start a copy process from **D:\ISO\WS2016_RTM.iso** to **\\\WS2019\E$**. If the copy process finishes during the next steps. Start it again.
1. While the copy process is running, disconnect one NIC.

   > Does the copy process continue?

1. Reconnect the NIC.
1. Disconnect the other NIC.

   > Does the copy process continue?

1. Reconnect the NIC.

#### PowerShell

Perform these steps on HV1.

1. Open a new, additional **Windows PowerShell**.
1. In the new **Windows PowerShell**, Start a copy process from **D:\ISO\WS2016_RTM.iso** to **\\\WS2019\E$**. If the copy process finishes during the next steps. Start it again.

   ````powershell
   Copy-Item D:\ISO\WS2016_RTM.iso \\WS2019\E$
   ````

1. While the copy process is running, switch to the original **Windows PowerShell**, running as Administrator, and disconnect one NIC.

   ````powershell
   $SwitchName = 'iSCSI'
   
   $VMNetworkAdapter = Get-VMNetworkAdapter -VMName $vMName | 
      Where-Object { $PSItem.SwitchName -eq $SwitchName }
   
   $VMNetworkAdapter | Disconnect-VMNetworkAdapter
   ````

   > Does the copy process continue?

1. Reconnect the NIC.

   ````powershell
   $VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName $SwitchName
   ````

1. Disconnect the other NIC.

   ````powershell
   $SwitchName = 'iSCSI2'
   $VMNetworkAdapter = Get-VMNetworkAdapter -VMName $vMName | 
      Where-Object { $PSItem.SwitchName -eq $SwitchName }
   
   $VMNetworkAdapter | Disconnect-VMNetworkAdapter
   ````

   > Does the copy process continue?

1. Reconnect the NIC.

   ````powershell
   $VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName $SwitchName
   ````

### Task 6: Examine the performance gain of MPIO

On HV1, make sure a copy process is still running.

Perform these steps on WS2019.

1. Open **Task Manager**.
1. In **Task manager**, examine the utilization of the Ethernet interfaces ([figure 4]).

   > How is the network traffic distributed?

[figure 1]: images/iSCSI-new-iscsi-virtual-disk.png
[figure 2]: images/iSCSI-initiator-properties-connect-disconnect.png
[figure 3]: images/iSCSI-advanced-settings.png
[figure 4]: images/MPIO-task-manager-ethernet.png
