Push-Location .
$testResults = (invoke-pester .\src\tests\ -PassThru -Show fails)

if ($testResults.FailedCount -gt 0)
{
    Write-PSFMessage -Level Critical     "Tests failed!"
    return
}
Pop-Location

