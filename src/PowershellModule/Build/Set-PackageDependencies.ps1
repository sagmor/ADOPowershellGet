Param(
    [string]
    $NusPecPath
)
$ErrorActionPreference = "Stop"
$NuspecNamespace = "http://schemas.microsoft.com/packaging/2011/10/nuspec.xsd"

$ModuleData = Import-PowerShellDataFile -Path "$PSScriptRoot\..\ADOPowershellGet.psd1"

[xml]$Nuspec = Get-Content -Path $NusPecPath

$DependenciesNode = $Nuspec.CreateElement("dependencies", $NuspecNamespace)

$ModuleData.RequiredModules | ForEach-Object {
    $DependencyNode = $Nuspec.CreateElement("dependency", $NuspecNamespace)
    $DependencyNode.SetAttribute("id", $_.ModuleName)
    $DependencyNode.SetAttribute("version", $_.ModuleVersion)
    $DependenciesNode.AppendChild($DependencyNode)
} | Out-Null

$Nuspec.GetElementsByTagName("metadata")[0].AppendChild($DependenciesNode) | Out-Null

$Nuspec.Save($NusPecPath)
