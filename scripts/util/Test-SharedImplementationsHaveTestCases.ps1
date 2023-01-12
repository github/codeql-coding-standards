#!/usr/bin/env pwsh
param(    
    [ValidateSet('c', 'cpp')]
    [string]
    $Language = 'c',
    [Parameter(Mandatory = $false)] 
    [string]
    $ReportDir = (Get-Location),
    [switch]
    $CIMode
)

Import-Module -Force -Name "$PSScriptRoot/../PSCodingStandards/CodingStandards"

$allQueries = @()
$queriesToCheck = @()

# load all the queries 
foreach ($s in $AVAILABLE_SUITES) {
    $allQueries += Get-RulesInSuite -Suite $s -Language $Language
}

foreach ($q in $allQueries){
    if($q | Get-Member "shared_implementation_short_name"){
        $queriesToCheck += $q
    }
}

if ($queriesToCheck.Count -eq 0) {
    throw "No queries loaded."
}
else {
    Write-Host "Loaded $($queriesToCheck.Count) queries with shared implementations."
}

# What we want to verify is that IF a shared implementation is used, then we
# have a valid test case WITHIN the language that is using it. 

$REPORT = @()

foreach($q in $queriesToCheck){
    # Get test directory 
    $testDirectory = Get-TestDirectory -RuleObject $q -Language $Language
    Write-Host "Verifying $Language language tests in $testDirectory..."    


    $row = @{
        "SUITE"               = $q.__memberof_suite;
        "PACKAGE"             = $q.__memberof_package;
        "RULE"                = $q.__memberof_rule;
        "QUERY"               = $q.short_name;
        "SHARED_NAME"         = $q.shared_implementation_short_name;
        "TEST_DIR_EXISTS"             = $false;
        "SOURCE_CODE_EXISTS"           = $false;        
        "EXPECTED_EXISTS"              = $false;
        "REFERENCE_EXISTS"              = $false;
   }

    # require a .c for language cpp
    # require a .expected 
    # require a .ql 

    if(-not (Test-Path $testDirectory)){
        Write-Host "Test directory $testDirectory does not exist."
        $REPORT += $row 

        continue 
    }

    $dirName = (Get-Item $testDirectory).Basename 
    $dirNameLower = $dirName.ToLower()
    $sharedName = $q.shared_implementation_short_name

    $row["TEST_DIR_EXISTS"] = $true 

    if((Test-Path (Join-Path $testDirectory "test.$Language"))){
        $row["SOURCE_CODE_EXISTS"] = $true 
    }else{
        Write-Host "-SOURCE $((Join-Path $testDirectory "test.$Language")) missing"
    }

    if((Test-Path (Join-Path $testDirectory "$sharedName.expected"))){
        $row["EXPECTED_EXISTS"] = $true 
    }else{
        Write-Host "-EXPECTED $((Join-Path $testDirectory "$sharedName.expected")) missing"
    }

    if((Test-Path (Join-Path $testDirectory "$sharedName.ql"))){
        $row["REFERENCE_EXISTS"] = $true 
    }else{
        Write-Host "-QL $((Join-Path $testDirectory "$sharedName.ql")) missing"
    }

    $REPORT += $row 
}

# output a CSV containing the elements that do not contain 
$fileTag = "$Language-$(Get-Date -Format "yyyy-MM-dd_HH-mm-ss")"
$reportOutputFile = Join-Path $ReportDir "TestReport-$fileTag.csv"
$missingReportOutputFile = Join-Path $ReportDir "MissingTestReport-$fileTag.csv"

$failCount = 0
foreach ($r in $REPORT) {
    if(($r["TEST_DIR_EXISTS"] -eq $false) -or ($r["SOURCE_CODE_EXISTS"] -eq $false) -or ($r["EXPECTED_EXISTS"] -eq $false) -or ($r["REFERENCE_EXISTS"] -eq $false)){
        $failCount += 1
        [PSCustomObject]$r | Export-CSV -Path $missingReportOutputFile -Append -NoTypeInformation
    }
    [PSCustomObject]$r | Export-CSV -Path $reportOutputFile -Append -NoTypeInformation
}

Write-Host "Write report to $reportOutputFile"

if(($CIMode) -and ($failCount -gt 0)){
    throw "Found $failCount/$($queriesToCheck.Count) invalid shared test uses"
}else{
    Write-Host "Found $failCount/$($queriesToCheck.Count) invalid shared test uses"
}
