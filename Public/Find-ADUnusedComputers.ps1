Function Find-ADUnusedComputers {
    <#
        .SYNOPSIS
        Find unused Active Directory computer account objects.

        .DESCRIPTION
        Find unused Active Directory computer account objects.

        .PARAMETER Days
        Accounts which have not been logged on to in this number of days will be considered inactive.  A default value of 90 days is provided.

        .PARAMETER OnlyNeverLogon
        Find Active Directory computer accounts which have never been logged on to.

        .PARAMETER DisabledOnly
        Find Active Directory computer accounts which are disabled.

        .EXAMPLE
        Find-ADUnsuedComputers
        Finds Active Directory computer objects which have not been logged on for 90 days or more or which have never been logged on to.

        .EXAMPLE
        Find-ADUnusedComputers -Days 60
        Finds Active Directory computer objects which have not been logged on for 60 days or more or have never been logged on to.

        Find-ADUnusedComputers -DisabledOnly
        Finds Active Directory computer accounts which are disabled.

        .INPUTS
        None.  Find-ADUnusedComputers does not accept pipeline input.

        .OUTPUTS
        Microsoft.ActiveDirectory.Management.ADComputer
    #>
    #Requires -Modules ActiveDirectory
    [OutputType([Microsoft.ActiveDirectory.Management.ADComputer])]
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

    # The parameter for Get-ADComputer
    $splat = @{
        Filter     = '*'
        Properties = 'LastLogonDate'
    }
    # If the SearchBase parameter was specified add it to the parameters to Get-ADComputer.
    if ($PSBoundParameters.ContainsKey('SearchBase'))
    {
        $splat.add('SearchBase', $SearchBase)
    }

    # Get computers objects from Active Directory.
    $computers = Get-ADComputer @splat
    
    # If the DisabledOnly parameter is specified we are only instrested in disabled computer objects.
    if ($PSBoundParameters.ContainsKey('DisabledOnly'))
    {
        foreach ($computer in $computers)
        {
            if (-not (Test-IsADComputerEnabled -Identity $computer.name))
            {
                $computer
            }
        }
    }
    # If the OnlyNeverLogon parameter is present output computers which have never logged on.
    elseif ($PSBoundParameters.ContainsKey('OnlyNeverLogon'))
    {
        $computers | Where-Object {$_.LastLogonDate -eq $null}
    }
    # Output all computers which have not logged on since or before $filterDate.
    else
    {
        $computers | Where-Object {$_.LastLogonDate -lt $filterDate}
    }
} # Find-ADUnusedComputers