Get-ChildItem -Path $PSScriptRoot/Private/*.ps1 | ForEach-Object {
    Write-Verbose "Loading $_"
    . $_.FullName
}

Get-ChildItem -Path $PSScriptRoot/Public/*.ps1 | ForEach-Object {
    Write-Verbose "Loading $_"
    . $_.FullName

    Export-ModuleMember -Function $_.BaseName
}
