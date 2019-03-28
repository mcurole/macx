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
        [parameter]
        [ValidateNotNullOrEmpty()]
        [alias("console")]
        [switch]$admin,
        [parameter(Position = 2)]
        [string]$gateway
    )

    $cmd = "mstsc /v:$hostname"
    if ($admin) {
        $cmd += " /admin"
    }
    if ($gateway -ne "") {
        $cmd += " /g:$gateway"
    }

    Invoke-Expression $cmd
}
