class Package {
    [ValidateNotNullOrEmpty()][String]$Name
    [ValidateNotNullOrEmpty()][String]$Path
    [String[]]$Tags
    
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
        $this.Tags = $data.Tag
    }

}