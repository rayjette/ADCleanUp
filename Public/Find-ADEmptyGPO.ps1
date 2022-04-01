Function Find-ADEmptyGPO
{
    <#
        .SYNOPSIS
        Returns unused group policy objects.

        .DESCRIPTION
        Returns unused group policy objects.

        Returns group policy objects which have never had there settings modified after creation.
        If the settings were modified and then changed back the gpo will not be returned because
        we are looking at the dsversion value on the gpo.

        .PARAMETER OnlyLinked
        Only linked group policy objects will be considered when looking for empty ones.

        .EXAMPLE
        Find-ADEmptyGPO

        Return group policy objects that have never been altered. 

        .INPUTS
        None.  Find-ADEmptyGPO does not except input via the pipeline.

        .OUTPUTS
        Microsoft.GroupPolicy.Gpo

        .NOTES
        https://github.com/rayjette/ADCleanUp.git
    #>
    [OutputType([Microsoft.GroupPolicy.Gpo])]
    [CmdletBinding()]
    param (
        [switch] $OnlyLinked
    )
    # Get group policy objects from Active Directory
    $GPOs = Get-GPO -All

    # Save Group Policy Objects which have never been altered.  Since we are looking at the dsversion
    # any GPO which has had it's setting modified and then removed will not be returned.
    $unmodifiedGpo = $GPOs | Where-Object {$_.user.dsversion -eq 0 -and $_.computer.dsversion -eq 0}

    # Return unmodified group policy objects.
    if ($PSBoundParameters.ContainsKey('OnlyLinked'))
    {
        $unmodifiedGpo | ForEach-Object {
            $report = Get-GPOReport -ReportType 'xml' -Name $PSItem.displayname
            if ($report.PSItem.psobject.properties.name -contains 'LinksTo')
            {
                $PSItem
            }
        }
    }
    else
    {
        $unmodifiedGpo    
    }
}