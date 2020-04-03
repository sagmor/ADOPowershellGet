$Violations = Invoke-ScriptAnalyzer -path $PSScriptRoot\..\Functions -Recurse -Settings $PSScriptRoot\PSScriptAnalyzerSettings.psd1

if ($null -eq $Violations) {
    exit 0
}

write-Warning "Scripts failed static analysis"
Write-Output $Violations

exit 1