class Package {
    [ValidateNotNullOrEmpty()][String]$Name
    [ValidateNotNullOrEmpty()][String]$Path

    Package(
        [String]$path,
        [String]$name
    ){
        $this.Path = $path 
        $this.Name = $name
    }

    Package(
        [String]$path,
        [System.Collections.Hashtable]$data
    ){
        $this.Path = $path
        $this.Name = $data.Name
    }

}