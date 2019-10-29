$testResults = (invoke-pester .\tests\ -PassThru)

if ($testResults.FailedCount -gt 0)
{
    Write-PSFMessage -Level Critical     "Tests failed!"
    return
}

Write-PSFMessage -Level Host "Installing the DBA Pipes module"
.\install.ps1 



