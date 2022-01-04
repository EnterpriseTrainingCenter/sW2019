# Lab: High availability Remote Desktop Session Host farm with Azure DB

## Required VMs

* DC1
* RDCB1
* RDCB2
* RDGW
* RDSH1
* RDSH2
* PKI
* DHCP
* Router
* CL1

## Exercises

1. [Install prerequisites & provision Azure SQL](#exercise-1-install-prerequisites-and-provision-azure-sql)
1. [Configure Remote Desktop roles and implement High Availability](#exercise-2-configure-remote-desktop-roles-and-implement-high-availability)
1. [Personal Session Desktops](#exercise-3-personal-session-desktops)

## Exercise 1: Install prerequisites and provision Azure SQL

### Introduction

In this exercise you  will first create a security group for the connection brokers and make RDCB1 and RDCB2 members. In DNS, you will create A records with the same name pointing to the IP addresses of RDCB1 and RDCB2. You will create a file share for the user profile disks. Finally, in Azure, you will create a basic Azure SQL database.

#### Tasks

1. [Install PowerShell modules for Azure (Optional)](#task-1-install-powershell-modules-for-Azure-optional)
1. [Prepare the environment for RDS](#task-2-prepare-the-environment-for-rds)
1. [Create a resource group (Optional)](#task-3-create-a-resource-group-optional)
1. [Prepare the Azure SQL Database](#task-4-prepare-the-azure-sql-database)

### Task 1: Install PowerShell modules for Azure (Optional)

*Note:* This task is only required, if you plan to use PowerShell to administer Azure.

Perform these steps on the host computer.

1. Open **Windows PowerShell**.
1. Install the latest version of the Azure PowerShell package in the scope of the current user.

    ````powershell
    Install-Package -Name Az -Scope CurrentUser
    ````

    Confirm all prompts.

    This will take a few minutes. Do not wait for the installation to complete. Continue with the next task.

### Task 2: Prepare the environment for RDS

#### Desktop Experience

Perform these steps on DC1.

1. Logon as **smart\Administrator**.
1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, in the context menu of **smart (local)**, click **New**, **Group**.
1. In the **Create Group** dialog, in **Group name**, enter **RDS Connection Brokers**.
1. Click **Members**.
1. Under **Members**, click **Add...**.
1. In **Select users, Contacts, Computers, Service Accounts, or Groups**, click **Object Types...**.
1. In Object Types, activate **Computers** and click **OK**.
1. Back in Select users, Contacts, Computers, Service Accounts, or Groups, add **RDCB1** and **RDCB2** and click **OK**.
1. Open **DNS**.
1. In **DNS Manager**, navigate to **Forward Lookup Zones**, **smart.etc**
1. In the context-menu of the forward lookup zone **smart.etc**, click **New Host (A or AAAA)...**.
1. In dialog **New Host**, in **Name**, enter **rdbroker**. In **IP address**, enter **10.1.1.51**. Clear the checkbox **Create associated pointer (PTR) record**. Click on **Add Host**.
1. In the message box **The host record rdbroker.smart.etc was successfully created.**, click **OK**.
1. Repeat the previous two steps with the IP address **10.1.1.52**.
1. Back in New Host, click **Done**.
1. Open **Server Manager**.
1. In Server Manager, on the left-hand side, click **File and Storage Services**.
1. In File and Storage Services, click **Shared**.
1. Under Shares, click **Tasks**, **New Share...**
1. In **New Share Wizard**, on page **Select the profile for this share**, click **SMB Share - Quick** and click **Next >**.
1. On page **Select the server and path for this share**, ensure **dc1** is selected, click **Type a custom path**, and click **Browse...**
1. In **Select Folder**, click **(C:)**, then click **New Folder**. Enter **UserProfileDisks** and press ENTER. With **UserProfileDisks** selected, click **Select Folder**.
1. Back on page Select the server and path for this share, click **Next >**.
1. Proceed trought the wizard accepting the defaults to create the share.

#### Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Google Chrome** and navigate to **https://admincenter.smart.etc**.
1. On the page Windows Admin Center, if the server **DC1** is not listed, click **Add**. Under **Servers**, click **Add**. In **Server name**, enter **DC1** and click **Add**.
1. On the page Windows Admin Center, connect to **DC1.smart.etc**.
1. Connected to DC1.smart.etc, under **Tools**, click **Active Directory**.

    If you do not see Active Directory, install the extension from Windows Admin Center Settings.

1. In **Active Directory Domain Services**, click **Create**, **Group**.
1. In the pane **Add Group**, in **Name**, enter **RDS Connection Brokers**. Under **Group Scope**, select **Global**, and click **Create**.
1. With the group **RDS Connection Brokers** selected, click **Properties**.
1. On **Active Directory Domain Services > Group properties: RDS Connection Brokers**, click **Membership**.
1. Click **Add**.
1. In the pane **Add Group Membershíp**, in **User SamAccountname**, enter **RDCB1$** and click **Add**.
1. Repeat the previous step to add **RDCB2$**.
1. Click **Save**.
1. Click **Close**.
1. On the left, click **DNS**.
1. In **DNS**, select the zone **smart.etc**.
1. At the bottom, click **+ Create a new DNS record**.
   * **DNS record type**: Host (A)
   * **Record name (uses FQDN if blank)**: rdbroker.smart.etc
   * **IP address**: 10.1.1.51
1. Repeat the previous step with the IP address **10.1.1.52**.
1. On the left, under **Tools**, click **Files & file sharing**.
1. In **Files**, click the tab, **File shares**.
1. In File shares, click **New share**.
1. In pane **New file share**, next to **Folder location**, click **Browse**.
1. In **Select a folder to share**, click ()
1. Under **Files**, double-click **(C:)**.
1. In **C:**, click **New Folder**.
1. In pane **Create New folder**, in **New folder name**, enter **UserProfileDisks** and click **Submit**.
1. Back in Select a folder to share, click **UserProfileDisks**, so that a checkmark appears on the left, and click **OK**.
1. Back in pane New file share, click **Create**.

#### PowerShell

Perform these steps on DC1.

1. Logon as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Create a global group **RDS Connection Brokers** and add **RDCB1$** and **RDCB2$**.

    ````powershell
    $name = 'RDS Connection Brokers'
    New-ADGroup -Name $name -GroupCategory Security -GroupScope Global
    Add-ADGroupMember -Identity $name -Members RDCB1$, RDCB2$
    ````

1. In DNS, in zone **smart.etc**, create two A records with the name **rdbroker** pointing to the IP addresses **10.1.1.51** and **10.1.1.52**.

   ````powershell
   $name = 'rdbroker'
   $zoneName = 'smart.etc'
   Add-DnsServerResourceRecordA `
      -Name $name -IPv4Address 10.1.1.51 -ZoneName $zoneName
   Add-DnsServerResourceRecordA `
      -Name $name -IPv4Address 10.1.1.52 -ZoneName $zoneName
   ````

1. Create a folder **C:\UserProfileDisks**.

    ````powershell
    $path = 'C:\UserProfileDisks'
    New-Item -Path C:\UserProfileDisks -ItemType Directory
    ````

1. Share the directory with the name **UserProfileDisks** giving **Everyone** full access.

    ````powershell
    New-SmbShare -Path $path -Name UserProfileDisks -FullAccess Everyone
    ````

### Task 3: Create a resource group (Optional)

*Note:* Perform this task only, if you are using your own Azure account. With a shared Azure account, you will not have the permissions to perform this task.

#### Desktop experience

Perform these steps on the host computer.

1. Open a web browser and navigate to **https://portal.azure.com**.
1. Logon with your Azure credentials.
1. At the top-left, click the hamburger menu ([figure 1]) and click **Create a resource**.
1. In **Search services and marketplace**, type **resource group**. When **Resource Group** appears below the input field, click on it.
1. On page **Resource Group**, click **Create**.
1. On tab **Basics**, in **Subscription**, select the subscription, you want to use for this lab. In **Resource group**, enter **HARDSH-** followed by your user name, e. g. *HARDSH-Susi*. In **Region** select a region close to you, e. g. **North Europe**. Click **Review + create**.

    Your instructor will advise you selecting an appropriate region.

1. On tab **Review + create**, if validation passed, click **Create**.

#### PowerShell

Perform these steps on the host computer.

*Note:* To perform this task, the installation of task 1 must be completed.

1. In **Windows PowerShell**, connect to you Azure account.

    ````powershell
    Connect-AzAccount
    ````

1. Logon with your Azure credentials.
1. List your Azure subscriptions.

    ````powershell
    Get-AzSubscription
    ````

    *Note:* If only one subscription gets listed, you can skip the next two steps.

1. Copy the **Id** of the Azure subscription, you want to use for this lab, to the clipboard.
1. Select the Azure subscription.

    ````powershell
    <# 
        Replace the SubscriptionId parameter value with the Id you copied to the
        clipboard.
    #>
    Select-AzSubscription -SubscriptionId 00000000-0000-0000-0000-000000000000
    ````

1. Create a resource group with the name **HARDSH-** followed by your user name.

    ````powershell
    $resourceGroupName = 'HARDSH-' # append your user name
    $resourceGroup = New-AzResourceGroup `
        -Name $resourceGroupName `
        -Location northeurope # You can replace the location, if you want.
    ````

### Task 4: Prepare the Azure SQL Database

#### Desktop experience

Perform these steps on the host computer.

1. Open a web browser and navigate to **https://portal.azure.com**.
1. Logon with your Azure credentials.

    If you are asked to provide more information about your account, you can skip the steps for 14 days.

1. At the top-left, click the hamburger menu ([figure 1]) and click **Create a resource**.
1. On page Create a resource, on the left, click **Databases**.
1. Under **SQL Database**, click **Create**.
1. In **Resource group**, select **HARDSH-** (followed by your user name) ([figure 2]).
1. In **Database name**, enter **RDDB_** followed by your last name ([figure 2]).
1. Below **Server**, click the link **Create new** ([figure 2]).
1. On page **Create SQL Database Server**, in **Server name**, enter a worldwide unique name, e.g. yourlastname-sql ([figure 3]).
1. In **Location**, choose a location next to you, e.g. **(Europe) North Europe** ([figure 3]).

    Your instructor will help you choosing an appropriate location.

1. For **Authentication method**, select **Use SQL authentication** (([figure 3])).
1. In **Server admin login** enter **sqladmin** (([figure 3])).

    You can choose any valid SQL Server user name.

1. In **Password** and **Confirm password**, enter a secure password ([figure 3]).

    *Important:* Take a note of the password. You will need it later.

1. Click **OK**.

1. Back on page Create SQL Database, for **Want to use SQL elastic pool**, select **No**.
1. Beside **Compute + storage**, click the link **Configure database**.
1. On page **Configure**, for **Service tier**, select **Basic (For less demanding workloads)** ([figure 4]) and click **Apply**.

    Notice the monthly cost estimation of the database.

1. For **Backup storage redundancy**, select **Locally-redundant backup storage** ([figure 2]).
1. Click **Next: Networking >** ([figure 2]).
1. Unter **Network connectivity**, click **Public endpoint** ([figure 5]).
1. Click **Review + create**.
1. Review the settings and click **Create**.

    By submitting the form, you created a deployment. You will be redirected to the Deployment page stating **Deployment is in progress**. Wait for the deployment to finish. This will take a minute or two. Meanwhile, on the left, you can click on **Template** and **Inputs** to learn about the architecture of an Azure deployment. Be sure to return to **Overview** from time to time.

1. When the message **Your deployment is complete** or **Deployment succeeded** appears, on **Overview**, click on **Go to resource**.
1. On the resource pane of your database, on the left, ensure **Overview** is selected. At the top, click **Set server firewall** ([figure 6]).
1. On page **Firewall settings**, at the top, click **Add client IP** and click **Save** ([figure 7]).

    *Note:* In a real-world scenario, you would add the public IP address of your Remote Desktop Connection Broker here.

1. In **Success!**, click **OK**.
1. At the top right, click the close icon.
1. Back on the Overview page of your database, click **Show database connection strings** ([figure 6]).
1. In **Connection strings**, click **ODBC**.
1. In the text area of the connection string, click the **Copy to clipboard** icon ([figure 8]).
1. Paste the connection string into a text editor such as Notepad.
1. In the text editor, replace the text **{your_password_here}** with the secure password you noted earlier in this task.

#### PowerShell

Perform these steps on the host computer.

1. Open **Windows PowerShell**.
1. Connect to your Azure account.

    ````powershell
    Connect-AzAccount
    ````

1. Logon with your Azure credentials.

    If you are asked to provide more information about your account, you can skip the steps for 14 days.

1. List your Azure subscriptions.

    ````powershell
    Get-AzSubscription
    ````

    *Note:* If only one subscription gets listed, you can skip the next two steps.

1. Copy the **Id** of the Azure subscription, you want to use for this lab, to the clipboard.
1. Select the Azure subscription.

    ````powershell
    <# 
        Replace the SubscriptionId parameter value with the Id you copied to the
        clipboard.
    #>
    Select-AzSubscription -SubscriptionId 00000000-0000-0000-0000-000000000000
    ````

1. Create credentials for an SQL admin user.

    ````powershell
    $sqlAdministratorCredentials = Get-Credential `
        -Message 'Enter the credentials for the SQL server admin user' `
        -UserName sqladmin # you can choose a different username, if you like
    ````

    When prompted, enter a password of your choice.

    *Important:* Take a note of the password. You will need it later.

1. Create a virtual SQL server.

    ````powershell
    $resourceGroup = Get-AzResourceGroup -Name 'HARDSH-Susi'
    $resourceGroupName = $resourceGroup.ResourceGroupName
    $location = $resourceGroup.Location

    # choose a worldwide unique server name, e.g. yourlastname-sql
    $serverName = '-sql'

    $azSqlServer = New-AzSqlServer `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -ServerName $serverName `
        -SqlAdministratorCredentials $sqlAdministratorCredentials 
    ````

    This will take a minute or two.

1. Create an Azure SQL database with the Edition **Basic** and a **Local** backup storage redundancy.

    ````powershell
    $databaseName = 'RDDB_' # append your last name, e.g. RDDB_Sorglos

    New-AzSqlDatabase `
        -ResourceGroupName $resourceGroupName `
        -DatabaseName $databaseName `
        -ServerName $serverName `
        -Edition Basic `
        -BackupStorageRedundancy Local
    ````

1. Add an allowed IP address to the server firewall.

    ````powershell
    # Contact a web API to retrieve the client's current IP address
    $clientIp = Invoke-WebRequest 'https://api.ipify.org' |
    Select-Object -ExpandProperty Content

    <#
        In a real-world scenario, you would set the startIpAddress and
        endIpAddress manually to the public IP address range of your connection
        brokers. In the lab we simply use the client's IP address.
    #>
    $startIpAddress = $clientIp
    $endIpAddress = $startIpAddress
    New-AzSqlServerFirewallRule `
        -ResourceGroupName $resourceGroupName `
        -ServerName $serverName `
        -FirewallRuleName 'Connection Broker' `
        -StartIpAddress $startIpAddress `
        -EndIpAddress $endIpAddress
    ````

1. Generate the connection string.

    ````powershell
    $server = $azSqlServer.FullyQualifiedDomainName
    $userId = $sqlAdministratorCredentials.UserName
    $connectionString = "Server=tcp:$server,1433;Initial Catalog=$databaseName;Persist Security Info=False;User ID=$userId;Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    $connectionString

1. Copy the connection string to the clipboard.
1. Paste the connection string into a text editor such as Notepad.
1. In the text editor, replace the text **{your_password_here}** with the secure password you noted earlier in this task.

## Exercise 2: Configure Remote Desktop roles and implement High Availability

### Introduction

In this exercise, first, you will create a Remote Desktop deployment using RDCB1 as connection broker, RDSH1 and RDSH2 as session hosts, DC1 as license server and RDGW as gateway and web access server. Then, you will reqest a wildcard certificate and assign it to the various RDS components. You will install the SQL Server 2016 ODBC driver on RDCB1 and RDCB2 and configure your deployment for Connection Broker high availability. You will create a full desktop session collection and test it. Finally, you will remove the session collection.

#### Tasks

1. [Install and Configure RDS](#task-1-install-and-configure-rds)
1. [Request a certificate](#task-2-request-a-certificate)
1. [Assign a certificate](#task-3-assign-a-certificate)
1. [Install SQL Server 2016 ODBC Drivers](#task-4-install-sql-server-2016-odbc-drivers)
1. [Configure Connection Broker high availability](#task-5-configure-connection-broker-high-availability)
1. [Verify the RD Gateway for Connection Broker high availability](#task-6-verify-the-rd-gateway-for-connection-broker-high-availability)
1. [Create a Session Collection](#task-7-create-a-session-collection)
1. [Test the Session Collection](#task-8-test-the-session-collection)
1. [Remove the Session Collection](#task-9-remove-the-session-collection)

### Task 1: Install and Configure RDS

#### Desktop experience

Perform these tasks on RDCB1.

1. Sign in as **smart\Administrator**.
1. Open **Server Manager**.
1. In Server Manager, click on **Manage**, **Add Servers**.
1. In Add Servers, in **Active Directory** search for RD and add RDGW, RDSH1, RDSH2, RDCB2.
1. Search for **DC1** and add it. Click **OK**.
1. Back in Server Manager, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, on page **Before you begin**, click **Next >**.
1. On page **Select installlation type**, select **Remote Desktop Services installation** and click **Next >**.
1. On page **Select deployment type**, select **Standard deployment** and click **Next >**.
1. On page **Select deployment scenario**, select **Session-based desktop deployment** and click **Next >**.
1. On page **Review role services**, click **Next >**.
1. On page **Specify RD Connection Broker server**, select **RDCB1** and click **Next >**.
1. On page **Specify RD Web Access server**, select **RDGW** and click **Next >**.
1. On page **Specify RD Session Host servers**, select **RDSH1** and **RDSH2** and click **Next >**.
1. On page **Confirm selections** verify your settings ([figure 9]), activate **Restart the destination server automatically if required**, and click **Deploy**.

    Wait for the deployment to complete. This will take a few minutes.

1. Click **Close**.
1. Back in Server Manager, click on **Remote Desktop Services**.
1. Click on **RD Licensing**.
1. In **Add RD Licensing Server**, select **DC1** and click **Next >**.
1. On page **Confirm selections** click **Add**.

    Wait for the deployment to complete. This will less than a minute.

1. Click **Close**.
1. Back in Server Manager, on Remote Desktop Services, Overview, click on **RD Gateway**.
1. In **Add RD Gateway Server**, select **RDGW** and click **Next >**.
1. On page **Name the self-signed SSL certificate**, type **rdgw.smart.etc** and click **Next >**.

    In a real-world scenario, you should use a name that is resolvable on the Internet.

1. On page **Confirm selections** click **Add**.

    Wait for the deployment to complete. This will less than a minute.

1. Click **Close**.

#### PowerShell

Perform these tasks on RDCB1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Create a new RD Session Deployment with **rdcb1.smart.etc** as **Connection Broker**, **rdsh1.smart.etc** as **Session Host** and **rdgw.smart.etc** as **Web Access Server**.

    ````powershell
    New-RDSessionDeployment `
        -ConnectionBroker rdcb1.smart.etc `
        -SessionHost rdsh1.smart.etc `
        -WebAccessServer rdgw.smart.etc
    ````

    This will take a few minutes.

1. Add **rdsh2.smart.etc** as Session Host to the deployment.

    ````powershell
    Add-RDServer -Server rdsh2.smart.etc -Role RDS-RD-SERVER
    ````

1. Add **dc1.smart.etc** as RD Licensing server to the deployment and set the configuration to per users.

    ````powershell
    Add-RDServer -Server dc1.smart.etc -Role RDS-LICENSING
    ````

1. Add **rdgw.smart.etc** as RD Gateway server to the deployment with rdgw.smart.etc as external FQDN.

    ````powershell
    Add-RDServer `
        -Server rdgw.smart.etc `
        -Role RDS-GATEWAY `
        -GatewayExternalFqdn rdgw.smart.etc
    ````

    In a real-world scenario, you should use a name that is resolvable on the Internet.

### Task 2: Request a certificate

#### Desktop experience

Perform these steps on RDCB1.

1. Run **certlm.msc** to open the certificate console for the local machine.
1. In certlm, navigate to **Personal**.
1. In certlm, in the context-menu of  **Personal**, click **All Tasks**, **Request New Certificate...**.
1. In the wizard **Certificate Enrollment**, on page **Before You Begin**, click **Next**.
1. On page **Select Certificate Enrollment Policy**, click **Next**.
1. On page **Request Certificates**, activate the check box **WebServer10Years**. Click the link **More information is required to enroll for this certificate. Click here to configure settings.**
1. In **Certificate Properties**, on tab **Subject**, under **Subject Name**, in the dropdown **Type**, select **Common Name**. In **Value**, enter **\*.smart.etc** and click **Add >**.
1. Under **Alternative name**, in the dropdown **Type**, select **DNS**. In **Value**, enter **\*.smart.etc** and click **Add >**.
1. Click **OK**.
1. Back on page Request Certificates, click **Enroll**.
1. On page **Certificate Installation Results**, click **Finish**.
1. Back in certlm, navigate to **Personal**, **Certificates**.
1. In the context menu of the certificate **Issued To** **\*.smart.etc**, click **All Tasks**, **Export...**
1. In **Certificate Export Wizard**, on page **Welcome to the Certificate Export Wizard**, click **Next**.
1. On page **Export Private Key**, select **Yes, export the private key** and click **Next**.
1. On page **Export File Format**, click **Next**.
1. On page **Security**, activate **Password** and enter a secure password. Repeat the password in **Confirm password** and click **Next**.

    *Important:* Take note of the password. You will need it in a moment.

1. On page **File to Export**, save the certificate to **c:\temp\smart.etc** and click **Next**.
1. On page **Completing the Certificate Export Wizard**, click **Finish**.
1. On the message **The export was successful.**, click **OK**.

#### PowerShell

Perform these steps on RDCB1.

1. Run **Windows PowerShell** as Administrator.
1. Request a certificate for FQDN **\*.smart.etc** using the template **WebServer10Years**.

   ````powershell
   $dnsName = '*.smart.etc'
   $subjectName = "CN=$($dnsName)"
   $template = 'WebServer10Years'
   $result = Get-Certificate `
       -Template $template `
       -SubjectName $subjectName `
       -DnsName $dnsName `
       -CertStoreLocation Cert:\LocalMachine\My   
   ````

1. Create a secure password for the exported certificate.

    ````powershell
    $password = Read-Host -AsSecureString -Prompt 'Password for pfx'
    ````

    At the prompt, enter a secure password.

    *Important:* Take note of the password. You will need it in a moment.

1. Export the certificate including the private key.

    ````powershell
    $path = 'c:\temp'
    New-Item -Path $path -ItemType Directory

    $filePath = Join-Path -Path $path -ChildPath 'smart.etc.pfx'
    $result.Certificate | 
    Export-PfxCertificate -FilePath $filePath -Password $password
    ````

### Task 3: Assign a certificate

#### Desktop experience

1. Switch to **Server Manager**.
1. In Server Manager, in Remote Desktop Services, Overview, under **Deployment Overview**, click **Tasks**, **Edit Deployment Properties**.
1. In Deployment Properties, on the left-hand side, click **Certificates**.
1. Select the **Role Service** **RD Connection Broker -Enable Single Sign On** and click **Select existing certificate...**.
1. In Select Existng Certificate, click **Browse..**.
1. Open **c:\temp\smart.etc.pfx**.
1. In **Password** enter the password you took note of during certificate export. Activate **Allow the certificate to be added to the Trusted Root Certification Authorities certificate store on the destination computers** and click **OK**.

1. Back in Deployment Properties, on page Certificates, click **Apply**.

    Column **Level** should now display **Trusted** and **Status** should display **OK**.

1. Repeat steps 24 - 28 for the remaining role services.

    *Important:* Do not click **OK** until you applied the certificate to all role services.

1. On the left-hand side, click **RD Gateway**.

1. On page RD Gateway, deactivate the checkbox **Bypass RD Gateway server for local addresses** and click **OK**.

#### PowerShell

1. Run **Windows PowerShell** as Administrator.
1. Import the certificate for the RD Connection Broker.

    ````powershell
    # $filepath = 'C:\Temp\smart.etc.pfx'
    # $password = Read-Host -AsSecureString -Prompt 'Password for pfx'
    Set-RDCertificate `
        -Role RDRedirector `
        -ImportPath $filePath `
        -Password $password `
        -Force
    ````

1. Import the certificate for the remaining roles.

    ````powershell
    Set-RDCertificate `
        -Role RDPublishing `
        -ImportPath $filePath `
        -Password $password `
        -Force
    Set-RDCertificate `
        -Role RDWebAccess `
        -ImportPath $filePath `
        -Password $password `
        -Force
    Set-RDCertificate `
        -Role RDGateway `
        -ImportPath $filePath `
        -Password $password `
        -Force

1. List the RD certificate with their level:

    ````powershell
    Get-RDCertificate
    ````

    This should return certificates for four roles. For all certificates, the **Level** should be **Trusted** and **IssuedTo** should be **CN=*.smart.etc**.

### Task 4: Install SQL Server 2016 ODBC Drivers

#### Desktop experience

Perform these steps on RDCB1 and RDCB2.

1. Sign in as **smart\Administrator**.
1. Restart the server to refresh its group membership.
1. Sign in as **smart\Administrator**.
1. Open **File Explorer**.
1. Navigate to **L:\Remote Desktop**.
1. Run **msodbcsql.msi** to install SQL Server 2016 ODBC Drivers.
1. Complete the setup accepting all defaults.

#### PowerShell

Perform these steps on RDCB1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Restart the RDCB1 and RDCB2 to refresh its group membership.

    ````powershell
    Invoke-Command -ComputerName RDCB2 -ScriptBlock { Restart-Computer }
    Restart-Computer
    ````

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Run **msodbcsql.msi** unattended to install SQL Server 2016 ODBC Drivers.

    ````powershell
    $msiName = 'msodbcsql.msi'
    $msiPath = "\\dc1\Labfiles\Remote Desktop\$msiName"
    msiexec.exe /i $msiPath /qn IACCEPTMSODBCSQLLICENSETERMS=YES
    <# 
        We cannot access a remote file in PowerShell remoting (double-hop 
        problem). Therefore, we must copy the setup file to the local file
        system first.
    #>
    $computerName = 'RDCB2' # remote computer name
    $remotePath = 'C:\Temp' # local path for msi on remote computer

    # Build the network path from the remotePath
    $destination = Join-Path `
        -Path "\\$computerName" `
        -ChildPath ($remotePath -replace ':', '$')

    # Create the destination directory
    New-Item -Path $destination -ItemType Directory

    # Copy the msi
    Copy-Item -Path $msiPath -Destination $destination -PassThru

    # Build the full path to msi
    $remoteMsiPath = Join-Path -Path $remotePath -ChildPath $msiName

    # Run setup
    Invoke-Command `
        -ComputerName $computerName `
        -ScriptBlock {
            # Use $using: to access variable defined in the host session
            msiexec.exe /i $using:remoteMsiPath /qn IACCEPTMSODBCSQLLICENSETERMS=YES 
        }

1. Verify the installation has succeeded.

    ````powershell
    Get-Package
    Invoke-Command -ComputerName $computerName -ScriptBlock { Get-Package }
    ````

    Both commands should - among other a package **Microsoft ODBC Driver 13 for...**.

### Task 5: Configure Connection Broker high availability

#### Desktop experience

Perform these steps on RDCB1.

1. Open **Server Manager**.
1. In Server Manager, click **Remote Desktop Services**.

    You might have to click twice.

1. Unter **Deployment Overview**, in the context-menu of **RD Connection Brokwer**, click **Configure High Availability**
1. In **Configure RD Connection Broker for High Availability**, on page **Before you begin**, click **Next >**.
1. On page **Configuration type**, select **Shared database server** and click **Next >**.
1. On page **Configure RD Connection Broker for High Availability**, in **DNS name for the RD Connection Broker cluster**, enter **rdbroker.smart.etc**. In **Connection string**, paste the connection string from the previous exercise and click **Next >**.
1. On page **Confirmation**, click **Configure**.

    The configuration should take less than a minute.

1. Click **Close**.
1. Back in Server Manager, in Remote Desktop Services, Overview, in the context-menu of **RD Connection Broker**, click **Add RD Connection Broker Server**.
1. In Add RD Connection Broker Server, on page **Before you begin**, click **Next >**.
1. On page **Select a server**, select **RDCB2** and click **Next >**.
1. On page **Confirmation**, click **Add**.

    The configuration should take a minute or two.

1. Click **Close**.
1. Back in Server Manager, in Remote Desktop Services, Overview, under **Deployment Overview**, click **Tasks**, **Edit Deployment Properties**.
1. In Deployment Properties, on the left-hand side, click **Certificates**.

    The **Status** for the two RD Connection Broker certificates shows **Error**, because the certificate was not installed on RDCB2 yet.

1. Select the **Role Service** **RD Connection Brokwer - Enable Single Sign On** and click **Select existing certificate...**.
1. Ensure, **Apply the certificate that is stored on the RD Connection Broker server** is selected, enter the **Password** for the certificate, **Allow the certificate to be added to the Trusted Root Certification Authorities certificate store on the destination computers**, and click **OK**.
1. Back in Deployment Properties, on page Certificates, click **Apply**.
1. Repeat steps 16 - 18 for the remaining role services.
1. Click **OK**.

#### PowerShell

Perform these steps on RDCB1.

1. Run **Windows PowerShell** as Administrator.
1. Set the connection string for the Azure SQL database.

    ````powershell
    <#
        Paste the connection string from the previous exercise between the quotation marks
    #>
    $databaseConnectionString = ''
    ````

1. Configure high availability for the connection broker with the client access name **rdbroker.smart.etc**.

    ````powershell
    $clientAccessName = 'rdbroker.smart.etc'
    Set-RDConnectionBrokerHighAvailability `
        -DatabaseConnectionString $databaseConnectionString `
        -ClientAccessName $clientAccessName
    ````

    The configuration should take less than a minute.

1. Add RDCB2 as connection broker.

    ````powershell
    Add-RDServer -Server rdcb2.smart.etc -Role RDS-CONNECTION-BROKER
    ````

    The configuration should take a minute or two.

1. Configure the certificates for the **RDRedirector** and the **RDPublishing** role.

    ````powershell
    $password = Read-Host -AsSecureString -Prompt 'Password for pfx'
    Set-RDCertificate -Role RDRedirector -Password $password -Force
    Set-RDCertificate -Role RDPublishing -Password $password -Force
    ````

1. List the RD certificate with their level:

    ````powershell
    Get-RDCertificate
    ````

    This should return certificates for four roles. For all certificates, the **Level** should be **Trusted** and **IssuedTo** should be **CN=*.smart.etc**.

### Task 6: Verify the RD Gateway for Connection Broker high availability

Perform these steps on RDGW.

1. On RDGW logon as **smart\administrator**.
1. Open **Remote Desktop Gateway Manager**.
1. In RD Gateway Manager, navigate to **RD Gateway Manager**, **RDGW (Local)**, **Policies**, **Resource Authorization Policies**.
1. Open **RDG_HighAvailabilityBroker_DNS_RR**.
1. In RDG_HighAvailabilityBroker_DNS_RR Properties, click the tab **Network Resources**.
1. On tab Network resources, ensure, that in **RD Gateway-managed group members** the entry **RDBROKER.SMART.ETC** appears ([figure 10]).
1. In the context-menu of **Resource Authorization Policies**, click **Manage Local Computer Groups**.
1. In Manage locally stored computer groups, select **RDG_DNSRoundRobin** and click **Properties**.
1. In RDG_DNSRoundRobin Properties, click the tab **Network resources**.
1. On tab Network resources, ensure that **RDBROKER.SMART.ETC** is listed under **Network resources**.
1. Close all open dialogs without making any changes.

### Task 7: Create a Session Collection

#### Desktop experience

Perform thes steps on RDCB1.

1. In Server Manager, navigate to **Server Manager**, **Remote Desktop Services**, **Collections**.
1. Under **COLLECTIONS**, click **Tasks**, **Create Session Collection**.
1. In Create Collection, on page **Before you begin**, click **Next >**.
1. On page **Name the collection**, in **Name**, type **Full Desktop**.
1. On page **Specify RD Session Host servers**, select **RDSH1** and **RDSH2**, and click **Next >**.
1. On page **Specify user groups**, click **Next >**.
1. On page **Specify user profile disks**, activate **Enable user profile disks**. In **Location of user profile disks**, enter **\\\DC1\UserProfileDisks**. In **Maximum size (in GB)**, enter **2** and click **Next >**.
1. On page **Confirmation** click **Create**.

    The configuration should take less than a minute.

1. Click **Close**.

#### PowerShell

Perform thes steps on RDCB1.

1. Run **Windows PowerShell** as Administrator.
1. Create a session collection with the name **Full Desktop** and the session hosts **rdsh1** and **rdsh2**.

    ````powershell
    $collectionName = 'Full Desktop'
    New-RDSessionCollection `
        -CollectionName $collectionName `
        -SessionHost rdsh1.smart.etc, rdsh2.smart.etc
    ````

1. Configure user group **SMARt\Domain Users** for the session collection.

    ````powershell
    Set-RDSessionCollectionConfiguration `
        -CollectionName $collectionName `
        -UserGroup 'SMART\Domain Users'
    ````

1. Configure user profile disks for the session collection with the disk path of **\\\DC1\UserProfileDisks** and a maximum size of **2 GB**.

    ````powershell
    Set-RDSessionCollectionConfiguration `
        -CollectionName $collectionName `
        -EnableUserProfileDisk `
        -MaxUserProfileDiskSizeGB 2 `
        -DiskPath '\\DC1\UserProfileDisks'
    ````

    The command might return an **Exception calling ".ctor" with "1" argument(s): "Invalid parameter "**, but it should work anyway. You can check the configuration.

    ````powershell
    Get-RDSessionCollectionConfiguration `
        -CollectionName $collectionName `
        -UserProfileDisk
    ````

### Task 8: Test the Session Collection

Perform these steps on CL1.

1. Sign in as **smart\User1**.
1. Open **Internet Explorer**.
1. Browse to **https://rdgw.smart.etc/RDWeb**.
1. Sign in as **smart\User1**.
1. On page **Work Resources**, click on **Full Desktop**.
1. Click **Connect**.

    You will be connected through the RD Gateway and the broker to either RDSH1 or RDSH2.

1. From the Remote Desktop session, sign out.
1. Back on page **Work Resources**, click **Sign out**.

### Task 9: Remove the Session Collection

#### Desktop experience

Perform these steps on RDCB1.

1. In **Server Manager**, under **COLLECTIONS**, in the context-menu of **Full Desktop**, click **Remove Collection**
1. In **Remove Collection**, click **Yes**.

#### PowerShell

Perform these steps on RDCB1.

1. Run **Windows PowerShell** as Administrator.
1. Remove all existing session collections.

    ````powershell
    Get-RDSessionCollection | Remove-RDSessionCollection
    ````

## Exercise 3: Personal Session Desktops

### Introduction

In this exercise you will create personal desktop session collection and test it.

#### Tasks

1. [Create a Personal Desktop Session Collection](#task-1-create-a-personal-desktop-session-collection)
1. [Test a Personal the Desktop Session Collection](#task-2-test-a-personal-desktop-session-collection)


### Task 1: Create a Personal Desktop Session Collection

Perform these steps on RDCB1.

1. Run **Windows PowerShell** as Administrator.
1. Create a new personal unmanaged session collection with the name **Personal Session Collection** and **rdsh1.smart.etc** and **rdsh2.smart.etc** as session hosts granting users administrative privileges.

    ````powershell
    $collectionName = 'Personal Session Desktops'
    New-RDSessionCollection `
        -CollectionName $collectionName `
        -SessionHost rdsh1.smart.etc, rdsh2.smart.etc `
        -PersonalUnmanaged  `
        -GrantAdministrativePrivilege
    ````

    You can ignore the warnings because of collision with our Group Policy settings:

1. Assign **rdsh1.smart.etc** to **smart\user1** and **rdsh2.smart.etc** to **smart\user2**.

    ````powershell
    Set-RDPersonalSessionDesktopAssignment `
        -CollectionName $collectionName `
        -Name rdsh1.smart.etc `
        -User smart\user1
    Set-RDPersonalSessionDesktopAssignment `
        -CollectionName $collectionName `
        -Name rdsh2.smart.etc `
        -User smart\user2
    ````

1. Verify assigned users.

    ````powershell
    Get-RDPersonalSessionDesktopAssignment -CollectionName $collectionName
    ````

### Task 2: Test a Personal Desktop Session Collection

Perform these steps on CL1.

1. Sign in as **smart\user1**.
1. Open **Internet Explorer**.
1. Browse to **https://rdgw.smart.etc/RDWeb**.
1. Sign in as **smart\User1**.
1. On page **Work Resources**, click on **Personal Session Desktops**.
1. Click **Connect**.
1. Connected to **RDBROKER.SMART.ETC**, run **Windows PowerShell** as Administrator.

    This should be possible without entering a password.

1. In Windows PowerShell, display the value of the environment variable **COMPUTERNAME**.

    ````powershell
    $env:COMPUTERNAME
    ````

    This should return **RDSH1**.

1. From **RDBROKER.SMART.ETC** (**RDSH1**), sign out.
1. Back on page **Work Resources**, click **Sign out**.
1. On page **Work Resources**, sign in as **smart\User2**.
1. Repeat steps 5 - 10.

    You should have been connected to **RDSH2**.

[figure 1]: images/Azure-hamburger-menu.png
[figure 2]: images/Azure-sql-database-basics.png
[figure 3]: images/Azure-sql-server.png
[figure 4]: images/Azure-SQL-database-configure.png
[figure 5]: images/Azure-SQL-database-networking.png
[figure 6]: images/Azure-sql-database-overview.png
[figure 7]: images/Azure-SQL-firewall-settings.png
[figure 8]: images/Azure-sql-database-connection-string-odbc.png
[figure 9]: images/Server-Manager-rd-deployment-confirm.png
[figure 10]: images/RD-gateway-resource-authroization-policy-rdg_highavailabilitybroker_dns_rr.png