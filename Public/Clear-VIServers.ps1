function Clear-VIServers {  
    [CmdletBinding(SupportsShouldProcess = $true,  
        ConfirmImpact = "Medium")]  
    param (  
    )  
    BEGIN {}#begin 
	PROCESS 
	{ 

		if ($psCmdlet.ShouldProcess("reset", "$DefaultVIServer and $DefaultVIServers")) { 
			Disconnect-VIServer -Server $DefaultVIServers -Confirm:$false
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
