function Get-LanguageForPath {
    param([Parameter(Mandatory)] 
        [string]
        $Path)

    $parts = $Path -split '/'

    $Language = $parts[0]

    foreach($L in $AVAILABLE_LANGUAGES){
        if($Language -eq $L){
            return $L
        }
    }

    throw "Unsupported Language: $Language"
}