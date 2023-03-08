function Get-ATestDirectory {
    param(
        [Parameter(Mandatory)] 
        [object]
        $RuleObject,
        [Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        [string]
        $Language
    )

    $ruleDir = Get-TestDirectory -RuleObject $RuleObject -Language $Language

    # return value MUST include the explicit test directory 
    $dirs = @($ruleDir)

    $dirs +=  (Get-Item "$($ruleDir).*" | ForEach-Object { $_.FullName })

    $dirs 
}
