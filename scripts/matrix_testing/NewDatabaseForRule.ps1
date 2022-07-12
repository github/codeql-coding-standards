. "$PSScriptRoot\GetCompilerExecutable.ps1"
. "$PSScriptRoot\GetCompilerArgs.ps1"
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
    $Configuration
    )

    Write-Host "Creating Database for Rule $RuleName..."
    
    $cppFiles = Get-ChildItem $RuleTestDir/*.cpp
    $cppFilesString = ([String]::Join(' ', $cppFiles))
    Write-Host "Found '.cpp' files $cppFilesString."
    
    $CompilerExecutable = Get-CompilerExecutable -Configuration $Configuration
    $CompilerArgs       = Get-CompilerArgs -Configuration $Configuration

    $BUILD_COMMAND="$CompilerExecutable $CompilerArgs $cppFilesString"

    if($UseTmpDir){
        $DB_PATH = Get-New-DB-Name
    }else{
        $DB_PATH = Get-New-DB-Name -Dir $RuleTestDir
    }

    Write-Host "codeql database create -l cpp -s $RuleTestDir --command='$BUILD_COMMAND' $DB_PATH"

    $procDetails = Start-Process -FilePath "codeql" -PassThru -NoNewWindow -Wait -ArgumentList "database create -l cpp -s $RuleTestDir --command=`"$BUILD_COMMAND`" $DB_PATH"

    if (-Not $procDetails.ExitCode -eq 0){
        throw "Database creation failed."
    }

    return $DB_PATH
}
