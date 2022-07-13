#!/usr/bin/env pwsh
param(
    [Parameter(Mandatory)] 
    [string]
    $CurrentFile
)
<# 
We find the opposite of whatever they pass in. If the user gives us the query
directory, we give them the test directory and if they give us the test
directory, we give them the query directory. 

Note that this works for shared queries as well. 
#>

# Logic 
# 1) Shared CPP queries get redirected to the Shared CPP Test 
# 2) Shared CPP Tests get redirected to the Shared Query
# 3) Shared C Tests get redirected to the shared CPP Query
# 4) Shared C Queries Don't exist. 
# 5) CPP Queries get redirected to the CPP Test 
# 6) CPP Tests get redirected to the CPP Query
# 7) C Queries get redirected to C tests 
# 8) C Tests get redirected to C queries 

# (1) Shared CPP Query 
#$CurrentFile = "C:\Projects\codeql-coding-standards\cpp\common\src\codingstandards\cpp\rules\sectionsofcodeshallnotbecommentedout\SectionsOfCodeShallNotBeCommentedOut.qll"

# (2) Shared CPP Test
#$CurrentFile = "C:\Projects\codeql-coding-standards\cpp\common\test\rules\catchblockshadowing\CatchBlockShadowing.ql"

# (3) Shared C Test (***Not WOrking)
#$CurrentFile = "C:\Projects\codeql-coding-standards\c\common\test\rules\donotaccessaclosedfile\DoNotAccessAClosedFile.ql"

# (4) Shared C Queries (DNE)

# (5) CPP Query 
#$CurrentFile = "C:\Projects\codeql-coding-standards\cpp\autosar\src\rules\A2-7-2\SectionsOfCodeCommentedOut.ql"

# (6) CPP Test 
#$CurrentFile = "C:\Projects\codeql-coding-standards\cpp\autosar\test\rules\A2-7-2\SectionsOfCodeCommentedOut.testref"

# (7) C Query 
#$CurrentFile = "C:\Projects\codeql-coding-standards\c\cert\src\rules\FIO42-C\CloseFilesWhenTheyAreNoLongerNeeded.ql"

# (8) C Test 
#$CurrentFile = "C:\Projects\codeql-coding-standards\c\cert\test\rules\FIO42-C\CloseFilesWhenTheyAreNoLongerNeeded.qlref"


$CurrentFile = Resolve-Path $CurrentFile # convert this to a real thing


$CPPSharedTest = $false
$CSharedTest = $false 
# it's a cpp shared query 
if(($CurrentFile.toString().IndexOf("\cpp\common\") -ge 0) -and ($CurrentFile.toString().IndexOf("\cpp\rules\") -ge 0)){
    Write-Host "Detected Shared CPP Query..."

    $OneAbove = Resolve-Path(Join-Path $CurrentFile ..\..\..\..\..\..\)
    $CurrentPathSrcOrTest = Resolve-Path(Join-Path $CurrentFile ..\..\..\..\..\)
    $CurrentRule = Resolve-Path(Join-Path $CurrentFile ..\)

    $Stem = Split-Path -Path  $CurrentPathSrcOrTest -Leaf
    $Rule = Split-Path -Path  $CurrentRule -Leaf

}
# shared cpp test \src\codingstandards\cpp\rules 
elseif(($CurrentFile.toString().IndexOf("\cpp\common\test\rules") -ge 0)){
    Write-Host "Detected Shared CPP Test..."

    $OneAbove = Resolve-Path(Join-Path $CurrentFile ..\..\..\..\)
    $CurrentPathSrcOrTest = Resolve-Path(Join-Path $CurrentFile ..\..\..\)
    $CurrentRule = Resolve-Path(Join-Path $CurrentFile ..\)

    $Stem = Split-Path -Path  $CurrentPathSrcOrTest -Leaf
    $Rule = Split-Path -Path  $CurrentRule -Leaf

    $CPPSharedTest = $true
}

# it's a c shared test 
elseif(($CurrentFile.toString().IndexOf("\c\common\test\rules\") -ge 0)){
    Write-Host "Detected Shared C Test..."

    $OneAbove = Resolve-Path(Join-Path $CurrentFile ..\..\..\..\..\..\)
    $CurrentPathSrcOrTest = Resolve-Path(Join-Path $CurrentFile ..\..\..\)
    $CurrentRule = Resolve-Path(Join-Path $CurrentFile ..\)

    $Stem = Split-Path -Path  $CurrentPathSrcOrTest -Leaf
    $Rule = Split-Path -Path  $CurrentRule -Leaf


    $CSharedTest = $true
}
# it's a normal query
else{
    Write-Host "Detected Non-Shared Query..."
    $OneAbove = Resolve-Path(Join-Path $CurrentFile ..\..\..\..\)
    $CurrentPathSrcOrTest = Resolve-Path(Join-Path $CurrentFile ..\..\..\)
    $CurrentRule = Resolve-Path(Join-Path $CurrentFile ..\)

    $Stem = Split-Path -Path  $CurrentPathSrcOrTest -Leaf
    $Rule = Split-Path -Path  $CurrentRule -Leaf
}
Write-Host "Input Path           : $($CurrentFile)"
Write-Host "CurrentSrcOrTest Path: $($CurrentPathSrcOrTest)"
Write-Host "One Above            : $($OneAbove)"
Write-Host "Stem                 : $($Stem)"
Write-Host "Rule                 : $($Rule)"


if($Stem -eq "test"){
    $SwitchTo = "src"

    # Small hack for inconsistent pathing 
    if($CPPSharedTest){
        $SwitchTo = "\src\codingstandards\cpp"
    }

    if($CSharedTest){
        $SwitchTo = "cpp\common\src\codingstandards\cpp\"
    }

}elseif($Stem -eq "src"){
    $SwitchTo = "test"
}else{
    Write-Host "Not a query file. Exiting."
    Exit 
}

Write-Host "Switch To            : $($SwitchTo)"


$NewPath = (Join-Path (Join-Path (Join-Path $OneAbove $SwitchTo) "rules") $Rule)

Write-Host "Switching to Path: $($NewPath)"

# prefer ql files
$F = (Get-ChildItem "$($NewPath)\*.ql*")

if($F.Length -eq 0){
    $Target = (Get-ChildItem "$($NewPath)\*")[0]
}else{
    $Target = $F[0]
}

Write-Host "Target File $($Target.FullName)"

code $Target.FullName
