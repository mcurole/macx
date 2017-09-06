Function Connect-RdServer {
    <#
.SYNOPSIS
	Connect to Remote Desktop Server
.DESCRIPTION
	The Connect-RdServer function starts the remote desktop client
.NOTES
	Author:  Mark Curole
.PARAMETER Hostname
	Specifies the hostname to connect to.
.PARAMETER Admin
	Specifies to connect in admin mode - console on Windows 2003
.EXAMPLE
	PS> Connect-RdServer server
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
