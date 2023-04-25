function Convert-DurationStringToMs {
    param(
    [Parameter(Mandatory)] 
    [string]
    $DurationString
    )

    $durationStack = @()
    $unitStack = @() 

    
    $durationBuff = $false
    $unitBuff     = $false

    for($i=0; $i -le $DurationString.Length; $i++){
        $s = $DurationString[$i]
        #Write-Host $s 
        if($s -match "\d|\."){ # consume if it is a number or a decimal

            # init buffer
            if($durationBuff -eq $false){
                $durationBuff = ""
            }

            # accept last unit 
            if(-Not $unitBuff -eq $false){
                $unitStack += $unitBuff
                $unitBuff = $false 
            }

            $durationBuff += $s 
        }else{                 # otherwise it is a unit -- multiply by it to get the ms.

            # init buffer
            if($unitBuff -eq $false){
                $unitBuff = ""
            }

            # accept last digit buffer 
            if(-Not $durationBuff -eq $false){
                $durationStack += $durationBuff
                $durationBuff = $false 
            }

            $unitBuff += $s
        }
    }

    # should always end with accepting the last one (because it will be a
    # unit)
    $unitStack += $unitBuff

    $totalMs = 0

    for($i=0; $i -le $unitStack.Length; $i++){

        $time =  [System.Convert]::ToDecimal($durationStack[$i])
        $unit = $unitStack[$i] 

        if($unit -eq 'h'){
            $time = $time * (60*60*1000)
        }
        if($unit -eq 'm'){
            $time = $time * (60*1000)
        }
        if($unit -eq 's'){
            $time = $time * (1000)
        }
        if($unit -eq 'ms'){
            $time = $time 
        }

        $totalMs += $time 
    }

    return $totalMs
}