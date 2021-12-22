# Lab: Installing and configuring Windows Admin Center

## Required VMs

* DC1
* DHCP
* Router
* SRV2
* PKI
* CL1

## Exercises

1. [Installing Windows Admin Center](#exercise-1-installing-windows-admin-center)
1. [Configuring Windows Admin Center](#exercise-2-configuring-windows-admin-center)

## Exercise 1: Installing Windows Admin Center

### Introduction

In this exercise, on SRV2, you will request a certificate using the template *WebServer10Years* for the subject name *admincenter.smart.etc* and the dns names *admincenter.smart.etc* and *admincenter*. Then, you will install Windows Admin Center using the certificate you requested.

#### Tasks

1. [Request a certificate](#task-1-request-a-certificate)
1. [Install Windows Admin Center binaries](#task-2-install-windows-admin-center-binaries)

### Task 1: Request a certificate

Perform these steps on SRV2.

1. Logon as **smart\Administrator**
1. Start Windows PowerShell by excuting the following command.

   ````shell
   powershell
   ````

1. Request a certificate and store the result in a variable.

   ````powershell
   # This is an array of strings, separated by commas
   $dnsName = 'admincenter.smart.etc', 'admincenter'
   
   # Expressions in double-quoted strings are indicated by $()
   # [0] is the first element of the string array
   $subjectName = "CN=$($dnsName[0])"
   
   # WebServer10Years is a custom template, we created for you
   $template = 'WebServer10Years'
   
   # The back tick ` can be used to split long command lines and make them more readable
   $result = Get-Certificate `
       -Template $template `
       -SubjectName $subjectName `
       -DnsName $dnsName `
       -CertStoreLocation Cert:\LocalMachine\My   
   ````

1. Leave PowerShell open for the next task

### Task 2: Install Windows Admin Center binaries

Perform these steps on SRV2.

1. Store the certificate thumbprint in a variable.

   ````powershell
   $thumbprint = $result.Certificate.Thumbprint
   ````

1. Download the current version of Windows Admin Center using BITS.

   ````powershell
   $path = 'C:\WindowsAdminCenter.msi'
   Start-BitsTransfer -Source 'https://aka.ms/WACDownload' -Destination $path
   ````

1. Execute the following commands to install Windows Admin Center binaries

   ````powershell
   # PowerShell variables can be used when executing external commands
   # They are expanded automatically
   msiexec /i $path /qb+ /L*v 'C:\WAC-install.log' CHK_REDIRECT_PORT_80=1 SME_PORT=443 SSL_CERTIFICATE_OPTION=installed SME_THUMBPRINT=$thumbprint
   ````

## Exercise 2: Configuring Windows Admin Center

### Introduction

In this exercise, you will configure Kerberos Constrained Delegation to be able to use Single Sign On (SSO) for the servers dc1, fs, HV1, HV2, sr1, sr2, S2D, S2D1, S2D2, S2D3, S2D4, SRV1903, Docker, Node1, Node2, PKI, SR1, SR2, and WS2019 from SRV2. As a second step, you will add a DNS host record for *admincenter.smart.etc* pointing to the IP address *10.1.1.73*.

#### Tasks

1. [Configure Kerberos Constrained Delegation and DNS](#task-1-configure-kerberos-constrained-delegation)
1. [Add a DNS record](#task-2-add-a-dns-record)

### Task 1: Configure Kerberos Constrained Delegation

#### Desktop Experience

Perform these steps on DC1.

1. Logon as **smart\Administrator**.
1. Open **Windows PowerShell ISE**.
1. In **Windows PowerShell ISE**, open the file **L:\WindowsAdminCenter\KCD.ps1**.
1. Review the script, add the following server names to the first line.

   * Docker
   * Node1
   * Node2
   * WS2019

   The first line should look like this:

   ````powershell
   $nodes=("dc1","fs","HV1","HV2","sr1","sr2","S2D","S2D1","S2D2","S2D3","S2D4","SRV1903", "Docker", "Node1", "Node2", "PKI", "SR1", "SR2", "WS2019")
   ````

1. Save the file to the folder Documents\WindowsPowerShell\Scripts. You might have to create that folder.
1. Run the script by pressing F5. The script configures Kerberos Contrained Delegation by granting SRV2 the permission to request tickets for various servers.

   *Note:*

   If you receive an error message in the form ``
   Get-ADComputer : Cannot find an object with identity`` followed by a computer name, the particular computer either does not exist or you have a typo in the definition of ``$nodes``.

#### PowerShell

Perform these steps on DC1.

1. Logon as **smart\Administrator**.
1. Open **Windows PowerShell**.
1. Define the target servers for KCD.

   ````powershell
   <#
   @() indicates an array of string, which we can loop through later
   If you place each element of the array on its own line, you can ommit the
   commas separating its elements normally.
   #>
   $nodes = @(
      'dc1'
      'fs'
      'HV1'
      'HV2'
      'sr1'
      'sr2'
      'S2D'
      'S2D1'
      'S2D2'
      'S2D3'
      'S2D4'
      'SRV1903'
      'Docker'
      'Node1'
      'Node2'
      'PKI'
      'SR1'
      'SR2'
      'WS2019'
   )
   ````

1. Configure KCD for each target computer.

   ````powershell
   $gw = Get-ADComputer -Identity "srv2"

   <#
   ForEach-Object loops through the pipeline, where we put the elements of
   $nodes first. On each iteration, $PSItem contains the next element in the
   array. $PSItem could  be written as $_ also.
   #>
   $nodes | ForEach-Object  {
      $Object = Get-ADComputer -Identity $PSItem
      Set-ADComputer $Object -PrincipalsAllowedToDelegateToAccount $gw 
   }

   ````

   *Note:*

   If you receive an error message in the form ``
   Get-ADComputer : Cannot find an object with identity`` followed by a computer name, the particular computer either does not exist or you have a typo in the definition of ``$nodes``.

1. Leave Windows PowerShell open for the next task.

### Task 2: Add a DNS record

#### Desktop experience

Perform these steps on DC1.

1. Open the DNS Management Console.
1. Create the following record in zone **smart.etc**.

   * Record type: A
   * Record data: admincenter
   * Record IP: 10.1.1.73

#### PowerShell

1. Using Windows PowerShell, create the following record in zone **smart.etc**.

   * Record type: A
   * Record data: admincenter
   * Record IP: 10.1.1.73

   ````powershell
   Add-DnsServerResourceRecordA `
      -ZoneName 'smart.etc' -Name admincenter -IPv4Address 10.1.1.73
   ````
