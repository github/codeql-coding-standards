$Functions  = @( Get-ChildItem -Path $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue )

foreach($i in $Functions){
    . $i.FullName 

    Write-Host "Importing $($i.FullName)"
}

Export-ModuleMember -Function $Functions.BaseName 

Write-Host "IMPORTING "