#!/usr/bin/env pwsh
param(
    # path to the matrix file. 
    [Parameter(Mandatory)] 
    [string]
    $MatrixReport,

    [Parameter(Mandatory = $false)] 
    [string]
    $ReportDir = (Get-Location),
    
    [Parameter(Mandatory)] 
    [ValidateSet('c', 'cpp')]
    [string]
    $Language,

    # The compiler to use.
    [Parameter(Mandatory)] 
    [ValidateSet('clang', 'armclang', 'tiarmclang', 'gcc', 'qcc')]
    [string]
    $Configuration
)

Import-Module -Name "$PSScriptRoot/../PSCodingStandards/CodingStandards"

. "$PSScriptRoot/NewDatabaseForRule.ps1"
. "$PSScriptRoot/Config.ps1"
. "$PSScriptRoot/Get-CompilerExecutable.ps1"

#
# Verify All the Required CLI Tools are Installed
#
Write-Host "Checking 'codeql' program...." -NoNewline
Test-ProgramInstalled -Program "codeql" 
Write-Host -ForegroundColor ([ConsoleColor]2) "OK" 

$CODEQL_VERSION = (codeql version --format json | ConvertFrom-Json).version 

Write-Host "Checking 'codeql' version = $REQUIRED_CODEQL_VERSION...." -NoNewline
if (-Not ($CODEQL_VERSION -eq $REQUIRED_CODEQL_VERSION)) {
    throw "Invalid CodeQL version $CODEQL_VERSION. Please install $REQUIRED_CODEQL_VERSION."
}
Write-Host -ForegroundColor ([ConsoleColor]2) "OK" 

Write-Host "Checking '$(Get-CompilerExecutable -Configuration $Configuration -Language $Language)' program...." -NoNewline
Test-ProgramInstalled -Program (Get-CompilerExecutable -Configuration $Configuration -Language $Language)
Write-Host -ForegroundColor ([ConsoleColor]2) "OK"     


$allQueries = @()

# load all the queries 
foreach ($s in $AVAILABLE_SUITES) {
    $allQueries += Get-RulesInSuite -Suite $s -Language $Language
}

$csv = Import-CSV $MatrixReport

# filter down to the rows that failed 
$failedQueries = $csv | Where-Object { $_.COMPILE_PASS -eq $false }


$PROMPT = @"
################ COMPILE FAILED FOR QUERY {0} ################
Suite        : {1} 
Package      : {2}
Rule         : {3}
Path to test : {4} [ctrl+click to edit]

You may attempt to fix the file and recompile using this tool
iteratively. 

Queries Currently in Triage: {5}
This is Query {6} of {7}
-------------------------------------------------------------
Action(1=Attempt Compile, 2=Next, 3=Add to Triage, 4=Save Progress and Write Triage Report)

"@

function Get-Query-From-Name {
    param(
        [Parameter(Mandatory)] 
        [array]
        $AllQueries,
        [Parameter(Mandatory)] 
        [string]
        $RuleName
    )

    foreach ($q in $AllQueries) {
        if ($q.short_name -eq $RuleName) {
            return $q
        }
    }

    throw "Cannot find query $RuleName."
}

$TRIAGE = @() 

$ctr = 0

:ctrl foreach ($row in $failedQueries) {
    $ctr += 1

    while ($true) {
        $q = Get-Query-From-Name -AllQueries $allQueries -RuleName $row.QUERY    
    
        $testDirectory = (Get-TestDirectory -RuleObject $q -Language $Language)
        $testPath = Join-Path $testDirectory "test.cpp"

        $P = $PROMPT -f $row.QUERY, $row.SUITE, $row.PACKAGE, $row.RULE, $testPath, $TRIAGE.Length, $ctr, $failedQueries.Length

        $cmd = Read-Host -Prompt $P

        if ($cmd -eq "1") {

            try {
                New-Database-For-Rule -RuleName $row.RULE -RuleTestDir $testDirectory -Configuration $Configuration -Language $Language
                Write-Host -ForegroundColor ([ConsoleColor]2) "OK" 
            }
            catch {
                Write-Host -ForegroundColor ([ConsoleColor]4) "FAILED"
            }
        }

        if ($cmd -eq "2") {
            break 
        }


        if ($cmd -eq "3") {
            $TRIAGE += $row 
            break 
        }
        
        if ($cmd -eq "4") {
            $TRIAGE += $row 
            break ctrl 
        }
    }
}

# write out the triage report 
$fileTag = "$($Configuration.ToLower())-$(Get-Date -Format "yyyy-MM-dd_HH-mm-ss")"

$reportOutputFile = Join-Path $ReportDir "CompileTriageReport-$fileTag.csv"

# Write out the detailed report 
Write-Host "Writing detailed triage report to $reportOutputFile"
foreach ($r in $TRIAGE) {
    [PSCustomObject]$r | Export-CSV -Path $reportOutputFile -Append -NoTypeInformation
}
