$SUITE_DEFINITIONS = [ordered]@{
    "CERT-C++" = @{}
    "AUTOSAR" = @{}
    "MISRA-C-2025" = @{
        IncludeSuites = @("MISRA-C-2012")
        ExcludeTags = @("external/misra/legacy")
    }
    "MISRA-C-2012" = @{}
    "CERT-C" = @{}
    "MISRA-C++-2023" = @{}
}
$AVAILABLE_SUITES = @($SUITE_DEFINITIONS.Keys)
$AVAILABLE_LANGUAGES = @("c", "cpp")