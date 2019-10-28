. $PSScriptRoot\..\..\functions\Get-DbpPackage.ps1 

Describe "Get-DbpPackage" -Tag "IntegrationTests" {

    $location = Resolve-Path $PSScriptRoot\..
    $testPackages = @{
            Paths = @("repos\minimal", "$location\repos\minimal" )
            Cases = @{ Name = "MPA"; Path = "$location\repos\minimal\packages\MPA" },
                    @{ Name = "MPB"; Path = "$location\repos\minimal\packages\MPB" }
        }, @{
            Paths = @("repos\complex", "$location\repos\complex")
            Cases = @{ Name = "Complex Package A"; Path = "$location\repos\complex\packages\CPA" },
                    @{ Name = "Complex Package B"; Path = "$location\repos\complex\packages\CPB" }
        }
        
    Context "Get-DbpPackage -From nonexisting should not throw" {
        $nonexistingFolders = @{ Path = "nonexisting\repo" }, @{ Path = "X:\it\is\not\there" }
        It "Trying to read from <Path>" -TestCases $nonexistingFolders {
            param($Path)
            { Get-DbpPackage -From $Path } | Should -Not -Throw
        }
    }

    @($testPackages).ForEach({
        $testPackage = $psitem 

        @($testPackage.Paths).ForEach({
            $fromPath = $psitem

            Context "Get-DbpPackage -From $fromPath" {

                # pretend the script is executed from near the test repos
                Push-Location $PSScriptRoot\..

                It "Package <Name> found" -TestCases $testPackage.Cases {
                    param($Name)
                    $packages = (Get-DbpPackage -From $fromPath)

                    $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

                    $testPackage | Should -Not -BeNull
                }

                It "Package <Name> is in <Path>" -TestCases $testPackage.Cases {
                    param($Name, $Path)
                    $packages = (Get-DbpPackage -From $fromPath)

                    $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

                    $testPackage.Path | Should -Be $Path
                }

                Pop-Location
            }
        })
    })
}