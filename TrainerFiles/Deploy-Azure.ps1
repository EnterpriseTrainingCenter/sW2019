[CmdletBinding()]
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
        RoleDefinitionNames = 'Owner'
    }
    @{
        NamePrefix = 'SRV1-'
        RoleDefinitionNames = 
            'Network Contributor', 
            'Virtual Machine Contributor'
    }
    @{
        NamePrefix = 'Recovery-'
        RoleDefinitionNames = 'Contributor'
    }
)

# Compatible versions of the Azure package

$azPackage = @{ Name = 'Az'; MinimumVersion='3.7.0'; MaximumVersion = '6.6.0' }


#endregion Global variables

class User {
    [string]$Username
    [string]$Displayname
    [string]$UserPrincipalName
    
    User($username, $displayName) {
        $this.Username = $username
        $this.Displayname = $displayName
    }
}

function New-InstallPackageJob {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,
        [string]
        $MinimumVersion,
        [string]
        $MaximumVersion,
        [string]
        $RequiredVersion
    )

    $package = Get-Package @PSBoundParameters -ErrorAction SilentlyContinue
    if (
        $null -eq $package
    ) {
        $jobName = "InstallPackageJob-$Name"
        $job = Get-Job -Name $jobName -ErrorAction SilentlyContinue
        if ($null -eq $job) {
            Write-Verbose "Installing $Name in the background..."
            $job = Start-Job `
                -Name $jobName `
                -ScriptBlock { 
                    Install-Package @using:PSBoundParameters -Scope CurrentUser -Force
                }            
        }
    
        if ($null -ne $job -and $job.State -ne 'Running') {
            Write-Verbose "Job $jobName ended. Removing job"
            Remove-Job -Job $job -Force
        }
    
        return $job            
    }
    return $null
}

function Wait-Package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,
        [string]
        $MinimumVersion,
        [string]
        $MaximumVersion,
        [string]
        $RequiredVersion
    )

    $job = New-InstallPackageJob @PSBoundParameters

    # $job is null, if the package is already installed

    if ($null -ne $job) {
        while ($job.State -eq 'Running') {
            Write-Verbose "Waiting for $($job.Name) to end."
            Start-Sleep -Seconds 3
        }
        Write-Verbose "$($job.Name) ended. Removing job."
        Remove-Job -Job $job
    }
}

function Read-UsersFromHost {
    [OutputType([User[]])]
    # Ask for users

    [User[]]$users = @()

    do {
        # Prompt for username

        $username = Read-Host -Prompt `
            'Username (UPN) without domain. Leave empty to finish the user list'
        
        # Empty username finishes this loop
        
        if (-not [string]::IsNullOrWhiteSpace($username)) {

            # Prompt for displayname, must not be empty

            do {
                $displayName = Read-Host -Prompt 'Display name'
                if ([string]::IsNullOrWhiteSpace($displayName)) {
                    Write-Warning -Message 'Display name must not be empty'
                }                    
            } until (-not [string]::IsNullOrWhiteSpace($displayName))

            # Prompt user, if user is correct
            do {
                Write-Host
                Write-Host "Username: " -ForegroundColor Green -NoNewline
                Write-Host $username -NoNewline
                Write-Host " Displayname: " -ForegroundColor Green -NoNewline
                Write-Host $displayName
                $correctUser = Read-Host `
                    -Prompt "Is this user correct (y/n)"
            } until ($correctUser -eq 'y' -or $correctUser -eq 'n')

            # If user is correct, add it to our array

            if ($correctUser -eq 'y') {
                $users += [User]::New($username, $displayName)
            }
        }
    } until ([string]::IsNullOrWhiteSpace($username))

    return $users
}

function New-AzureADUsers {
    [CmdletBinding()]
    [OutputType([Microsoft.Open.AzureAD.Model.User])]
    param (
        [Parameter()]
        [User[]]
        $Users
    )
    # Install Az package in the background

    $null = New-InstallPackageJob @azPackage

    if ($null -eq $Users) {
        $Users = Read-UsersFromHost
    }


    # Wait for Az to be installed

    Wait-Package @azPackage

    # Select user domain

    $domain = Select-AzureADDomain


    # Creating users
    $PasswordProfile = New-Object `
        -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $Password
    $PasswordProfile.ForceChangePasswordNextLogin = $false

    foreach ($user in $users) {
        $user.UserPrincipalName = "$($user.Username)@$($domain.Name)"
        Write-Verbose "Search for user $($user.UserPrincipalName)"
        $azureADUser = Get-AzureADUser `
            -Filter "UserPrincipalName eq '$($user.UserPrincipalName)'"
        if ($null -eq $azureADUser) {
            Write-Verbose "Creating user $($user.DisplayName)"
            $azureADUser =  New-AzureADUser `
                -UserPrincipalName $user.UserPrincipalName `
                -DisplayName $user.DisplayName `
                -MailNickName $user.Username `
                -PasswordProfile $PasswordProfile `
                -AccountEnabled $true `
                -CompanyName $CompanyName
        }
        $azureADUser
    }
}

function Remove-AzureAdUsers {
    Wait-Package @azPackage

    do {

        try {
            [Microsoft.Open.AzureAD.Model.User[]] $users = Get-AzureADUser -All $true
        }
        catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] {
            Connect-AzContextAzureAd
        }
        catch {
            throw        
        }
    } until ($null -ne $users)

    $users = $users | Where-Object { $PSItem.CompanyName -eq $CompanyName }

    foreach ($user in $users) {
        Write-Verbose "Removing user $($user.Displayname)"
        $user | Remove-AzureADUser
    }
}

function Select-AzureADDomain {
    [OutputType([Microsoft.Open.AzureAD.Model.Domain])]

    $azureAdModule = Get-Module -Name AzureAD -ListAvailable

    if ($null -eq $azureAdModule) {
        Wait-Package @azPackage
    }

    do {
        try {
            $domains = Get-AzureADDomain | Where-Object { $PSItem.IsVerified }
            Write-Host 'Please select the domain for the users'
            for ($i = 0; $i -lt $domains.Count; $i++) {
                $domain = $domains[$i]
                Write-Host "[$i] $($domain.Name)"
            }
        
            do {
                $domainIndex = Read-Host `
                    -Prompt 'Please enter the domain''s index'
            } until ($domainIndex -ge 0 -and $domainIndex -lt $domains.Count)
            $domain = $domains[$domainIndex]
        }
        catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] {
            Connect-AzContextAzureAd
        }
        catch {
            throw            
        }        
    } until ($null -ne $domain)

    return $domain
}

function New-UserAzResourceGroup {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Microsoft.Open.AzureAD.Model.User]
        $User
    )

    # If there is no context, select a subscription first

    if ($null -eq (Get-AzContext)) {
        Select-Subscription
    }

    foreach ($userResourceGroup in $userResourceGroups) {
        $resourceGroupName = $userResourceGroup.NamePrefix + $User.MailNickName            
        $roleDefinitionNames = $userResourceGroup.RoleDefinitionNames

        # Create the resource group

        Write-Verbose "Creating resource group $resourceGroupName"

        New-AzResourceGroup `
            -Location $Location `
            -Name $resourceGroupName `
            -Tag @{ CompanyName = $CompanyName }

        # Assign roles to user

        foreach ($roleDefinitionName in $roleDefinitionNames) {
            Write-Verbose `
                "Assigning role $roleDefinitionName to $($User.UserPrincipalName) for resource group $resourceGroupName"
            New-AzRoleAssignment `
                -SignInName $User.UserPrincipalName `
                -ResourceGroupName $resourceGroupName `
                -RoleDefinitionName $roleDefinitionName
        }
    }

}
function Select-Subscription {
    do {
        try {
            # Get subscriptions

            $subscriptions = Get-AzSubscription  | 
            Where-Object { $PSItem.State -eq 'Enabled' }

            # Select subscription

            Write-Host 'Please select a subscription'

            for ($i = 0; $i -lt $subscriptions.Length; $i++) {
                $subscription = $subscriptions[$i]
                Write-Host "[$i] $($subscription.Name)"
            }

            do {
                $subscriptionIndex = Read-Host `
                    -Prompt 'Enter the subscription number and press ENTER'    
            } until (
                $subscriptionIndex -ge 0 `
                -and $subscriptionIndex -lt $subscriptions.Length
            )

            $subscription = $subscriptions[$subscriptionIndex]

            Set-AzContext -SubscriptionObject $subscription
            
        }
        # If we are not connected, sign in first
        catch [System.Management.Automation.PSInvalidOperationException] {
            switch ($PSItem.Exception.Message) {
                'Run Connect-AzAccount to login.' {
                    Write-Verbose `
                        'Not signed in to Azure. Connecting to Azure Account.'
                    $null = Connect-AzAccount 
                }
                Default {}
            }
        }
        catch {
            throw
        }

    } until ($null -ne $subscription)
}

function Connect-AzContextAzureAd {
    # If there is no context, select a subscription first

    $context = Get-AzContext

    while ($null -eq $context) {
        $context = Select-Subscription
    }

    Connect-AzureAD -TenantId $Context.Tenant.Id -AccountId $Context.Account.Id
}

function Remove-RecoveryServicesVault {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]
        $Name
    )
    $subscriptionId = (Get-AzContext).Subscription
    $recoveryServicesVault = Get-AzRecoveryServicesVault `
        -Name $Name `
        -ResourceGroupName $ResourceGroupName
    Set-AzRecoveryServicesAsrVaultContext -Vault $recoveryServicesVault

    # Disable soft delete
    Set-AzRecoveryServicesVaultProperty `
        -Vault $recoveryServicesVault.ID `
        -SoftDeleteFeatureState Disable
    
    # fetch backup items in soft delete state
    Write-Verbose "Soft delete disabled for the vault $Name"
    $recoveryServicesBackupItems = Get-AzRecoveryServicesBackupItem `
        -BackupManagementType AzureVM `
        -WorkloadType AzureVM `
        -VaultId $recoveryServicesVault.ID | 
    Where-Object {$_.DeleteState -eq "ToBeDeleted"}
    
    # Undelete items in soft delete state
    foreach ($recoveryServicesBackupItem in $recoveryServicesBackupItems)
    {
        Undo-AzRecoveryServicesBackupItemDeletion `
            -Item $recoveryServicesBackupItem `
            -VaultId $recoveryServicesVault.ID `
            -Force 
    }

    # Invoking API to disable enhanced security

    $accesstoken = Get-AzAccessToken
    $token = $accesstoken.Token
    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'='Bearer ' + $token
    }
    $body = @{properties=@{enhancedSecurityState= "Disabled"}}
    $uri = 'https://management.azure.com/subscriptions/' `
        + $subscriptionId+'/resourcegroups/' `
        + $resourceGroupName +'/providers/Microsoft.RecoveryServices/vaults/' `
        + $name +'/backupconfig/vaultconfig?api-version=2019-05-13'
    $response = Invoke-RestMethod `
        -Uri $uri `
        -Headers $authHeader `
        -Body ($body | ConvertTo-JSON -Depth 9) `
        -Method PATCH

    #Fetch all protected items and servers
    $backupItemsVM = Get-AzRecoveryServicesBackupItem `
        -BackupManagementType AzureVM `
        -WorkloadType AzureVM `
        -VaultId $recoveryServicesVault.ID
    $backupItemsSQL = Get-AzRecoveryServicesBackupItem `
        -BackupManagementType AzureWorkload `
        -WorkloadType MSSQL `
        -VaultId $recoveryServicesVault.ID
    $backupItemsAFS = Get-AzRecoveryServicesBackupItem `
        -BackupManagementType AzureStorage `
        -WorkloadType AzureFiles `
        -VaultId $recoveryServicesVault.ID
    $backupContainersSQL = Get-AzRecoveryServicesBackupContainer `
        -ContainerType AzureVMAppContainer `
        -Status Registered `
        -VaultId $recoveryServicesVault.ID | 
        Where-Object {$_.ExtendedInfo.WorkloadType -eq "SQL"}
    $StorageAccounts = Get-AzRecoveryServicesBackupContainer `
        -ContainerType AzureStorage `
        -Status Registered `
        -VaultId $recoveryServicesVault.ID
    $backupServersMARS = Get-AzRecoveryServicesBackupContainer `
        -ContainerType "Windows" `
        -BackupManagementType MAB `
        -VaultId $recoveryServicesVault.ID
    $backupServersMABS = Get-AzRecoveryServicesBackupManagementServer `
        -VaultId $recoveryServicesVault.ID | 
        Where-Object { $_.BackupManagementType -eq "AzureBackupServer" }
    $backupServersDPM = Get-AzRecoveryServicesBackupManagementServer `
        -VaultId $recoveryServicesVault.ID | 
        Where-Object { $_.BackupManagementType-eq "SCDPM" }

        # stop backup and delete Azure VM backup items
    foreach($item in $backupItemsVM)
    {
        Disable-AzRecoveryServicesBackupProtection `
            -Item $item `
            -VaultId $recoveryServicesVault.ID `
            -RemoveRecoveryPoints `
            -Force
    }
    Write-Verbose "Disabled and deleted Azure VM backup items"

    # stop backup and delete SQL Server in Azure VM backup items
    foreach($item in $backupItemsSQL) 
    {
        Disable-AzRecoveryServicesBackupProtection `
            -Item $item `
            -VaultId $recoveryServicesVault.ID `
            -RemoveRecoveryPoints -Force
    }
    Write-Verbose "Disabled and deleted SQL Server backup items"

    # disable auto-protection for SQL
    foreach($item in $protectableItems)
    {
        Disable-AzRecoveryServicesBackupAutoProtection `
            -BackupManagementType AzureWorkload `
            -WorkloadType MSSQL `
            -InputItem $item `
            -VaultId $recoveryServicesVault.ID
    }
    Write-Verbose "Disabled auto-protection and deleted SQL protectable items"

    # unregister SQL Server in Azure VM protected server
    foreach($item in $backupContainersSQL)
    {
        Unregister-AzRecoveryServicesBackupContainer `
            -Container $item `
            -VaultId $recoveryServicesVault.ID
    }
    Write-Verbose "Deleted SQL Servers in Azure VM containers" 

    # stop backup and delete SAP HANA in Azure VM backup items
    foreach($item in $backupItemsSAP) 
    {
        Disable-AzRecoveryServicesBackupProtection `
            -Item $item `
            -VaultId $recoveryServicesVault.ID `
            -RemoveRecoveryPoints `
            -Force
    }
    Write-Verbose "Disabled and deleted SAP HANA backup items"

    #unregister SAP HANA in Azure VM protected server
    foreach($item in $backupContainersSAP)
    {
        Unregister-AzRecoveryServicesBackupContainer `
        -Container $item `
        -Force `
        -VaultId $recoveryServicesVault.ID 
    }
    Write-Verbose "Deleted SAP HANA in Azure VM containers"

    #stop backup and delete Azure File Shares backup items
    foreach($item in $backupItemsAFS)
    {
        Disable-AzRecoveryServicesBackupProtection `
            -Item $item `
            -VaultId $recoveryServicesVault.ID `
            -RemoveRecoveryPoints `
            -Force
    }
    Write-Verbose "Disabled and deleted Azure File Share backups"

    # unregister storage accounts
    foreach($item in $StorageAccounts)
    {   
        Unregister-AzRecoveryServicesBackupContainer `
        -Container $item `
        -VaultId $recoveryServicesVault.ID
    }
    Write-Verbose "Unregistered Storage Accounts"

    # unregister MARS servers and delete corresponding backup items
    foreach($item in $backupServersMARS) 
    {
        Unregister-AzRecoveryServicesBackupContainer `
            -Container $item `
            -VaultId $recoveryServicesVault.ID
    }
    Write-Verbose "Deleted MARS Servers"

    # unregister MABS servers and delete corresponding backup items
    foreach($item in $backupServersMABS)
    { 
        Unregister-AzRecoveryServicesBackupManagementServer `
            -AzureRmBackupManagementServer $item `
            -VaultId $recoveryServicesVault.ID
    }
    Write-Verbose "Deleted MAB Servers"

    #unregister DPM servers and delete corresponding backup items
    foreach($item in $backupServersDPM) 
    {
        Unregister-AzRecoveryServicesBackupManagementServer `
            -AzureRmBackupManagementServer $item `
            -VaultId $recoveryServicesVault.ID
    }
    Write-Verbose "Deleted DPM Servers"



    Remove-AzRecoveryServicesVault -Vault $recoveryServicesVault
    #Finish
}

function Install-Lab {
    $users = New-AzureADUsers
    $users
    foreach ($user in $users) {
        New-UserAzResourceGroup -User $user
    }
    
}

function Uninstall-lab {
    # Remove users
    Remove-AzureADUsers

    # Find resource groups and delete them

    $resourceGroups = Get-AzResourceGroup -Tag @{ CompanyName = $CompanyName }

    foreach ($resourceGroup in $resourceGroups) {

        # Some resource types need special treatment

        $resources = Get-AzResource `
            -ResourceGroupName $resourceGroup.ResourceGroupName
        foreach ($resource in $resources) {
            Write-Verbose "Removing resource $($resource.Name)"
            switch ($resource.ResourceType) {
                'Microsoft.StorageSync/storageSyncServices' {

                    $storageSyncService = Get-AzStorageSyncService `
                        -ResourceGroupName $resourceGroup.ResourceGroupName `
                        -Name $resource.Name

                    # Remove sync groups

                    $storageSyncGroups = $storageSyncService |
                        Get-AzStorageSyncGroup
                    foreach ($storageSyncGroup in $storageSyncGroups) {

                        # Remove server endpoints

                        Write-Verbose "In storage sync group $($storageSyncGroup.SyncGroupName), removing server endpoints."

                        $storageSyncGroup | 
                        Get-AzStorageSyncServerEndpoint |
                        Remove-AzStorageSyncServerEndpoint -Force

                        # Remove cloud endpoints

                        Write-Verbose "In storage sync group $($storageSyncGroup.SyncGroupName), removing cloud endpoints."
                        $storageSyncGroup |
                        Get-AzStorageSyncCloudEndpoint |
                        Remove-AzStorageSyncCloudEndpoint -Force
                    }
                    Write-Verbose 'Removing storage sync groups'
                    $storageSyncGroups | Remove-AzStorageSyncGroup -Force

                    
                    # Remove registered servers
                    Write-Verbose 'Removing servers from Azure Storage Sync'
                    $storageSyncService | 
                    Get-AzStorageSyncServer | 
                    Unregister-AzStorageSyncServer -Force

                    # Remove storage sync service
                    $storageSyncService | Remove-AzStorageSyncService -Force
                }
                'Microsoft.RecoveryServices/vaults' {
                    Remove-RecoveryServicesVault `
                        -ResourceGroupName `
                            $resourceGroup.ResourceGroupName `
                        -Name $resource.Name
                }
                Default {
                }
            }
        }

        Write-Verbose "Removing resource group $($resourceGroup.ResourceGroupName)"
        $null = $resourceGroup | Remove-AzResourceGroup -Force
    }

    # Remove Azure AD applications

    Get-AzureADApplication `
        -SearchString 'WindowsAdminCenter-https://admincenter.smart.etc' | 
    Remove-AzureADApplication
}

New-InstallPackageJob @azPackage

$command = ''
while ($command -ne 'p' -and $command -ne 'u') {
    $command = Read-Host -Prompt `
        "Do you want to [p]rovision or [u]nprovision the Azure for the labs"
}

switch ($command) {
    'p' { Install-Lab }
    'u' { Uninstall-Lab }
    Default {}
}





