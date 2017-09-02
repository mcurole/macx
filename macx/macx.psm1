Function Start-RdsClient {
    <#
.SYNOPSIS
	Starts Remote Desktop Client
.DESCRIPTION
	The start-rdsclient function starts the remote desktop service client
.NOTES
	Author:  Mark Curole
.PARAMETER Hostname
	Specifies the hostname to connect to.
.PARAMETER Admin
	Specifies to connect in admin mode - console on Windows 2003
.EXAMPLE
	PS> start-rdsclient server
#>
    param(
        [parameter(ValueFromPipeline = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string] $hostname,
        [parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [alias("console")]
        [switch]$admin
    )

 
    if ($admin) {
        mstsc /v:$hostname /admin
    } 
    else {
        mstsc /v:$hostname
    }
}

set-alias ts start-rdsclient
set-alias rds start-rdsclient

function Clear-VIServers {  
    [CmdletBinding(SupportsShouldProcess = $true,  
        ConfirmImpact = "Medium")]  
    param (  
    )  
    BEGIN {}#begin 
	PROCESS 
	{ 

		if ($psCmdlet.ShouldProcess("reset", "$DefaultVIServer and $DefaultVIServers")) { 
			Disconnect-VIServer -Server $global:DefaultVIServers -Confirm:$false
		} 

    } #process 
	
	END {}#end 

    <#
.SYNOPSIS
    Clears VIServers Variables to reset PowerCLI
.DESCRIPTION
    The Clear-VIServers function clears the PowerCLI global variables $DefaultVIServer and $DefaultVIServers. This is to be used to reset PowerCLI in case of network
    disruption or an other time when Disconnect-VIServer was not performed
.PARAMETER <Parameter-Name>
.EXAMPLE
.INPUTS
.OUTPUTS
.NOTES
.LINK
#> 

}

Set-Alias -Name cvis -Value Clear-VIServers

Function Switch-DockerEngine {
    <#
.SYNOPSIS
	Switch Docker Engine Between Windows and Linux Containers
.DESCRIPTION
	Switch Docker Engine Between Windows and Linux Containers
.NOTES
	Author:  Mark Curole
.EXAMPLE
	PS> Switch-DockerEngine
#>
    param( )

	& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon
}

New-Alias sde Switch-DockerEngine

function Test-IsAdmin {
    <#
        .SYNOPSIS
            Checks if the current Powershell instance is running with elevated privileges or not.
        .EXAMPLE
            PS C:\> Test-IsAdmin
        .OUTPUTS
            System.Boolean
                True if the current Powershell is elevated, false if not.
    #>
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
        return $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    }
    catch {
        throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f $_
    }

}

function Convert-IISLogsToObject {
    <#
    .Synopsis
        Converts plain text IIS logs into a ps Object
    .DESCRIPTION
        Converts plain text IIS logs into a ps Object
    .EXAMPLE
        Get-ChildItem '<path to logs>\*.log' | Convert-IISLogsToObject | Sort-Object c-ip -Unique
    .EXAMPLE
        Convert-IISLogsToObject -path (Get-ChildItem '<path to logs>\*log') | Where-Object { $_.'cs-username' -eq '<userName>' } | Sort-Object c-ip -Unique
    .NOTES
        General notes
    .AUTHOR
        Ben Taylor - 09/07/2016
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( { Test-Path -Path $_ })]
        [string[]]
        $path
    )

    Process {
        forEach ($filePath in $path) {
            $headers = (Get-Content -Path $filePath -TotalCount 4 | Select-Object -First 1 -Skip 3) -replace '#Fields: ' -split ' '
            $headers = $headers[0..($headers.count - 2)] 
            Get-Content $filePath | Select-String -Pattern '^#' -NotMatch | ConvertFrom-Csv -Delimiter ' ' -Header $headers
        }
    }
}



#set-alias putty "C:\Program Files (x86)\putty\putty.exe"
set-alias zip write-zip
set-alias unzip expand-archive
set-alias rh Resolve-DnsName



#. "$psscriptroot\ipxls.ps1"

Export-ModuleMember -function Start-RdsClient
Export-ModuleMember -Function Clear-VIServers
Export-ModuleMember -function Switch-DockerEngine
Export-ModuleMember -Function Test-IsAdmin
Export-ModuleMember -Function Convert-IISLogsToObject

Export-ModuleMember -alias ts
Export-ModuleMember -alias rds
Export-ModuleMember -alias zip
Export-ModuleMember -alias unzip
Export-ModuleMember -alias rh
Export-ModuleMember -Alias cvis
Export-ModuleMember -Alias sde
