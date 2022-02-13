Function Find-ADUnusedUsers {
    <#
        .SYNOPSIS
        Find unused Active Directory user account objects.

        .DESCRIPTION
        Find unused Active Directory user account objects.

        .PARAMETER Days
        Accounts which have not been logged on to in this number of days will be considered inactive.  A default value of 90 days is provided.

        .PARAMETER OnlyNeverLogon
        Find Active Directory user accounts which have never been logged on to.

        .PARAMETER DisabledOnly
        Find Active Directory user accounts which are disabled.

        .EXAMPLE
        Find-ADUnsuedComputers
        Finds Active Directory user objects which have not been logged on for 90 days or more or which have never been logged on to.

        .EXAMPLE
        Find-ADUnusedUsers -Days 60
        Finds Active Directory user objects which have not been logged on for 60 days or more or have never been logged on to.

        Find-ADUnusedUsers -DisabledOnly
        Finds Active Directory user accounts which are disabled.

        .INPUTS
        None.  Find-ADUnusedUsers does not accept pipeline input.

        .OUTPUTS
        Microsoft.ActiveDirectory.Management.ADUser
    #>
    #Requires -Modules ActiveDirectory
    [OutputType([Microsoft.ActiveDirectory.Management.ADUser])]
    [CmdletBinding(DefaultParameterSetName='Default')]
    Param (
        [Parameter(Mandatory, ParameterSetName='Days')]
        [ValidateNotNullOrEmpty()]
        [Int32]$Days = 90,

        [Parameter(Mandatory, ParameterSetName='NeverLogon')]
        [switch]$OnlyNeverLogon,

        [Parameter(Mandatory, ParameterSetName='DisabledOnly')]
        [switch]$DisabledOnly,

        [string]$SearchBase
    )
    $filterDate = (Get-Date).AddDays(-$Days)

    # The parameter for Get-ADUser
    $splat = @{
        Filter     = '*'
        Properties = 'LastLogonDate'
    }
    # If the SearchBase parameter was specified add it to the parameters to Get-ADUser.
    if ($PSBoundParameters.ContainsKey('SearchBase'))
    {
        $splat.add('SearchBase', $SearchBase)
    }

    # Get computers objects from Active Directory.
    $users = Get-ADUser @splat
    
    # If the DisabledOnly parameter is specified we are only instrested in disabled user objects.
    if ($PSBoundParameters.ContainsKey('DisabledOnly'))
    {
        foreach ($user in $users)
        {
            if (-not (Test-IsADUserEnabled -Identity $user.samaccountname))
            {
                $user
            }
        }
    }
    # If the OnlyNeverLogon parameter is present output user which have never logged on.
    elseif ($PSBoundParameters.ContainsKey('OnlyNeverLogon'))
    {
        $users | Where-Object {$null -eq $_.LastLogonDate}
    }
    # Output all users which have not logged on since or before $filterDate.
    else
    {
        $users | Where-Object {$_.LastLogonDate -lt $filterDate}
    }
} # Find-ADUnusedUsers