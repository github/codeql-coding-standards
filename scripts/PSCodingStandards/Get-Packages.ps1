function Get-Packages {
    param([Parameter(Mandatory)] 
        [ValidateSet('c', 'cpp')]
        [string]
        $Language)

    return Get-ChildItem (Join-Path (Get-RepositoryRoot) "/rule_packages/$Language/*.json")
}