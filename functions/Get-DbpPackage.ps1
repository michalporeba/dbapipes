. $PSScriptRoot\..\classes\Package.ps1

function Get-DbpPackage
{
    [CmdletBinding()]
    param(
        [String]$From
    )
    process 
    { 
        # using Resolve-Path throws if the path doesn't exist, the below doesn't.
        $path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($From)
        
        if (Test-Path -Path $path -PathType Container)
        {
            if (Test-Path -Path "$path\packages" -PathType Container)
            {
                $path = "$path\packages"
                $packageFolders = (Get-ChildItem $path -Directory)
                @($packageFolders).ForEach({
                    if (Test-Path "$psitem\package.psd1" -PathType Leaf)
                    {
                        try {
                            [Package]::new($psitem.FullName, (Import-PowerShellDataFile -Path "$psitem\package.psd1" -ErrorAction SilentlyContinue))
                        } catch {
                            Write-PSFMessage -Function "Get-DbpPackage" -Level Verbose "Failed to load $psitem\package.psd1"
                        }
                    } else {
                        [Package]::new($psitem.FullName, $psitem.Name)
                    }
                })
            }
            else 
            {
                # TODO: there is no packages folder. look for zips
            }
        }
        elseif (Test-Path -Path $path -PathType Leaf -Filter *.zip)
        {
            # TODO: this is a zip package
        }
        
    }
}