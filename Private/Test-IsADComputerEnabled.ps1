Function Test-IsADComputerEnabled($Identity)
{
    [bool](Get-ADComputer -Identity $Identity).enabled
} # Test-IsADComputerEnabled