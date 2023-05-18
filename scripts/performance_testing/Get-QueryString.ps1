function Get-QueryString {
    param(
        [Parameter(Mandatory)] 
        [string]
        $LogLine    
    )
    $In = $LogLine.IndexOf('Evaluation done; writing results to ')+36
    $Out = $LogLine.IndexOf('.bqrs')

    return $LogLine.SubString($In, $Out - $In)
}

