Write-Debug "Running exportxls.ps1 to create function Export-Xls"

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

Export-ModuleMember -function Export-Xls