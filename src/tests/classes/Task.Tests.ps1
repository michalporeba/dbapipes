. $PSScriptRoot\..\..\classes\Task.ps1 

Describe "Unit tests of Test class"{
    
    $testData = @(@{ 
        Task = @{ Query = "query1.sql" }
        Name = "query1.sql"
    }, @{ 
        Task = @{ Name = "Query2"; Query = "query2.sql" }
        Name = "Query2"
    })

    Context "Testing Task constructor"{

        It "Constructor sets Query" -TestCases $testData {
            param($Task, $Name)
            $sut = [Task]::new($Task);
            $sut.Query | Should -Be $Task.Query -Because "it should be $($Task.Query)"
            $sut.Name | Should -Be $Name -Because "it should be $($Name)"
        }
    }
}