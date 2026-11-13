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

    return Split-Path -Path (Get-TestFile -RuleObject $RuleObject -Language $Language) -Parent
}
