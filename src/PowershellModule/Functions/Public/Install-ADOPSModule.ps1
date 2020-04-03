<#

.ForwardHelpTargetName Install-Module
.ForwardHelpCategory Function

#>
function Install-ADOPSModule {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "Processed by Install-Module call")]
    [CmdletBinding(ConfirmImpact='Medium', HelpUri='https://go.microsoft.com/fwlink/?LinkID=398573')]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [string]
        $Feed,

        [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Name},

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [string]
        ${MinimumVersion},

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [string]
        ${MaximumVersion},

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [string]
        ${RequiredVersion},

        [ValidateSet('CurrentUser','AllUsers')]
        [string]
        $Scope = "CurrentUser",

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [uri]
        ${Proxy},

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${ProxyCredential},

        [switch]
        ${AllowClobber},

        [switch]
        ${SkipPublisherCheck},

        [switch]
        ${Force},

        [Parameter(ParameterSetName='NameParameterSet')]
        [switch]
        ${AllowPrerelease},

        [switch]
        ${AcceptLicense},

        [switch]
        ${PassThru})

    begin
    {

        $FeedUrl = Get-ADOFeedURL $Feed
        $Credential = Get-ADOFeedCredential $FeedUrl
        $RepositoryName = "ADO/$Feed"

        $PSBoundParameters.Remove("Account") | Out-Null
        $PSBoundParameters.Remove("Feed") | Out-Null
        Register-PSRepository -Name $RepositoryName -SourceLocation $FeedUrl -Credential $Credential -InstallationPolicy Trusted | Out-Null
        $PSBoundParameters['Repository'] = ,$RepositoryName
        $PSBoundParameters['Credential'] = $Credential

        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Install-Module', [System.Management.Automation.CommandTypes]::Function)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        Unregister-PSRepository -Name $RepositoryName | Out-Null
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
}