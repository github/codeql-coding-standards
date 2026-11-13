# takes paths like this: 
# c/cert/src/rules/DCL39-C/InformationLeakageAcrossTrustBoundariesC.ql
# c/common/test/rules/informationleakageacrossboundaries/InformationLeakageAcrossBoundaries.expected
# c/common/test/rules/informationleakageacrossboundaries/InformationLeakageAcrossBoundaries.ql
# c/common/test/rules/informationleakageacrossboundaries/arrays.c
# c/common/test/rules/informationleakageacrossboundaries/interprocedural.c
# c/common/test/rules/informationleakageacrossboundaries/multilayer.c
# c/common/test/rules/informationleakageacrossboundaries/test.c
# c/misra/src/rules/RULE-18-8/VariableLengthArrayTypesUsed.ql
# c/misra/src/rules/RULE-8-12/ValueImplicitEnumerationConstantNotUnique.ql
# c/misra/test/rules/RULE-18-8/VariableLengthArrayTypesUsed.expected
# c/misra/test/rules/RULE-18-8/test.c
# c/misra/test/rules/RULE-8-12/ValueImplicitEnumerationConstantNotUnique.expected
# c/misra/test/rules/RULE-8-12/test.c
# cpp/cert/src/rules/DCL55-CPP/InformationLeakageAcrossTrustBoundaries.ql
# cpp/common/test/rules/informationleakageacrossboundaries/InformationLeakageAcrossBoundaries.expected
# cpp/common/test/rules/informationleakageacrossboundaries/InformationLeakageAcrossBoundaries.ql
# cpp/common/test/rules/informationleakageacrossboundaries/InformationLeakageAcrossTrustBoundaries.expected
# cpp/common/test/rules/informationleakageacrossboundaries/arrays.cpp
# cpp/common/test/rules/informationleakageacrossboundaries/inheritance.cpp
# cpp/common/test/rules/informationleakageacrossboundaries/interprocedural.cpp
# cpp/common/test/rules/informationleakageacrossboundaries/multilayer.cpp
# cpp/common/test/rules/informationleakageacrossboundaries/test.cpp

# Matches original rule directories and resolved fixture directories, including
# shared tests and compiler-specific variants.

function Get-RuleForPath {
    param([Parameter(Mandatory)] 
        [string]
        $Path,
        [ValidateSet('c', 'cpp')]
        [string]
        $Language
        ) 

    # load all the queries for all languages 
    $allQueries = @()
    $queriesToCheck = @()


    foreach ($s in $AVAILABLE_SUITES) {
        $allQueries += Get-RulesInSuite -Suite $s -Language $Language
    }


    $repositoryRoot = Get-RepositoryRoot
    $modifiedPath = [IO.Path]::GetRelativePath(
        $repositoryRoot, [IO.Path]::GetFullPath($Path, $repositoryRoot))
    # replace "src" with "test" to make it match up
    $sep = [IO.Path]::DirectorySeparatorChar
    $modifiedPathWithReplacement = $modifiedPath.Replace(
        ($sep + "src" + $sep + "rules"), ($sep + "test" + $sep + "rules"))

    
    $matchingRules = @()

    # for each query, create the test directory 
    foreach($q in $allQueries){
        # Keep the wrapper's own directory even when its fixture is elsewhere.
        $standard = ($q.__memberof_suite -split "-")[0].ToLowerInvariant()
        $testDirs = @(Join-Path $Language "$standard/test/rules/$($q.__memberof_rule)")
        $testDirs += Get-ATestDirectory -RuleObject $q -Language $Language
        foreach($testDirectory in $testDirs){
            $testPath = [IO.Path]::GetRelativePath(
                $repositoryRoot, [IO.Path]::GetFullPath($testDirectory, $repositoryRoot))

            if ((Split-Path $modifiedPath -Parent) -eq $testPath -or
                (Split-Path $modifiedPathWithReplacement -Parent) -eq $testPath) {
                $matchingRules += $q 
                break
            }
        }
    }

    if($matchingRules.Count -gt 0){
        return $matchingRules
    }

    throw "Path does not appear to be part of a rule."
}