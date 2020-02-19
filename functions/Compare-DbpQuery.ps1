
function Compare-DbpQuery
{
    [CmdletBinding()]
    param(
        [String]$SqlInstance,
        [String]$Database,
        [String]$Path,
        [String[]]$File
    )

    process {
        $template = $null;
        $templateFile = "";
        $currentFile = "";

        @($File).foreach{
            $filePath = (Join-Path -Path $Path -ChildPath $psitem)
            Write-PSFMessage -Function "Compare-DbpQuery" -Level Verbose "Executing $filePath"
            $currentFile = $psitem 
            $current = Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -File $filePath

            if ($null -eq $template){
                $template = $current
                $templateFile = $psitem
                $templateColumns = ($template[0] | Get-Member -MemberType Property)
            } else {
                Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "Comparing results from $currentFile and $templateFile"
                #check the number of rows
                if ($template.Length -ne $current.Length) {
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Warning "Expected $($template.Length) rows but found $($current.Length)"
                    return
                } else {
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  Row numbers match ($($template.Length))"
                }

                #check column numbers
                $currentColumns = ($current[0] | Get-Member -MemberType Property)
                if ($templateColumns.Length -ne $currentColumns.Length) {
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Warning "Expected $($templateColumns.Length) columns but found $($currentColumns.Length)"
                    return
                } else {
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  Column numbers match ($($templateColumns.Length))"
                }

                #Check column names and types
                for($i = 0; $i -lt $templateColumns.Length; ++$i){
                    if ($templateColumns[$i].Name -ne $currentColumns[$i].Name)
                    {
                        Write-PSFMessage -Function "Compare-DbpQuery" -Level Warning "  Exepcted column $($templateColumns[$i].Name) at index $i but $($currentColumns[$i].Name) was found."
                        return
                    }
                }

                #test data column after column 
                for($i = 0; $i -lt $templateColumns.Length; ++$i){
                    for($j = 0; $j -lt $template.Length; ++$j) {
                        if ($template[$j][$templateColumns[$i].Name] -ne $current[$j][$currentColumns[$i].Name]) {
                            Write-PSFMessage -Function "Compare-DbpQuery" -Level Warning "  Value of $($templateColumns[$i].Name) in row $($j+1) should be $($template[$j][$templateColumns[$i].Name]) but was $($current[$j][$currentColumns[$i].Name])"
                            return 
                        }
                    }
                    Write-PSFMessage -Function "Compare-DbpQuery" -Level Output "  Data in column $($templateColumns[$i].Name) matches exactly"
                }    
            }
            
        }
    }
}