. "$PSScriptRoot/Config.ps1"
function Get-CompilerSpecificFiles {
    param([Parameter(Mandatory)] 
        [string]
        $Configuration,
        [Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        [string]
        $Language,
        [Parameter(Mandatory)] 
        [string]
        $TestDirectory,
        [Parameter(Mandatory)] 
        [string]
        $Query
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
    Write-Host "Scanning for compiler specific files in $TestDirectory"

    foreach($f in (Get-ChildItem -Filter "*.$Language.$Configuration" $TestDirectory)){
        Write-Host "Found file $f..."
        $f
    }

    foreach($f in (Get-ChildItem -Filter "$Query.expected.$Configuration" $TestDirectory)){
        Write-Host "Found file $f..."
        $f 
    }

}