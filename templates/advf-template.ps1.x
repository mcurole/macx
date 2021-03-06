function aaaa-yyyyyy{ 
[CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact="Medium Low High None", 
    DefaultParameterSetName="XXXXX")] 
param ( 
[parameter(Position=0,
   Mandatory=$true,
   ParameterSetName="YYYYYYYYYY",
   ValueFromPipeline=$true, 
   ValueFromPipelineByPropertyName=$true,
   ValueFromRemainingArguments=$true,
   HelpMessage="Put your message here" )]
   [Alias("CN", "ComputerName")]  
   [AllowNull()]
   [AllowEmptyString()]
   [AllowEmptyCollection()]
   [ValidateCount(1,10)]
   [ValidateLength(1,10)]
   [ValidatePattern("[A-Z]{2,8}[0-9][0-9]“)]
   [ValidateRange(0,10)]
   [ValidateScript({$_ -ge (get-date)})]
   [ValidateSet("Low", "Average", "High")]
   [ValidateNotNull()]
   [ValidateNotNullOrEmpty()]
   [string]$computer=”.” 
) 
BEGIN{}#begin 
PROCESS{

if ($psCmdlet.ShouldProcess(“## object ##”, “## message ##”)) {
    ## action goes here
}

}#process 
END{}#end