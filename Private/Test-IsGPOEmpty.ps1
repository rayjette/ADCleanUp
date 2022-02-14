Function Test-IsGPOEmpty
{
    param (
        [Microsoft.GroupPolicy.Gpo]$GPO
    )
    [bool](($GPO.user.dsversion -eq 0) -and ($GPO.computer.dsversion -eq 0))
} # Test-IsGPOEmpty