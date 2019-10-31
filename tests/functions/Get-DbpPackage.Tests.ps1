. $PSScriptRoot\..\..\functions\Get-DbpPackage.ps1 

Describe "Get-DbpPackage" -Tag "IntegrationTests" {

    $location = Resolve-Path $PSScriptRoot\..
    $referencePackages = @{
            Paths = @("repos\minimal", "$location\repos\minimal" )
            Cases = @{ Name = "MPA"; Path = "$location\repos\minimal\packages\MPA"; Tags = @(); Soruces = @(); },
                    @{ Name = "MPB"; Path = "$location\repos\minimal\packages\MPB"; Tags = @(); Sources = @(); }
        }, @{
            Paths = @("repos\complex", "$location\repos\complex")
            Cases = @{ Name = "Complex Package A"; Path = "$location\repos\complex\packages\CPA"; Tags = @("CpaTag"); Dbs = @("db1"); },
                    @{ Name = "Complex Package B"; Path = "$location\repos\complex\packages\CPB"; 
                       Tags = @("CpbTag1", "CpbTag2");
                       Dbs = @("db1", "db2");
                    }
        }
        
    Context "Get-DbpPackage -From nonexisting should not throw" {
        $nonexistingFolders = @{ Path = "nonexisting\repo" }, @{ Path = "X:\it\is\not\there" }
        It "Trying to read from <Path>" -TestCases $nonexistingFolders {
            param($Path)
            { Get-DbpPackage -From $Path } | Should -Not -Throw
        }
    }

    @($referencePackages).ForEach({
        $referencePackage = $psitem 

        @($referencePackage.Paths).ForEach({
            $fromPath = $psitem

            Context "Get-DbpPackage -From $fromPath" {

                # pretend the script is executed from near the test repos
                Push-Location $PSScriptRoot\..

                It "Package [<Name>] found" -TestCases $referencePackage.Cases {
                    param($Name)
                    $packages = (Get-DbpPackage -From $fromPath)
                    $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

                    $testPackage | Should -Not -BeNull
                }

                It "Package [<Name>] is in <Path>" -TestCases $referencePackage.Cases {
                    param($Name, $Path)
                    $packages = (Get-DbpPackage -From $fromPath)
                    $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

                    $testPackage.Path | Should -Be $Path
                }

                It "Package [<Name>] has all expected tags" -TestCases $referencePackage.Cases {
                    param($Name, $Tags)
                    $packages = (Get-DbpPackage -From $fromPath)
                    $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

                    @($Tags).ForEach({
                        $testPackage.Tags | Should -Contain $psitem -Because "$psitem is expected tag for $Name"
                    })
                }

                It "Package [<Name>] doesn't have unexpected tags" -TestCases $referencePackage.Cases {
                    param($Name, $Tags)
                    $packages = (Get-DbpPackage -From $fromPath)
                    $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

                    @($testPackage.Tags).ForEach({
                        $Tags | Should -Contain $psitem -Because "all the tags should be expected"
                    })
                }

                It "Package [<Name>] has all the expected sources" -TestCases $referencePackage.Cases {
                    param($Name, $Dbs)
                    $packages = (Get-DbpPackage -From $fromPath)
                    $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }
                    
                    Write-Host "TestSource = $Dbs"

                    @($Dbs).ForEach({
                        Write-Host "TestSource = $psitem"
                        $testPackage.Sources | Should -Contain $psitem -Because "$psitem is expected source for $Name"
                    })
                }

                It "Package [<Name>] doesn't have unexpected sources" -TestCases $referencePackage.Cases {
                    param($Name, $Dbs)
                    $packages = (Get-DbpPackage -From $fromPath)
                    $testPackage = $packages | Where-Object { $psitem.Name -eq $Name }

                    Write-Host "Source = $Dbs"
                    @($testPackage.Sources).ForEach({
                        Write-Host "Source = $psitem"
                        $Dbs | Should -Contain $psitem -Because "all the sources should be expected"
                    })
                }

                Pop-Location
            }
        })
    })
}