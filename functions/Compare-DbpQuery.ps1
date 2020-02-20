
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

        if (@($File).Length -eq 1)
        {
            $File = @($File,"$File.previous")
        }

        @($File).foreach{
            $filePath = (Join-Path -Path $Path -ChildPath $psitem)
            Write-PSFMessage -Function "Compare-DbpQuery" -Level Verbose "Executing $filePath"
            $currentFile = $psitem 
            $current = Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -File $filePath -SqlParameters $Parameters -EnableException

            if ($null -eq $current) {
                Write-PSFMessage -Function "Compare-DbpQuery" -Level Critical "there is no data to look at"
                return
            }

            if ($null -eq $template){
                $template = $current
                $templateFile = $psitem
                $templateColumns = ($template[0] | Get-Member -MemberType Property)
            } else {
                Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "Comparing results from $currentFile and $templateFile"
                #check the number of rows
                if ($template.Length -ne $current.Length) {
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  PROBLEM: Expected $($template.Length) rows but found $($current.Length)"
                    if ($StopOnFirst -eq $true) { return }
                } else {
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Verbose "  Row numbers match ($($template.Length))"
                }

                #check column numbers
                $currentColumns = ($current[0] | Get-Member -MemberType Property)
                if ($templateColumns.Length -ne $currentColumns.Length) {
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "PROBLEM: Expected $($templateColumns.Length) columns but found $($currentColumns.Length)"
                    if ($StopOnFirst -eq $true) { return }
                } else {
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Verbose "  Column numbers match ($($templateColumns.Length))"
                }

                Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  Columns = $($templateColumns.Length), Rows = $($template.Length)"

                #Check column names and types
                for($i = 0; $i -lt $templateColumns.Length; ++$i){
                    if ($templateColumns[$i].Name -ne $currentColumns[$i].Name)
                    {
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
                    if ($templateColumns[$i].Name -in @($Investigate)){
                        Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  Investigating column $($templateColumns[$i].Name)"           
                    }
                    for($j = 0; $j -lt $template.Length; ++$j) {
                        if ($template[$j][$templateColumns[$i].Name] -ne $current[$j][$currentColumns[$i].Name]) {
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
                            Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  PROBLEM: Value of $($templateColumns[$i].Name) in row $($firstAffectedRow) should be $($expectedValue) but was $($actualValue). ($rowsAffected rows affected)."
                            if ($StopOnFirst -eq $true) { return }
                        } else {
                            Write-PSFMessage -Function "Compare-DbpQuery" -Level Verbose "  Data in column $($templateColumns[$i].Name) matches exactly"
                        }
                    }
                }    
            }
            
        }
    }
}