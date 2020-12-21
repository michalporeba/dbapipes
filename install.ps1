Push-Location $PSScriptRoot

if (@(Get-Module dbapipes).Count -gt 0) { 
    Remove-Module dbapipes 
}

Import-Module $PSScriptRoot\src\dbapipes.psd1 

Pop-Location