# Fill in the destination and search bases
$destination = ""
$searchBases = @(
    "",
    ""
)

# Getting variables ready
$filesToDeploy = (Get-ChildItem -Path .\files).Name
$computers = @()
$sortedComputers = @()

# Let's build a list of computers to deploy to!
# Depending on the scenario, comment and uncomment the various Get-Computer commands
foreach ($searchBaseItem in $searchBases) {
    $searchBaseItem
    ################  Specific Terminals  ################
    <# 
    $computers = @(
        "",
        "",
        ""
    )
    #>


    ################  Specific Locations  ################
    <# $filterString = "Name -like 'AA##*' -or Name -like 'AA##*'"

    $computers += (Get-ADComputer -Filter $filterString -SearchBase $searchBaseItem). name | Sort-Object
    $computers += (Get-ADComputer -Filter $filterString -SearchBase $searchBaseItem).name    | Sort-Object #>


    ################  Everyone  ################
    $computers += (Get-ADComputer -Filter "*" -SearchBase $searchBaseItem).name
}

# Now we sort for easier follow up later on
$sortedComputers = $computers | Sort-Object

# Go Go GO!!!!
ForEach ($computer in $sortedComputers) {
    Write-Host "$computer, are you there? ..." -foregroundcolor yellow -backgroundcolor black

    if (Test-Connection -ComputerName $computer -Quiet) {
        
        Write-Host "Connected to $computer!" -foregroundcolor yellow -backgroundcolor black
        foreach ($file in $filesToDeploy) {
            if (!(Test-Path "\\$computer\$destination\$file")) {
                Write-Host "Copying $file to $computer" -ForegroundColor DarkCyan -BackgroundColor Black
                Copy-Item ".\files\$file" -Destination "\\$computer\$destination"
            } else {
                Write-Host "---$file--- already deployed to $computer" -ForegroundColor Green -BackgroundColor Black
            }
        }
   
    } else {
        Write-Host "$computer didn't answer...  :(" -foregroundcolor yellow -backgroundcolor black
        $computer | Out-File -FilePath "failed_connections.txt" -Append -NoClobber
    }
}
