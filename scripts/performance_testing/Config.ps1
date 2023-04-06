Import-Module -Name "$PSScriptRoot/../PSCodingStandards/CodingStandards"

$REQUIRED_CODEQL_VERSION = (Get-Content (Join-Path (Get-RepositoryRoot) "supported_codeql_configs.json") | ConvertFrom-Json).supported_environment.codeql_cli

