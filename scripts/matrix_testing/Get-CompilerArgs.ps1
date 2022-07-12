. "$PSScriptRoot\Config.ps1"
function Get-CompilerArgs {
    param([Parameter(Mandatory)] 
        [string]
        $Configuration,
        [Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        [string]
        $Language
    )
    return $COMPILER_ARGS[$Language][$Configuration]
}