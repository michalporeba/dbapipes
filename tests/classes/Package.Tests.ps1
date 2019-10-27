. $PSScriptRoot\..\..\classes\Package.ps1 

Describe "Unit tests of Package class"{
    
    $words = @{ word = "abc" },@{ word = "123" }

    Context "Testing Package constructor"{

        It "Constructor sets Path to <word>" -TestCases $words {
            param($word)
            $package = [Package]::new('name', $word);
            $package.Path | Should -Be $word
        }
    }
}