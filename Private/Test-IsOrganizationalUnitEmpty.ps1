Function Test-IsOrganizationalUnitEmpty
{
    param (
        [string]$DistinguishedName
    )
    $object = Get-ADObject -Filter '*' -SearchBase $DistinguishedName -SearchScope OneLevel -ResultSetSize 1
    if (-not $object) {$true} else {$false}
} # Test-IsOrganizationalUnitEmpty