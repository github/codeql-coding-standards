. "$PSScriptRoot\Config.ps1"
function Get-CompilerExecutable {
    param([Parameter(Mandatory)] 
        [string]
        $Configuration
    )
    return $COMPILER_MAPPINGS[$Configuration]
}