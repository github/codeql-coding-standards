$ErrorActionPreference = "Stop"
$repositoryRoot = (Resolve-Path "$PSScriptRoot/../..").Path
Push-Location $repositoryRoot
try {
    Import-Module "$repositoryRoot/scripts/PSCodingStandards/CodingStandards"
    $queries = @(foreach ($suite in $AVAILABLE_SUITES) {
        Get-RulesInSuite -Language c -Suite $suite
    })
    $expectedFiles = @{
        "LanguageExtensionsShouldBeMinimized" =
            "c/misra/test/rules/RULE-1-2/LanguageExtensionsShouldBeMinimized.qlref"
        "LanguageExtensionsShouldNotBeUsed" =
            "c/misra/test/rules/RULE-1-2/LanguageExtensionsShouldNotBeUsed.qlref"
        "ReservedMacroName" = "c/misra/test/rules/RULE-21-1/ReservedMacroName.qlref"
        "DefineAndUndefUsedOnReservedIdentifierOrMacroName" =
            "c/misra/test/rules/RULE-21-1/DefineAndUndefUsedOnReservedIdentifierOrMacroName.qlref"
        "SinglePointOfExit" = "c/misra/test/rules/RULE-15-5/SinglePointOfExit.qlref"
        "DoNotCallSystem" = "c/cert/test/rules/ENV33-C/DoNotCallSystem.qlref"
        "ConversionBetweenFunctionPointerAndOtherType" =
            "c/misra/test/rules/RULE-11-1/ConversionBetweenFunctionPointerAndOtherType.qlref"
    }

    foreach ($name in $expectedFiles.Keys) {
        $query = @($queries | Where-Object { $_.short_name -eq $name })
        if ($query.Count -ne 1) {
            throw "Expected exactly one query named $name"
        }
        $testFile = Get-TestFile -RuleObject $query[0] -Language c
        $expected = [IO.Path]::GetRelativePath(
            $repositoryRoot, (Join-Path $repositoryRoot $expectedFiles[$name]))
        if ($testFile -ne $expected) {
            throw "Unexpected test file for ${name}: $testFile"
        }
        $directory = Get-TestDirectory -RuleObject $query[0] -Language c
        if ($directory -ne (Split-Path $expected -Parent)) {
            throw "Unexpected fixture directory for ${name}: $directory"
        }
        if (-not (Test-Path ([IO.Path]::ChangeExtension($testFile, ".expected")))) {
            throw "Missing expected results for $name"
        }
    }

    $sourceFiles = @{
        "c/misra/src/rules/RULE-20-15/ReservedMacroName.ql" = "ReservedMacroName"
        "c/misra/src/rules/DIR-1-2/LanguageExtensionsShouldBeMinimized.ql" =
            "LanguageExtensionsShouldBeMinimized"
    }
    foreach ($source in $sourceFiles.Keys) {
        foreach ($path in @($source, (Join-Path $repositoryRoot $source))) {
            $rules = @(Get-RuleForPath -Language c -Path $path)
            if ($rules.Count -ne 1 -or $rules[0].short_name -ne $sourceFiles[$source]) {
                throw "Unexpected rules for source path: $path"
            }
        }
    }
    $rules = @(Get-RuleForPath -Language c -Path $expectedFiles["ReservedMacroName"])
    if ($rules.Count -ne 2 -or $rules.short_name -notcontains "ReservedMacroName" -or
        $rules.short_name -notcontains "DefineAndUndefUsedOnReservedIdentifierOrMacroName") {
        throw "Expected both wrappers for the shared reserved-macro fixture."
    }

    $currentQueries = @($queries | Where-Object {
        $_.__applicable_suites -contains "MISRA-C-2025"
    })
    foreach ($name in @(
        "FunctionDeclaredImplicitly",
        "ArrayFunctionArgumentNumberOfElements",
        "TerminationFunctionsOfStdlibhUsed"
    )) {
        $query = @($currentQueries | Where-Object { $_.short_name -eq $name })
        if ($query.Count -ne 1 -or $query[0].__memberof_suite -ne "MISRA-C-2012") {
            throw "Expected the older-owned query in MISRA-C-2025: $name"
        }
    }
    if ($currentQueries | Where-Object { $_.tags -contains "external/misra/legacy" }) {
        throw "Legacy wrappers must not be included in MISRA-C-2025."
    }

    & (Get-Module CodingStandards) {
        $SUITE_DEFINITIONS["Future-Suite"] = @{
            IncludeSuites = @("CERT-C")
            ExcludeTags = @("external/cert/severity/low")
        }
        try {
            $futureQueries = @(Get-RulesInSuite -Language c -Suite "CERT-C" |
                Where-Object { $_.__applicable_suites -contains "Future-Suite" })
            if (-not $futureQueries -or
                $futureQueries.tags -contains "external/cert/severity/low") {
                throw "Configured suite inclusion and tag exclusions were not applied."
            }
        }
        finally {
            $SUITE_DEFINITIONS.Remove("Future-Suite")
        }
    }

    $shared = [pscustomobject]@{
        shared_implementation_short_name = "SharedQuery"
    }
    $sharedFile = Get-TestFile -RuleObject $shared -Language cpp
    if ($sharedFile.Replace("\", "/") -ne "cpp/common/test/rules/sharedquery/SharedQuery.ql") {
        throw "Unexpected shared test file: $sharedFile"
    }
    Write-Host "Matrix tooling regression tests passed."
}
finally {
    Pop-Location
}
