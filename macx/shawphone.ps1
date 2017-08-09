Write-Debug "Running shawphone.ps1 to create function get-shawphone"

function get-shawphone {
	<#
.SYNOPSIS
	Get phone information
.DESCRIPTION
	The get-shawphone gets data from the phone book.
.NOTES
	Author:  Mark Curole
.PARAMETER Name
	Name of person to search
.EXAMPLE
	PS> get-shawphone -name mark
#>
	param(
	[parameter(ValueFromPipeline = $true,Position=1)]
	[ValidateNotNullOrEmpty()]
	[string] $name
	)

$shawphone = New-WebServiceProxy -uri "http://shawphone.shawinc.com/PhoneService.svc"

$shawphone.search($name,"","","","","","","","") 

}

New-Alias gsp get-shawphone

Export-ModuleMember -function get-shawphone
Export-ModuleMember -Alias gsp