class Package {
    [ValidateNotNullOrEmpty()][String]$Name
    [ValidateNotNullOrEmpty()][String]$Path

    Package(
        [String]$name,
        [String]$path
    ){
        $this.Name = $name
        $this.Path = $path 
    }

}