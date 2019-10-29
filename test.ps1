$testResults = (invoke-pester .\tests\ -PassThru)

if ($testResults.FailedCount -gt 0)
{
    Write-PSFMessage -Level Error "Tests failed!"
    return
}

Write-PSFMessage -Level Host "Installing the DBA Pipes module"
.\install.ps1 

Write-PSFMessage -Level Host "Copying test packages to C:\DbaPipes"



