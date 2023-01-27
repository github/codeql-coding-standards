#!/usr/bin/env pwsh
param(    
    [ValidateSet('c', 'cpp', 'all')]
    [string]
    $Language = 'all',
    [switch]
    $CIMode

)

Import-Module -Name "$PSScriptRoot/../PSCodingStandards/CodingStandards"

# load the rules.
$rules = Get-RulesFromCSV -Language $Language

# find out duplicates
$counter = @{} 

foreach($rule in $rules){
    $key = "$($rule.Language):$($rule.Standard):$($rule.ID)"
    if($counter.Contains($key)){
        $counter[$key] += $rule
    }else{
        $counter[$key] = @()
        $counter[$key] += $rule
    }
}

$duplicates = @()
$numDuplicates = 0

foreach($k in $counter.Keys){
    if($counter[$k].Count -gt 1){
        $numDuplicates = $numDuplicates + 1 
        foreach($v in $counter[$k]){
            $duplicates += $v           
        }    
    }
}

$duplicates | Format-Table 

if(($CIMode) -and ($numDuplicates -gt 0)){
    throw "Found $numDuplicates duplicate Rule IDs"
}else{
    Write-Host "Found $numDuplicates duplicate Rule IDs"
}