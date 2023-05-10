<#
.Description
MatrixTest - Performs matrix testing of the Coding Standards Suite against
various compilers. 

Example Usage: 

`MatrixTest.ps1 -Configuration Clang -Suite -SuiteName AUTOSAR `

All Parameters: 

 -Suite [<SwitchParameter>]
        The mode to run the tool in. Valid values are: Suite, Rule, or Package.

        Required?                    true
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Rule [<SwitchParameter>]

        Required?                    true
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Package [<SwitchParameter>]

        Required?                    true
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -ReportDir <String>

        Required?                    false
        Position?                    named
        Default value                (Get-Location)
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -UseTmpDir [<SwitchParameter>]
        Tells the script to use the sytem tmp directory instead of the rule
        directory.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Configuration <String>
        The compiler to use.

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -SuiteName <String>
        For a suite, the suites we support. Valid values are 'CERT-C++' and
        'AUTOSAR'.

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -RuleName <String>
        The rule to test, e.g.: A0-1-1.

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -PackageName <String>
        The package to test. This will test all rules within the specified
        package. Valid values are taken from the basename of the `.json` files within the
        `rule_packages` directory.

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

#> 
param(
    # The mode to run the tool in. Valid values are: Suite, Rule, or Package.
    [Parameter(Mandatory, ParameterSetName = 'Suite')] 
    [switch]
    $Suite,
    [Parameter(Mandatory, ParameterSetName = 'Rule')] 
    [switch]
    $Rule,
    [Parameter(Mandatory, ParameterSetName = 'Package')] 
    [switch]
    $Package,

    [Parameter(Mandatory, ParameterSetName = 'All')] 
    [switch]
    $AllRules,

    [Parameter(Mandatory)] 
    [ValidateSet('c', 'cpp')]
    [string]
    $Language,

    [Parameter(Mandatory = $false)] 
    [string]
    $ReportDir = (Get-Location),

    # Skip summary report -- used for Linux hosts that don't support 
    # the OLE database stuff. 
    [Parameter(Mandatory = $false)] 
    [switch]
    $SkipSummaryReport,

    # Tells the script to use the sytem tmp directory instead of the rule
    # directory.
    [Parameter(Mandatory = $false)] 
    [switch]
    $UseTmpDir,

    # Number of threads to use
    [Parameter(Mandatory = $false)] 
    [string]
    $NumThreads = 10,

    # The compiler to use.
    [Parameter(Mandatory)] 
    [ValidateSet('clang', 'armclang', 'tiarmclang', 'gcc', 'qcc')]
    [string]
    $Configuration,

    # For a suite, the suites we support. Valid values are 'CERT-C++' and
    # 'AUTOSAR' and MISRA-C-2012 and CERT-C
    [Parameter(Mandatory, ParameterSetName = 'Suite')] 
    [ValidateSet("CERT-C++", "AUTOSAR", "MISRA-C-2012", "CERT-C")]
    [string]
    $SuiteName,

    # The rule to test, e.g.: A0-1-1.
    [Parameter(Mandatory, ParameterSetName = "Rule")] 
    [string]
    $RuleName,

    # The package to test. This will test all rules within the specified
    # package. Valid values are taken from the basename of the `.json` files within the
    # `rule_packages` directory. 
    [Parameter(Mandatory, ParameterSetName = "Package")] 
    [ValidateSet("Allocations",
        "BannedSyntax",
        "BannedTypes",
        "BannedFunctions",
        "Classes",
        "Concurrency",
        "Const",
        "Declarations",
        "Exceptions1",
        "Exceptions2",
        "Includes",
        "Invariants",
        "Iterators",
        "Literals",
        "Loops",
        "Macros",
        "Naming",
        "Scope",
        "Side-effects1",
        "Side-effects2",
        "Classes",
        "SmartPointers1",
        "SmartPointers2",
        "SideEffects1",
        "SideEffects2",
        "Strings",
        "Templates",
        "Classes",
        "Freed",
        "Initialization",
        "Functions",
        "Null",
        "OperatorInvariants",
        "VirtualFunctions",
        "Conditionals",
        "MoveForward",
        "Operators",
        "TypeRanges",
        "Lambdas",
        "Pointers",
        "IntegerConversion",
        "Expressions")]
    [string]
    $PackageName
)

Import-Module -Name "$PSScriptRoot/../PSCodingStandards/CodingStandards"

. "$PSScriptRoot/CreateSummaryReport.ps1"
. "$PSScriptRoot/Get-CompilerExecutable.ps1"
. "$PSScriptRoot/Config.ps1"

$REPORT = @() 
$queriesToCheck = @()

#
# Step 1: Load the queries we are going to check
#

$allQueries = @()
$queriesToCheck = @()

# load all the queries 
foreach ($s in $AVAILABLE_SUITES) {
    $allQueries += Get-RulesInSuite -Suite $s -Language $Language
}

# filter the set down based on the selections 

if ($Suite) {
    $queriesToCheck = $allQueries | Where-Object { $_.__memberof_suite -eq $SuiteName }
}
elseif ($Package) {
    $queriesToCheck = $allQueries | Where-Object { $_.__memberof_package -eq $PackageName }
}
elseif ($Rule) {
    $queriesToCheck = $allQueries | Where-Object { $_.__memberof_rule -eq $RuleName }
}
elseif ($AllRules) {
    $queriesToCheck = $allQueries
}

if ($queriesToCheck.Count -eq 0) {
    throw "No queries loaded."
}
else {
    Write-Host "Loaded $($queriesToCheck.Count) Queries."
}


#
# Step 2: Verify All the Required CLI Tools are Installed
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

#
# Step 3: For each rule to test, compile a test database and run the query
# against it. Compare the results to the contents of the `.expected` file within
# the directory for the rule's test.
#
$jobRows = $queriesToCheck | ForEach-Object -ThrottleLimit $NumThreads -Parallel {

    Import-Module -Name "$using:PSScriptRoot/../PSCodingStandards/CodingStandards"

    . "$using:PSScriptRoot/NewDatabaseForRule.ps1"
    . "$using:PSScriptRoot/ExecuteQueryAndDecodeAsJson.ps1"
    . "$using:PSScriptRoot/Get-CompilerSpecificFiles.ps1"
    . "$using:PSScriptRoot/Pop-CompilerSpecificFiles.ps1"
    . "$using:PSScriptRoot/Push-CompilerSpecificFiles.ps1"

    $q = $_ 

    $CurrentSuiteName = $q.__memberof_suite 
    $CurrentRuleName = $q.__memberof_rule
    $CurrentQueryName = $q.short_name
    $CurrentPackageName = $q.__memberof_package


    # all the test directories -- there may be more than one for a given rule 
    $testDirs = (Get-ATestDirectory -RuleObject $q -Language $using:Language)

    foreach($testDirectory in $testDirs){

        Write-Host "Acquiring lock for $testDirectory"
        $Mutex = New-Object -TypeName System.Threading.Mutex -ArgumentList $false, ("__Matrix_" + $testDirectory.Replace([IO.Path]::DirectorySeparatorChar,"_"));
        $Mutex.WaitOne() | Out-Null;
        Write-Host "Locked $testDirectory"        

        # for the report 
        $row = @{
            "SUITE"             = $CurrentSuiteName;
            "PACKAGE"           = $CurrentPackageName;
            "RULE"              = $CurrentRuleName;
            "QUERY"             = $CurrentQueryName;
            "COMPILE_PASS"      = $false;
            "COMPILE_ERROR_OUTPUT"    = "";
            "TEST_PASS"         = $false ;
            "TEST_DIFFERENCE"   = "";
        }



        Write-Host "====================[Rule=$CurrentRuleName,Suite=$CurrentSuiteName/Query=$CurrentQueryName]====================" 


        try {
            ###########################################################
            ###########################################################
            # Push context 
            ###########################################################

            if ($q.shared_implementation_short_name) {      
                $fileSet = (Get-CompilerSpecificFiles -Configuration $using:Configuration -Language $using:Language  -TestDirectory $testDirectory -Query $q.shared_implementation_short_name)            
            }
            else {
                $fileSet = (Get-CompilerSpecificFiles -Configuration $using:Configuration -Language $using:Language  -TestDirectory $testDirectory -Query $CurrentQueryName)            
            }
            
            if($fileSet){
                $context = Push-CompilerSpecificFiles -Configuration $using:Configuration -Language $using:Language -FileSet $fileSet
            }

            Write-Host "Compiling database in $testDirectory..." -NoNewline

            try {
                $db = New-Database-For-Rule -RuleName $CurrentRuleName -RuleTestDir $testDirectory -Configuration $using:Configuration -Language $using:Language
                Write-Host -ForegroundColor ([ConsoleColor]2) "OK" 
            }
            catch {
                Write-Host -ForegroundColor ([ConsoleColor]4) "FAILED"
                $row["COMPILE_ERROR_OUTPUT"] = $_
                                
                continue    # although it is unlikely to succeed with the next rule skipping to the next rule
                            # ensures all of the rules will be reported in the
                            # output. 
            }

            $row["COMPILE_PASS"] = $true
            
            Write-Host "Checking expected output..."

            # Dragons below 🐉🐉🐉
            #  
            # Note this technique uses so-called "wizard" settings to make it possible
            # to compare hand compiled databases using qltest. The relative paths and
            # other options are required to be set as below (especially the detail about
            # the relative path of the dataset and the test).

            # the "dataset" should be the `db-cpp` directory inside the database
            # directory. HOWEVER. It should be the path relative to the test directory. 
            
            $rulePath = Resolve-Path $testDirectory
            $dbPath = Resolve-Path $db 
            
            Write-Host "Resolving database $dbPath relative to test directory $rulePath"
            $dataset = Resolve-Path (Join-Path $dbPath "db-cpp")

            Push-Location $rulePath   
            $datasetRelPath = Resolve-Path -Relative $dataset
            Pop-Location 

            Write-Host "Using relative path: $datasetRelPath"

            # Actually do the qltest run. 
            # codeql test run <qltest file> --dataset "relpath"

            if ($q.shared_implementation_short_name) {      
                $qlRefFile = Join-Path $rulePath "$($q.shared_implementation_short_name).ql"
            }
            else {
                $qlRefFile = Join-Path $rulePath "$CurrentQueryName.qlref" 
            }

            Write-Host "codeql test run $qlRefFile --search-path . --dataset=`"$datasetRelPath`""

            $stdOut = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())
            $stdErr = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())
            

            Write-Host "Standard Out Buffered to: $stdOut"
            Write-Host "Standard Error Buffered to: $stdErr"
            
            $procDetails = Start-Process -FilePath "codeql" -PassThru -NoNewWindow -Wait -ArgumentList "test run $qlRefFile --search-path . --dataset=`"$datasetRelPath`"" -RedirectStandardOutput $stdOut -RedirectStandardError $stdErr
            
            if (-Not $procDetails.ExitCode -eq 0) {

                Write-Host -ForegroundColor ([ConsoleColor]4) "FAILED" 
                Get-Content $stdOut | Out-String | Write-Host 

                $row["TEST_DIFFERENCE"] = Get-Content $stdOut | Out-String 

            }
            else {
                $row["TEST_PASS"] = $true 
                Write-Host -ForegroundColor ([ConsoleColor]2) "OK" 
            }         
        }finally {

            # output current row state 
            $row 

            # release any held mutexes            
            $Mutex.ReleaseMutex();

            ###########################################################
            ###########################################################
            # Context is restored here
            ###########################################################
            if($context){
                Pop-CompilerSpecificFiles -Context $context 
            }
        }
    }
    # go to next row 
}

# combine the outputs 
$jobRows | ForEach-Object {
    $REPORT += $_ 
}

# 
# Step 4: Create reports 
# 

$fileTag = "$($Configuration.ToLower())-$Language-$(Get-Date -Format "yyyy-MM-dd_HH-mm-ss")"

$reportOutputFile = Join-Path $ReportDir "MatrixTestReport-$fileTag.csv"
$summaryReportOutputFile = Join-Path $ReportDir "MatrixTestReportSummary-$fileTag.csv"

# Write out the detailed report 
Write-Host "Writing detailed report to $reportOutputFile"
foreach ($r in $REPORT) {
    [PSCustomObject]$r | Export-CSV -Path $reportOutputFile -Append -NoTypeInformation
}

if (-not $SkipSummaryReport){
    # write out a summary 
    Write-Host "Writing summary report to $summaryReportOutputFile"
    Create-Summary-Report -DataFile $reportOutputFile -OutputFile $summaryReportOutputFile
}
