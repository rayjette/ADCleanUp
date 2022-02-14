Function Find-ADEmptyOrganizationalUnit
{
    <#
        .SYNOPSIS
        Find empty organizational units in Active Directory.
        
        .DESCRIPTION
        Find empty organizational units in Active Directory.

        .PARAMETER SearchBase
        Specify a location in the directory to search for empty organization units at.

        .EXAMPLE
        Find-ADEmptyOrganizationalUnit
        Find all empty organizational unit's in Active Directory.

        .EXAMPLE
        Find-ADEmptyOrganizationalUnit -SearchBase 'OU=devisionA,dc=myDomain,dc=com.
        Look for empty organizational units under the location specified by SearchBase.

        .INPUTS
        None.  Find-ADEmptyOrganizationalUnit does not accept input from the pipeline.

        .OUTPUTS
        Microsoft.ActiveDirectory.Management.ADOrganizationalUnit

    #>
    [OutputType([Microsoft.ActiveDirectory.Management.ADOrganizationalUnit])]
    [CmdletBinding()]
    param (
        [string]$SearchBase
    )

    # Parameters for Get-ADOrganizationalUnit
    $splat = @{
        Filter = '*'
    }

    # If the SearchBase parameter was specified append it to the parameters for Get-ADOrganizationalUnit
    if ($PSBoundParameters.ContainsKey('SearchBase'))
    {
        $splat.add('SearchBase', $SearchBase)
    }

    # Get all organizational units from Active Directory
    $organizationalUnit = Get-ADOrganizationalUnit @splat

    # Loop though all organizuation unit's in Active Directory outputting any empty ones.
    foreach ($ou in $organizationalUnit)
    {
        if (Test-IsOrganizationalUnitEmpty -DistinguishedName $ou.DistinguishedName)
        {
            $ou
        }

    }
} # Find-ADEmptyOrganizationalUnit