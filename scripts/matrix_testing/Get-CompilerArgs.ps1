. "$PSScriptRoot/Config.ps1"
function Get-CompilerArgs {
    param(
        [Parameter(Mandatory)] 
        [string]
        $Configuration,
        [Parameter(Mandatory)] 
        [string]
        $TestDirectory,    
        [Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        [string]
        $Language
    )
    $baseArgs = $COMPILER_ARGS[$Language][$Configuration]

    $optionsFile = (Join-Path $TestDirectory "options.$Configuration") 

    # perhaps there is an options file? 
    if(Test-Path $optionsFile){
        return $baseArgs + " " + (Get-Content $optionsFile)
    }

    return $baseArgs 
}