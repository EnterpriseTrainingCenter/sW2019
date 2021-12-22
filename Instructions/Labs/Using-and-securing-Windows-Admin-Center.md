# Lab: Using and securing Windows Admin Center

## Required VMs

* DC1
* DHCP
* Router
* SRV2
* PKI
* CL1

## Exercises

1. [Using Windows Admin Center](#exercise-1-using-windows-admin-center)
1. [Securing Windows Admin Center](#exercise-2-securing-windows-admin-center)

## Exercise 1: Using Windows Admin Center

### Introduction

In this exercise, you will set the default language of Windows Admin Center to English and install the Active Directory extension.  Then, you manually add connections to DC1 and DHCP. Next, you will import connections for HV1 and HV2. Moreover, you will examine how to administer DC1 using Windows Admin Center. Especially, you will try to restart the DNS Server service, retrieve network adapters and their IP settings, filter the application event log for errors and warning, examine storage, and the Windows Update settings.

#### Tasks

1. [Configure settings in Windows Admin Center](#task-1-configure-settings-in-windows-admin-center)
1. [Connect to Computers](#task-2-connect-to-computers)
1. [Import Windows Admin Center Connections](#task-3-import-windows-admin-center-connections)
1. [Use Windows Admin Center Tools](#task-4-use-windows-admin-center-tools)
1. [Examine PowerShell functions used by Windows Admin Center](#task-5-examine-powershell-functions-used-by-windows-admin-center)

### Task 1: Configure settings in Windows Admin Center

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
   * Restart the DNS Server service
   * Retrieve Network Adapters and their IP settings
   * Filter the application event log for errors and warnings
   * Examine Storage
   * Examine Windows Update settings

### Task 5: Examine PowerShell functions used by Windows Admin Center

Perform these steps on CL1.

1. On the **Windows Admin Center** Page click on the PowerShell Icon on the upper right corner ([figure 4]).

2. Examine the functions that Windows Admin Center uses to complete its tasks. You can even copy those scripts to reuse it in your own scripts. ([figure 5])

## Exercise 2: Securing Windows Admin Center

### Introduction

In this exercise you will create the domain-local groups DL_WAC-Admins, and DL_WAC-Users in the domain, and give them the Gateway Users and Gateway Administrators role in Windows Admin Center to configure access permissions. Moreover, you will test the permissions. Finally, you will activate and test role-based-access control for SRV2, by adding *smart\user1* to *Windows Admin Center Administrators*, and *smart\user2* to *Windows Admin Center Readers*.

#### Tasks

1. [Create groups to secure Windows Admin Center](#task-1-create-groups-to-secure-windows-admin-center)
1. [Configure allowed groups in Windows Admin Center](#task-2-configure-allowed-groups-in-windows-admin-center)
1. [Test Windows Admin Center access permissions](#task-3-test-windows-admin-center-access-permissions)
1. [Activate role-based access control for Windows Admin Center](#task-4-activate-role-based-access-control-for-windows-admin-center)
1. [Test role-based access control for Windows Admin Center](#task-5-test-role-based-access-control-for-windows-admin-center)

### Task 1: Create groups to secure Windows Admin Center

#### Desktop Experience

Perform these steps on DC1.

1. Logon as **smart\administrator**.
1. Open the **Active Directory Users and Computers** console.
1. Create two domain-local groups in the **Users** container.

   * DL_WAC-Admins
   * DL_WAC-Users

1. Add **smart\user1** as a member of the **DL_WAC-Admins** group.
1. Add **smart\user2** as a member of the **DL_WAC-Users** group.

#### Windows Admin Center

1. On CL1 switch to the browser window with **Windows Admin Center**.
1. On the **Windows Admin Center** page, click on **DC1** to open the connection to the server.
1. On the left-hand side, under **Tools**, click **Active Directory**
1. Click **Create**, **Group**.
1. In the **Add Group** pane, in **Name**, enter DL_WAC-Admins. In **Group Scope**, ensure **Domain Local** is selected. Beside **Create in: DC=smart,DC=etc**, click **Change...**, select **Users**, and click **Select**.
1. Back in the **Add Group** pane, click **Create**.
1. Click **Create**, **Group**.
1. In the **Add Group** pane, in **Name**, enter DL_WAC-Users. In **Group Scope**, ensure **Domain Local** is selected, and click **Create**.
1. Back in **Active Directory Domain Services**, select **DL_WAC-Admins**, and click **Properties**.
1. On the left-hand side, click **Membership**.
1. Click **Add**.
1. In the **Add Group Membership** pane, in **User SamAccountName**, enter **user1**, and click **Add**.
1. Click **Save**.
1. Click **Close**.
1. To add **user2** to **DL_WAC-Users**, repeat step 9 - 14 accordingly. You may have to search for **DL_WAC-Users** first.

#### PowerShell

1. Logon as **smart\administrator**.
1. Run **Windows PowerShell** as Administrator.
1. Create two domain-local groups in the **Users** container.

   ````powershell
   # The -PassThru paramater return the created group, so that we can store it
   # in a variable for easier processing in the next step.
   $aDGroupWacAdmins = New-ADGroup `
      -Name DL_WAC-Admins `
      -GroupScope DomainLocal `
      -PassThru
   $aDGroupWacUsers = New-ADGroup `
      -Name DL_WAC-Users `
      -GroupScope DomainLocal `
      -PassThru
   ````

1. Add **smart\user1** as a member of the **DL_WAC-Admins** group.

   ````powershell
   $aDGroupWacAdmins | Add-ADGroupMember -Members user1
   ````

1. Add **smart\user2** as a member of the **DL_WAC-Users** group.

   ````powershell
   $aDGroupWacUsers | Add-ADGroupMember -Members user2
   ````

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

[figure 1]: images/WAC-icon-settings.png
[figure 2]: images/WAC-add-server-connection-dc1.png
[figure 3]: images/WAC-add-server-connection-dhcp.png
[figure 4]: images/WAC-icon-powershell.png
[figure 5]: images/WAC-view-powershell-scripts-for-home.png
[figure 6]: images/WAC-add-allowed-group.png
[figure 7]: images/WAC-RBAC-applied.png
[figure 8]: images/WAC-groups.png
[figure 9]: images/WAC-limited-access-srv2.png
