# Parameters

$password = 'Pa$$w0rd' # Define you own default password
$companyName = 'ETC2022' # This should be unique. Used to remove users later.
$resourceGroupNamePrefix = 'HARDSH-' # This is the prefix for resource groups
$location = 'northeurope' # This is the default location for azure resources
$azPackage = @{ Name = 'Az'; RequiredVersion = '6.6.0' }

# Global variables

$users = @()

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
        $RequiredVersion
    )

    if ($null -eq (Get-Package -Name $Name)) {
        $jobName = "InstallPackageJob-$Name"
        $job = Get-Job -Name $jobName
        if ($null -eq $job) {
            Write-Host "Installing $Name in the background..."
            Start-Job `
                -Name $jobName `
                -ScriptBlock { 
                    Install-Package @PSBoundParameters -Scope CurrentUser -Force
                }            
        }
    
        if ($null -ne $job -and $job.State -ne 'Running') {
            Write-Host "Job $jobName ended. Removing job"
            Remove-Job -Job $job
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
        $RequiredVersion
    )

    $job = New-InstallPackageJob @PSBoundParameters

    # $job is null, if the package is already installed

    if ($null -ne $job) {
        while ($job.State -eq 'Running') {
            Write-Host "Waiting for $($job.Name) to end."
            Start-Sleep -Seconds 3
        }
        Write-Host "$($job.Name) ended. Removing job."
        Remove-Job -Job $job
    }
}

function New-AzureADUsers {
    # Install Az package in the background

    $null = New-InstallPackageJob @azPackage

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
                Write-Host "Username: $username"
                Write-Host "Displayname: $displayName"
                $correctUser = Read-Host `
                    -Prompt "Is this user correct (y/n)"
            } until ($correctUser -eq 'y' -or $correctUser -eq 'n')

            # If user is correct, add it to our array

            if ($correctUser -eq 'y') {
                $users += [User]::New($username, $displayName)
            }
        }
    } until ([string]::IsNullOrWhiteSpace($username))

    # Wait for Az to be installed

    Wait-Package @azPackage

    # Sign in to Azure AD

    Write-Host 'Connecting to Azure AD'
    $null = Connect-AzureAd

    # Select user domain

    $domain = Select-AzureADDomain

    # Creating users
    $passwordProfile = New-Object `
        -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $passwordProfile.Password = $password

    foreach ($user in $users) {
        $user.UserPrincipalName = "$($user.Username)@$($domain.Name)"
        Write-Host "Creating user $($user.DisplayName)"
        $null = New-AzureADUser `
            -UserPrincipalName $user.UserPrincipalName `
            -DisplayName $user.DisplayName `
            -MailNickName $user.Username `
            -PasswordProfile $passwordProfile `
            -AccountEnabled $true `
            -CompanyName $companyName
    }

    return $users
}

function Remove-AzureAdUsers {
    Wait-Package @azPackage

    # Sign in to Azure AD

    Write-Host 'Connecting to Azure AD'
    $null = Connect-AzureAd

    [Microsoft.Open.AzureAD.Model.User[]] $users = Get-AzureADUser -All $true |
    Where-Object { $PSItem.CompanyName -eq $companyName }

    foreach ($user in $users) {
        Write-Host "Removing user $($user.Displayname)"
        $user | Remove-AzureADUser
    }
}

function Select-AzureADDomain {
    Wait-Package @azPackage
    $domains = Get-AzureADDomain | Where-Object { $PSItem.IsVerified }

    Write-Host 'Please select the domain for the users'
    for ($i = 0; $i -lt $domains.Count; $i++) {
        $domain = $domains[$i]
        Write-Host "[$i] $($domain.Name)"
    }

    do {
        $domainIndex = Read-Host -Prompt 'Please enter the domain''s index'
    } until ($domainIndex -ge 0 -and $domainIndex -lt $domains.Count)
    $domain = $domains[$domainIndex]
    return $domain
}

function New-AzUserRG {
    [CmdletBinding()]
    param (
        [Parameter()]
        [User]
        $User
    )

    $roleDefinitionNames = 'SQL DB Contributor', 'SQL Server Contributor'
    $resourceGroupName = $resourceGroupNamePrefix + $User.Username
    Write-Host "Creating resource group $resourceGroupName"

    $null = New-AzResourceGroup `
        -Location $location `
        -Name $resourceGroupName `
        -Tag @{ CompanyName = $companyName }

    foreach ($roleDefinitionName in $roleDefinitionNames) {
        Write-Host `
            "Assigning role $roleDefinitionName to $($User.UserPrincipalName) for resource group $resourceGroupName"
        $null = New-AzRoleAssignment `
            -SignInName $User.UserPrincipalName `
            -ResourceGroupName $resourceGroupName `
            -RoleDefinitionName $roleDefinitionName
    }
}
function Select-Subscription {
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
    $subscriptionIndex = Read-Host -Prompt 'Enter the subscription number and press ENTER'    
    } until ($subscriptionIndex -ge 0 -and $subscriptionIndex -lt $subscriptions.Length)

    $subscription = $subscriptions[$subscriptionIndex]

    Set-AzContext -SubscriptionObject $subscription
    return $subscription
}

function Install-Lab {
    $users = New-AzureADUsers
    Wait-Package @azPackage

    Write-Host 'Connecting to Azure'
    $null = Connect-AzAccount
    $null = Select-Subscription
    foreach ($user in $users) {
        New-AzUserRG -User $user
    }
    
}

function Uninstall-lab {
    # Remove users
    Remove-AzureADUsers

    # Select Azure subscription
    
    $null = Connect-AzAccount
    $null = Select-Subscription

    # Find resource groups and delete them

    $resourceGroups = Get-AzResourceGroup -Tag @{ CompanyName = $companyName }

    foreach ($resourceGroup in $resourceGroups) {
        Write-Host "Removing resource group $($resourceGroup.ResourceGroupName)"
        $null = $resourceGroup | Remove-AzResourceGroup -Force
    }
}


New-InstallPackageJob @azPackage

$command = ''
while ($command -ne 'p' -and $command -ne 'u') {
    $command = Read-Host -Prompt `
        "Do you want to [p]rovision or [u]nprovision the HA RDSH lab in Azure"
}

switch ($command) {
    'p' { Install-Lab }
    'u' { Uninstall-Lab }
    Default {}
}





