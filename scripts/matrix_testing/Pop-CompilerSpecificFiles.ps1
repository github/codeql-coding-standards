. "$PSScriptRoot/Config.ps1"
function Pop-CompilerSpecificFiles {
    param([Parameter(Mandatory)] 
        [hashtable[]]    
        $Context
    )

    foreach($c in $Context){

        $origin = $c.origin 
        $temp   = $c.temp 

        if($temp){
            Write-Host "Restoring $temp -> $origin"
            Copy-Item -Force -Path $temp -Destination $origin
        }else {
            # otherwise we just need to delete the origin 
            Write-Host "Removing unneeded context item $origin"
            Remove-Item -Force $origin 
        }
    }
    
}