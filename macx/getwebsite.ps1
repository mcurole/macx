Write-Debug "Running getwebsite.ps1 to create function get-website"

function get-website {
<#
.SYNOPSIS
	Launches browser to a web site.
.DESCRIPTION
	The get-website function launches a browser to a website
.NOTES
	Author:  Mark Curole
.PARAMETER Site
	Specifies the site to access.
.EXAMPLE
	PS> get-website "http://www.microsoft.com"
#>
Param ([parameter(ValueFromPipeline = $true,Position=1)] [string] $Site = "http://www.google.com/ig?hl=en" )

[diagnostics.process]::start($Site)

}

set-alias gws get-website

Export-ModuleMember -function get-website
Export-ModuleMember -alias gws
