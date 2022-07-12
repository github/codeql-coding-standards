. "$PSScriptRoot\GetRepositoryRoot.ps1"
function Get-Packages {
    return Get-ChildItem (Join-Path (Get-RepositoryRoot) "\rule_packages\*.json")
}