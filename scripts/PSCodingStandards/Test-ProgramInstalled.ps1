function Test-ProgramInstalled {
    param(
        [Parameter(Mandatory)] 
        [string]
        $Program
    )

    if ($null -eq (Get-Command $Program -ErrorAction SilentlyContinue)) {
        throw "Suitable '$Program' program not installed."
    }
}
