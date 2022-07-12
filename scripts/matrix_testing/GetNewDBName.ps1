function Get-New-DB-Name {
    param([Parameter(Mandatory = $false)] 
        [string]
        $Dir = [System.IO.Path]::GetTempPath()
    )

    [string] $db = "$([System.Guid]::NewGuid()).testproj"
    return Join-Path $Dir $db 
}