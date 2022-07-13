function Get-RepositoryRoot {
    return git rev-parse --show-toplevel 
}
