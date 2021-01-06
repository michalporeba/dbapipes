. $PSScriptRoot\..\classes\Package.ps1

function Get-DbpPackage
{
    [CmdletBinding()]
    param(
        [String]$From
    )
    begin 
    {
        Write-PSFMessage -Level Verbose -Message "starting Get-DbpPackage"
    }
    process 
    { 
        if (-not (Test-Path $From)) { 
            Write-PSFMessage -Level Warning "$From does not exist"
            return 
        }

        # using Resolve-Path throws if the path doesn't exist, the below doesn't.

        $path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($From)
        
        if (Test-Path -Path $path -PathType Container)
        {
            $path = "$path\packages"
            if (Test-Path -Path "$path" -PathType Container)
            {
                Write-PSFMessage -Level Verbose -Message "Looking for packages in $path"
                
                $packageFolders = (Get-ChildItem $path -Directory)
                @($packageFolders).ForEach({
                    Write-PSFMessage -Level Verbose -Message "Folder is $psitem"
                    if (Test-Path "$path\$psitem\package.psd1" -PathType Leaf)
                    {
                        try {
                            $packageConfig = (Import-PowerShellDataFile -Path "$path\$psitem\package.psd1" -ErrorAction SilentlyContinue)
                            [Package]::new($psitem.FullName, $packageConfig)
                        } catch {
                            Write-PSFMessage -Level Verbose "Failed to load $psitem\package.psd1"
                        }
                    } else {
                        Write-PSFMessage -Level Warning -Message "Missing package.psd1"
                        [Package]::new($psitem.FullName, $psitem.Name)
                    }
                })
            }
            else 
            {
                # TODO: there is no packages folder. look for zips
                Write-PSFMessage -Level Warning -Message "There is no '$($path)packages' folder"
            }
        }
        elseif (Test-Path -Path $path -PathType Leaf -Filter *.zip)
        {
            # TODO: this is a zip package
            Write-PSFMessage -Message "Must be a ZIP package. currently not supported"
        }
    }
}