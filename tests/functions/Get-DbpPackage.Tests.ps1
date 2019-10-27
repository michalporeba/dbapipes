. $PSScriptRoot\..\..\functions\Get-DbpPackage.ps1 

Describe "Get-DbpPackage" -Tag "IntegrationTests" {

    $location = Resolve-Path $PSScriptRoot\..
    $cases = @{ Name = "MPA"; Path = "$location\repos\minimal\packages\MPA"},
             @{ Name = "MPB"; Path = "$location\repos\minimal\packages\MPB"}

    Context "Get-DbpPackage -From nonexisting should not throw" {
        $nonexistingFolders = @{ Path = "nonexisting\repo" }, @{ Path = "X:\it\is\not\there" }
        It "Trying to read from <Path>" -TestCases $nonexistingFolders {
            param($Path)
            { Get-DbpPackage -From $Path } | Should -Not -Throw
        }
    }

    Context "Get-DbpPackage -From repos\minimal" {

        # pretend the script is executed from near the test repos
        Push-Location $PSScriptRoot\..

        It "Package <Name> found" -TestCases $cases {
            param($Name)
            $packages = (Get-DbpPackage -From repos\minimal)

            $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

            $testPackage | Should -Not -BeNull
        }

        It "Package <Name> is in <Path>" -TestCases $cases {
            param($Name, $Path)
            $packages = (Get-DbpPackage -From repos\minimal)

            $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

            $testPackage.Path | Should -Be $Path
        }

        Pop-Location
    }

    Context "Get-DbpPackage -From $location\repos\minimal" {
        It "Package <Name> found" -TestCases $cases {
            param($Name)
            $packages = (Get-DbpPackage -From $location\repos\minimal)

            $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

            $testPackage | Should -Not -BeNull
        }

        It "Package <Name> is in <Path>" -TestCases $cases {
            param($Name, $Path)
            $packages = (Get-DbpPackage -From $location\repos\minimal)

            $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

            $testPackage.Path | Should -Be $Path
        }
    }
}