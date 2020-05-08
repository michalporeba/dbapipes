# dbapipes

The idea is to allow simple automation of data import and export between SQL Server database and text files with PowerShell. 

It is possible to use [dbatools](https://dbatools.io/) to run a T-SQL script to query a database and then save it to a csv file, or to use the [ImportExcel](https://www.powershellgallery.com/packages/ImportExcel/) package to save it as an excel file. But it doesn't allow for easy scheduling, running and re-running data extracts (or perhaps imports) in groups or on regular bases. 

Rather than running individual `dbatools` and `ImportExcel` commands, it should be possible to configure data sources, scripts and destinations to easily schedule regular execution of data extracts. It should be possible to add extra metadata to such configurations to help with execution over date ranges. For example a monthly data export could be run for a full year, or a daily for a month. 

`Get-DbaPipe -Name sample* | Invoke-DbaPipe -From '2020-01-01' -To '2020-03-31'`

The above should be enough to run all defined data extracts with names starting with _sample_ and invoke it on predefined servers/databases for dates between 2020-01-01 and 2020-03-31. If an extract is configured as monthly, it should produce 3 monthly output files, and any that is configured as daily should produce one output file per day within the date range. The files should be saved in predefined locations, or perhaps delivered remotely over sftp and such. 
