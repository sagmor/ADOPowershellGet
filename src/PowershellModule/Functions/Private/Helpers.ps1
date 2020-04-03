<#
.SYNOPSIS
    Build a nuget Feed url from the account/feed info
#>
function Get-ADOFeedURL {
    [CmdletBinding()]
    [OutputType('System.String')]
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Feed
    )

    $Components = $Feed.Split('/')
    $Account = $Components[0]
    $FeedName = $Components[1]

    "https://$Account.pkgs.visualstudio.com/_packaging/$FeedName/nuget/v2/"
}

<#
.SYNOPSIS
    Get credentials for an ADO feed
#>
function Get-ADOFeedCredential {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $FeedUrl
    )

    $RawCredentials = & "$PSScriptRoot\..\..\Assets\CredentialProvider.VSS.exe" -V Silent -U $FeedUrl | ConvertFrom-Json

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to fetch credentials for feed"
    }

    $Username = $RawCredentials.Username
    $Password = ConvertTo-SecureString $RawCredentials.Password -AsPlainText -Force

    $Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

    $Credential
}
