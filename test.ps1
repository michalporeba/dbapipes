Push-Location .\src
$testResults = (invoke-pester .\tests\ -PassThru -Show fails)

Pop-Location


if ($testResults.FailedCount -gt 0)
{
    Write-PSFMessage -Level Critical     "Tests failed!"
    return
}


