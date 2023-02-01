. "$PSScriptRoot/Config.ps1"
function Get-CompilerSpecificFiles {
    param([Parameter(Mandatory)] 
        [string]
        $Configuration,
        [Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        [string]
        $TestDirectory
    )

    #
    # Convention is as follows:
    #
    # For test files:
    #
    # file.c/cpp is used for ALL compilers 
    # file.c.<configuration>/file.cpp.<configuration> is used for <configuration>
    #
    # file.expected is used for all compilers 
    # file.expected.<configuration> is used for <configuration> 
    $sourceFiles = Get-ChildItem -Filter "*.$Language.$Configuration"

    $expectedFiles = Get-ChildItem -Filter "*.expected.$Configuration"

    return $sourceFiles + $expectedFiles
}