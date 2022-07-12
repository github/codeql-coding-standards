function Get-TestDirectory {
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
        $ruleDir = $RuleObject.shared_implementation_short_name.ToLower()
    }
    else {

        if ($RuleObject.__memberof_suite -eq "AUTOSAR") {
            $standardString = "autosar"
        }
        elseif ($RuleObject.__memberof_suite -eq "CERT-C++") {
            $standardString = "cert"
        }
        elseif ($RuleObject.__memberof_suite -eq "CERT-C") {
            $standardString = "cert"
        }
        elseif ($RuleObject.__memberof_suite -eq "MISRA-C-2012") {
            $standardString = "misra"
        }
        else {
            throw "Unknown standard $($RuleObject.__memberof_suite)"
        }

        $ruleDir = $RuleObject.__memberof_rule
    }

    return Join-Path (Join-Path (Join-Path (Join-Path $Language $standardString) "test") "rules") $ruleDir
}
