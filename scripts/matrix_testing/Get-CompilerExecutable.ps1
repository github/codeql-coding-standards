. "$PSScriptRoot/Config.ps1"
function Get-CompilerExecutable {
    param([Parameter(Mandatory)] 
        [string]
        $Configuration,
        [Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        [string]
        $Language
    )
    return $COMPILER_MAPPINGS[$Language][$Configuration]
}