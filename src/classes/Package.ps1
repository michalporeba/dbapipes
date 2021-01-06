class Package {
    [ValidateNotNullOrEmpty()][String]$Name
    [ValidateNotNullOrEmpty()][String]$Path
    [String[]]$Sources
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
        $data
        $this.Path = $path
        $this.Name = $data.Name
        $this.Sources = $data.Source.Database
        $this.Tags = $data.Tag
    }
}