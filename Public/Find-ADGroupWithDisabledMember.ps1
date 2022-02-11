Function Find-ADGroupWithDisabledMember
{
    <#
        .SYNOPSIS
        Finds Active Directory groups with disabled members.

        .DESCRIPTION
        Looks for groups in Active Directory for members which are disabled and outputs thoese members.

        .PARAMETER Name
        The name of one or more groups to search of disabled members.

        .EXAMPLE
        Find-ADGroupWithDisabledMember
        Finds groups with disabled members.

        .EXAMPLE
        Find-ADGroupWithDisabledMember -SearchBase 'OU=Groups,DC=MyDomain,DC=com'
        Finds groups with disabled members at the location sepcified by SearchBase.

        .INPUTS
        None.  Find-ADGroupWithDeletedMember does not accept input via the pipeline.
        
        .OUTPUTS
        System.Management.Automation.PSCustomObject.
    #>
    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName='Default')]
    Param (
        [Parameter(Mandatory, ParameterSetName='SearchBase')]
        [ValidateNotNullOrEmpty]
        [string]$SearchBase
    )
    # The parameters to pass to Get-ADGroup
    $splat = @{Filter = '*'}

    # If SearchBase is specified add it to the parameter list
    if ($PSBoundParameters.ContainsKey('SearchBase'))
    {
        $splat.add('SearchBase', $SearchBase)
    }

    # Get groups from Active Directory.
    $groups = Get-ADGroup @splat

    # Initialize a counter for the progress bar
    $count = 0



    foreach ($group in $groups)
    {
        # Update counter and generate a progress bar.
        $count++
        $writeProgressSplatting = @{
            Activity = 'Finding groups with disabled users as members.'
            Status   = "Finding Group $count of $($groups.count)."
            PercentComplete = (($count / $groups.count) * 100)
        }
        Write-Progress @writeProgressSplatting

        # Get the members of the current group
        $groupMembers = $group | Get-ADGroupMember

        # Veriables to store disabled users and computers.
        $disabledUsers = @()
        $disabledComputers = @()

        # Get both the users and computers which are disabled in the current group.
        foreach ($member in $groupMembers)
        {
            # Get disabled users
            if (($member.objectClass -eq 'user') -and (-not (Test-IsADUserEnabled -Identity $member.samaccountname)))
            {
                $disabledUsers += $member.name
            }
            # Get disabled computers
            if (($member.objectClass -eq 'computer') -and (-not (Test-IsADComputerEnabled -Identity $member.samaccountname)))
            {
                $disabledComputers += $member.name
            }
        }

        # Create our return object for disabled users.
        if ($disabledUsers)
        {
            [PSCustomObject]@{
                Name = $group.name
                MemberType = 'User'
                DisabledMembers = $disabledUsers -join ', '
            }
        }
        # Create our return object for disabled computers.
        if ($disabledComputers)
        {
            [PSCustomObject]@{
                Name = $group.name
                MemberType = 'Computer'
                DisabledMembers = $disabledComputers -join ', '
            }
        }
    }
} # Find-ADGroupWithDisabledMember