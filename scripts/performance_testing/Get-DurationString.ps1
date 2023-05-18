function Get-DurationString {
    param(
        [Parameter(Mandatory)] 
        [string]
        $LogLine    
    )
    $In = $LogLine.IndexOf('eval')+5
    $Out = $LogLine.indexof(']')

    return $LogLine.substring($In, $Out - $In)
}

