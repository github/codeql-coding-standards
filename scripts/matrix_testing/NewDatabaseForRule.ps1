. "$PSScriptRoot\Get-CompilerExecutable.ps1"
. "$PSScriptRoot\Get-CompilerArgs.ps1"
. "$PSScriptRoot\GetNewDBName.ps1"

function New-Database-For-Rule {

    param([Parameter(Mandatory)] 
        [string]
        $RuleName,
        [Parameter(Mandatory)] 
        [string]
        $RuleTestDir,
        [Parameter(Mandatory)] 
        [string]
        $Configuration,
        [Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        [string]
        $Language
    )

    Write-Host "Creating Database for Rule $RuleName..."
    
    $cppFiles = Get-ChildItem $RuleTestDir/*.c*
    $cppFilesString = ([String]::Join(' ', $cppFiles))
    Write-Host "Found '.cpp' files $cppFilesString."
    
    $CompilerExecutable = Get-CompilerExecutable -Configuration $Configuration -Language $Language
    $CompilerArgs = Get-CompilerArgs -Configuration $Configuration -Language $Language

    $BUILD_COMMAND = "$CompilerExecutable $CompilerArgs $cppFilesString"

    if ($UseTmpDir) {
        $DB_PATH = Get-New-DB-Name
    }
    else {
        $DB_PATH = Get-New-DB-Name -Dir $RuleTestDir
    }

    Write-Host "codeql database create -l cpp -s $RuleTestDir --command='$BUILD_COMMAND' $DB_PATH"

    $procDetails = Start-Process -FilePath "codeql" -PassThru -NoNewWindow -Wait -ArgumentList "database create -l cpp -s $RuleTestDir --command=`"$BUILD_COMMAND`" $DB_PATH"

    if (-Not $procDetails.ExitCode -eq 0) {
        throw "Database creation failed."
    }

    return $DB_PATH
}
