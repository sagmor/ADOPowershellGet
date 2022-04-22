<#
.SYNOPSIS
    Build a nuget Feed url from the Account/Feed info. Account may consist of just Organization or Organization/Project.
.PARAMETER feed
    The feed Account and value. Expected format as "Organization/Feed" or "Organization/Project/Feed".
#>
function Get-ADOFeedURL {
    [CmdletBinding()]
    [OutputType('System.String')]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Feed
    )

    $Account = $Feed.Substring(0, $Feed.LastIndexOf('/'))
    $FeedName = $Feed.Substring($Feed.LastIndexOf('/') + 1)

    "https://pkgs.dev.azure.com/$Account/_packaging/$FeedName/nuget/v2/"
}

<#
.SYNOPSIS
    Get credentials for an ADO feed
#>
function Get-ADOFeedCredential {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCredential')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
    Param(
        [Parameter(Mandatory = $true)]
        [string] $FeedUrl,

        [Parameter()]
        [string] $AccessToken
    )

    if ($AccessToken) {
        Write-Verbose "Using provided Access Token"
        $Username = "AccessToken"
        $Password = ConvertTo-SecureString $AccessToken -AsPlainText -Force

        # On Azure Pipeline agents the Agent tries to invoke the embeded CredentialProvider causing issues
        # See: https://github.com/OneGet/oneget/issues/460
        # This forces CredentialProvider to use the provided AccessToken
        $env:VSS_NUGET_ACCESSTOKEN = $AccessToken
        $env:VSS_NUGET_URI_PREFIXES = $FeedUrl -replace "\/$", ""
    }
    else {
        $Verbosity = ""
        if ($VerbosePreference -match "Silent") {
            $Verbosity = "Silent"
        }
        else {
            $Verbosity = "Detailed"
        }

        $RawCredentials = & "$PSScriptRoot\..\..\Assets\CredentialProvider.VSS.exe" -V $Verbosity -U $FeedUrl | ConvertFrom-Json

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to fetch credentials for feed"
        }

        $Username = $RawCredentials.Username
        $Password = ConvertTo-SecureString $RawCredentials.Password -AsPlainText -Force
    }


    $Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

    $Credential
}

<#
.SYNOPSIS
    Cleanup system from temporary resources
#>
function Clear-TemporaryRepository {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [string] $RepositoryName,
        [Parameter()]
        [string] $AccessToken
    )

    if ($AccessToken) {
        Write-Verbose "Cleaning up VSS environment variables"
        $env:VSS_NUGET_ACCESSTOKEN = ""
        $env:VSS_NUGET_URI_PREFIXES = ""
    }

    Unregister-PSRepository -Name $RepositoryName | Out-Null
}
