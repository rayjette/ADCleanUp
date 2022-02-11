#Requires -Modules ActiveDirectory, GroupPolicy

# Get public and private function definition files.
$PrivateFunctions = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$PublicFunctions = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)


# Dot source the public and private functions
foreach ($import in @($PrivateFunctions + $PublicFunctions))
{
    try
    {
        . $import.fullname
    }
    catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}