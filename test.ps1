$testResults = (invoke-pester .\tests\ -PassThru -Show fails)

if ($testResults.FailedCount -gt 0)
{
    Write-PSFMessage -Level Critical     "Tests failed!"
    return
}

Write-PSFMessage -Level Host "Installing the DBA Pipes module"
.\install.ps1 

Compare-DbpQuery -SqlInstance localhost -Database tempdb -Path D:\SqlCompare\ -File Sample.sql,Matching.sql,Different.sql



