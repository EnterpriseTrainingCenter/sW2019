# Trainer Preparation: HA RDSH farm with Azure DB

In the Lab **HA RDSH farm with Azure DB**, students must create an Azure SQL database. Because students most probably do not have an Azure account, it is recommended, that the trainer's Azure account (e. g. an Azure Pass subscription) is used.

The steps here are intended to be performed by the trainer in preparation of the lab. The steps can be done as a demo during or prior to the course.

## Exercise 1: Provisioning

### Introduction

This exercise is intended to be performed by the trainer in preparation of the lab. The steps can be done as a demo during or prior to the course.

You first create users for the students. Then, you create a separate resource group for each user and grant the user permissions to create SQL servers and databases.

#### Task 1: Prepare the script to provision Azure for the HA-RDSH lab

1. Download the script [HARDSHLab.ps1](/TrainerFiles/HARDSHLab.ps1).
1. Check some parameters at the top of the script

    ````powershell
    $password = 'Pa$$w0rd' # Define you own default password
    $companyName = 'ETC2022' # This should be unique. Used to remove users later.
    $resourceGroupNamePrefix = 'HARDSH-' # This is the prefix for resource groups
    $location = 'northeurope' # This is the default location for azure resources
    ````

    $password will be the first-time password for the users. The users will be required to change the password at first sign in. Distribute the password to the students.

    Make sure that $companyName is not in use for any user in your Azure AD tenant. Moreover, it must not be in use as a tag for any resource group. In doubt, change the value to some random string.

    The resource groups will be create with the naming schema HARDSH-Username. The resource group names must be unique in the subscription. If you must change the prefix, you must advise students to use a different resource group name in the lab.

    $location is the location where resources are created by default. Valid locations can be retrieved using ````Get-AzLocation````.


#### Task 2: Run script to provision Azure for the HA-RDSH lab

1. Run PowerShell-script [HARDSHLab.ps1](/TrainerFiles/HARDSHLab.ps1).

    ````
    Do you want to [p]rovision or [u]nprovision the HA RDSH lab in Azure:
    ````

1. Enter **p**.

    ````
    Username (UPN) without domain. Leave empty to finish the user list:
    ````

1. Enter a valid UPN prefix for the first user, such as Max.Mustermann or MMustermann or MaxMustermann or Max. Spaces and special characters are not allowed.

    ```` 
    Display name:
    ````

1. Enter a display name for the first user.

    The script will show user name and display name again and ask:

    ````
    Is this user correct (y/n):
    ````

1. If everything looks fine, enter **y**, otherwise **n**.

1. Repeat steps 3 - 5 for more users.

1. When you entered all users, on ````Username (UPN) without domain. Leave empty to finish the user list:```` simply press ENTER without entering anything.

1. After the script displays ````Connecting to Azure AD```` a Microsoft authentication window will appear. Enter your Azure AD account credentials.

    ````
    Please select the domain for the users
    [0] mydomain.com
    [1] mydomain.onmicrosoft.com
    [3] mydomain.mail.onmicrosoft.com
    Please enter the domain's index: 0
    ````

1. On the list of possible domains, enter the index number of the domain, in which you want the users to be created.

    This message appears for every user.

    ````
    Creating user
    ````

    ````
    Connecting to Azure
    ````

1. Another Microsoft authentication windows appears. Enter the credentials for your Azure subscription.

    ````
    Please select a subscription
    [0] MSDN-Plattformen
    [1] Zugriff auf Azure Active Directory
    ````

1. Select the index number of the subscription, where the resource groups should be created.

    These messages appear for every user.

    ````
    Creating resource group HARDSH-
    Assigning role SQL DB Contributor to  for resource group HARDSH-
    Assigning role SQL Server Contributor to  for resource group HARDSH-
    ````

#### Task 3: Manually prepare the lab

In case you are unable to use the script, use these steps to prepare the lab.

1. In Azure AD create a user account for every student.
1. In the Azure subscription, create a resource group for every student, named HARDSH-Username.
1. Assign the users the roles **SQL DB Contributor** and **SQL Server Contributor** to the corresponding resource groups.

## Exercise 2: Cleanup

### Introduction

This exercise is intended to be performed by the trainer after the lab was completed by the students. The steps can be done as a demo during or after the course.

You will remove the resource groups and the users.

#### Task 2: Run script to unprovision Azure for the HA-RDSH lab

1. Run PowerShell-script [HARDSHLab.ps1](/TrainerFiles/HARDSHLab.ps1).

    ````
    Do you want to [p]rovision or [u]nprovision the HA RDSH lab in Azure:
    ````

1. Enter **u**.

1. After the script displays ````Connecting to Azure AD```` a Microsoft authentication window will appear. Enter your Azure AD account credentials.

    This message appears for every user.

    ````
    Removing user
    ````

    ````
    Connecting to Azure
    ````

1. Another Microsoft authentication windows appears. Enter the credentials for your Azure subscription.

    ````
    Please select a subscription
    [0] MSDN-Plattformen
    [1] Zugriff auf Azure Active Directory
    ````

1. Select the index number of the subscription, where the resource groups should be created.

    This message appear for every resource group.

    ````
    Removing resource group HARDSH-
    ````

#### Task 3: Manually unprovision the lab

In case you are unable to use the script, use these steps to unprovision the lab.

1. In Azure AD delelete the user account for every student.
1. In the Azure subscription, delete the resource group for every student, named HARDSH-Username.
