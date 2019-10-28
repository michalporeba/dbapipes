. $PSScriptRoot\..\..\classes\Package.ps1 

Describe "Unit tests of Package class"{
    
    $words = @{ word = "abc" },@{ word = "123" }

    Context "Testing Package constructor"{

        It "Constructor sets Name to <word>" -TestCases $words {
            param($word)
            $package = [Package]::new('path', $word);
            $package.Name | Should -Be $word
        }

        It "Constructor sets Path to <word>" -TestCases $words {
            param($word)
            $package = [Package]::new($word, 'name');
            $package.Path | Should -Be $word
        }
    }
}