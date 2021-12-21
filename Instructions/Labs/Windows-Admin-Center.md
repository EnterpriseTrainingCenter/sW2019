# Lab: Windows Admin Center

## Required VMs

* DC1
* DHCP
* Router
* SRV2
* PKI
* CL1

## Exercises

1. [Installing and configuring Windows Admin Center](#exercise-1-installing-and-configuring-windows-admin-center)
1. [Using Windows Admin Center](#exercise-2-using-windows-admin-center)
1. [Securing Windows Admin Center](#exercise-3-securing-windows-admin-center)

## Exercise 1: Installing and configuring Windows Admin Center

### Introduction

In this exercise, you will install Windows Admin Center on Windows Server 2019 Core Edition using a trusted certificate on SRV2. After that you will configure Kerberos Constrained Delegation to be able to use Single Sign On (SSO) for the servers dc1, fs, HV1, HV2, sr1, sr2, S2D, S2D1, S2D2, S2D3, S2D4, SRV1903, Docker, Node1, Node2, PKI, SR1, SR2, and WS2019

#### Tasks

1. [Request a certificate](#task-1-request-a-certificate)
1. [Install Windows Admin Center binaries](#task-2-install-windows-admin-center-binaries)
1. [Configure Kerberos Constrained Delegation and DNS](#task-3-configure-kerberos-constrained-delegation-and-dns)

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

### Task 3: Configure Kerberos Constrained Delegation and DNS

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
1. Open the DNS Management Console.
1. Create the following record in zone **smart.etc**.

   * Record type: A
   * Record data: admincenter
   * Record IP: 10.1.1.73

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

1. Create the following record in zone **smart.etc**.

   * Record type: A
   * Record data: admincenter
   * Record IP: 10.1.1.73

   ````powershell
   Add-DnsServerResourceRecordA `
      -ZoneName 'smart.etc' -Name admincenter -IPv4Address 10.1.1.73
   ````

## Exercise 2: Using Windows Admin Center

### Introduction

In this exercise, you will set the default language of Windows Admin Center to English, install the Active Directory extension, add manually add connections to DC1 and DHCP, import a connections for HV1 and HV2, test some basic administrative functionality, and examine the PowerShell functions, that make up Windows Admin Center.

#### Tasks

1. [Configure Windows Admin Center](#task-1-configure-windows-admin-center)
1. [Connect to Computers](#task-2-connect-to-computers)
1. [Import Windows Admin Center Connections](#task-3-import-windows-admin-center-connections)
1. [Use Windows Admin Center Tools](#task-4-use-windows-admin-center-tools)
1. [Examine PowerShell functions used by Windows Admin Center](#task-5-examine-powershell-functions-used-by-windows-admin-center)

### Task 1: Configure Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Start **Internet Explorer** and browse to <https://admincenter.smart.etc>.
   > Why does Windows Admin Center not start in Internet Explorer?
1. Start **Google Chrome** and browse to <https://admincenter.smart.etc>
1. Add a bookmark for Windows Admin Center for later use.
1. Click on the gear Icon on the upper right corner ([figure 1]) to open Windows Admin Center settings.
1. Change the default language of Windows Admin Center to **English** and the regional format to match your region.
1. Click on **Extensions**
1. Click on **Installed extensions**
1. Install available updates for existing extensions.
1. Install the extension **Active Directory**.
1. Leave Windows Admin Center open for the next task.

### Task 2: Connect to Computers

Perform these steps on CL1.

1. Click on **Windows Admin Center** and **Add**.
1. Add a server connection for **DC1** ([figure 2]).

   > Do you have to enter credentials for DC1? Why or why not?

1. Add another connection for server **DHCP** ([figure 3]).

   > Do you have to enter credentials for DHCP? Why or why not?

1. Leave Windows Admin Center open for the next task.

### Task 3: Import Windows Admin Center Connections

Perform these steps on CL1.

1. Open **Notepad** and create a text file, writing each server name on its own line.

   ````shell
   hv1.smart.etc
   hv2.smart.etc
   ````

1. Save the file with the name **connections.txt** to the **Documents** folder.
1. In **Windows Admin Center**, click **Add**.
1. Under **Servers**, click **Add**.
1. Click the tab **Import a list**.
1. Select the file you created earlier in this task, and click **Add**. You should see two new shared connections for HV1 and HV2.
1. Leave **Windows Admin Center** open for the next task.

### Task 4: Use Windows Admin Center Tools

Perform these steps on CL1.

1. On the **Windows Admin Center** page, click on **DC1** to open the connection to the server.
1. Navigate through the different tools on the left – notice that all the necessary tools you need to administer a machine are in one place. You can even open a remote PowerShell. or RDP session from within Windows Admin Center.
1. Use **Windows Admin Center** to fulfill the following tasks on **DC1**:
   * Restart the DNS Server Service
   * Retrieve Network Adapters and their IP Settings
   * Filter the application event log for errors and warnings
   * Examine Storage
   * Examine Windows Update settings

### Task 5: Examine PowerShell functions used by Windows Admin Center

Perform these steps on CL1.

1. On the **Windows Admin Center** Page click on the PowerShell Icon on the upper right corner ([figure 4]).

2. Examine the functions that Windows Admin Center uses to complete its tasks. You can even copy those scripts to reuse it in your own scripts. ([figure 5])

## Exercise 3: Securing Windows Admin Center

### Introduction

In this exercise you will create the domain-local groups DL_WAC-Admins, and DL_WAC-Users in the domain, and give them the Gateway Users and Gateway Administrators role in Windows Admin Center to configure access permissions. Finally, you will activate and test role-based-access control for SRV2.

#### Tasks

1. [Create groups to secure Windows Admin Center](#task-1-create-groups-to-secure-windows-admin-center)
1. [Configure allowed groups in Windows Admin Center](#task-2-configure-allowed-groups-in-windows-admin-center)
1. [Test Windows Admin Center access permissions](#task-3-test-windows-admin-center-access-permissions)
1. [Activate role-based access control for Windows Admin Center](#task-4-activate-role-based-access-control-for-windows-admin-center)
1. [Test role-based access control for Windows Admin Center](#task-5-test-role-based-access-control-for-windows-admin-center)

### Task 1: Create groups to secure Windows Admin Center

Perform these steps on DC1.

1. Logon as **smart\administrator**.
1. Open the **Active Directory Users and Computers** console.
1. Create two domain-local groups in the **Users** container.

   * DL_WAC-Admins
   * DL_WAC-Users

1. Add **smart\user1** as a member of the **DL_WAC-Admins** group.
1. Add **smart\user2** as a member of the **DL_WAC-Users** group.

### Task 2: Configure allowed groups in Windows Admin Center

Perform these steps on CL1.

1. On CL1 switch to the browser window with **Windows Admin Center**.
1. Click on the gear icon to open admin center settings.
1. On the left, click on the tab **Access**.
1. In the **Allowed groups** sections click on the **Add** button.
1. Add the **smart\DL_WAC-Users** group as **Gateway users** group ([figure 6]).
1. Add the **smart\DL_WAC-Admins** group as **Gateway administrators**
1. Delete the **BUILTIN\Users** group.
1. Logoff from CL1.

### Task 3: Test Windows Admin Center access permissions

Peform these steps on CL1.

1. Logon as **smart\user1**
1. Open **Google Chrome** and connect to <https://admincenter>.

   > Can you connect to Windows Admin Center? Why?

1. Click on the gear icon to open admin center settings.
1. Click on **Extensions**.
1. Install the **DNS (Preview)** extension.

   > Can you install the extension? Why?

1. Go back to the Windows Admin Center homepage
1. Click on SRV2.

   > Can you connect to SRV2? Why or why not?

1. Logoff and logon as **smart\user2**.
1. Open Google Chrome and connect to <https://admincenter>.

   > Can you connect to Windows Admin Center? Why?

1. Click on the gear icon to open admin center settings

   > Can you install extensions as user2? Why or why not?

   > Can you manage access as user2? Why or why not?

1. Logoff.

### Task 4: Activate role-based access control for Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\administrator**.
1. Open Google Chrome and connect to <https://admincenter>.
1. Click on **SRV2.smart.etc** to connect.
1. On the left, on the bottom of the tree, click on **Settings**.
1. Click on the tab **Role-based Access Control**.
1. Click on **Apply** and then **Yes** to activate RBAC for SRV2. Notice the task information in the notification are on the upper right corner. Wait for a **Successfully scheduled the application of RBAC** notification.
1. Refresh the browser window.
1. The status of Role-based Access Control should now show **Applied** ([figure 7]).
1. On the left, click on **Local Users & Groups**.
1. Click on **Groups**.
1. Scroll to the bottom of the list - RBAC should have created three additional groups ([figure 8]).
1. Click on the **Windows Admin Center Administrators** group and add **smart\user1** as a member.
1. Click on the **Windows Admin Center Readers** group and add **smart\user2** as a member.
1. Logoff.

### Task 5: Test role-based access control for Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\user1**.
1. Open **Google Chrome** and connect to <https://admincenter>
1. Click on **SRV2**.

   > Is the connection successful? Why?

   > What features can you administer as user1? Which are not available?

1. Logoff.
1. Logon **smart\user2**.
1. Open **Google Chrome** and connect to <https://admincenter>
1. Click on **SRV2**.

   > Is the connection successful? Why?

   > What features can you administer as user2? Which are not available?

   > Is there any indication of limited access (hint: [figure 9])?

1. Logoff from CL1

[figure 1]: images/Lab04/figure01.png
[figure 2]: images/Lab04/figure02.png
[figure 3]: images/Lab04/figure03.png
[figure 4]: images/Lab04/figure04.png
[figure 5]: images/Lab04/figure05.png
[figure 6]: images/Lab04/figure06.png
[figure 7]: images/Lab04/figure07.png
[figure 8]: images/Lab04/figure08.png
[figure 9]: images/Lab04/figure09.png
