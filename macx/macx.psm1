Function Export-Xls{
	<#
.SYNOPSIS
	Saves Microsoft .NET Framework objects to a worksheet in an XLS file
.DESCRIPTION
	The Export-Xls function allows you to save Microsoft .NET Framework objects
	to a named worksheet in an Excel file (type XLS). The position of the
	worksheet can be specified.
.NOTES
	Author:  Luc Dekens
.PARAMETER InputObject
	Specifies the objects to be written to the worksheet. The parameter accepts
	objects through the pipeline.
.PARAMETER Path
	Specifies the path to the XLS file.
.PARAMETER WorksheetName
	The name for the new worksheet. If not specified the name will
	be "Sheet" followed by the "Ticks" value
.PARAMETER SheetPosition
	Specifies where the new worksheet will be inserted in the series of
	existing worksheets. You can specify "begin" or "end". The default
	is "begin".
.PARAMETER NoTypeInformation
	Omits the type information from the worksheet. The default is to
	include the "#TYPE" line.
.PARAMETER AppendWorksheet
	Specifies if the worksheet should keep or remove the existing
	worksheet in the spreadsheet. The default is to append.
.EXAMPLE
	PS> Export-Xls -
#>
	param(
	[parameter(ValueFromPipeline = $true,Position=1)]
	[ValidateNotNullOrEmpty()]
	$InputObject,
	[parameter(Position=2)]
	[ValidateNotNullOrEmpty()]
	[string]$Path,
	[string]$WorksheetName = ("Sheet " + (Get-Date).Ticks),
	[string]$SheetPosition = "begin",
	[switch]$NoTypeInformation = $true,
	[switch]$AppendWorksheet = $true
	)

	Begin{
		$excelApp = New-Object -ComObject "Excel.Application"
		$originalAlerts = $excelApp.DisplayAlerts
		$excelApp.DisplayAlerts = $false
		$excelApp.Visible = $true
		if(Test-Path -Path $Path -PathType "Leaf"){
			$workBook = $excelApp.Workbooks.Open($Path)
		}
		else{
			$workBook = $excelApp.Workbooks.Add()
		}
		$sheet = $excelApp.Worksheets.Add($workBook.Worksheets.Item(1))
		if(!$AppendWorksheet){
			$workBook.Sheets | where {$_ -ne $sheet} | %{$_.Delete()}
		}
		$sheet.Name = $WorksheetName
		if($SheetPosition -eq "end"){
			$nrSheets = $workBook.Sheets.Count
			2..($nrSheets) |%{
				$workbook.Sheets.Item($_).Move($workbook.Sheets.Item($_ - 1))
			}
		}
		$tempCsvName = $env:Temp + "\Report-" + (Get-Date).Ticks + ".csv"
		$array = @()
	}

	Process{
		$array += $InputObject
	}

	End{
		$array | Export-Csv -Path $tempCsvName -NoTypeInformation:$NoTypeInformation
		$csvBook = $excelApp.Workbooks.Open($tempCsvname)
		$csvSheet = $csvBook.Worksheets.Item(1)
		$csvSheet.UsedRange.Copy() | Out-Null
		$sheet.Paste()
		$sheet.UsedRange.EntireColumn.AutoFit() | Out-Null
		if($excelApp.Version -lt 14){
			$csvbook.Application.CutCopyMode = $false
		}
		$csvBook.Close($false,$null,$null)
		Remove-Item -Path $tempCsvName -Confirm:$false
		$workbook.Sheets.Item(1).Select()
		$workbook.SaveAs($Path)
		$excelApp.DisplayAlerts = $originalAlerts
		$excelApp.Quit()
		Stop-Process -Name "Excel"
	}
}


function Start-Rdsclient {
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

function Clear-VIServers{  
[CmdletBinding(SupportsShouldProcess=$true,  
    ConfirmImpact="Medium")]  
param (  
)  
BEGIN{}#begin 
PROCESS{ 

if ($psCmdlet.ShouldProcess("reset", "$DefaultVIServer and $DefaultVIServers")) { 
    $global:DefaultVIServer = $nul
    $global:DefaultVIServers = $nul
} 

}#process 
END{}#end 

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
    } catch {
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
        [ValidateScript({ Test-Path -Path $_ })]
        [string[]]
        $path
    )

    Process {
        forEach($filePath in $path) {
            $headers = (Get-Content -Path $filePath -TotalCount 4 | Select -First 1 -Skip 3) -replace '#Fields: ' -split ' '
            $headers = $headers[0..($headers.count-2)] 
            Get-Content $filePath | Select-String -Pattern '^#' -NotMatch | ConvertFrom-Csv -Delimiter ' ' -Header $headers
        }
    }
}


#set-alias putty "C:\Program Files (x86)\putty\putty.exe"
set-alias zip write-zip
set-alias unzip expand-archive
set-alias xn "C:\Program Files (x86)\XML Notepad 2007\XmlNotepad.exe"
set-alias rh Resolve-DnsName



#. "$psscriptroot\ipxls.ps1"

Export-ModuleMember -function Export-Xls
Export-ModuleMember -function start-rdsclient
Export-ModuleMember -function get-website
Export-ModuleMember -Function Clear-VIServers
Export-ModuleMember -function get-shawphone
Export-ModuleMember -Function Test-IsAdmin
Export-ModuleMember -Function Convert-IISLogsToObject

Export-ModuleMember -alias gws
Export-ModuleMember -alias ts
Export-ModuleMember -alias rds
#Export-ModuleMember -alias putty
Export-ModuleMember -alias zip
Export-ModuleMember -alias unzip
Export-ModuleMember -alias xn
Export-ModuleMember -alias rh
Export-ModuleMember -Alias cvis
Export-ModuleMember -Alias gsp
