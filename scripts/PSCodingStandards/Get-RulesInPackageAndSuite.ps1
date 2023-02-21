
function Get-RulesInPackageAndSuite {
    param(
        [Parameter(Mandatory)] 
        [System.IO.FileSystemInfo]
        $Package,
        [Parameter(Mandatory)] 
        [string]
        $Suite,
        [Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        [string]
        $Language
        )

    $rulesInPackage = @()

    $ds = Get-Content $Package | ConvertFrom-Json

    $suiteRules = $ds.$Suite 

    if (-Not $suiteRules) {
        Write-Host "No $Suite rules found in $Package."
        return $rulesInPackage
    }

    $rules = $suiteRules | Get-Member -MemberType NoteProperty

    foreach ($n in $rules) {
        Write-Host "Loading rule $Suite/$($p.BaseName)/$($n.Name)"

        $queries = $suiteRules."$($n.Name)".queries 
        # for each query, we add some additional metadata for later filtering 
        $queries | Add-Member -NotePropertyName __memberof_suite -NotePropertyValue $Suite
        $queries | Add-Member -NotePropertyName __memberof_package -NotePropertyValue $Package.BaseName
        $queries | Add-Member -NotePropertyName __memberof_rule -NotePropertyValue $n.Name 
        $queries | Add-Member -NotePropertyName __memberof_language -NotePropertyValue $Language 
        
        $rulesInPackage += $queries 
    }

    return $rulesInPackage
}
