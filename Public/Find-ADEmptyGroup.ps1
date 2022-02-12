Function Find-ADEmptyGroup
{
    <#
        .SYNOPSIS
        Finds empty Active Directory groups.

        .DESCRIPTION
        Finds empty Active Directory groups.  An empty group is one which does not have any members.  Built-in Windows Gropus (Cricital System Objects) and Exchange built-in groups are not considered.
    
        .PARAMETER SearchBase
        SearchBase can be used to specify where in the directory to search from.

        .PARAMETER Type
        The type of group to search.  Accepted values are security and distribution.  If not specified all group types are searched.

        .EXAMPLE
        Find-ADEmptyGroup
        Finds empty groups found in Active Directory.

        .EXAMPLE
        Find-ADEmptyGroup -SearchBase OU=Groups,DC=MyDomain,DC=com
        Finds empty groups in the OU specified by SearchBase.

        .EXAMPLE
        Find-ADEmptyGroup -Type Distribution
        Finds empty distirbution groups.

        .INPUTS
        None.  Find-ADEmptyGroup does not accept input from the pipeline.

        .OUTPUTS
        Microsoft.ActiveDirectory.Management.ADGroup

    #>
    [OutputType([Microsoft.ActiveDirectory.Management.ADGroup])]
    [CmdletBinding(DefaultParameterSetName='Default')]
    param 
    (
        [Parameter(Mandatory, ParameterSetName='SearchBase')]
        [ValidateNotNullOrEmpty()]
        [string]$SearchBase,

        [ValidateSet('Security', 'Distribution')]
        [string]$Type
    )
    # These are the parameters for Get-ADGroup.  The LDAPFilter returns all groups except critical system objects.
    # Critical System Object will be ignored and not reported on.
    $splat = @{
        LDAPFilter = '(&(objectClass=group)(!isCriticalSystemObject=TRUE)(!member=*))'
    }
    # Add the SearchBase parameter to the list of parameters if specified.
    if ($PSBoundParameters.ContainsKey('SearchBase'))
    {
        $splat.add('SearchBase', $SearchBase)
    }
    # Get groups matching the LDAPFilter
    $groups = Get-ADGroup @splat

    # If the type parameter has been specified we only want groups of this type
    if ($PSBoundParameters.ContainsKey('Type'))
    {
        $groups = $groups | Where-Object {$_.GroupCategory -eq $type}
    }

    # Remove any built-in Exchange groups.  These will not be reported on.
    $groups | Where-Object {$_.distinguishedname -notmatch 'Microsoft Exchange Security Groups'}
} # Find-ADEmptyGroup