function Get-TestFile {
    param(
        [Parameter(Mandatory)]
        [object]
        $RuleObject,
        [Parameter(Mandatory)]
        [ValidateSet('c', 'cpp')]
        [string]
        $Language
    )

    if ($RuleObject.shared_implementation_short_name) {
        $standardString = "common"
        $queryName = $RuleObject.shared_implementation_short_name
        $ruleDir = $queryName.ToLower()
        $extension = ".ql"
    }
    else {
        if ($RuleObject.__memberof_suite -eq "AUTOSAR") {
            $standardString = "autosar"
        }
        elseif ($RuleObject.__memberof_suite -in @("CERT-C", "CERT-C++")) {
            $standardString = "cert"
        }
        elseif ($RuleObject.__memberof_suite -in @(
            "MISRA-C-2012", "MISRA-C-2025", "MISRA-C++-2023"
        )) {
            $standardString = "misra"
        }
        else {
            throw "Unknown standard $($RuleObject.__memberof_suite)"
        }

        $queryName = $RuleObject.short_name
        $ruleDir = $RuleObject.__memberof_rule
        $extension = ".qlref"
    }

    $testDirectory = Join-Path (Join-Path (Join-Path (Join-Path $Language $standardString) "test") "rules") $ruleDir
    $testFile = Join-Path $testDirectory "$queryName$extension"
    $referenceFile = Join-Path $testDirectory "$queryName.testref"
    if (-not (Test-Path -LiteralPath $testFile -PathType Leaf) -and
        (Test-Path -LiteralPath $referenceFile -PathType Leaf)) {
        $reference = Get-Content -LiteralPath $referenceFile -Raw -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($reference)) {
            throw "Empty test reference: $referenceFile"
        }
        if ([IO.Path]::IsPathRooted($reference.Trim())) {
            throw "Test reference must be repository-relative: $referenceFile"
        }

        $repositoryRoot = Get-RepositoryRoot
        $testFile = Join-Path $repositoryRoot $reference.Trim()
        if ([IO.Path]::GetExtension($testFile) -notin @(".ql", ".qlref")) {
            throw "Test reference must name a .ql or .qlref file: $referenceFile"
        }
        if (-not (Test-Path -LiteralPath $testFile -PathType Leaf)) {
            throw "Referenced test does not exist: $testFile"
        }
        $expectedFile = [IO.Path]::ChangeExtension($testFile, ".expected")
        if (-not (Test-Path -LiteralPath $expectedFile -PathType Leaf)) {
            throw "Referenced test has no expected results: $expectedFile"
        }
        return [IO.Path]::GetRelativePath($repositoryRoot, (Resolve-Path -LiteralPath $testFile).Path)
    }

    return $testFile
}
