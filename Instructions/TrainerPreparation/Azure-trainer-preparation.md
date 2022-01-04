# Trainer Preparation: Azure

In the some labs, students must create and manage Azure resources. Because students most probably do not have an Azure account, it is recommended, that the trainer's Azure account (e. g. an Azure Pass subscription) is used.

The steps here are intended to be performed by the trainer in preparation of the lab. The steps can be done as a demo during or prior to the course.

## Exercises

1. [Provisioning](#exercise-1-provisioning)
1. [Cleanup](#exercise-2-cleanup)

## Exercise 1: Provisioning

### Introduction

This exercise is intended to be performed by the trainer in preparation of the lab. The steps can be done as a demo during or prior to the course.

You first create users for the students. Then, you create a separate resource group for each user and grant the user permissions to create SQL servers and databases.

#### Tasks

1. [Prepare the script](#task-1-prepare-the-script)
2. [Run script](#task-2-run-script)
3. [Manually prepare the lab](#task-3-manually-prepare-the-lab)

### Task 1: Prepare the script

1. Download the script [Deploy-Azure.ps1](/TrainerFiles/Deploy-Azure.ps1).
1. Check some parameters at the top of the script

    ````powershell
    param (
        [String]
        $Password = 'Pa$$w0rd', # Define you own default password
        [String]
        $CompanyName = 'ETC2022', # This should be unique. Used to remove users later.
        [String]
        $Location = 'northeurope' # This is the default location for azure resources
    )

    #region Global variables

    # Define the resource groups which should be create for each user.

    $userResourceGroups = @(
        @{
            NamePrefix = 'HARDSH-'
            RoleDefinitionNames = 'SQL DB Contributor', 'SQL Server Contributor'
        }
        @{
            NamePrefix = 'AzFS-'
            RoleDefinitionNames = 'Contributor'
        }
        @{
            NamePrefix = 'SRV1-'
            RoleDefinitionNames = 'Network Contributor', 'Virtual Machine Contributor'
        }
        @{
            NamePrefix = 'Management-'
            RoleDefinitionNames = 'Automation Contributor', 'Log Analytics Contributor'
        }
    )
    ````

    You can either change the defaults in the file or provide the parameters at runtime.

    $password will be the first-time password for the users. The users will be required to change the password at first sign in. Distribute the password to the students.

    Make sure that $companyName is not in use for any user in your Azure AD tenant. Moreover, it must not be in use as a tag for any resource group. In doubt, change the value to some random string.

    $location is the location where resources are created by default. Valid locations can be retrieved using ````Get-AzLocation````.

    $userResourceGroups define prefixes for various resource groups, the script will create for each user. Make sure, the prefixes are unique in your environment. If you change the prefixes, you will have to tell your users. Do not tamper with the RoleDefinitionNames. This will break the script and the labs.

### Task 2: Run script

1. It is recommended to disconnect from AzureAD and Azure before starting the script.

    ````powershell
    Disconnect-AzureAD
    Disconnect-AzAccount
    ````

    *Note:* If you receive an error message telling you, that the Cmdlet was not recognized, ignore it and continue.

1. Run PowerShell-script [Deploy-Azure.ps1](/TrainerFiles/Deploy-Azure.ps1).

    *Note:* The script supports the ````-Verbose```` parameter for more informative output.

1. At question ````Do you want to [p]rovision or [u]nprovision the HA RDSH lab in Azure:````, enter **p**.
1. At question ````Username (UPN) without domain. Leave empty to finish the user list:```` enter a valid user name, e.g. **Susi.Sorglos** or **MMustermann**.
1. At question ````Display name:```` enter the display name of the user, e. g. **Susi Sorglos** or **Max Mustermann**.

    The script will show something like this.

    ````
    Username: Max.Mustermann Displayname: Max Mustermann
    ````

1. At question ````Is this user correct (y/n):````, enter either **y** or **n**. If you enter **n**, the user will not be created later.
1. Repeat steps 4 - 6 for every user. To finish entering users, at step 4, enter a blank username.
1. If you are not signed in to Azure yet (recommended), a Microsoft authentication windows will open. Enter the credentials for your Azure account.

    The script will list the subscriptions in your account:

    ````
    Please select a subscription
    [0] MSDN-Plattformen
    [1] Azure Pass
    [2] Zugriff auf Azure Active Directory
    ````

1. At question ````Enter the subscription number and press ENTER:```` enter the number of the subscription from the list you want to use.

    The script will list the domains for the associated Azure Active Directory:

    ````
    [0] korecky.at
    [1] korecky.emea.microsoftonline.com
    [2] KORECKY1.onmicrosoft.com
    [3] easyon.at
    ````

1. At question ````Please enter the domain's index:```` select the domain you want to use for the users.

    The script will create the users. If the users already exist, they will be skipped, but shown in the output anyways.

    ````
    ObjectId                             DisplayName    UserPrincipalName        UserType
    --------                             -----------    -----------------        --------
    dbc4a9e9-48b0-4fa6-b395-a429b3129d53 Susi Sorglos   Susi.Sorglos@easyon.at   Member
    0d6dbacb-44a1-49cb-b2c3-8ca0e39f1791 Max Mustermann Max.Mustermann@easyon.at Member
    ````

    For each user, the script will create resource groups and assign the roles SQL DB Contributor and SQL Server Contributor to the user.

    ````
    ResourceGroupName : HARDSH-Susi.Sorglos
    Location          : northeurope
    ProvisioningState : Succeeded
    Tags              : {CompanyName}
    TagsTable         :
                        Name         Value
                        ===========  =======
                        CompanyName  ETC2022

    ResourceId        : /subscriptions/7022e6b1-cda5-4c07-a5f6-48c042625b6b/resourceGroups/HARDSH-Susi.Sorglos
    ManagedBy         :


    RoleAssignmentId   : /subscriptions/7022e6b1-cda5-4c07-a5f6-48c042625b6b/resourceGroups/HARDSH-Susi.Sorglos/providers/Microsoft.Authorization/roleAssignments/5279db0c-abf4-4998-8ee4-a311ea30805d
    Scope              : /subscriptions/7022e6b1-cda5-4c07-a5f6-48c042625b6b/resourceGroups/HARDSH-Susi.Sorglos
    DisplayName        : Susi Sorglos
    SignInName         : Susi.Sorglos@easyon.at
    RoleDefinitionName : SQL DB Contributor
    RoleDefinitionId   : 9b7fa17d-e63e-47b0-bb0a-15c516ac86ec
    ObjectId           : dbc4a9e9-48b0-4fa6-b395-a429b3129d53
    ObjectType         : User
    CanDelegate        : False


    RoleAssignmentId   : /subscriptions/7022e6b1-cda5-4c07-a5f6-48c042625b6b/resourceGroups/HARDSH-Susi.Sorglos/providers/Microsoft.Authorization/roleAssignments/b0b86f08-3107-4061-b448-ba444a820676
    Scope              : /subscriptions/7022e6b1-cda5-4c07-a5f6-48c042625b6b/resourceGroups/HARDSH-Susi.Sorglos
    DisplayName        : Susi Sorglos
    SignInName         : Susi.Sorglos@easyon.at
    RoleDefinitionName : SQL Server Contributor
    RoleDefinitionId   : 6d8ee4ec-f05a-4a1d-8b00-a9b17e38b437
    ObjectId           : dbc4a9e9-48b0-4fa6-b395-a429b3129d53
    ObjectType         : User
    CanDelegate        : False
    ````

    The rest of the output was trimmed for readability purposes.

Congratulations: You have provisioned the lab sucessfully!

### Task 3: Manually prepare the lab

In case you are unable to use the script, use these steps to prepare the lab.

1. In Azure AD create a user account for every student.
1. In the Azure subscription, create a resource groups for every student, named:
    * HARDSH-Username
    * AzFS-Username
    * SRV1-Username
    * Management-Username
1. In resource group **HARDSH-Username**, assign the corresponding users the roles **SQL DB Contributor** and **SQL Server Contributor**.
1. In resource group **AzFS-Username**, assign the corresponding users the role **Contributor**.
1. In resource group **SRV1-Username**, assign the corresponding users the roles **Network Contributor** and **Virtual Machine Contributor**.
1. In resource group **Management-Username**, assign the corresponding users the roles **Automation Contributor** and **Log Analytics Contributor**.

## Exercise 2: Cleanup

### Introduction

This exercise is intended to be performed by the trainer after the lab was completed by the students. The steps can be done as a demo during or after the course.

You will remove the resource groups and the users.

#### Tasks

1. [Run the script](#task-1-run-the-script)
2. [Manually unprovision the lab](#task-2-manually-unprovision-the-lab)

### Task 1: Run the script

1. Run PowerShell-script [Deploy-Azure.ps1](/TrainerFiles/Deploy-Azure.ps1).

    *Note:* The script supports the ````-Verbose```` parameter for more informative output. Because the script has minimal output, especially while unprovisioning the lab, it is recommended to append it.

1. At question ````Do you want to [p]rovision or [u]nprovision the HA RDSH lab in Azure:````, enter **u**.
1. If you are not signed in to Azure yet (recommended), a Microsoft authentication windows will open. Enter the credentials for your Azure account.

    The script will list the subscriptions in your account:

    ````
    Please select a subscription
    [0] MSDN-Plattformen
    [1] Azure Pass
    [2] Zugriff auf Azure Active Directory
    ````

1. At question ````Enter the subscription number and press ENTER:```` enter the number of the subscription from the list you want to use.

The script will automatically remove all users with the company name defined in the parameters. Moreover, it will remove all resource group with the tag companyname and the value of the company name defined in the parameters.

### Task 2: Manually unprovision the lab

In case you are unable to use the script, use these steps to unprovision the lab.

1. In Azure AD delelete the user account for every student.
1. In the Azure subscription, delete the resource groups for every student:

    * HARDSH-Username
    * AzFS-Username
    * SRV1-Username
    * Management-Username