# Lab: Web Application Proxy

## Required VMs

* DC1
* PKI
* DHCP
* Router
* CL1
* CL2 on HV1
* SRV2
* NET1
* ADFS1
* WAP1

## Exercises

1. [IIS Application Configuration](#exercise-1-iis-application-configuration)
1. [ADFS Server Configuration](#exercise-2-adfs-server-configuration)
1. [Web Application Proxy Server Configuration](#exercise-3-web-application-proxy-server-configuration)
1. [Publish an internal web application using pass-through authentication](#exercise-4-publish-an-internal-web-application-using-pass-through-authentication)
1. [Publish an internal web application using AD FS basic authentication](#exercise-5-publish-an-internal-web-application-using-ad-fs-basic-authentication)
1. [Configure a web app for Kerberos authentication](#exercise-6-configure-a-web-app-for-kerberos-authentication)
1. [Publish an internal web application using AD FS authentication](#exercise-7-publish-an-internal-web-application-using-ad-fs-authentication)
1. [HTTP-HTTPS redirect](#exercise-8-http-https-redirect)

## Exercise 1: IIS Application Configuration

### Introduction

In this exercise, on NET1, you will install IIS with ASP.NET 3.5 and 4.7, basic and windows authentication. You will replace the default document with a sample application from L:\Web Application Proxy\authpage.zip. Then, you will configure the default web site for https and change the http port to 8080.

#### Tasks

1. [Install IIS and web application](#task-1-install-iis-and-web-application)
1. [Configure the website for HTTPS](#task-2-configure-the-website-for-https)

### Task 1: Install IIS and web application

#### Desktop experience

Perform these steps on NET1.

1. Sign in as **smart\Administrator**.
1. Open **Server Manager**.
1. In Server Manager, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, proceed to page **Select server roles**.
1. On page Select server roles, activate **Web Server (IIS)**. In the dialog appearing, click **Add Features**. Click **Next >**.
1. On page **Select features**, click **Next >**.
1. On page **Web server Role (IIS)**, click **Next >**.
1. On page **Select role services**, expand **Web Server**, **Security**.
1. Activate **Basic Authentication** and **Windows Authentication**.
1. Expand **Web Server**, **Application Development**.
1. Activate **ASP.NET 3.5** and **ASP.NET 4.7**. When a dialog appears, click **Add features**. Click **Next >**.
1. On page **Confirm installation selections**, click **Install**.
1. Click **Close**.
1. Open **File Explorer**.
1. In File Explorer, from **c:\inetpub\wwwroot**, delete **iisstart.htm** and **iisstart.png**.
1. Open **L:\Web Application Proxy\authpage.zip** and navigate to the folder **authpage**.
1. From the authpage folder in L:\Web Application Proxy\authpage.zip, copy all files to **C:\inetpub\wwwroot**.

    After the copy operation C:\inetpub\wwwroot should look like [figure 1].

1. Open **Internet Explorer**.
1. In Internet Explorer, navigate to **http://localhost**.

    You should see an application page like in [figure 2].

#### Windows Admin Center

Perform these steps on CL1.

1. Sign in as **smart\administrator**.1
1. Open **Google Chrome**.
1. In Google Chrome, navigate to **https://admincenter.smart.etc**.
1. On Windows Admin Center, click **NET1.smart.etc**.

    If asked for credentials, enter **smart\Administrator**.

1. Connected to NET1.smart.etc, under **Tools**, click **Roles & features**.
1. On Roles and features, expand **Web Server (IIS)**, **Web Server**, **Application Development**.
1. Activate ASP.NET 3.5 and ASP.NET 4.7.
1. Expand **Web Server (IIS)**, **Web Server**, **Security**.
1. Activate **Basic Authentication** and **Windows Authentication**.
1. Click **Install**.
1. On the pane **Install Roles and Features**, activate **Reboot the server automatically, if required** and click **Yes**.
1. Open **File Explorer**.
1. Open **L:\Web Application Proxy\authpage.zip**.
1. From L:\Web Application Proxy\authpage.zip, copy the folder **authpage** to **C:\\**.
1. Switch to **Google Chrome**.
1. Under Tools, click **Files & file sharing**.
1. On tab **Files**, navigate to **C:\inetpub\wwwroot**.
1. In C:\inetpub\wwwroot, select iisstart.htm and iisstart.png and **Delete**.

    Depending on your screen size, you might have to click the ellipsis (**...**, **More**) to access the Delete command.

1. In **Delete Multiple Items**, click **Yes**.
1. Click **Upload**.

    Depending on your screen size, you might have to click the ellipsis (**...**, **More**) to access the Delete command.

1. On pane Upload, click **Select files**.
1. In Open, navigate to **C:\authpage**.
1. In C:\authpage, select all files and click **Open**.
1. Back on pane Upload, click **Submit**.
1. Open a new tab.
1. Navigate to **http://net1**.

    You should see an application page like in [figure 2].

#### PowerShell

Perform these steps on NET1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Install the features **Web Server**, **Basic Authentication**, **Windows Authentication**. **ASP.NET 3.5** and **ASP.NET 4.7**.

    ````powershell
    Install-WindowsFeature `
        -Name `
            Web-Server, `
            Web-Asp-Net, `
            Web-Asp-Net45, `
            Web-Basic-Auth, `
            Web-Windows-Auth `
        -IncludeManagementTools
    ````

1. From **c:\inetpub\wwwroot**, delete **iisstart.htm** and **iisstart.png**.

    ````powershell
    Remove-Item -Path c:\inetpub\wwwroot\iisstart.htm
    Remove-Item -Path c:\inetpub\wwwroot\iisstart.png

1. Expand archive **L:\Web Application Proxy\Authpage.zip** to **C:\inetpub\wwwroot**.

    ````powershell
    Expand-Archive `
        -Path 'L:\Web Application Proxy\Authpage.zip' `
        -DestinationPath C:\inetpub\wwwroot\
    ````

1. Move the files from **C:\inetpub\wwwroot\authpage\\** to **C:\inetpub\wwwroot\\** and remove the directory **C:\inetpub\wwwroot\authpage\\**.

    ````powershell
    Move-Item `
        -Path C:\inetpub\wwwroot\authpage\*.* `
        -Destination C:\inetpub\wwwroot\
    Remove-Item -Path C:\inetpub\wwwroot\authpage\
    ````

1. Open **Internet Explorer** and navigate to **http://localhost**.

    ````powershell
    & 'C:\Program Files\internet explorer\iexplore.exe' http://localhost
    ````

    You should see an application page like in [figure 2].

### Task 2: Configure the website for HTTPS

#### Desktop experience

Perform these steps on NET1.

1. Open **Internet Information Services (IIS) Manager**.
1. On the left, under **Connections**, click **NET1 (SMART\Administrator)**
1. In the pane **NET1 Home**, under **IIS**, double-click **Server Certificates** ([figure 3]).
1. In Server Certificates, in the pane **Actions**, click **Create Domain Certificate...**
1. In Create Certificate, on page **Distinguished Name Properties**, in **Common name**, enter **\*.mysmart.com**. In **Organization**, enter **Smart Corp.**. In **Organizational unit**, enter **IT**. In **City/locality**, **State/province**, and **Country/region**, enter your location. Click **Next**.
1. On page **Online Certification Authority**, click **Select...**.
1. In **Select Certification Authority**, click **SmartRootCA** and click **OK**.
1. Back on page Online Certification Authority, in **Friendly name** enter **Wildcard** ([figure 4]). Click **Finish**.
1. Back in Server Certificates, in the context-menu of **Wildcard**, click **Export...**.
1. In the dialog Export Certificate, in **Export to**, enter **C:\mysmart.pfx**. In **Password** and **Confirm password**, enter a secure password ([figure 5]). Click **OK**.

    *Important:* Take a note of the password. You will need it later.

1. Under **Connections**, navigate to **NET1 (SMART\Administrator)**, **Sites**, **Default Web Site**.
1. In the context-menu of **Default Web Site**, click **Edit Bindings...**.
1. In the dialog Site Bindings, click **Add...**.
1. In the dialog Add Site Binding, under **Type**, select **https**. Under **SSL certificate**, select **Wildcard** ([figure 6]). Click **OK**.
1. Back in Site Bindings, click **http** and click **Edit...**.
1. In the dialog Edit Site Binding, in **Port**, enter **8080** and click **OK**.
1. Back in Site Bindings ([figure 7]), click **Close**.

#### PowerShell

1. Run **Windows PowerShell** as Administrator.
1. Request a certificate for **\*.mysmart.com** based on the WebServer10Years template and store the result in a variable.

    ````powershell
    $subjectName = "CN=*.mysmart.com"

    <#
        In contrast to IIS Manager, Get-Certificate requests the certificate in
        the context of the computer, if Cert:\LocalMachine is used as
        certificate store. By default, NET1 does not have permissions to request
        certificates based on the default WebServer certificate template.

        In the lab environment, there is the custom template WebServer10Years,
        which every authenticated user is allowed to enroll. Authenticated users
        include computers such as NET1. Therefore, we use this template.
    #>
    $template = 'WebServer10Years'
    # Attention! No ending backslash!
    $certStoreLocation = 'Cert:\LocalMachine\My' 
    
    $enrollmentResult = Get-Certificate `
        -Template $template `
        -SubjectName $subjectName `
        -CertStoreLocation $certStoreLocation
    ````

1. Create a secure password for the exported certificate.

    ````powershell
    $password = Read-Host -AsSecureString -Prompt 'Password for pfx'
    ````

    At the prompt, enter a secure password.

    *Important:* Take a note of the password. You will need it later.

1. Export the certificate including the private key.

    ````powershell
    $filePath = 'c:\mysmart.pfx'
    $enrollmentResult.Certificate | 
    Export-PfxCertificate -FilePath $filePath -Password $password
    ````

1. For the site **Default Web Site** create a new **https** binding with the certificate.

    ````powershell
    $name = 'Default Web Site'
    New-IISSiteBinding `
        -Name $name `
        -Protocol https `
        -BindingInformation *:443: `
        -CertStoreLocation $certStoreLocation `
        -CertificateThumbPrint $enrollmentResult.Certificate.Thumbprint
    ````

1. Change the port of the existing http binding to 8080.

    ````powershell
    <#
         Unfortunately, it is not possible to change the existing binding using
         PowerShell. Therefore, we must remove the existing binding first.
         -Confirm is a switch parameter, that normally enforces confirmation on
         cmdlets. In the case of Remove-IISSiteBinding, confirmation is enforced
         by default. Therefore, we must set it to $false. Because -Confirm is
         a switch parameter, to provide a value, we must type a colon after the
         parameter name.
    #>
    Remove-IISSiteBinding `
        -Name $name `
        -Protocol http `
        -BindingInformation *:80: `
        -Confirm:$false
    New-IISSiteBinding -Name $name -Protocol http -BindingInformation *:8080:
    ````

1. Verify the bindings.

    ````powershell
    Get-IISSiteBinding -Name $name
    ````

    The result should be:

    ````shell
    protocol bindingInformation sslFlags
    -------- ------------------ --------
    http     *:8080:                None
    https    *:443:                 None
    ````

## Exercise 2: ADFS Server Configuration

### Introduction

In this exercise, in the domain, you will first create the KDS root key for group managed service accounts. Then you will install and configure ADFS on ADFS1 with the certificate created in the previous exercise and a group managed service account.

#### Tasks

1. [Create the KDS root key for group managed service accounts](#task-1-create-the-kds-root-key-for-group-managed-service-accounts)
1. [Install ADFS and import the certificate](#task-2-install-adfs-and-import-the-certificate)
1. [Configure ADFS](#task-3-configure-adfs)

### Task 1: Create the KDS root key for group managed service accounts

Perform these steps on DC1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Create the KDS Root Key for Group Managed Service Accounts.

    ````powershell
    Add-KdsRootKey -EffectiveTime (get-date).AddDays(-1)
    ````

    *Note:* In a real world scenario you should execute ````Add-KdsRootKey```` without any parameters and wait for 24 hours to replicate the KDS root key through your Active Directory infrastructure.

### Task 2: Install ADFS and import the certificate

#### Desktop experience

Perform these steps on ADFS1.

1. Sign in as **smart\Administrator**.
1. Open **Server Manager**.
1. In Server Manager, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, proceed to page **Select server roles**.
1. On page Select server roles, activate **Active Directory Federation Services**. Click **Next >**.
1. Proceed through the wizard to install Active Directory Federation Services role.
1. Do not wait for the installation to finish. Click **Close**.

1. Open **File Explorer**.
1. In File Explorer, navigate to **\\\NET1\C$**.
1. In \\\NET1\c$, open **mysmart.pfx**.
1. In **Certificate Import Wizard**, on page **Welcome to the Certificate Import Wizard**, under **Store Location**, click **Local Machine**.
1. On page **File to Import**, click **Next**.
1. On page **Private Key protection**, in **Password**, enter the password you took note of in the previous excercise and click **Next**.
1. On page **Certificate store**, click **Next**.
1. On page **Completing the Certificate Import Wizard**, click **Finish**.
1. On message **The import was successful.**, click **OK**.

#### PowerShell

Perform these steps on ADFS1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Start the installation of windows feature **ADFS-Federation** as background job.

    ````powershell
    <#
        Start-Job initiates a script block as background job, so we do not have
        to wait for the installation to finish.
    #>
    $job = Start-Job `
        -ScriptBlock { 
            Install-WindowsFeature -Name ADFS-Federation -IncludeManagementTools 
        }

1. Import the exported certificate from the previous exercise into the local machine store.

    ````powershell
    $password = Read-Host -AsSecureString -Prompt 'Password for pfx'
    $x509Certificate2 = Import-PfxCertificate `
        -CertStoreLocation Cert:\LocalMachine\My\ `
        -FilePath '\\NET1\c$\mysmart.pfx' `
        -Password $password
    ````

    At the prompt, enter the password you took note of in the previous exercise.

1. Check the status of the installation job.

    ````powershell
    $job
    ````

    Repeat this step until **State** is not equal to **Running**. If everything worked, the **State** should be **Completed**. Notice **HasMoreData** is **True**.

1. Receive the job results.

    ````powershell
    Receive-Job -Job $job
    ````

    The result should be:

    ````shell
    Success Restart Needed Exit Code      Feature Result
    ------- -------------- ---------      --------------
    True    No             Success        {Active Directory Federation Services}
    WARNING: To finish configuring this server for the federation server role using Windows PowerShell, see http://go.microsoft.com/fwlink/?LinkId=224868.
    ````

1. Check the status of the job again.

    ````powershell
    $job
    ````

    Notice **HasMoreData** is **False** now. Receiving the job result data, deleted it from the job.

1. Remove the job.

    ```powershell
    Remove-Job -Job $job
    ````

### Task 3: Configure ADFS

#### Desktop experience

Perform these steps on ADFS1.

1. In Server Manager, click the notification flag with the warning triangle and click the link **Configure the federation service on this server** ([figure 8]).
1. In Active Directory Federation Service Configuration Wizard, on page **Welcome**, click **Create the first federation server in a federation farm** and click **Next >**.
1. On page **Connect to Active Directory Domain Services**, click **Next >**.
1. On page **Specify Service Properties**, for **SSL certificate**, select **\*.mysmart.com**. In **Federation Service Name**, type **sts.mysmart.com**. In **Federation Service Display name**, type **Smart ADFS**. Click **Next >**.
1. On page **Specify Service Account**, click **Create a Group Managed Service Account**. In **Acount Name**, enter **gmsa-ADFS**. Click **Next >**.
1. On page **Specify Configuration Database**, click **Create a database on this server using Windows Internal Database** and click **Next >**.
1. On page **Review Options**, click **Next >**.
1. On page **Pre-requisite Checks**, click **Configure**.

    Wait for the configuration to complete.

1. On page **Results**, click **Close**.
1. Run **Windows PowerShell** as Administrator.
1. Enable **IdpinitiatedSignon** for testing purposes.

    ````powershell
    Set-AdfsProperties -EnableidpinitiatedSignonPage $true
    ````

1. Open **Internet Explorer**.
1. In Internet explorer, navigate to **https://sts.mysmart.com/adfs/ls/idpinitiatedsignon.aspx**
1. On page Smart ADFS, click the button to sign in (the button is labeled in the browser's default language.)
1. In **Windows Security**, enter the credentials for a domain user.

    You should see a message stating you are signed in.

#### PowerShell

Perform these steps on ADFS1.

1. Create the first noede in a new federation server farm. Use the certificate you imported in the previous task. Ad federation service name, use **sts.mysmart.com**. As federation service display name, use **Smart ADFS**. Use a group managed service account with the name **gmsa-ADFS$**.

    ````powershell
    Install-AdfsFarm `
        -CertificateThumbprint $x509Certificate2.Thumbprint `
        -FederationServiceName sts.mysmart.com `
        -FederationServiceDisplayName 'Smart ADFS' `
        -GroupServiceAccountIdentifier smart\gmsa-ADFS$
    ````

1. Enable **IdpinitiatedSignon** for testing purposes.

    ````powershell
    Set-AdfsProperties -EnableidpinitiatedSignonPage $true
    ````

1. Open Internet Explorer and navigate to **https://sts.mysmart.com/adfs/ls/idpinitiatedsignon.aspx**

    ````powershell
    & 'C:\Program Files\internet explorer\iexplore.exe' https://sts.mysmart.com/adfs/ls/idpinitiatedsignon.aspx
    ````

1. On page Smart ADFS, click the button to sign in (the button is labeled in the browser's default language.)
1. In **Windows Security**, enter the credentials for a domain user.

## Exercise 3: Web Application Proxy Server Configuration

### Introduction

In this exercise, on WAP1, you will install and configure the Web Application Proxy to work with your ADFS implementation. Moreover, you will configure your host computer to use NET1 as DNS server to resolve the DNS name of your ADFS implementation.

#### Tasks

1. [Import the certificate and install the Web Application Proxy role service](#task-1-import-the-certificate-and-install-the-web-application-proxy-role-service)
2. [Configure the WAP role service](#task-2-configure-the-web-application-proxy-role-service)
3. [Configure the DNS client](#task-3-configure-the-dns-client)

### Task 1: Import the certificate and install the Web Application Proxy role service

#### Desktop experience

Perform these steps on WAP1.

1. Sign in as **smart\Administrator**.
1. Open **Server Manager**.
1. In Server Manager, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, proceed to page **Select server roles**.
1. On page Select server roles, activate **Remote Access**. Click **Next >**.
1. Proceed through the wizard to the page **Select role service**.
1. On page Select role services, activate **Web Application Proxy**. In the dialog, click **Add Features**.
1. Proceed through the wizard to install Web Application Proxy role.
1. Do not wait for the installation to finish. Click **Close**.
1. Open **File Explorer**.
1. In File Explorer, navigate to **\\\NET1\C$**.
1. In \\\NET1\c$, open **mysmart.pfx**.
1. In **Certificate Import Wizard**, on page **Welcome to the Certificate Import Wizard**, under **Store Location**, click **Local Machine**.
1. On page **File to Import**, click **Next**.
1. On page **Private Key protection**, in **Password**, enter the password you took note of in the previous excercise and click **Next**.
1. On page **Certificate store**, click **Next**.
1. On page **Completing the Certificate Import Wizard**, click **Finish**.
1. On message **The import was successful.**, click **OK**.

#### PowerShell

Perform these steps on ADFS1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Start the installation of windows feature **ADFS-Federation** as background job.

    ````powershell
    $job = Start-Job `
        -ScriptBlock { 
            Install-WindowsFeature -Name ADFS-Federation -IncludeManagementTools 
        }

1. Import the exported certificate from the previous exercise into the local machine store.

    ````powershell
    $password = Read-Host -AsSecureString -Prompt 'Password for pfx'
    $x509Certificate2 = Import-PfxCertificate `
        -CertStoreLocation Cert:\LocalMachine\My\ `
        -FilePath '\\NET1\c$\mysmart.pfx' `
        -Password $password
    ````

    At the prompt, enter the password you took note of in the previous exercise.

1. Check the status of the installation job.

    ````powershell
    $job
    ````

    Repeat this step until **State** is not equal to **Running**. If everything worked, the **State** should be **Completed**. Notice **HasMoreData** is **True**.

1. Receive the job results.

    ````powershell
    Receive-Job -Job $job
    ````

    The result should be:

    ````shell
    Success Restart Needed Exit Code      Feature Result
    ------- -------------- ---------      --------------
    True    No             Success        {Remote Access, Remote Server Administrati...
    WARNING: To finish configuring this server for the Web Application Proxy role service using Windows PowerShell, see http://go.microsoft.com/fwlink/?LinkId=294322.
    ````

1. Remove the job.

    ```powershell
    Remove-Job -Job $job
    ````

### Task 2: Configure the Web Application Proxy role service

#### Desktop experience

Perform these steps on WAP1.

1. In Server Manager, click the notification flag with the warning triangle and click the link **Open the Web Application Proxy Wizard**.
1. In Web Application Proxy Configuration Wizard, on page **Welcom**, click **Next >**.
1. On page **Federation Server**, in **Federation service name**, enter **sts.mysmart.com**. In **User name** and **Password** enter the credentials of **smart\Administrator**. Click **Next >**.
1. On page **AD FS Proxy Certificate**, under **Select a certficate to be used by the AD FS Proxy**, select **\*.mysmart.com** and click **Next >**.
1. On page **Confirmation**, click **Configure**.
1. On page **Results**, click **Close**.

#### PowerShell

Perform these steps on WAP1.

1. Run **Windows PowerShell** as Administrator.
1. Store the credential for the federation service trust in a variable.

    ````powershell
    $credential = Get-Credential `
        -Message 'Federation service trust credentail' `
        -UserName smart\Administrator
    ````

    At the prompt, enter the password for smart\Administrator

1. Configure the web application proxy using the certificate you imported in the previous task and the credential you created in the previous step. Use **sts.mysmart.com** as federation service name.

    ````powershell
    Install-WebApplicationProxy `
        -CertificateThumbprint $x509Certificate2.Thumbprint `
        -FederationServiceTrustCredential $credential `
        -FederationServiceName sts.mysmart.com

### Task 3: Configure the DNS client

#### Desktop experience

Perform these steps on CL2.

1. Sign in as **smart\administrator**
1. Open **View Network Connections**.
1. In the context-menu of **Datacenter2**, click **Properties**.
1. In Datacenter2 Properties, click **Internet Protocol Version 4 (TCP/IPv4)** and click **Properties**.
1. In Internet Protocol Version 4 (TCP/IPv4) Properties, click **Use the following DNS server addresses**. In **Preferred DNS server**, enter 10.1.1.70 and click **OK**.
1. Back in vEthernet (Classrooom) Properties, click **Close**.
1. Open **Windows PowerShell**.
1. Resolve the DNS name sts.mysmart.com.

    ````powershell
    Resolve-DnsName sts.mysmart.com
    ````

    In the result, the IP address should be 10.1.1.72.

1. Open **Firefox**.
1. In the web browser, navigate to **https://sts.mysmart.com/adfs/ls/idpinitiatedsignon.aspx**.

    You might receive a warning regarding the certificate. Proceed to the website anyways.

    You should see to the Smart ADFS sign in page.

##### PowerShell

Perform these steps on the CL2.

1. Run **Window PowerShell** as Administrator.
1. For the network adapter **Datacenter2** set the DNS client address to **10.1.1.70**.

    ````powershell
    Set-DnsClientServerAddress `
        -InterfaceAlias 'Datacenter2' `
        -ServerAddresses 10.1.1.70
    ````

1. Resolve the DNS name sts.mysmart.com.

    ````powershell
    Resolve-DnsName sts.mysmart.com
    ````

    In the result, the IP address should be 10.1.1.72.

1. Open a web browser.
1. In the web browser, navigate to **https://sts.mysmart.com/adfs/ls/idpinitiatedsignon.aspx**.

    You might receive a warning regarding the certificate. Proceed to the website anyways.

    You should see to the Smart ADFS sign in page.

## Exercise 4: Publish an internal web application using pass-through authentication

### Introduction

In this exercise, first you will create a DNS A record for app1.mysmart.com pointing to WAP1 (10.1.1.72). You will create the same record in the Datacenter2 zone scope. In the Datacenter1 zone scope, create the record pointing to 10.1.1.71. Then, you will use Web Application Proxy to publish the app using pass-through authentication and SSL. After testing anonymous authentication, you will switch the web app to basic authentication and test it again.

#### Tasks

1. [Create DNS A Records for the web app](#task-1-create-dns-a-records-for-the-web-app)
1. [Publish web app with anonymous authentication](#task-2-publish-web-app-with-anonymous-authentication)
1. [Test anonymous authentication](#task-3-test-anonymous-authentication)
1. [Change authentication of web app to basic](#task-4-change-authentication-of-web-app-to-basic)
1. [Test basic authentication](#task-5-test-basic-authentication)

### Task 1: Create DNS A Records for the web app

Perform these steps on NET1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Create a DNS A record for app1.mysmart.com pointing to 10.1.1.72.

    ````powershell
    $name = 'app1'
    $zoneName = 'mysmart.com'
    Add-DnsServerResourceRecordA `
        -Name $name `
        -IPv4Address 10.1.1.72 `
        -ZoneName $zoneName
    ````

1. Create a DNS A record for app1.mysmart.com pointing to 10.1.1.70 in the Datacenter1 zone scope.

    ````powershell
    Add-DnsServerResourceRecordA `
        -Name $name `
        -IPv4Address 10.1.1.70 `
        -ZoneName $zoneName `
        -ZoneScope Datacenter1
    ````

1. Create a DNS A record for app1.mysmart.com pointing to 10.1.1.72 in the Datacenter2 zone scope.

    ````powershell
    Add-DnsServerResourceRecordA `
        -Name $name `
        -IPv4Address 10.1.1.72 `
        -ZoneName $zoneName `
        -ZoneScope Datacenter2
    ````

### Task 2: Publish web app with anonymous authentication

Perform these steps on WAP1.

1. Sign in as **smart\Administrator**.
1. Open **Remote Access Management**.
1. In Remote Access Management Console, on the right-hand side, under **Tasks**, click **Publish**.
1. In Publish New Application Wizard, on page **Welcome**, click **Next >**.
1. On page **Preauthentication**, click **Pass-through** and click **Next >**.
1. On page **Publishing Settings**, in **Name**, enter **App1**. In **External URL** and **Backend server URL**, enter **https://app1.mysmart.com**. Under **External certificate**, select the ***.mysmart.com** and click **Next >**.
1. On page **Confirmation**, click **Publish**.
1. On page **Results**, click **Close**.

#### PowerShell

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Publish the internal application **https://app1.mysmart.com** under the same URL using the certificate **\*.mysmart.com** and passthrough authentication.

    ````powershell
    $x509Certificate2 = `
        Get-ChildItem Cert:\LocalMachine\My\ | 
        Where-Object { $PSItem.Subject -eq 'CN=*.mysmart.com' }
    $externalUrl = 'https://app1.mysmart.com'
    $backendServerUrl = $externalUrl
    Add-WebApplicationProxyApplication `
        -ExternalPreAuthentication PassThrough `
        -Name 'App1' `
        -ExternalUrl $externalUrl `
        -ExternalCertificateThumbprint $x509Certificate2.Thumbprint `
        -BackendServerUrl $backendServerUrl
    ````

### Task 3: Test anonymous authentication

Perform these steps on CL2.

1. Sign in as **smart\Administrator**.
1. Open **Firefox**.
1. In Firefox, browse to https://app1.mysmart.com.

    At the top of the page, **Authentication method** should be **Anonymous**.

1. From the hamburger menu, click **Find in this Page...** (or press CTRL + F).
1. In **Find in page**, type **REMOTE_ADDR**.

    You will find this value near the bottom of the page. It should be **10.1.1.72**, which is the IP address of WAP1. WAP1 proxies the clients request to NET1 (IP address 10.1.1.70).

### Task 4: Change authentication of web app to basic

#### Desktop experience

Perform these steps on NET1.

1. Sign in as **smart\Administrator**.
1. Open **Internet Information Services (IIS) Manager**.
1. In Internet Information Services (IIS) Manager, navigate to **NET1 (SMART\Administrator)**, **Sites**, **Default Web Site**.
1. In **Default Web Site Home**, under **IIS**, open **Authentication**.
1. In Authentication, click **Anonymous Authentication**. On the right-hand side, under **Actions**, click **Disable**.
1. Click **Basic Authentication**. On the right-hand side, under **Actions**, click **Enable**.

#### PowerShell

Perform these steps on NET1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. For Default Web Site, disable anonymous authentication.

    ````powershell

    $path = 'IIS:\'
    $location = 'Default Web Site'
    $name = 'enabled'

    Set-WebConfigurationProperty `
        -PSPath $path `
        -Location $location `
        -Name $name `
        -Filter `
            '/system.webServer/security/authentication/anonymousAuthentication' `
        -Value false
    ````

1. For Default Web site, enable basic authentication.

    ````powershell
    Set-WebConfigurationProperty `
        -PSPath $path `
        -Location $location `
        -Name $name `
        -Filter `
            '/system.webServer/security/authentication/basicAuthentication' `
        -Value true
    ````

### Task 5: Test basic authentication

Perform these steps on CL2.

1. In Firefox, refresh the page.
1. In **Authentication** required, enter the credentials of any domain user.
1. In **Would you like Firefox to save this login for mysmart.com?**, click the arrow down and click **Never Save**.

    Now, the **Authentication Method** should be **Basic**. **Identity** should display the user you used to sign in to the web app.

## Exercise 5: Publish an internal web application using AD FS basic authentication

### Introduction

In this exercise, in ADFS, you will create a relying party trust for the non claims aware application https://app1.mysmart.com. Then, you will publish the web app using WAP and test the authentication.

#### Tasks

1. [Create a relying party trust](#task-1-create-a-relying-party-trust)
1. [Publish web app using AD FS and basic authentication](#task-2-publish-web-app-using-ad-fs-and-basic-authentication)
1. [Test AD FS and basic authentication](#task-3-test-ad-fs-and-basic-authentication)

### Task 1: Create a relying party trust

#### Desktop experience

Perform these steps on ADFS1.

1. Sign in as **smart\Administrator**.
1. Open **AD FS Management**.
1. In AD FS, navigate to **AD FS**, **Relying Party Trusts**.
1. In the context-menu of **Relying Party Trusts**, click **Add Relying Party Trust...**
1. In Add Relying Party Trust Wizard, on page **Welcome to the Add Relying Party Trust Wizard**, click **Non claims aware** and click **Start**.
1. On page **Specify Display Name**, in **Display Name**, enter **App1 MySmart** click **Next >**.
1. On page **Configure Identifiers**, in **Relying party trust identifier**, type **https://app1.mysmart.com** and click **Add**. Then, click **Next >**.
1. On page **Chose Access Control Policy**, click **Permit everyone** and click **Next >**.
1. On page **Ready to Add Trust**, click **Next >**.
1. On page **Finish**, click **Close**.

#### PowerShell

Perform these steps on ADFS1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Add a non claims aware relying party trust with the name **App1 MySmart** for **https://app1.mysmart.com** with the access control policy **Permit everyone**.

    ````powershell
    Add-AdfsNonClaimsAwareRelyingPartyTrust `
        -Name 'App1 MySmart' `
        -Identifier https://app1.mysmart.com `
        -AccessControlPolicyName 'Permit everyone'

### Task 2: Publish web app using AD FS and basic authentication

#### Desktop experiecne

Peform these steps on WAP1.

1. In **Remote Access Management Console**, click **APP1**.
1. Under **Tasks**, click **Remove**.
1. Under **Tasks**, click **Publish**.
1. In Publish New Application Wizard, on page **Welcome**, click **Next >**.
1. On page **Preauthentication**, click **Active Directory Federation Services (AD FS)** and click **Next >**.
1. On page **Supported Clients**, click **HTTP Basic** and click **Next >**.
1. On page **Relying Party**, click **App1 MySmart** and click **Next >**.
1. On page **Publishing Settings**, in **Name**, enter **App1**. In **External URL** and **Backend server URL**, enter **https://app1.mysmart.com**. Under **External certificate**, select the ***.mysmart.com** and click **Next >**.
1. On page **Confirmation**, click **Publish**.
1. On page **Results**, click **Close**.

#### PowerShell

Perform these steps on WAP1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Remove the web application proxy application **App1**.

    ````powershell
    Remove-WebApplicationProxyApplication -Name 'App1'
    ````

1. Publish the internal application **https://app1.mysmart.com** under the same URL using the certificate **\*.mysmart.com** using ADFS for Richt Clients as authentication method and **App1 MySmart** as the ADFS relying party name..

    ````powershell
    $x509Certificate2 = `
        Get-ChildItem Cert:\LocalMachine\My\ | 
        Where-Object { $PSItem.Subject -eq 'CN=*.mysmart.com' }
    $externalUrl = 'https://app1.mysmart.com'
    $backendServerUrl = $externalUrl
    Add-WebApplicationProxyApplication `
        -ExternalPreAuthentication ADFSforRichClients `
        -ADFSRelyingPartyName 'App1 MySmart' `
        -Name 'App1' `
        -ExternalUrl $externalUrl `
        -ExternalCertificateThumbprint $x509Certificate2.Thumbprint `
        -BackendServerUrl $backendServerUrl
    ````

### Task 3: Test AD FS and basic authentication

Perform these steps on CL2.

1. Sign in as **smart\Administrator**.
1. Open **Firefox**.
1. In Firefox, navigate to **https://app1.mysmart.com**.
1. Under **This site is asking you to sign in**, enter the credentials of any domain user.

    **Authentication Method** should be **Basic**. **Identity** should display the user you used to sign in to the web app. However, WAP1 and ADFS1 performed a pre-authentication. Therefore, faulty authentication requests would not hit the web app.

## Exercise 6: Configure a web app for Kerberos authentication

### Introduction

In this exercise, you will first change the authentication of the web app from basic to Windows. Then, you will add SPNs to allow Kerberos authentication. Finally, you will test the Kerberos authentication to the web app using the internal client.

#### Tasks

1. [Change authentication of web app to Windows](#task-1-change-authentication-of-web-app-to-windows)
1. [Configure Kerberos authentication](#task-2-configure-kerberos-authentication)
1. [Test Kerberos authentication](#task-3-test-kerberos-authentication)

### Task 1: Change authentication of web app to Windows

#### Desktop experience

Perform these steps on NET1.

1. Sign in as **smart\Administrator**.
1. Open **Internet Information Services (IIS) Manager**.
1. In Internet Information Services (IIS) Manager, navigate to **NET1 (SMART\Administrator)**, **Sites**, **Default Web Site**.
1. In **Default Web Site Home**, under **IIS**, open **Authentication**.
1. In Authentication, click **Basic Authentication**. On the right-hand side, under **Actions**, click **Disable**.
1. Click **Windows Authentication**. On the right-hand side, under **Actions**, click **Enable**.

#### PowerShell

Perform these steps on NET1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. For Default Web Site, disable anonymous authentication.

    ````powershell

    $path = 'IIS:\'
    $location = 'Default Web Site'
    $name = 'enabled'

    Set-WebConfigurationProperty `
        -PSPath $path `
        -Location $location `
        -Name $name `
        -Filter `
            '/system.webServer/security/authentication/basicAuthentication' `
        -Value false
    ````

1. For Default Web site, enable basic authentication.

    ````powershell
    Set-WebConfigurationProperty `
        -PSPath $path `
        -Location $location `
        -Name $name `
        -Filter `
            '/system.webServer/security/authentication/windowsAuthentication' `
        -Value true
    ````

### Task 2: Configure Kerberos authentication

Perform these steps on DC1.

1. Sign in as **smart\Administrator**.
1. Open **Command Prompt**.
1. Add the Service Principal Name **HTTP/app1.mysmart.com** to **NET1**.

    ````shell
    setspn -a HTTP/app1.mysmart.com NET1
    ````

### Task 3: Test Kerberos authentication

Perform these steps on CL1.

1. Sign in as **smart\Administrator**.
1. Open **Command Prompt**.
1. Purge all Kerberos tickets.

    ````shell
    klist purge
    ````

1. Open **Google Chrome**.
1. In Google Chrome, navigate to **https://app1.mysmart.com**.

    The page should open without any prompt for credentials. **Authentication Method** should be **Negotiate (KERBEROS**. **Identity** should display the user you used to sign in to the web app. **REMOTE_ADDR** shows the IP address of CL1, because it is on the Internal client subnet.

1. Switch to **Command Prompt**.

1. List all Kerberos tickets.

    ````shell
    klist
    ````

    The result should contain these lines:

    ````shell
    #1>     Client: Administrator @ SMART.ETC
            Server: HTTP/app1.mysmart.com @ SMART.ETC
            KerbTicket Encryption Type: AES-256-CTS-HMAC-SHA1-96
            Ticket Flags 0x40a10000 -> forwardable renewable pre_authent name_canonicalize
            Start Time: 1/3/2022 21:48:48 (local)
            End Time:   1/4/2022 7:48:48 (local)
            Renew Time: 1/10/2022 21:48:48 (local)
            Session Key Type: AES-256-CTS-HMAC-SHA1-96
            Cache Flags: 0
            Kdc Called: dc1.smart.etc
    ````

*Note:* Accessing the web app form CL2 does not work at the moment. We will fix that in the next exercise.

## Exercise 7: Publish an internal web application using AD FS authentication

### Introduction

In this exercise, you will configure Active Directory and WAP to allow for Kerberos authentication. The, you will publish the web app again as true web application with delegated authentication to ADFS. As a result, authentication will occur on the ADFS sign in page.

#### Tasks

1. [Configure Kerberos Contrained Delegation](#task-1-configure-kerberos-contrained-delegation)
2. [Publish web app using AD FS authentication](#task-2-publish-web-app-using-ad-fs-authentication)
3. [Test AD FS authentication](#task-3-test-ad-fs-authentication)

### Task 1: Configure Kerberos Contrained Delegation

#### Desktop experience

Perform these steps on DC1.

1. Sign in as **smart\Administrator**.
1. Open **Command Prompt**.
1. Add the Service Principal Names **HTTP/WAP1** and **HTTP/WAP1.smart.etc**  to **WAP1**.

    ````shell
    setspn -a HTTP/WAP1 WAP1
    setspn -a HTTP/WAP1.smart.etc WAP1
    ````

1. Open Active Directory Administrative Center.
1. Use **Global Search** to search for **WAP1**.
1. Open the **Properties** of **WAP1**.
1. In WAP1, click **Delegation**.
1. Click **Trust this computer for delegation to specified services only**.
1. Click **Use any authentication protocol**.
1. Click **Add...**.
1. In Add Services, click **Add Users or Computers...**.
1. In Select Users or Computers, click **Object Types...**.
1. Search for NET1 and click **OK**.
1. Back in Add Services, select **HTTP/app1.mysmart.com** and click **OK**.
1. Back in WAP1, click **OK**.

#### PowerShell

Perform these steps on DC1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Add the Service Principal Names **HTTP/WAP1** and **HTTP/WAP1.smart.etc**  to **WAP1**.

    ````powershell
    setspn -a HTTP/WAP1 WAP1
    setspn -a HTTP/WAP1.smart.etc WAP1
    ````

1. Set **WAP1** to be trusted for delegation for specified services only.

    ````powershell
    <#
        TrustedForDelegation and TrustedToAuthForDelegation are switch
        parameters. To provide values other than $true, you have to append a
        colon.
    #>
    Set-ADAccountControl WAP1$ `
        -TrustedForDelegation:$false `
        -TrustedToAuthForDelegation:$true
    ````

1. Add the service **HTTP/app1.mysmart.com** to the allowed to delegate to list of **WAP1**.

    ````powershell
    <#
        The Replace parameter uses a hash table with name/value-pairs to
        define the attributes to be replaced. In PowerShell a hash table is
        written as @{ }.
    #>
    Set-ADComputer WAP1$  `
        -Replace:@{ "msDS-AllowedToDelegateTo"="HTTP/app1.mysmart.com" }
    ````

### Task 2: Publish web app using AD FS authentication

#### Desktop experience

Perform these steps on WAP1.

1. Restart the computer.
1. Sign in as **smart\Administrator**.
1. Open **Remote Access Management**.
1. In **Remote Access Management Console**, click **APP1**.
1. Under **Tasks**, click **Remove**.
1. Under **Tasks**, click **Publish**.
1. In Publish New Application Wizard, on page **Welcome**, click **Next >**.
1. On page **Preauthentication**, click **Active Directory Federation Services (AD FS)** and click **Next >**.
1. On page **Supported Clients**, click **Web and MSOFBA** and click **Next >**.
1. On page **Relying Party**, click **App1 MySmart** and click **Next >**.
1. On page **Publishing Settings**, in **Name**, enter **App1**. In **External URL** and **Backend server URL**, enter **https://app1.mysmart.com**. Under **External certificate**, select the **\*.mysmart.com**. In **Backend server SPN**, enter **HTTP/app1.mysmart.com**. Click **Next >**.
1. On page **Confirmation**, click **Publish**.
1. On page **Results**, click **Close**.

#### PowerShell

Perform these steps on WAP1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Remove the web application proxy application **App1**.

    ````powershell
    Remove-WebApplicationProxyApplication -Name 'App1'
    ````

1. Publish the internal application **https://app1.mysmart.com** under the same URL using the certificate **\*.mysmart.com** using ADFS for Richt Clients as authentication method and **App1 MySmart** as the ADFS relying party name..

    ````powershell
    $x509Certificate2 = `
        Get-ChildItem Cert:\LocalMachine\My\ | 
        Where-Object { $PSItem.Subject -eq 'CN=*.mysmart.com' }
    $externalUrl = 'https://app1.mysmart.com'
    $backendServerUrl = $externalUrl
    Add-WebApplicationProxyApplication `
        -ExternalPreAuthentication ADFS `
        -ADFSRelyingPartyName 'App1 MySmart' `
        -Name 'App1' `
        -ExternalUrl $externalUrl `
        -ExternalCertificateThumbprint $x509Certificate2.Thumbprint `
        -BackendServerUrl $backendServerUrl `
        BackendServerAuthenticationSpn 'HTTP/app1.mysmart.com'
    ````

### Task 3: Test AD FS authentication

Perform these steps on CL2.

1. Sign in as **smart\Administrator**.
1. Open **Firefox**.
1. In Firefox, navigate to **https://app1.mysmart.com**.

    You will be redirected to https://sts.mysmart.com.

1. On page **Smart ADFS**, enter the credentials of any domain user.
1. In **Save login for mysmart.com?**, click the arrow down and click **Never save**.

    **Authentication Method** should be **Negotiate (KERBEROS)**. **Identity** should display the user you used to sign in to the web app. **REMOTE_ADDR** is **10.1.1.72**, which is the IP address of WAP1.

## Exercise 8: HTTP-HTTPS redirect

### Introduction

In this exercise, you will enable automatic redirction for clients from HTTP to HTTPS.

#### Tasks

1. [Enable HTTP-HTTPS redirect](#task-1-enable-http-https-redirect)
1. [Test HTTP-HTTPS redirect](#task-2-test-http-https-redirect)

### Task 1: Enable HTTP-HTTPS redirect

#### Desktop experience

Perform these steps on WAP1.

1. Sign in as **smart\Administrator**.
1. Open **Remote Access Management**.
1. In Remote Access Management Console, under **PUBLISHED WEB APPLICATIONS**, click **App1**.
1. Under **Tasks**, click **Edit**.
1. In Edit Published Web Appliation Wizard, on page **Welcome**, click **Next >**.
1. On page **Publishing Settings**, activate **Enable HTTP to HTTPS redirection** and click **Next >**.
1. On page **Confirmation**, click **Edit**.
1. On page **Results**, click **Close**.
1. Open **Windows Defender firewall with Advanced Security**.
1. In Windows Defender Firewall with Advanced Security, in the context-menu of **Inbound Rules**, click **New Rule...**.
1. In New Inbound Rule Wizard, on page **Rule Type**, click **Port** and click **Next >**.
1. On page **Protocol and Ports**, click **TCP**. In **Specific local ports**, enter 80 and click **Next >**.
1. On page **Action**, click **Allow the connection** and click **Next >**.
1. On page **Profile**, click **Next >**.
1. On page **Name**, in **Name**, enter **AD FS HTTP Services (TCP-in)** anc click **Finish**.

#### PowerShell

Perform these steps on WAP1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Publish the internal application **https://app1.mysmart.com** under the same URL using the certificate **\*.mysmart.com** using ADFS for Richt Clients as authentication method and **App1 MySmart** as the ADFS relying party name..

    ````powershell
    Get-WebApplicationProxyApplication -Name 'App1' | 
    Set-WebApplicationProxyApplication -EnableHTTPRedirect
    ````

1. In the Windows Defender Firewall, create an inbound rule for HTTP traffic.

    ````powershell
    New-NetFirewallRule `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort 80 `
        -Action Allow `
        -Profile Any `
        -DisplayName 'AD FS HTTP Services (TCP-In)'
    ````

### Task 2: Test HTTP-HTTPS redirect

Perform these steps on CL2.

1. Sign in as **smart\Administrator**.
1. Open **Firefox**.
1. In Firefox, navigate to **http://app1.mysmart.com**.h

    You will be redirected to https://sts.mysmart.com.

1. On page **Smart ADFS**, enter the credentials of any domain user.

    **Authentication Method** should be **Negotiate (KERBEROS)**. **Identity** should display the user you used to sign in to the web app. **REMOTE_ADDR** is **10.1.1.72**, which is the IP address of WAP1.


[figure 1]: images/inetpub-wwwroot-authpage.png
[figure 2]: images/who-iis.png
[figure 3]: images/IIS-server-certificates.png
[figure 4]: images/IIS-domain-certificate-online-certification-authority.png
[figure 5]: images/IIS-export-certificate.png
[figure 6]: images/IIS-add-binding-ssl.png
[figure 7]: images/iis-site-bindings.png
[figure 8]: images/Server-Manager-notification-configure-adfs.png