class Task 
{
    [String]$Query 

    Task(
        [System.Collections.Hashtable]$data
    ){
        $this.Query = $data.Query
    }
}