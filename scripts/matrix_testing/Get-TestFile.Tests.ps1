$ErrorActionPreference = "Stop"
$repositoryRoot = (Resolve-Path "$PSScriptRoot/../..").Path
Push-Location $repositoryRoot
try {
    Import-Module "$repositoryRoot/scripts/PSCodingStandards/CodingStandards"
    $queries = Get-RulesInSuite -Language c -Suite "MISRA-C-2025"
    $expectedFiles = @{
        "LanguageExtensionsShouldBeMinimized" = "c/misra/test/rules/RULE-1-2/LanguageExtensionsShouldBeMinimized.qlref"
        "ReservedMacroName" = "c/misra/test/rules/RULE-21-1/ReservedMacroName.qlref"
        "SinglePointOfExit" = "c/misra/test/rules/RULE-15-5/SinglePointOfExit.qlref"
    }

    foreach ($name in $expectedFiles.Keys) {
        $query = @($queries | Where-Object { $_.short_name -eq $name })
        if ($query.Count -ne 1) {
            throw "Expected exactly one query named $name"
        }
        $testFile = Get-TestFile -RuleObject $query[0] -Language c
        $expected = [IO.Path]::GetFullPath((Join-Path $repositoryRoot $expectedFiles[$name]))
        if ([IO.Path]::GetFullPath($testFile) -ne $expected) {
            throw "Unexpected test file for ${name}: $testFile"
        }
        $directory = Get-TestDirectory -RuleObject $query[0] -Language c
        if ([IO.Path]::GetFullPath($directory) -ne (Split-Path $expected -Parent)) {
            throw "Unexpected fixture directory for ${name}: $directory"
        }
        if (-not (Test-Path ([IO.Path]::ChangeExtension($testFile, ".expected")))) {
            throw "Missing expected results for $name"
        }
    }

    $shared = [pscustomobject]@{
        shared_implementation_short_name = "SharedQuery"
    }
    $sharedFile = Get-TestFile -RuleObject $shared -Language cpp
    if ($sharedFile.Replace("\", "/") -ne "cpp/common/test/rules/sharedquery/SharedQuery.ql") {
        throw "Unexpected shared test file: $sharedFile"
    }
    Write-Host "Get-TestFile regression tests passed."
}
finally {
    Pop-Location
}
