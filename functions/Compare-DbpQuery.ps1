
function Compare-DbpQuery
{
    [CmdletBinding()]
    param(
        [String]$SqlInstance,
        [String]$Database,
        [String]$Path,
        [String[]]$File,
        [String[]]$Accept,
        [String[]]$Investigate,
        [Switch]$StopOnFirst,
        [String]$IdColumn = $null,
        [PSCustomObject]$Parameters = @{}
    )

    process {
        $template = $null;
        $templateFile = "";
        $currentFile = "";
        $executionStats = @{};
        

        if (@($File).Length -eq 1)
        {
            $File = @("$File.previous", $File)
        }

        @($File).foreach{
            $issuesFound = 0;
            $filePath = (Join-Path -Path $Path -ChildPath $psitem)
            $currentFile = $psitem 
            Write-PSFMessage -Function "Compare-DbpQuery" -Level Verbose "Executing $filePath"
            $ts = Get-Date
            $current = Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -File $filePath -SqlParameters $Parameters -EnableException
            $executionStats.Add($psitem, @{ Query = $psitem; ExecutionTime = ((Get-Date)-$ts);})

            if ($null -eq $current) {
                Write-PSFMessage -Function "Compare-DbpQuery" -Level Critical "there is no data to look at"
                return
            }

            if ($null -eq $template){
                Write-PSFMessage -Function "Compare-DbpQuery" -Level Verbose "Assinging $psitem as the template"
                $template = $current
                $templateFile = $psitem
                $templateColumns = ($template[0] | Get-Member -MemberType Property)
            } else {
                Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "Comparing results from $currentFile against $templateFile"
                #check the number of rows
                if ($template.Length -ne $current.Length) {
                    ++$issuesFound;
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  PROBLEM: Expected $($template.Length) rows but found $($current.Length)"
                    if ($StopOnFirst -eq $true) { return }
                } else {
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Verbose "  Row numbers match ($($template.Length))"
                }

                #check column numbers
                $currentColumns = ($current[0] | Get-Member -MemberType Property)
                if ($templateColumns.Length -ne $currentColumns.Length) {
                    ++$issuesFound;
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "PROBLEM: Expected $($templateColumns.Length) columns but found $($currentColumns.Length)"
                    if ($StopOnFirst -eq $true) { return }
                } else {
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Verbose "  Column numbers match ($($templateColumns.Length))"
                }

                Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "Checking $($templateColumns.Length) columns and $($template.Length) rows"

                #Check column names and types
                for($i = 0; $i -lt $templateColumns.Length; ++$i){
                    if ($templateColumns[$i].Name -ne $currentColumns[$i].Name)
                    {
                        ++$issuesFound;
                        Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  PROBLEM: Exepcted column $($templateColumns[$i].Name) at index $i but $($currentColumns[$i].Name) was found."
                        if ($StopOnFirst -eq $true) { return }
                    }
                }

                #test data column after column 
                for($i = 0; $i -lt $templateColumns.Length; ++$i){
                
                    $rowsAffected = 0
                    $firstAffectedRow = 0;
                    $expectedValue = $null;
                    $actualValue = $null 
                    if (![String]::IsNullOrEmpty($templateColumns[$i].Name) -and $templateColumns[$i].Name -in @($Investigate)){
                        Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  Investigating column $($templateColumns[$i].Name)"           
                    }
                    for($j = 0; $j -lt $template.Length; ++$j) {
                        if ($template[$j][$templateColumns[$i].Name] -cne $current[$j][$currentColumns[$i].Name]) {
                            if ($rowsAffected++ -eq 0) {
                                $firstAffectedRow = $j+1
                                $expectedValue = $template[$j][$templateColumns[$i].Name]
                                $actualValue = $current[$j][$currentColumns[$i].Name]
                            }

                            if ($templateColumns[$i].Name -in @($Investigate)){
                                if ($null -ne $IdColumn) {
                                    $IdString = " (ID=$($template[$j][$IdColumn]))"
                                }
                                Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "    Row $($j+1)$($IdString): Expected $($template[$j][$templateColumns[$i].Name]) but found $($current[$j][$currentColumns[$i].Name])"   
                            }
                        }
                    }
                    if ($templateColumns[$i].Name -in @($Accept)){
                        Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  ACCEPTED: $rowsAffected differences in column $($templateColumns[$i].Name) have been accepted."
                    } else {
                        if ($rowsAffected -gt 0) {
                            ++$issuesFound;
                            Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  PROBLEM: Value of $($templateColumns[$i].Name) in row $($firstAffectedRow) should be $($expectedValue) but was $($actualValue). ($rowsAffected rows affected)."
                            if ($StopOnFirst -eq $true) { return }
                        } else {
                            Write-PSFMessage -Function "Compare-DbpQuery" -Level Verbose "  Data in column $($templateColumns[$i].Name) matches exactly"
                        }
                    }
                }

                if ($issuesFound -eq 0){
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "No issues found in $psitem"
                } 
            } 
        }

        $executionStats.Values | Select Query, ExecutionTime
    }
}