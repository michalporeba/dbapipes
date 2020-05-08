$testResults = (invoke-pester .\tests\ -PassThru -Show fails)

if ($testResults.FailedCount -gt 0)
{
    Write-PSFMessage -Level Critical     "Tests failed!"
    return
}

