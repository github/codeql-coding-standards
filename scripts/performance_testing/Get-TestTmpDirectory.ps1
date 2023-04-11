function Get-TestTmpDirectory {
    $Dir = [System.IO.Path]::GetTempPath()
    return Join-Path $Dir "$([System.Guid]::NewGuid())"
}

