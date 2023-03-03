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

# And produces one or more rules for it. It does this by loading every rule
# and computing the test directory for it. This test directory is then 
# used to see if a) it is a substring of the supplied path or if b) it 
# is a substring of the path once the substitution `/src/` -> `/test/` is
# applied  

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


    $modifiedPathWithReplacement = Join-Path (Resolve-Path . -Relative) $Path 
    # replace "src" with "test" to make it match up
    $sep = [IO.Path]::DirectorySeparatorChar
    $modifiedPathWithReplacement = $modifiedPathWithReplacement.Replace( ($sep + "src" + $sep + "rules"), ($sep + "test" + $sep + "rules"))    
    $modifiedPath = Join-Path (Resolve-Path . -Relative) $Path 

    
    $matchingRules = @()

    # for each query, create the test directory 
    foreach($q in $allQueries){
        # get test directory
        $testDirs = (Get-ATestDirectory -RuleObject $q -Language $Language)
        foreach($testDirectory in $testDirs){
            # resolve path to be compatible 
            $testPath = (Join-Path (Resolve-Path . -Relative) $testDirectory)

            if((Split-Path $modifiedPath -Parent) -eq $testPath){
                $matchingRules += $q 
                continue 
            }

            if((Split-Path $modifiedPathWithReplacement -Parent) -eq $testPath){
                $matchingRules += $q 
                continue 
            }
        }
    }

    if($matchingRules.Count -gt 0){
        return $matchingRules
    }

    throw "Path does not appear to be part of a rule."
}