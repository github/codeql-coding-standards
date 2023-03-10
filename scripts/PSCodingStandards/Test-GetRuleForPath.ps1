function Test-GetRuleForPath {
param(
    [Parameter(Mandatory)] 
    [string]
    $PR
)

$prData = (gh pr view -R github/codeql-coding-standards $PR --json headRefOid,headRepository,author,isCrossRepository,headRepositoryOwner,headRefName,files) | ConvertFrom-Json

foreach($f in $prData.files){
    try {
        Write-Host "[C] Scanning file for relationship $($f.path)..."
        $rulesToTest = Get-RuleForPath -Language c -Path "$($f.path)"
     
        Write-Host "[C] Got $($rulesToTest.Count) potential C rules..."
     
        foreach($r in $rulesToTest){
            $ruleNames += $r.__memberof_rule 
            Write-Host "[C] Found rule $r "
        }
    }catch{
        Write-Host "No $Language rules found for path: $($f.path)"
    }


    try {
        Write-Host "[CPP] Scanning file for relationship $($f.path)..."
        $rulesToTest = Get-RuleForPath -Language cpp -Path "$($f.path)"
     
        Write-Host "[CPP] Got $($rulesToTest.Count) potential CPP rules..."
     
        foreach($r in $rulesToTest){
            Write-Host "[CPP] Found rule $r "
        }
    }catch{
        Write-Host "No CPP rules found for path: $($f.path)"
    }
}
}