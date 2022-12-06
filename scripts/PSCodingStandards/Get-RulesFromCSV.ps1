function Get-RulesFromCSV {
    param(
        [ValidateSet('c', 'cpp', 'all')]
        [string]
        $Language = 'all')


        $csvFile = (Join-Path (Get-RepositoryRoot) "rules.csv")
    
        Write-Host "Loading rules for language=$Language from file $csvFile..."

        $csv = Import-Csv $csvFile
        $filteredCSV = @()
        # don't filter if not neeeded 
        if ($Language -eq 'all'){
            $filteredCSV = $csv
        }else{
            foreach($rule in $csv){
                if($rule.Language -eq $Language){
                    $filteredCSV += $rule 
                }
            }
        }
 
        Write-Host "Loaded $($filteredCSV.Length) rules."

        return $csv 

}