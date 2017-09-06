# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    $ProjectRoot = Resolve-Path "$PSScriptRoot\.."
    $Timestamp = Get-Date -UFormat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $ModuleName = Split-Path -Path $PSScriptRoot -Leaf
    $ModuleRoot = $PSScriptRoot
    $OutPutFolder = "$PSScriptRoot\Output"
    $ImportFolders = @('Public', 'Internal', 'Classes', 'DSCResources', 'TypeExtensions')
    $PsmPath = Join-Path -Path $PSScriptRoot -ChildPath "Output\$($ModuleName)\$($ModuleName).psm1"
    $PsdPath = Join-Path -Path $PSScriptRoot -ChildPath "Output\$($ModuleName)\$($ModuleName).psd1"
    $HelpPath = Join-Path -Path $PSScriptRoot -ChildPath "Output\$($ModuleName)\en-US"
    $PublicFolder = 'Public'
    $DSCResourceFolder = 'DSCResources'
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
}

# $compileParams = @{
#     Inputs = {
#         foreach ($folder in $ImportFolders)
#         {
#             Get-ChildItem -Path $folder -Recurse -File -Filter '*.ps1'
#         }
#     }

#     Output = {
#         $PsmPath
#     }
# }

Task default -depends Clean, Compile, CopyPSD, UpdatePublicFunctionsToExport, Test

Task Clean {
    if (-not(Test-Path $OutPutFolder))
    {
        New-Item -ItemType Directory -Path $OutPutFolder | Out-Null
    }

    Remove-Item -Path "$($OutPutFolder)\*" -Force -Recurse
   
}

#task Compile @compileParams {
task Compile {
    if (Test-Path -Path $PsmPath)
    {
        Remove-Item -Path $PsmPath -Recurse -Force
    }
    New-Item -Path $PsmPath -Force > $null

    foreach ($folder in $ImportFolders)
    {
        $currentFolder = Join-Path -Path $ModuleRoot -ChildPath $folder
        Write-Verbose -Message "Checking folder [$currentFolder]"

        if (Test-Path -Path $currentFolder)
        {
            $files = Get-ChildItem -Path $currentFolder -File -Filter '*.ps1'
            foreach ($file in $files)
            {
                Write-Verbose -Message "Adding $($file.FullName)"
                Get-Content -Path $file.FullName >> $PsmPath
            }
        }
    }
}

task CopyPSD {
    $copy = @{
        Path        = "$($ModuleName).psd1"
        Destination = $PsdPath
        Force       = $true
    }
    Copy-Item @copy
}

#task UpdatePublicFunctionsToExport -if (Test-Path -Path $PublicFolder) {
task UpdatePublicFunctionsToExport {
    $publicFunctions = (Get-ChildItem -Path $PublicFolder -Filter "*.ps1").BaseName

    Update-ModuleManifest -Path $PsdPath -FunctionsToExport $publicFunctions
}

Task Test {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"
    $resultFile = "{0}\testResults{1}.xml" -f $OutPutFolder, (Get-date -Format 'yyyyMMdd_hhmmss')
    $testFolder = Join-Path -Path $PSScriptRoot -ChildPath 'Tests\*'
    Invoke-Pester -Path $testFolder -OutputFile $resultFile -OutputFormat NUnitxml
    "`n"
}

Task Deploy {
    $lines
    
    Invoke-PSDeploy -Force
}