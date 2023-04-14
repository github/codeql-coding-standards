<#
.SYNOPSIS
    Test release performance. Generates outputs 2 csv files containing the slowest predicates as well as the queries
    causing work. Note that the method of computing query execution time is inaccurate due to the shared nature of 
    predicates. 

.DESCRIPTION
    Test release performance. Generates outputs 2 csv files containing the slowest predicates as well as the queries
    causing work. Note that the method of computing query execution time is inaccurate due to the shared nature of 
    predicates. 
#>
param(
    # Configures tool to run tests. 
    [Parameter(Mandatory, ParameterSetName = 'RunTests')] 
    [switch]
    $RunTests,

    # Specifies the number of threads to use.
    [Parameter(Mandatory=$false, ParameterSetName = 'RunTests')] 
    [string]
    $Threads=5,

    # Specifies the database to use for testing. Should be a zipped database 
    # directory. 
    [Parameter(Mandatory, ParameterSetName = 'RunTests')] 
    [string]
    $DatabaseArchive,

    # The timestamp to use for the test.
    [Parameter(Mandatory = $false, ParameterSetName = 'RunTests')] 
    [string]
    $TestTimestamp=(Get-Date -Format "yyyy-MM-dd_HH-mm-ss"),

    # The path to the coding standards root directory. This can be either the 
    # root of the repository or the root of the coding standards directory. 
    [Parameter(Mandatory=$false, ParameterSetName = 'RunTests')] 
    [string]
    $CodingStandardsPath="$PSScriptRoot/../../",

    [Parameter(Mandatory, ParameterSetName = 'ProcessResults')] 
    [switch]
    $ProcessResults,

    # Configures tool to process results.
    [Parameter(Mandatory, ParameterSetName = 'ProcessResults')] 
    [string]
    $ResultsFile,
    # Where results should be written to.
    [Parameter(Mandatory=$false)] 
    [string]
    $ResultsDirectory = (Join-Path (Get-Location) "performance_tests"),
    
    # The release tag to use for the test. 
    [Parameter(Mandatory=$false)] 
    [string]
    $ReleaseTag = "current",
    # Which suite to run.
    [Parameter(Mandatory)] 
    [ValidateSet('cert', 'misra', 'autosar')]
    [string]
    $Suite,
    # The platform to run on. This is just a descriptive string.
    [Parameter(Mandatory=$false)] 
    [string]
    $Platform=$PSVersionTable.Platform,
    # The language to run on.
    [Parameter(Mandatory)] 
    [ValidateSet('c', 'cpp')]
    [string]
    $Language
)

Import-Module -Name "$PSScriptRoot/../PSCodingStandards/CodingStandards"

. "$PSScriptRoot/Config.ps1"
. "$PSScriptRoot/Get-TestTmpDirectory.ps1"
. "$PSScriptRoot/Convert-DurationStringToMs.ps1"
. "$PSScriptRoot/Get-DurationString.ps1"
. "$PSScriptRoot/Get-QueryString.ps1"

# Test Programs 
Write-Host "Checking 'codeql' program...." -NoNewline
Test-ProgramInstalled -Program "codeql" 
Write-Host -ForegroundColor ([ConsoleColor]2) "OK" 

$CODEQL_VERSION = (codeql version --format json | ConvertFrom-Json).version 

Write-Host "Checking 'codeql' version = $REQUIRED_CODEQL_VERSION...." -NoNewline
if (-Not ($CODEQL_VERSION -eq $REQUIRED_CODEQL_VERSION)) {
    throw "Invalid CodeQL version $CODEQL_VERSION. Please install $REQUIRED_CODEQL_VERSION."
}
Write-Host -ForegroundColor ([ConsoleColor]2) "OK"



# Create the results/work directory 
$RESULTS_DIRECTORY = Get-TestTmpDirectory 
New-Item -Path $RESULTS_DIRECTORY -ItemType Directory | Out-Null

Write-Host "Writing Results to $RESULTS_DIRECTORY"

if (-Not $ProcessResults){

    $DB_UNPACKED_TMP = Join-Path $RESULTS_DIRECTORY db-unpacked
    $DB_UNPACKED     = Join-Path $RESULTS_DIRECTORY db
    $DB_FILENAME     = (Get-Item $DatabaseArchive).Name
    Write-Host "Copying database to $RESULTS_DIRECTORY..."
    # Copy and unpack the dataset 
    Copy-Item -Path $DatabaseArchive -Destination $RESULTS_DIRECTORY

    Expand-Archive -LiteralPath $RESULTS_DIRECTORY\$DB_FILENAME -DestinationPath $DB_UNPACKED_TMP 

    foreach($f in Get-ChildItem $DB_UNPACKED_TMP){
        Move-Item -Path $f -Destination $DB_UNPACKED 
    }


    $SARIF_OUT = Join-Path $RESULTS_DIRECTORY "suite=$Suite,datum=sarif.sarif"
    $EvaluatorLog = Join-Path $RESULTS_DIRECTORY "evaluator-log.json"
    $EvaluatorResults = Join-Path $RESULTS_DIRECTORY "evaluator-results.json"


    $stdOut = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())
    $stdErr = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())
        
    Write-Host "Standard Out Buffered to: $stdOut"
    Write-Host "Standard Error Buffered to: $stdErr"

    $SuiteRoot = Join-Path $Language $Suite "src" "codeql-suites"
    # For some reason nothing is written to stdout so we use stderr 
    $SuitePath = Join-Path $CodingStandardsPath $SuiteRoot ($Suite + "-default.qls")
    $procDetails = Start-Process -FilePath "codeql" -PassThru -NoNewWindow -Wait -ArgumentList "database analyze --rerun --threads $Threads --debug --tuple-counting  --evaluator-log=$EvaluatorLog --format sarif-latest --search-path $(Resolve-Path $CodingStandardsPath) --output $SARIF_OUT $DB_UNPACKED $SuitePath" -RedirectStandardOutput $stdOut -RedirectStandardError $stdErr

    if (-Not $procDetails.ExitCode -eq 0) {
        Get-Content $stdErr | Out-String | Write-Host 
        Write-Host -ForegroundColor ([ConsoleColor]4) "FAILED" 
        throw "Performance suite failed to run. Will not report data."
    }
    else {
        Write-Host -ForegroundColor ([ConsoleColor]2) "OK" 
        $runData = $stdErr
    }

}else{
    $runData = $ResultsFile
}
# Step 1: Compile data from queries
# 
$PERFORMANCE_DATA = @()

foreach($l in Get-Content $runData){

    # skip lines that aren't ones we can process
    if(-Not $l.Contains("Evaluation done;")){
        continue 
    }

    $durationString = Get-DurationString -LogLine $l 
    $queryString    = Get-QueryString -LogLine $l 
    $timeInMs       = Convert-DurationStringToMs -DurationString $durationString 

    $row = @{
        "Query"           = $queryString;
        "TimeInMs"         = $timeInMs;
    }

    Write-Host "LOG: Duration=$durationString; TimeInMs=$timeInMs; Query=$queryString"

    $PERFORMANCE_DATA += $row 
}
# Step 2: Compile predicate data 
#
#

# the data must first be transformed 
$procDetails = Start-Process -FilePath "codeql" -PassThru -NoNewWindow -Wait -ArgumentList "generate log-summary $EvaluatorLog  $EvaluatorResults"

if (-Not $procDetails.ExitCode -eq 0) {
    Write-Host -ForegroundColor ([ConsoleColor]4) "FAILED" 
    throw "Did not find performance results summary."
}
else {
    Write-Host -ForegroundColor ([ConsoleColor]2) "OK" 
}


# Step 3: Write out granular performance data
# 
# We root this in $ResultsDirectory/release-$Release-<date_of_run>/platform-<platform_name>/$Suite.csv

# Create the Directory (and it's parents)
$outputDirectory = (Join-Path $ResultsDirectory "release=$ReleaseTag,testedOn=$TestTimestamp" "platform=$Platform" "language=$Language")
$outputDirectorySARIF = $outputDirectory

$queryOutputFile = Join-Path $outputDirectory "suite=$Suite,datum=queries.csv"
$evaluatorResultsFile = Join-Path $outputDirectory "suite=$Suite,datum=evaluator-log.json"

# Create the output directory.
# note there is no need to create the sarif out directory -- it will be created
# by the copy command, below.

New-Item -Type Directory -Path $outputDirectory -ErrorAction Ignore | Out-Null


# Copy processed results out
Copy-Item -Path $EvaluatorResults -Destination $evaluatorResultsFile
Copy-Item -Path $SARIF_OUT -Destination $outputDirectorySARIF

# Write out the report 
Write-Host "Writing report to $queryOutputFile"
foreach ($r in $PERFORMANCE_DATA) {
    [PSCustomObject]$r | Export-CSV -Path $queryOutputFile -Append -NoTypeInformation
}