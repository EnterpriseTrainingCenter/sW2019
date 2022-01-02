# Lab: DNS Policies

## Required VMs

* DC1
* NET1
* DHCP
* Router
* CL1
* SRV2
* CL2 on HV1

## Exercises

1. [DNS server configuration](#exercise-1-dns-server-configuration)
1. [Add DNS zone scopes and records](#exercise-2-add-dns-zone-scopes-and-records)
1. [Test DNS query policies](#exercise-3-test-dns-query-policies)

## Exercise 1: DNS server configuration

### Introduction

In this exercise you will install the DNS server role on DNS1. You will create a new forward lookup zone mysmart.com. In the zone, you will create an A record resolving to 8.8.8.8. On DC1, you will create a conditional forwarder for mysmart.com pointing to the IP address of NET1. Finally, you will test the name resolution of the new record.

#### Tasks

1. [Install DNS](#task-1-install-dns)
1. [Create a new zone](#task-2-create-a-new-zone)
1. [Create an A record](#task-3-create-an-a-record)
1. [Create a conditional forwarder](#task-4-create-a-conditional-forwarder)
1. [Test name resolution of the new record](#task-5-test-name-resolution-of-the-new-record)

### Task 1: Install DNS

#### Desktop experience

Perform these steps on NET1.

1. Sign in as **smart\Administrator**.
1. Open **Server Manager**.
1. In Server Manager, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, proceed to page **Select server roles**.
1. On page Select server roles, activate **DNS Server**. In the dialog appearing, click **Add Features**.
1. Proceed through the wizard to install DNS Server.

#### PowerShell

Perform these steps on NET1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Install the DNS feature including management tools.

    ````powershell
    Install-WindowsFeature -Name DNS -IncludeManagementTools 
    ````

### Task 2: Create a new zone

#### Desktop experience

Perform these steps on NET1.

1. In Server Manager, click **Tools**, **DNS**.
1. In DNS Manager, navigate to **DNS**, **NET1**, **Forward Lookup Zones**.
1. In the context-menu of **Forward Lookup Zones**, click **New Zone...**.
1. In New Zone Wizard, on page **Welcome to the New Zone Wizard**, click **Next >**.
1. On page **Zone type**, ensure **Primare zone** is selected and click **Next >**.
1. On page **Zone name**, in **Zone name**, enter **mysmart.com** and click **Next >**.
1. On page **Zone file**, click **Next >**.
1. On page **Dynamic Update**, ensure **Do not allow dynamic updates** is selected and click **Next >**.
1. On page **Completing the New Zone Wizard**, click **Finish**.
1. Back in DNS Manager, in the tree pane, click **mysmart.com**

#### PowerShell

Perform this task on NET1.

In **Windows PowerShell**, Create a new forward lookup zone **mysmart.com**.

````powershell
$zoneName = 'mysmart.com'
Add-DnsServerPrimaryZone -Name $zoneName -ZoneFile "$zoneName.dns"
````

### Task 3: Create an A record

#### Desktop experience

Perform these steps on NET1.

1. In the context-menu of **mysmart.com**, click **New Host (A or AAAA)...**
1. In New Host, in **Name (uses parent domain name if blank)**, enter **test**. In **IP address**, enter 8.8.8.8 and click **Add Host**.
1. In message **The host record test.mysmart.com was successfully created** click **OK**.
1. Back in New Host, click **Done**.

#### PowerShell

Perform this task on NET1.

In **Windows PowerShell**, in zone **mysmart.com**, create a new A record **test** pointing to **8.8.8.8**.

````powershell
Add-DnsServerResourceRecordA `
    -ZoneName $zoneName `
    -Name test `
    -IPv4Address 8.8.8.8
````

### Task 4: Create a conditional forwarder

#### Desktop experience

Perform these steps on NET1.

1. Back in DNS Manager, In the context-menu of **DNS**, click **Connect to DNS Server...**.
1. In Connect to DNS Server, click **The following computer**, enter **DC1**, and click **OK**.
1. Back in DNS Manager, navigate to **DNS**, **DC1**, **Conditional Forwarders**.
1. In the context-menu of **Conditional Forwarders**, click **New Condiditional Forwarders...**.
1. In New Conditional Forwarder, in **DNS Domain**, enter **mysmart.com**. Under **IP addresses of the master servers**, click **\<Click here to add and IP Address or DNS name>**. Enter **10.1.1.70.** and click **OK**.
1. Open **Command Prompt**.

#### PowerShell

Perform this task on NET1.

In **Windows PowerShell**, on DNS server DC1, create a new conditional forwarder for **mysmart.com** pointing to **10.1.1.70**.

````powershell
Add-DnsServerConditionalForwarderZone `
    -ComputerName DC1 `
    -ZoneName $zoneName `
    -MasterServers 10.1.1.70 
````

### Task 5: Test name resolution of the new record

Perform these steps on NET1.

1. Run **Windows PowerShell**
1. Resolve **test.mysmart.com**.

    ````powershell
    Resolve-DnsName test.mysmart.com
    ````

    As response, you should get the A record with the IPAddress 8.8.8.8.

## Exercise 2: Add DNS zone scopes and records

### Introduction

In this exercise you will configure zone scopes to resolve sts.mysmart.com to 10.1.1.71, if queried from subnet 10.1.1.0/24 and to resolve to 10.1.1.72, if queried from 10.1.2.0/24. 

#### Tasks

1. [Add zone scopes](#task-1-add-zone-scopes)
1. [Add records in zone scopes](#task-2-add-records-in-zone-scopes)
1. [Add DNS client subnets](#task-3-add-dns-client-subnets)
1. [Configure DNS query resolution policies](#task-4-configure-dns-query-resolution-policies)
1. [Test DNS policies from internal client subnet](#task-5-test-dns-policies-from-internal-client-subnet)
1. [Test DNS policies from external client subnet](#task-6-test-dns-policies-from-external-client-subnet)

### Task 1: Add zone scopes

Perform these steps on NET1.

1. Run **Windows PowerShell** as Administrator.
1. List all DNS zones.

    ````powershell
    Get-DnsServerZone
    ````

1. For zone **mysmart.com**, create a zone scopes **Datacenter1** and **Datacenter2**.

    ````powershell
    # $zoneName = 'mysmart.com'
    $zoneScopeNameDatacenter1 = 'Datacenter1'
    $zoneScopeNameDatacenter2 = 'Datacenter2'
    Add-DnsServerZoneScope -ZoneName $zoneName -Name $zoneScopeNameDatacenter1
    Add-DnsServerZoneScope -ZoneName $zoneName -Name $zoneScopeNameDatacenter2
    ````

1. List the zone scopes and their properties.

    ````powershell
    Get-DnsServerZoneScope -ZoneName $zoneName
    ````

### Task 2: Add records in zone scopes

Perform these steps on NET1.

1. Add an A record with the name **sts** to the zone scope of **Datacenter 1** pointing to **10.1.1.71** and to zone scope **Datacenter 2** pointing to **10.1.1.72**.

    ````powershell
    $name = 'sts'
    Add-DnsServerResourceRecordA `
        -ZoneName $zoneName `
        -ZoneScope $zoneScopeNameDatacenter1 `
        -Name $name `
        -IPv4Address 10.1.1.71
    Add-DnsServerResourceRecordA `
        -ZoneName $zoneName `
        -ZoneScope $zoneScopeNameDatacenter2 `
        -Name $name `
        -IPv4Address 10.1.1.72
    ````

1. List the records for the Datacenter1 zone.

    ````powershell
    Get-DnsServerResourceRecord `
        -ZoneName $zoneName `
        -ZoneScope $zoneScopeNameDatacenter1
    ````

1. List the records for the Datacenter2 zone.

    ````powershell
    Get-DnsServerResourceRecord `
        -ZoneName $zoneName `
        -ZoneScope $zoneScopeNameDatacenter2
    ````

### Task 3: Add DNS client subnets

Perform this task on NET1.

Add two client subnets for the subnets **10.1.1.0/24** and **10.1.2.0/24**.

````powershell
$clientSubnetNameDatacenter1 = 'Internal'
$clientSubnetNameDatacenter2 = 'External'
Add-DnsServerClientSubnet `
    -Name $clientSubnetNameDatacenter1 `
    -IPv4Subnet 10.1.1.0/24
Add-DnsServerClientSubnet `
    -Name $clientSubnetNameDatacenter1 `
    -IPv4Subnet 10.1.2.0/24
````

### Task 4: Configure DNS query resolution policies

Perform these steps on NET1.

1. Create a DNS query resolution policy allowing queries from the client subnet of Datacenter1 to resolve records in the zone scope of Datacenter 1.

    ````powershell
    Add-DnsServerQueryResolutionPolicy `
        -Name Datacenter1 `
        -Action ALLOW `
        -ZoneName $zoneName `
        -ZoneScope $zoneScopeNameDatacenter1 `
        -ClientSubnet "EQ,$clientSubnetNameDatacenter1"
    ````

1. Create a DNS query resolution policy allowing queries from the client subnet of Datacenter 2 to resolve records in the zone scope of Datacenter 2.

    ````powershell
    Add-DnsServerQueryResolutionPolicy `
        -Name Datacenter2 `
        -Action ALLOW `
        -ZoneName $zoneName `
        -ZoneScope $zoneScopeNameDatacenter2 `
        -ClientSubnet "EQ,$clientSubnetNameDatacenter2"
    ````

1. Get the DNS query policies and their processing order:

    ````powershell
    Get-DnsServerQueryResolutionPolicy -ZoneName $zoneName
    ````

## Exercise 3: Test DNS query policies

### Introduction

In this exercise, you will test the name resolution from the internal and external client subnet.

#### Tasks

1. [Test DNS policies from internal client subnet](#task-1-test-dns-query-policies-from-internal-client-subnet)
1. [Test DNS policies from external client subnet](#task-2-test-dns-query-policies-from-external-client-subnet)

### Task 1: Test DNS query policies from internal client subnet

Perform this task on NET1.

Resolve **sts.mysmart.com**.

````powershell
Resolve-DnsName sts.mysmart.com
````

This should return a record with IPAddress of 10.1.1.71.

### Task 2: Test DNS query policies from external client subnet

Perform these steps on CL2.

1. Sign in as **smart\administrator**.
1. Run **Windows PowerShell**.
1. Resolve **sts.mysmart.com**.

    ````powershell
    Resolve-DnsName sts.mysmart.com -Server 10.1.1.70 -DnsOnly
    ````

    This should return a record with IPAddress of 10.1.1.72.

    > Why do you have to use the ````-DnsOnly```` switch parameter? Hint: Run the command again without the parameter.
