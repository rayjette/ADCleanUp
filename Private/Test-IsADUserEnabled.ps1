Function Test-IsADUserEnabled($Identity)
{
    [bool](Get-ADUser -Identity $Identity).enabled
} # Test-IsADUserEnabled