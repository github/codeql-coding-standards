function Get-Test-Directory {
    param(
        [Parameter(Mandatory)] 
        [object]
        $RuleObject
    )

    if ($RuleObject.shared_implementation_short_name) {
        $standardString = "common"
        $ruleDir = $RuleObject.shared_implementation_short_name.ToLower()
    }
    else {

        if ($RuleObject.__memberof_suite -eq "AUTOSAR") {
            $standardString = "autosar"
        }
        elseif ($RuleObject.__memberof_suite -eq "CERT-C++") {
            $standardString = "cert"
        }
        else {
            throw "Unknown standard $($RuleObject.__memberof_suite)"
        }

        $ruleDir = $RuleObject.__memberof_rule
    }

    return Join-Path (Join-Path (Join-Path (Join-Path "cpp" $standardString) "test") "rules") $ruleDir
}
