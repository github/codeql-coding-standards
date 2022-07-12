. "$PSScriptRoot\GetPackages.ps1"
. "$PSScriptRoot\GetRulesInPackageAndSuite.ps1"

function Get-Rules-In-Suite {
    param(
        [Parameter(Mandatory)] 
        [string]
        $Suite
    )

    $tmpQueries = @()

    foreach ($p in Get-Packages) {
        Write-Host "Reading package: [$Suite/$($p.BaseName)]"        
        $tmpQueries += Get-Rules-In-Package-And-Suite -Package $p -Suite $Suite 
    }

    return $tmpQueries
}
