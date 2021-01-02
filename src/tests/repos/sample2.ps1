@{
    Name = "Sample Package Name"
    Tag = @("Tag1", "Tag2")
    Source = @{
        Database = @("db1", "db2")
        # a source could be a list of named database
        # or a filter / pattern for database name
        # or perhaps a file or a folder
    }
    Staging = @{
        Type = "Database"
        # data could be staged in a database
        # in a local temporary folder, or 
        # in a named folder local or on network
        # it could be defined here or as a parameter or config variable
    }
    Destination = @{ 
        # could be specified here or during execution as parameter
        # or perhaps in a separate file or as a config variable
        # options should include a database table or a delivery in a file
        # through sftp or to a network share
    }
    Schedule = @{
        # could be an addition or alternative
        # to task types, so with a single external
        # trigger that runs daily all tasks could be executed
    }
    Task = @(
        { Name = "task1" }
        # a task could be defined here
        # or imported from external predefined set
        # tasks could have their own tags, but not sources, staging or destinations
        # in early versions it was possible, but it makes it too difficult to manage
        # perhaps an ability to skip execution based on some 'query' could be used
    )
}