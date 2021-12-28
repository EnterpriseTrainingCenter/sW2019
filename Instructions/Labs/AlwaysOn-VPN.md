# Lab: AlwaysOn VPN

## Required VMs

    * DC1
    * DHCP
    * Router
    * PKI
    * CL1
    * ISP
    * Net1
    * VPN

## Exercises

1. [Prepare and enroll certificates](#exercise-1-prepare-and-enroll-certificates)
1. [Configure the RAS, NPS Server, Router, and DNS](#exercise-2-configure-the-ras-nps-Server-router-and-dns)
1. [Creating and testing a VPN User Profile](#exercise-3-creating-and-testing-a-vpn-user-profile)
1. [Create and test a VPN device tunnel](#exercise-4-create-and-test-a-vpn-device-tunnel)

## Exercise 1: Prepare and enroll certificates

### Introduction

In this exercise, you will first create groups for VPN users with User1 and User2 as members, VPN Servers with VPN$ as member, and NPS Servers with Net1$ as member. Then, you will create duplicate and configure the certificate templates for Computer, User and RAS and IAS servers to create templates for VPN users, VPN computers, VPN servers and NPS servers. You will configure PKI to issue the new templates. You will enable Autoenroll for computers and users in the domain. Finally you will verify the certificates created using Autoenroll for User1, CL1 and Net1. Moreover, you will manually enroll a certificate using the VPN server template for the machine VPN using the DNS names vpn.myetc.at, vpn and 131.107.0.1.

#### Tasks

1. [Create VPN Users, VPN Servers and NPS Server Groups]: (#task-1-create-vpn-users-vpn-servers-and-nps-server-groups)
1. [Create certificate templates](#task-2-create-certificate-templates)
1. [Configure the CA to enroll certificates](#task-3-configure-the-ca-to-enroll-certificates)
1. [Configure GPO for Autoenrollment](#task-4-configure-gpo-for-autoenrollment)
1. [Verify the user and computer certificate](#task-5-verify-the-user-and-computer-certificate)
1. [Verify the NPS server certificate](#task-6-verify-the-nps-server-certificate)
1. [Enroll and verify the VPN Server certificate](#task-7-enroll-and-verify-the-vpn-server-certificate)

### Task 1: Create VPN Users, VPN Servers and NPS Server Groups

#### Desktop Experience

Perform these steps on DC1.

1. Logon as **smart\Administrator**.
1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, in the context menu of **smart (local)**, click **New**, **Group**.
1. In the **Create Group** dialog, in **Group name**, enter **VPNUsers**.
1. Click **Members**.
1. Under **Members**, click **Add...** and add **User1** and **User2**.
1. Click **OK**.
1. In Active Directory Administrative Center, in the context menu of **smart (local)**, click **New**, **Group**.
1. In the **Create Group** dialog, in **Group name**, enter **VPNServers**.
1. Click **Members**.
1. Under **Members**, click **Add...**.
1. In the dialog **Select Users, Contacts, Computers, Service Accounts, or Groups**, click **Object Types...**.
1. In the dialog Object Types, activate the checkbox **Computers** and click **OK**.
1. In the dialog **Select Users, Contacts, Computers, Service Accounts, or Groups**, search for and add the computer **VPN**.
1. In the **Create Group** dialog, click **OK**.
1. Repeat steps 8 - 15 to create the group **NPSServers** and add the computer **Net1** to it.
1. Restart **VPN** and **Net1** to make the change in group membership effecitve. Moreover, if you are logged on anywhere with **User1** or **User2**, logoff.

#### Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Google Chrome** and navigate to **https://admincenter.smart.etc**.
1. On the page Windows Admin Center, if the server **DC1** is not listed, click **Add**. Under **Servers**, click **Add**. In **Server name**, enter **DC1** and click **Add**.
1. On the page Windows Admin Center, connect to **DC1.smart.etc**.
1. Connected to DC1.smart.etc, under **Tools**, click **Active Directory**.

    If you do not see Active Directory, install the extension from Windows Admin Center Settings.

1. In **Active Directory Domain Services**, click **Create**, **Group**.
1. In the pane **Add Group**, in **Name**, enter **VPNUsers**. Under **Group Scope**, select **Global**, and click **Create**.
1. With the group **VPNUsers** selected, click **Properties**.
1. On **Active Directory Domain Services > Group properties: VPNUsers**, click **Membership**.
1. Click **Add**.
1. In the pane **Add Group Membershíp**, in **User SamAccountname**, enter **User1** and click **Add**.
1. Repeat the previous step to add **User2**.
1. Click **Save**.
1. Click **Close**.
1. Repeat steps 6 - 14 to create groups with members accordng to the table below.

    | Name       | Members |
    |------------|---------|
    | VPNServers | VPN$    |
    | NPSServers | Net1$   |

1. Go back to the home page of **Windows Admin Center**.
1. On the page Windows Admin Center, if the server **VPN** is not listed, click **Add**. Under **Servers**, click **Add**. In **Server name**, enter **VPN** and click **Add**. If access is denied, use the credentials of **smart\Administrator**.
1. Repeat the previous step for the server **Net1**, if needed.
1. On the page Windows Admin Center, connect to **VPN.smart.etc**.
1. Connected to VPN.smart.etc, on **Overview**, click **Restart**.
1. Repeat the previous two steps for **Net1.smart.etc**. Moreover, if you are logged on anywhere with **User1** or **User2**, logoff.

#### PowerShell

Perform these steps on DC1.

1. Logon as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Create a global group **VPNUsers** and add **User1** and **User2**.

    ````powershell
    $name = 'VPNUsers'
    New-ADGroup -Name $name -GroupCategory Security -GroupScope Global
    Add-ADGroupMember -Identity $name -Members User1, User2
    ````

1. Create a global group **VPNUsers** and add **User1** and **User2**.

    ````powershell
    $name = 'VPNServers'
    New-ADGroup -Name $name -GroupCategory Security -GroupScope Global
    Add-ADGroupMember -Identity $name -Members VPN$
    ````

1. Create a global group **VPNUsers** and add **User1** and **User2**.

    ````powershell
    $name = 'NPSServers'
    New-ADGroup -Name $name -GroupCategory Security -GroupScope Global
    Add-ADGroupMember -Identity $name -Members Net1$
    ````

1. Restart **VPN** and **Net1** to make the change in group membership effective. Moreover, if you are logged on anywhere with **User1** or **User2**, logoff.

    ````powershell
    Invoke-Command -ComputerName VPN, Net1 -ScriptBlock { Restart-Computer }
    ````

### Task 2: Create certificate templates

Perform these steps on PKI.

1. Logon ans **smart\Administrator**.
1. On the Desktop, open **EnterprisePKI.msc**.
1. In EnterprisePKI, click **Certificate Templates**.
1. In Certificate Templates, in the context-menu of template **User**, click **Duplicate Template**.
1. Configure the template according to the table below, then click **OK**.

    | Tab                           | Label                                               | Value                                |
    |-------------------------------|-----------------------------------------------------|--------------------------------------|
    | **Compatibility**             | **Certification Authority**                         | Windows Server 2012 R2               |
    |                               | **Certificate recipient**                           | Windows 8.1 / Windows Server 2012 R2 |
    | **General**                   | **Template display name**                           | VPN User Authentication              |
    |                               | **Publish certificate in Active Directory**         | Deactivated                          |
    | **Request handling**          | **Allow private key to be exported**                | Deactivated                          |
    | **Cryptography** ([figure 1]) | **Provider Category**                               | Key Storage Provider                 |
    |                               | **Requests must use on of the following providers** | Activated                            |
    |                               | **Microsoft Software Key Storage Provider**         | Deactived                            |
    |                               | **Microsoft Platform Crypto Provider** *            | Activated                            |
    |                               | **Microsoft Smart Card Key Storage Provider**       | Deactived                            |
    |                               | **Request hash**                                    | SHA256                               |
    | **Subject Name**              | **Include e-mail name in subject name**             | Deactivated                          |
    |                               | **E-mail name**                                     | Deactivated                          |
    | **Security** ([figure 2])     | **Add...**                                          | VPNUsers                             |
    |                               | **Remove**                                          | Domain Users                         |
    |                               | **VPNUsers**, **Enroll** and **AutoEnroll**         | **Allow**                            |

    \* this setting requires a TPM or vTPM; if a user's device or VM does not provide this, you have to select **Microsoft Software Key Storage Provider**.

1. In Certificate Templates, in the context-menu of template **Computer**, click **Duplicate Template**.
1. Configure the template according to the table below, then click **OK**.

    | Tab                  | Label                                               | Value                                |
    |----------------------|-----------------------------------------------------|--------------------------------------|
    | **Compatibility**    | **Certification Authority**                         | Windows Server 2012 R2               |
    |                      | **Certificate recipient**                           | Windows 8.1 / Windows Server 2012 R2 |
    | **General**          | **Template display name**                           | VPN Computer Authentication          |
    |                      | **Publish certificate in Active Directory**         | Deactivated                          |
    | **Request handling** | **Allow private key to be exported**                | Deactivated                          |
    | **Cryptography**     | **Provider Category**                               | Key Storage Provider                 |
    |                      | **Requests must use on of the following providers** | Activated                            |
    |                      | **Microsoft Software Key Storage Provider**         | Deactived                            |
    |                      | **Microsoft Platform Crypto Provider**              | Activated                            |
    |                      | **Microsoft Smart Card Key Storage Provider**       | Deactived                            |
    |                      | **Request hash**                                    | SHA256                               |
    | **Security**         | **Domain Computers**: **Autoenroll**, **Allow**     | Activated                            |

1. In Certificate Templates, in the context-menu of template **RAS and IAS Server**, click **Duplicate Template**.
1. Configure the template according to the table below, then click **OK**.

    | Tab                  | Label                                 | Value                                   |
    |----------------------|---------------------------------------|-----------------------------------------|
    | **General**          | **Template display name**             | VPN Server Authentication               |
    | **Subject Name**     | **Supply in the request**             | Activated                               |
    | **Extensions**       | **Application Policies** ([figure 3]) | **Add...** IP security IKE intermediate |
    | **Security**         | **Add...**                            | VPNUsers                                |
    |                      | **Remove**                            | Domain Users                            |
    |                      | **VPNServers**, **Enroll**            | **Allow**                               |

1. In Certificate Templates, in the context-menu of template **RAS and IAS Server**, click **Duplicate Template**.
1. Configure the template according to the table below, then click **OK**.

    | Tab                  | Label                                         | Value                                   |
    |----------------------|-----------------------------------------------|-----------------------------------------|
    | **General**          | **Template display name**                     | NPS Server Authentication               |
    | **Security**         | **Add...**                                    | VPNUsers                                |
    |                      | **Remove**                                    | Domain Users                            |
    |                      | **NPSServers**, **Enroll** and **Autoenroll** | **Allow**                               |

1. Leave the EnterprisePKI console open and proceed with the next task.

### Task 3: Configure the CA to enroll certificates

#### Desktop experience

Perform these steps on PKI.

1. In the EnterprisePKI console navigate to **Certification Authority (Local)**, **SmartRootCA**, **Certificate Templates**.
1. In the context menu of **Certificate Templates**, click **New**, **Certificate Template to issue**.
1. In the dialog **Enable Certificate Templates** select the templates which you created in the previous task and click **OK**.
    * VPN User Authentication
    * VPN Computer Authentication
    * VPN Server Authentication
    * NPS Server Authentication

#### PowerShell

Perform these steps on PKI.

1. Add the certificate templates which you created in the previous task to the CA.

    ````powershell
    <# 
        The name parameter requires the template name. In the previous task you
        configured the template display name only. The template name was derived
        from the template display name by removing all spaces. Therefore, the
        names here are the names from the previous task without spaces.
    #>
    Add-CATemplate -Name VPNComputerAuthentication -Force
    Add-CATemplate -Name VPNComputerAuthentication -Force
    Add-CATemplate -Name VPNServerAuthentication -Force
    Add-CATemplate -Name NPSServerAuthentication -Force
    ````

### Task 4: Configure GPO for Autoenrollment

Perform these steps on DC1.

1. Open **Group Policy Management Console**.
1. In Group Policy Management Console, in the domain **smart.etc**, create a new Group Policy Object named **Autoenrollment** and link it to the domain.
1. In the context menu of **Autoenrollment**, click **Edit...**.

1. In **Group Policy Management Editor**, navigate to **Computer Configuration**, **Policies**, **Windows Settings**, **Security Settings**, **Public Key Policies**.
1. Open the setting **Certificate Services Client - Auto-Enrollment** policy.
1. In the dialog Certificate Services Client - Auto-Enrollment Properties, for **Configuration Model**, select **Enabled**. Activate **Renew expired certificates, update pending certificates, and remove revoked certificates** and **Update certificates that use certficate templates**. Click **OK**
1. Back in Group Policy Management Editor, navigate to **User Configuration**, **Policies**, **Windows Settings**, **Security Settings**, **Public Key Policies**.
1. Repeat steps 5 and 6.
1. Close **Group Policy Management Editor**.

### Task 5: Verify the user and computer certificate

#### Desktop experience

Perform these steps on CL1.

1. Sign in as **smart\User1**.
1. On the Start menu, type **certmgr.msc**, and press Enter.
1. In certmgr , navigate to **Personal**, **Certificates**.
1. Open the certificate **Issued To** **User1**.
1. In the dialog **Certificate**, on the tab **General**, confirm that the date listed under **Valid from** is today’s date. Click **OK**.
1. Close **certmgr**.
1. On the Start menu, type **certlm.msc**, and press Enter.
1. In the certlm, navigate to **Personal**, **Certificates**.
1. Open the certificate **Issued To** **CL1.smart.etc**.
1. In the dialog **Certificate**, on the tab **General**, confirm that the date listed under **Valid from** is today’s date. Click **OK**.
1. Close **certlm**.

#### PowerShell

Perform these steps on CL1.

1. Sign in as **smart\User1**.
1. Run **Windows PowerShell**.
1. List the user's personal certificates.

    ````powershell
    Get-ChildItem Cert:\CurrentUser\My | Format-List DnsNameList, NotBefore
    ````

    **DnsNameList** should be **{User1}**. **NotBefore** should show date and time from just minutes before.

1. List the computer's personal certificate

    ````powershell
    Get-ChildItem Cert:\LocalMachine\My | Format-List DnsNameList, NotBefore
    ````

    **DnsNameList** should be **{CL1.smart.etc}**. **NotBefore** should show date and time from just minutes before.

### Task 6: Verify the NPS server certificate

#### Desktop experience

Perform these steps on Net1.

1. Sign in as **smart\Administrator**.
1. On the Start menu, type **certlm.msc**, and press Enter.
1. In the certlm, navigate to **Personal**, **Certificates**.
1. Open the certificate **Issued To** **net1.smart.etc**.
1. In the dialog **Certificate**, on the tab **General**, confirm that the date listed under **Valid from** is today’s date. Click **OK**.
1. Close **certlm**.

#### PowerShell

Perform these steps on Net1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell**.
1. List the computer's personal certificate

    ````powershell
    Get-ChildItem Cert:\LocalMachine\My | Format-List DnsNameList, NotBefore
    ````

    **DnsNameList** should be **{net1.smart.etc}**. **NotBefore** should show date and time from just minutes before.

### Task 7: Enroll and verify the VPN Server certificate

#### Desktop experience

Perform these steps on VPN.

1. Sign in as **smart\Administrator**.
1. On the start menu type **certlm.msc** and press Enter.
1. In certlm, in the context-menu of  **Personal**, click **All Tasks**, **Request New Certificate**.
1. In the wizard **Certificate Enrollment**, on page **Before You Begin**, click **Next**.
1. On page **Select Certificate Enrollment Policy**, click **Next**.
1. On page **Request Certificates**, activate the check box **VPN Server Authentication**. Click the link **More information is required to enroll for this certificate. Click here to configure settings.**
1. In **Certificate Properties**, on tab **Subject**, under **Subject Name**, in the dropdown **Type**, select **Common Name**. In **Value**, enter **vpn.myetc.at** and click **Add >**.
1. Under **Alternative name**, in the dropdown **Type**, select **DNS**. In **Value**, enter **vpn.myetc.at** and click **Add >**.
1. Repeat the previous step with the values **vpn** and **131.107.0.1**.
1. Click **OK**.
1. Back on page Request Certificates, click **Enroll**.
1. On page **Certificate Installation Results**, click **Finish**.
1. In certlm, navigate to **Personal**, **Certificates**.
1. Open the certificate **Issued To** **vpn.myetc.at**.
1. In the dialog **Certificate**, on the tab **General**, confirm that the date listed under **Valid from** is today’s date. On tab **Details**, select **Enhanced Key Usage** and verify that **Server Authentication** and **IP security IKE intermediate** are in the list below. Click **OK**.
1. Close **certlm**.

#### PowerShell

Perform these steps on VPN.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Request a certificate for dnsname **vpn.myetc.at**, **vpn** and **131.107.0.1** using the template **VPNServerAuthentication**.

   ````powershell
   $dnsName = 'vpn.myetc.at', 'vpn', '131.107.0.1'
   $subjectName = "CN=$($dnsName[0])"
   $template = 'VPNServerAuthentication'
   $result = Get-Certificate `
       -Template $template `
       -SubjectName $subjectName `
       -DnsName $dnsName `
       -CertStoreLocation Cert:\LocalMachine\My   
   ````

1. List the computer's personal certificate

    ````powershell
    Get-ChildItem Cert:\LocalMachine\My |
    Format-List DnsNameList, NotBefore, EnhancedKeyUsageList
    ````

    **DnsNameList** should be **{vpn.myetc.at, vpn, 131.107.0.1}**. **NotBefore** should show date and time from just minutes before. **EnhancedKeyusageList** should be **{Server Authentication (1.3.6.1.5.5.7.3.1), IP security IKE intermediate (1.3.6.1.5.5.8.2.2), Client Authentication (1.3.6.1.5.5.7.3.2)}**.

## Exercise 2: Configure the RAS, NPS Server, Router, and DNS

### Introduction

In this exercise, you will install the Network Policy and Access Services role on NET1. You will configure it for VPN connections, add vpn.smart.etc as RADIUS client with certificate-based authenticaton. You will need to configure a firewall rule to allow inbound traffic on UDP port 1812. Then, you will register the NPS server in Active Directory. On machine VPN, you will install the Remote Access role for for DirectAccess and VPN (RAS). Then, you will configure it for VPN only and as RADIUS client for NET1. You will configure it for certificate based authentication to accept certificates from SmartRootCA only. Finally, you will add a DNS host record to server ISP pointing vpn.myetc.at to 131.107.0.1.

#### Tasks

1. [Install and configure the NPS Server](#task-1-install-and-configure-the-nps-server)
1. [Configure the Firewall](#task-2-configure-the-firewall)
1. [Register the NPS Server in Active Directory](#task-3-register-the-nps-server-in-active-directory)
1. [Install Remote Access as a RAS Gateway VPN Server](#task-4-install-remote-access-as-a-ras-gateway-vpn-server)
1. [Configure external DNS](#task-5-configure-external-dns)

### Task 1: Install and configure the NPS Server

Perform these steps on NET1.

1. Sign in as **smart\administrator**.
1. Open **Server Manager**.
1. In Server Manager, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, proceed to page **Select server roles**.
1. On page Select server roles, activate **Network Policy and Access Services**.
1. Proceed through the Add Role and Features Wizard accepting the defaults and installing the role.
1. When installation has finished, click **Close**.
1. Back in Server Manager, click **Tools**, **Network Policy Server**.
1. In network Policy Server, select **NPS (Local)**.
1. In the main pane, in the dropdown under **Standard Configuration**, ensure that **RADIUS server for Dial-Up or VPN Connections** is selected.
1. Click the link **Configure VPN or Dial-Up**.
1. In the wizard **Configure VPN or Dial-up**, on page **Select Dial-up or Virtual Private Network Connections Type**, click **Virtual Private Network (VPN) Connections** and click **Next**.
1. On page **Specify Dial-Up or VPN Server**, under **RADIUS clients**, click **Add...**.
1. In **New RADIUS Client**, ensure **Enable this RADIUS client** is actvated.
1. In **Friendly name** and **Address (IP or DNS)**, type **vpn.smart.etc**.
1. Under **Shared Secret**, click the radio button **Generate**, then click the button **Generate**.

    *Important*: Take note of the generated shared secret, e. g. by copying into Notepad on the host server.

1. Click on **OK**.

1. Back on page Specify Dial-Up or VPN Server, click **Next**.
1. On page **Configure Authentication Methods**, activate the checkbox **Extensible Authentication Protocol** and clear the checkbox **Microsoft Encrypted Authentication version 2 (MS-CHAPv2)**. In the dropdown **Type**, select **Microsoft: Smart Card or other certificate** and click **Configure**.
1. In **Smart Card or other Certificate Properties**, in the dropdown **Certificate issued to**, ensure that NET1.smart.etc is selected. Verify, that **Issuer** is **SmartRootCA** and **Expiration date** is a date in the future (probably one year from today). Click on **OK**.
1. Back on page Configure Authentication Methods, click **Next**.
1. On page **Specify User Groups**,  add the group **VPNUsers** and click **Next**.
1. On page **Specify IP Filters**, do not make any changes and click **Next**.
1. On page **Specify Encryption Settings**, deactivate **Basic encryption (MPPE 40-bit)** and **Strong encryption (MPPE 56-bit)** and click **Next**.
1. On page **Specify a Realm Name**, click **Next**.
1. On page **Completing New Dial-up or Virtual Private Network Connections and RADIUS clients**, click on **Finish**.
1. Leave **Network Policy Server** open for the next task.

### Task 2: Configure the Firewall

*Note*: Despite of an already activated rule for UDP traffic on port 1812, you have to create another for these packets, because the existing rule does not work correctly

#### Desktop experience

Perform these steps on NET1.

1. Switch to **Server Manager**.
1. In Server Manager, click **Tools**, **Windows Defender Firewall with Advanced Security**.
1. In Wndows Defender Firewall with Advanced Security, click **Inbound Rules**.
1. In the context-menu of **Inbound Rules**, click **New Rule...**
1. In the **New Inbound Rule Wizard**, on page **Rule Type**, click **Port** and **Next >**.
1. On page **Protocol and Ports**, click **UDP**.
1. Click **Specific local ports**, enter **1812**, and click **Next >**.
1. On page **Action**, ensure **Allow the connection** is selected and click **Next >**.
1. On page **Profile**, deactivate **Private** and **Public**, and click **Next >**.
1. On page **Name**, in **Name**, enter **NPS (RADIUS Authenticaton UDP in)** and click **Finish**.

#### Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Google Chrome** and navigate to **https://admincenter.smart.etc**.
1. On the page Windows Admin Center, if the server **NET1** is not listed, click **Add**. Under **Servers**, click **Add**. In **Server name**, enter **NET1** and click **Add**.
1. On the page Windows Admin Center, connect to **NET1.smart.etc**.
1. Connected to NET1.smart.etc, under **Tools**, click **Firewall**.
1. In Firewall, click **Incoming rules**.
1. Click **New**.
1. In the **New Rule** pane, provide the values from the table below and click **Create**.

    | Label                    | Value                             |
    |--------------------------|-----------------------------------|
    | **Name**                 | NPS (RADIUS Authenticaton UDP in) |
    | **Direction**            | Incoming                          |
    | **Action**               | Allowed                           |
    | **Enable Firewall Rule** | Yes                               |
    | **Protocol**             | UDP                               |
    | **Local port**           | 1812                              |
    | **Profiles**             | Domain                            |

#### PowerShell

Perform these steps on NET1.

1. Run **Windows PowerShell** as Administrator.
1. Add a firewall rule with the name **NPSRadiusAuthenticationUDPIn**, display name **NPS (RADIUS Authenticaton - UDP-in)** allowing inbound traffic on **UDP** port **1812** for the **Domain** profile.

    ````powershell
    New-NetFirewallRule `
        -Direction Inbound `
        -Protocol UDP `
        -LocalPort 1812 `
        -Action Allow `
        -Profile Domain `
        -Name 'NPSRadiusAuthenticationUDPIn' `
        -DisplayName "NPS (Radius Authenticaton - UDP-in)"
    ````

### Task 3: Register the NPS Server in Active Directory

#### Desktop experience

Perform these steps on NET1.

1. In **Network Policy Server**, in the context-menu of **NPS (Local)** click **Register server in Active Directory**.
1. In the dialog Network Policy Server, click on **OK**.
1. In the dialog Network Policy Server, click on **OK** again.

#### Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Google Chrome** and navigate to **https://admincenter.smart.etc**.
1. On the page Windows Admin Center, if the server **DC1** is not listed, click **Add**. Under **Servers**, click **Add**. In **Server name**, enter **DC1** and click **Add**.
1. On the page Windows Admin Center, connect to **DC1.smart.etc**.
1. Connected to DC1.smart.etc, under **Tools**, click **Active Directory**.

    If you do not see Active Directory, install the extension from Windows Admin Center Settings.

1. In **Active Directory Domain Services**, search and select the group **RAS and IAS Servers**.
1. With the group RAS and IAS Servers selected, click **Properties**.
1. On **Active Directory Domain Services > Group properties: VPNUsers**, click **Membership**.
1. Click **Add**.
1. In the pane **Add Group Membershíp**, in **User SamAccountname**, enter **NET1$** and click **Add**.
1. Click **Save**.
1. Click **Close**.

#### PowerShell

Perform these steps on DC1.

1. Sign in as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Add the computer account **NET1** to the group **RAS and IAS Servers**.

    ````powershell
    Add-ADGroupMember -Identity 'RAS and IAS Servers' -Members NET1$
    ````

### Task 4: Install Remote Access as a RAS Gateway VPN Server

#### Desktop experience

Perform these steps on VPN.

1. Sign on as **smart\administrator**.
1. Open **Server Manager**.
1. In Server Manager, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, proceed to page **Select server roles**.
1. On page Select server roles, activate **Remote Access**.
1. Proceed to page **Role Services**.
1. On page **Role Services**, activate **DirectAccess and VPN (RAS)**. In the dialog appearing, click **Add Features**.
1. Proceed through the Add Role and Features Wizard accepting the defaults and installing the role.
1. When installation has finished, click **Close**.
1. In Server Manager, click the notification flag with the warning triangle and click the link **Open the Getting Started Wizard**.
1. In **Configure Remote Access**, click **Deploy VPN only**.
1. In **Routing and Remote Access**, in the context-menu of **VPN (local)**, click **Configure and Enable Routing and Remote Access**.
1. In the **Routing and Remote Access Server Setup Wizard**, on page **Welcome to the Routing and Remote Access Server Setup Wizard**, click **Next >**.
1. On page **Configuration**, click **Custom Configuration** and click **Next >**.
1. On page **Custom Configuration**, click **VPN access** and click **Next >**.
1. On page **Completing the Routing and Remote Access Server Setup Wizard**, click  **Finish**.
1. In **Routing and Remote Access**, click on **OK**.
1. In **Routing and Remote Access**, click on **Start service**.
1. Back in Routing and Remote Access, in the context-menu of **VPN (local)**, click **Properties**.
1. In VPN (local) Properties, click the tab **Security**.
1. On the tab Security, under **Authentication provider**, select **RADIUS Authentication** and click **Configure...**.
1. In **RADIUS Authentication**, click **Add...**.
1. In **Add RADIUS Server**, in **Server name**, type **net1.smart.etc**. Next to **Shared secret**, click **Change...**.
1. In **Change Secret**, in **New secret** and **Confirm new secret**, enter the shared secret you noted in the previous task and click **OK**.
1. Back in Add RADIUS Server, click **OK**.
1. Back in RADIUS Authentication, click **OK**.
1. Back in **VPN (local) Properties**, click tab **IPv4**.
1. On tab IPv4, under **IPv4 address assignment**, click **Static address pool** and click **Add...**.
1. In dialog **New IPv4 Address range**, in **Start IP address**, type **10.1.3.100**, in **End IP address**, type **10.1.3.200**, and click **OK**.
1. Back in **VPN (local) Properties**, click **OK**.
1. Run **Windows Powershell** as Administrator
1. Configure Certificate based authentication.

    ````powershell
    $rootCertificate = 
        Get-ChildItem -Path 'Cert:\LocalMachine\Root\' |
        Where-Object { 
            $PSItem.Subject -eq 'CN=SmartRootCA, DC=smart, DC=etc' 
        }

    Set-VpnAuthProtocol `
        -UserAuthProtocolAccepted Certificate, EAP `
        -RootCertificateNameToAccept $rootCertificate
    Restart-Service RemoteAccess
    ````

#### PowerShell

Perform these steps on VPN.

1. Sign on as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Install the feature DirectAccess-VPN including the management tools.

    ````powershell
    Install-WindowsFeature -Name DirectAccess-VPN -IncludeManagementTools
    ````

1. Install Remote Access with VPN type **VPN** only, RADIUS server **net1.smart.etc**, a random shared secret the the IPv4 address range of 10.1.3.100 to 10.1.3.200.

    ````powershell
    $radiusServer = 'net1.smart.etc'
    $sharedSecret = '' # provide the shared secret you noted in the previous task
    $iPAddressRange = '10.1.3.100', '10.1.3.200'
    Install-RemoteAccess `
        -VpnType Vpn `
        -RadiusServer $radiusServer `
        -SharedSecret $sharedSecret `
        -IPAddressRange $iPAddressRange
    ````

1. Set the VPN authentication protocol to Certificate and EAP and to accept certificates from **SmartRootCA** only.

    ````powershell
    $rootCertificate = 
        Get-ChildItem -Path 'Cert:\LocalMachine\Root\' |
        Where-Object { 
            $PSItem.Subject -eq 'CN=SmartRootCA, DC=smart, DC=etc' 
        }

    Set-VpnAuthProtocol `
        -UserAuthProtocolAccepted Certificate, EAP `
        -RootCertificateNameToAccept $rootCertificate
    Restart-Service RemoteAccess
    ````

### Task 4: Create a static route

*Note:* You must create a static route to be able to send packets back to a connected VPN client. 10.1.1.58 is the IP address of server VPN in the network Datacenter1.

#### Desktop experience

Perform these steps on Router.

1. Sign in as **smart\administrator**.
1. Open **Routing and Remote Access**.
1. In Routing and Remote Acess, navigate to **ROUTER (local)**, **IPv4**, **Static Routes**.
1. In the context-menu of **Static Routes**, click **New Static Route...**.
1. In **IPv4 Static Route**, provide values from the table below and click **OK**.

    | Label            | Value         |
    |------------------|---------------|
    | **Interface**    | Datacenter1   |
    | **Destination**  | 10.1.3.0      |
    | **Network mask** | 255.255.255.0 |
    | **Gateway**      | 10.1.1.58     |
    | **Metric**       | 256           |

#### PowerShell

Perform these steps on Router.

1. Sign in as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. On interface **Datacenter1** add a new route for the destination prefix of **10.1.3.0/24** with **10.1.1.58** as next hop.

    ````powershell
    New-NetRoute `
        -AddressFamily IPv4 `
        -InterfaceAlias Datacenter1 `
        -DestinationPrefix '10.1.3.0/24' `
        -NextHop 10.1.1.58 `
        -RouteMetric 256
    ````

### Task 5: Configure external DNS

#### Desktop experience

Perform these tasks on ISP.

1. Sign in as **administrator**.

    This is the local administrator since the VM is not domain-joined.

1. In Start menu, from **Windows Administrative Tools**, open **DNS**.
1. In **DNS Manager**, navigate to **Forward Lookup Zones**, **myetc.at**
1. In the context-menu of the forward lookup zone **myetc.at**, click **New Host (A or AAAA)...**.
1. In dialog **New Host**, in **Name**, enter **vpn**. In **IP address**, enter **131.107.0.1**. Clear the checkbox **Create associated pointer (PTR) record**. Click on **Add Host**.
1. In the message box **The host record vpn.myetc.at was successfully created.**, click **OK**.
1. Back in New Host, click **Done**.

#### PowerShell

1. Sign in as **administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Add an A record to zone **myetc.at** with the name **vpn** and the IPv4 address of **131.107.0.1**.

    ````powershell
    Add-DnsServerResourceRecordA `
        -ZoneName myetc.at `
        -Name vpn `
        -IPv4Address 131.107.0.1
    ````

## Exercise 3: Creating and testing a VPN User Profile

### Introduction

In this exercise you will first manually create a VPN connection on the client and test it. Then, you will use the script MakeProfile.ps1 to create a VPN user profile and configuration script. You will execute the configuration script to create an AlwaysOn VPN connection. Finally, you will test AlwaysOn functionality.

[Documentation and Download for makeprofile.ps1](https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/always-on-vpn/deploy/vpn-deploy-client-vpn-connections#makeprofileps1-full-script)

#### Tasks

1. [Prepare the client to create a template VPN Profile](#task-1-prepare-the-client-to-create-a-template-vpn-profile)
1. [Configure template VPN Profile](#task-2-configure-template-vpn-profile)
1. [Connect the client to the Internet](#task-3-connect-the-client-to-the-internet)
1. [Test the VPN connecton](#task-4-test-the-vpn-connection)
1. [Create a VPN user profile and configuration script, and test the connection](#task-5-create-a-vpn-user-profile-and-configuration-script-and-test-the-connection)
1. [Test AlwaysOn functionality](#task-6-test-alwayson-functionality)
1. [Remove the AlwaysOn VPN connection](#task-7-remove-the-alwayson-vpn-connection)

### Task 1: Prepare the client to create a template VPN Profile

#### Desktop experience

Perform these steps on CL1.

1. Sign in as **smart\Administrator**.
1. Open **Computer Management**.
1. In Computer Management, navigate to **Computer Management (Local)**, **System Tools**, **Local Users and Groups**, **Groups**.
1. Open the group **Administrators**.
1. In **Administrators Properties**, click **Add...**

    *Note:* You must add User1 to the local Adminstrators group, in order to later execute a script, which will create a VPN user profile and configuraton script.

1. In **Select Users, Computer, Service Accounts, or Groups**, search for **User1** and click **OK**.
1. Back in Administrators Properties, click **OK**.
1. Open **File Explorer**.
1. Copy the folder **L:\AlwaysOnVPN** to **C:\\**.
1. Sign out.

#### PowerShell

Perform these steps on CL1.

1. Sign in as **smart\Administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Add **smart\User1** to the local **Administrators** group.

    ````powershell
    Add-LocalGroupMember -Group Administrators -Member smart\User1
    ````

1. Copy the directory **L:\AlwaysOnVPN** to **C:\\**.

    ````powershell
    Copy-Item L:\AlwaysOnVPN C:\ -Recurse
    ````

### Task 2: Configure template VPN Profile

Perform these steps on CL1.

1. Sign in as **smart\user1**.
1. Open **VPN Settings**.
1. In **Settings**, on page **VPN**, click **Add a VPN connection**.
1. In **Add a VPN connection**, provide the values from the table below and click **Save**.

    | Label                      | Value              |
    |----------------------------|--------------------|
    | **VPN provider**           | Windows (built-in) |
    | **Connection name**        | smartAOVTemplate   |
    | **Server name or address** | vpn.myetc.at       |
    | **VPN type**               | IKEv2              |
    | **Type of sign-in info**   | Certificate        |

1. Back on page VPN, in the section **Related Settings**, click **Change adapter options**.
1. In **Network Connections**, in the context-menu of **smartAOVTemplate**, click **Properties**.
1. In smartAOVTemplate Properties, click the tab **Security**.
1. On tab Security, under **Authentication**, click **Properties**.
1. In **Smart Card or other Certificate Properties**, under **Connect to these servers**, type **net1.smart.etc**. Under **Trusted Root Certificatation Authorities** activate **SmartRootCA**. Activate **Don't prompt user to authorize new servers or trusted certification authorities** and click **OK**.
1. Back on smartAOVTemplate Properties, click on **OK**.
1. Leave **Settings** with the page **VPN** open, for an upcoming task.

### Task 3: Connect the client to the Internet

#### Desktop experience

Perform these steps on the host computer or the hosting cloud service.

1. Open **Hyper V Manager**.
1. In the context menu of virtual machine **CL1**, click **Settings...**.
1. In **Settings for CL1**, click **Datacenter1**.
1. Under **Network Adapter**, for **Virtual switch**, select **Simulated-Internet**.
1. Click **OK**.

#### Windows PowerShell

Perform these steps on the host computer or the hosting cloud service.

1. Run **Windows PowerShell** as Administrator.
1. Connect the network adapter **Datacenter1** of **CL1** to the switch **Simulated-Internet**.

    ````powershell
    Connect-VMNetworkAdapter `
        -VMName CL1 `
        -Name Datacenter1 `
        -SwitchName Simulated-Internet
    ````

### Task 4: Test the VPN connection

Perform these steps on CL1.

1. In **Settings** on page **VPN**, click **smartAOVTemplate**.
1. Click **Connect**.

    The connection should be established successfully to proceed with the next task.

### Task 5: Create a VPN user profile and configuration script, and test the connection

1. Run **Windows PowerShell** as Administrator.
1. Execute the script **C:\AlwaysOnVPN\MakeProfile.ps1**.
    The script creates two files on the Desktop. The xml-file contains configuration for a new VPN connection, including EAP-Authentication settings and the settings for AlwaysOn. The ps1-file will create a VPN connection on your Windows 10 client.
1. Execute **VPN_Profile.ps1** on the desktop.

    ````powershell
    <#
        To reliably get the desktop folder path, we execute a static method
        in .NET Framework. GetFolderPath is a statc method of the class
        System.Environment. Use the syntax with brackets and the double-colon
        to call a static method.
        
        Moreover, Environment.Specialfolder is an enum in the System class. To
        use enums with a dot in the name, replace the dot with a plus sign.
        Single values of enums, like Desktop, are addressed with a similar
        syntax like static methods, brackets and double-colon.
    #>
    $desktopPath = [System.Environment]::GetFolderPath(
        [System.Environment+SpecialFolder]::Desktop
    )
    
    ````

    In **Settings** on page **VPN**. You should see a new VPN connection **smartAlwaysOnVPN**.

1. Click on **smartAlwaysOnVPN**.
1. Ensure, **Connect automatically** is activated and click **Connect**.

    Below smartAlwaysOnVPN, you should see **Connected**.

### Task 6: Test AlwaysOn functionality

#### Desktop experience

Perform these steps on the host computer or the hosting cloud service.

1. Open **Hyper V Manager**.
1. In the context menu of virtual machine **CL1**, click **Settings...**.
1. Place the windows **Settings for CL1** and **CL1 - Virtual Machine Connection** side by side, so you can see the content in both. In **CL1 -Virtual Machine Connection**, you should still see the **VPN** page of the **Settings** app. The status of **smartAlwaysOnVPN** should still show **Connected**.
1. In **Settings for CL1**, click **Datacenter1**.
1. Under **Network Adapter**, for **Virtual switch**, select **Not connected** and click **Apply**.

    Obviously, the smartAlwayOnVPN is not connected anymore, but the checkbox **Connect automatically** should still be activated.

1. In Settings for CL1, for **Virtual switch**, select **Semulated-Internet** and click **Apply**.

    smartAlwayOnVPN will connect again and show **Connected**.

1. Under **Network Adapter**, for **Virtual switch**, select **Datacenter1** and click **Apply**.

#### PowerShell

Perform these steps on the host computer or the hosting cloud service.

1. Run **Windows PowerShell** as Administrator.
1. Place the windows **Settings for CL1** and **Windows PowerShell** side by side, so you can see the content in both. In **CL1 -Virtual Machine Connection**, you should still see the **VPN** page of the **Settings** app. The status of **smartAlwaysOnVPN** should still show **Connected**.

1. Disconnect the network adapter **Datacenter1** of **CL1**.

    ````powershell
    Disconnect-VMNetworkAdapter -VMName CL1 -Name Datacenter1 `
    ````

    Obviously, the smartAlwayOnVPN is not connected anymore, but the checkbox **Connect automatically** should still be activated.

1. Connect the network adapter **Datacenter1** of **CL1** to the virtual switch **Simulated-Internet**.

    ````powershell
    Connect-VMNetworkAdapter `
        -VMName CL1 `
        -Name Datacenter1 `
        -SwitchName Simulated-Internet
    ````

    smartAlwayOnVPN will connect again and show **Connected**.

1. Connect the network adapter **Datacenter1** of **CL1** to the virtual switch **Datacenter1**.

    ````powershell
    Connect-VMNetworkAdapter `
        -VMName CL1 `
        -Name Datacenter1 `
        -SwitchName Datacenter1
    ````

### Task 7: Remove the AlwaysOn VPN connection

Perform these steps on CL1.

1. On the **VPN** page of **Settings**, if **smartAlwayOnVPN** is connected, click on **Disconnect**.
1. Unter **smartAlwaysOnVPN**, click **Remove**.

## Exercise 4: Create and test a VPN device tunnel

### Introduction

In this exercise, you will use a PowerShell script to create a VPN device tunnel. You will test and verify the device tunnel, by signing in as a new domain user, never signed in to the client before, while physically connected to the internet.

[Documentation for the XML file and the script used in this exercise](https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/vpn-device-tunnel-config#configure-the-vpn-device-tunnel)

#### Tasks

1. [Create a VPN device tunnel](#task-1-create-a-vpn-device-tunnel)
1. [Test the device tunnel](#task-2-test-the-device-tunnel)
1. [Verify the device tunnel](#task-3-verify-the-device-tunnel)
1. [Connect the client to the corporate network](#task-4-connect-the-client-to-the-corporate-network)

### Task 1: Create a VPN device tunnel

Perform these steps on CL1.

1. Run **Windows PowerShell** as Administrator.
1. Run a Windows PowerShell in the context of **SYSTEM**.

    ````shell
    PsExec64 -i -s powershell.exe
    ````

1. Accept the license agreement from Sysinternals.
1. Create a VPN device tunnel.

    ````powershell
    Set-Location c:\AlwaysOnVPN
    .\VPNProfile_Device.ps1 -ProfileName DeviceTunnel -xmlFilePath .\VPNProfile_Device.xml
    exit
    ````

1. Back in **Windows PowerShell** run as Administrator (blue background), retrieve the list of VPN connections for all users.

    ````powershell
    Get-VpnConnection -AllUserConnection
    ````

    The device tunnel should appear like this. However, the Guid will be different.

    ````shell
    Name                  : DeviceTunnel
    ServerAddress         : vpn.myetc.at
    AllUserConnection     : True
    Guid                  : {A53BDE40-66CD-46AA-AACE-39DCE70466EF}
    TunnelType            : Ikev2
    AuthenticationMethod  : {MachineCertificate}
    EncryptionLevel       : Required
    L2tpIPsecAuth         :
    UseWinlogonCredential : False
    EapConfigXmlStream    :
    ConnectionStatus      : Disconnected
    RememberCredential    : False
    SplitTunneling        : True
    DnsSuffix             : smart.etc
    IdleDisconnectSeconds : 0
    ````

1. Open **Network connectons**.

    ````powershell
    ncpa.cpl
    ````

    You should see a new VPN connection called **DeviceTunnel**.

### Task 2: Test the device tunnel

#### Desktop experience

Perform these steps on the host computer or the hosting cloud service.

1. Open **Hyper V Manager**.
1. In the context menu of virtual machine **CL1**, click **Settings...**.
1. Place the windows **Settings for CL1** and **CL1 - Virtual Machine Connection** side by side, so you can see the content in both. In **CL1 -Virtual Machine Connection**, you should still see the **Network Connections** and the status of **DeviceTunnel**.
1. In **Settings for CL1**, click **Datacenter1**.
1. Under **Network Adapter**, for **Virtual switch**, select **Simulated-Interrnet** and click **Apply**.

    DeviceTunnel will connect and the icon will become colored to show the connected status.

#### PowerShell

Perform these steps on the host computer or the hosting cloud service.

1. Run **Windows PowerShell** as Administrator.
1. Place the windows **Settings for CL1** and **Windows PowerShell** side by side, so you can see the content in both. In **CL1 -Virtual Machine Connection**, you should still see the **Network Connections** and the status of **DeviceTunnel**.
1. Connect the network adapter **Datacenter1** of **CL1** to the virtual switch **Simulated-Internet**.

    ````powershell
    Connect-VMNetworkAdapter `
        -VMName CL1 `
        -Name Datacenter1 `
        -SwitchName Simulated-Internet
    ````

    DeviceTunnel will connect and the icon will become colored to show the connected status.

### Task 3: Verify the device tunnel

#### Desktop experience

Perform these steps on CL1.

1. Restart the computer.
1. Wait for a few seconds and sign in as **smart\user3**.

    This user has never logged on to CL1. Therefore, no credentials are cached. Sign in should be successful because of the established device tunnel.

1. Open **File Explorer**.
1. Verify that drive **L:\\** is connected and its content can be listed.

#### PowerShell

Perform these steps on CL1.

1. In **Windows PowerShell**, restart the computer.

    ````powershell
    Restart-Computer
    ````

1. Wait for a few seconds and sign in as **smart\user3**.

    This user has never logged on to CL1. Therefore, no credentials are cached. Sign in should be successful because of the established device tunnel.

1. Open **Windows PowerShell**.
1. Verify that drive **L:\\** is connected and its content can be listed.

    ````powershell
    Get-ChildItem L:\
    ````

### Task 4: Connect the client to the corporate network

#### Desktop experience

Perform these steps on the host computer or the hosting cloud service.

1. In **Settings for CL1**, click **Datacenter1**.
1. Under **Network Adapter**, for **Virtual switch**, select **Datacenter1** and click **OK**.

#### PowerShell

1. Connect the network adapter **Datacenter1** of **CL1** to the virtual switch **Datacenter1**.

    ````powershell
    Connect-VMNetworkAdapter `
        -VMName CL1 `
        -Name Datacenter1 `
        -SwitchName Datacenter1
    ````

[figure 1]: images/certificate-template-cryptography.png
[figure 2]: images/certificate-template-security-vpnusers.png
[figure 3]: images/certificate-template-application-policies-extension.png
[figure 4]: images/certificate-enroll-vpn-server-authentication.png
[figure 5]: images/certificate-enroll-properties-vpn.png