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

