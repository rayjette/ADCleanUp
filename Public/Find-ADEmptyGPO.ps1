Function Find-ADEmptyGPO
{
    <#
        .SYNOPSIS
        Finds empty GPO's.  An empty GPO is one in which settings have never been defined.

        .DESCRIPTION
        Finds empty GPO's.  An empty GPO is one in which settings have never been defined.
        
        This works by checking both the user and computer dsversion values and if they are
        both 0 the GPO will be returned as empty.  Because of the way the dsversion values
        are used, GPO's will not be returned as empty if settings have been changed and then
        removed at a later time.

        .EXAMPLE
        Find-ADEmptyGPO
        Finds empty Group Policy objects in Active Dirctory.

        .INPUTS
        None.  Find-ADEmptyGPO does not except input via the pipeline.

        .OUTPUTS
        Microsoft.GroupPolicy.Gpo
    #>
    [OutputType([Microsoft.GroupPolicy.Gpo])]
    [CmdletBinding()]
    param ()

    # Get group policy objects from Active Directory
    $GPOs = Get-GPO -All

    # Return Group Policy Objects which have never been altered.  Since we are looking at the dsversion
    # any GPO which has had it's setting modified and then removed will not be returned.
    $GPOs | Where-Object {$_.user.dsversion -eq 0 -and $_.computer.dsversion -eq 0}
}