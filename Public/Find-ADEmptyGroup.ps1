Function Find-ADEmptyGroup
{
    <#
        .SYNOPSIS
        Finds empty Active Directory groups.

        .DESCRIPTION
        Finds empty Active Directory groups.  An empty group is one which does not have any members.  Built-in Windows Gropus (Cricital System Objects) and Exchange built-in groups are not considered.
    
        .PARAMETER SearchBase
        SearchBase can be used to specify where in the directory to search from.

        .EXAMPLE
        Find-ADEmptyGroup
        Finds empty groups found in Active Directory.

        .EXAMPLE
        Find-ADEmptyGroup -SearchBase OU=Groups,DC=MyDomain,DC=com
        Finds empty groups in the OU specified by SearchBase.

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
        [string]$SearchBase
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

    # Remove any built-in Exchange groups.  These will not be reported on.
    $groups | Where-Object {$_.distinguishedname -notmatch 'Microsoft Exchange Security Groups'}
} # Find-ADEmptyGroup