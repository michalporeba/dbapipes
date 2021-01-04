class Task 
{
    [String]$Query
    [String]$Name

    Task(
        [System.Collections.Hashtable]$data
    ){
        $this.Query = $data.Query
        $this.Name = ($data.Name, $data.Query, "" -ne $null)[0]
    }
}