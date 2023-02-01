. "$PSScriptRoot/Config.ps1"
function Pop-CompilerSpecificFiles {
    param([Parameter(Mandatory)] 
        $Context
    )

    foreach($c in $Context){

        $origin = $context.origin 
        $temp   = $context.temp 

        if(-Not $temp -eq $null){
            Write-Host "Restoring $temp -> $origin"
            Move-Item -Force -Path $temp $origin
        }else {
            # otherwise we just need to delete the origin 
            Write-Host "Removing unneeded context item $origin"
            Remove-Item -Force $origin
        }
    }
    
}