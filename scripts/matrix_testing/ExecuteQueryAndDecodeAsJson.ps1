function Execute-QueryAndDecodeAsJson() {
    param([Parameter(mandatory)]
        [string]
        $DatabasePath,
        [string]
        $QueryPath
    )

    $bqrs = (Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())) + ".bqrs"
    if ( -Not (Test-Path -Path $QueryPath -PathType Leaf) ) {
        throw "Could not resolve query: $QueryPath."
    }

    codeql query run -q -o $bqrs -d $DatabasePath $QueryPath
    if ( -Not $LASTEXITCODE -eq 0 ) {
        throw "Failed to execute query: $QueryPath."
    }

    $jsonResult = (Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())) + ".json"
    codeql bqrs decode -q -o $jsonResult --format=json $bqrs
     if ( -Not $LASTEXITCODE -eq 0 ) {
        throw "Failed to decode results file $bqrs."
    }
    $result = Get-Content -Path $jsonResult | ConvertFrom-Json

    return $result
}
