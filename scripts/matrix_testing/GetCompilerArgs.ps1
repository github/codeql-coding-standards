. "$PSScriptRoot\Config.ps1"
function Get-CompilerArgs {
    param([Parameter(Mandatory)] 
        [string]
        $Configuration
    )
    return $COMPILER_ARGS[$Configuration]
}