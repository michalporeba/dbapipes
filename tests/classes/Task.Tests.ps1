. $PSScriptRoot\..\..\classes\Task.ps1 

Describe "Unit tests of Test class"{
    
    $testData = @(@{ Task = @{
        Query = "query1.sql"
    }}, @{ Task = @{
        Query = "query2.sql"
    }})

    Context "Testing Task constructor"{

        It "Constructor sets Query" -TestCases $testData {
            param($Task)
            $task = [Task]::new($Task);
            $task.Query | Should -Be $Task.Query -Because "it should be $($Task.Query)"
        }
    }
}