Write-Debug "Running startrdsclient.ps1 to create function start-rdsclient"

function start-rdsclient {
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
	[parameter(ValueFromPipeline = $true,Position=1)]
	[ValidateNotNullOrEmpty()]
	[string] $hostname,
	[parameter(Position=2)]
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

Export-ModuleMember -function start-rdsclient
Export-ModuleMember -alias ts
Export-ModuleMember -alias rds
