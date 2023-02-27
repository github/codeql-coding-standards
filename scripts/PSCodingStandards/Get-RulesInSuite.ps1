function Get-RulesInSuite {
    param(
        [Parameter(Mandatory)] 
        [string]
        $Suite,
        [Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        [string]
        $Language
    )

    $tmpQueries = @()

    foreach ($p in Get-Packages -Language $Language) {
        Write-Host "Reading package: [$Language/$Suite/$($p.BaseName)]"        
        $tmpQueries += Get-RulesInPackageAndSuite -Package $p -Suite $Suite -Language $Language
    }

    return $tmpQueries
}
