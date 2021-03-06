$CAPath = 'CASERVERFQDN\CANAME'
$webURL1 = 'webserver1.ldap389.info'
$webURL2 = 'webserver2.ldap389.fr'
$webURL3 = 'webserver3.ldap389.info'
$CertTemplate = '2008-Webserver'
$webserver = 'WEBSERVERNAME'


$iisinf = 'iis.inf'
$iisreq = 'iis.req'
$iiscrt = 'iis.crt'


#Create PSsession to IIS server
New-PSSession -computername $webserver

$array = @($iisinf,$iisreq,$CAPath,$webURL1,$webURL2,$webURL3,$CertTemplate)

icm $webserver -scriptblock {

	param($argarray)

	#Create Policy file inf
	new-item $argarray[0] -type file


	add-content $argarray[0] '[Version]'
	add-content $argarray[0] 'Signature="$Windows NT$"'
	add-content $argarray[0] ''
	add-content $argarray[0] '[NewRequest]'
	add-content $argarray[0] 'Exportable = FALSE'
	add-content $argarray[0] 'KeyLength = 2048'
	add-content $argarray[0] 'RequestType = CMC'
	add-content $argarray[0] '[RequestAttributes]'
	$line = 'CertificateTemplate= ' + $argarray[6]
	add-content $argarray[0] $line
	add-content $argarray[0] '[Extensions]'
	add-content $argarray[0] '2.5.29.17 = "{text}"'
	$line = '_continue_ = "dns=' + $argarray[3] + '&"'
	add-content $argarray[0] $line
	$line = '_continue_ = "dns=' + $argarray[4] + '&"'
	add-content $argarray[0] $line
	$line = '_continue_ = "dns=' + $argarray[5] + '&"'
	add-content $argarray[0] $line


	#Create Req file
	certreq -config $argarray[2] -new $argarray[0] $argarray[1]




} -ArgumentList $array,$null


$array = @($CAPath,$iisreq)

#Send Request for approval to CA

$Requestforsigning = icm $webserver {param($argarray);certreq.exe -config $argarray[0] -submit $argarray[1]} -ArgumentList $array,$null
 
#Get Request ID
$reqt = $Requestforsigning[0].replace('RequestId: ','')

#Prompt
$Proceed = read-host "Issue certificate for request ID"$reqt"? To perform this operation this you need to be a CA Manager (Y/N)"

if ($Proceed -eq 'Y') {

	#Accept request and sign certificate
	certutil -resubmit $reqt



	$array = @($reqt,$iiscrt,$CAPath,$iisreq,$iisinf)

	icm $webserver -scriptblock {

		param($argarray)
		#Retrieve CRT file, in order to put in Certificate store
		certreq -config $argarray[2] -retrieve $argarray[0] $argarray[1]

		#Put certificate in Certificate store
		certreq -accept $argarray[1]

		#Clean INF CRT and REQ files
		Remove-Item $argarray[1]
		Remove-Item $argarray[3]
		Remove-Item $argarray[4]

	} -ArgumentList $array,$null



	#Get certificate thumbprint to upper case, replace spaces and quote 
	$thumbprint = ((((certutil -view -restrict "RequestID=$reqt" -out CertificateHash csv)[1]).replace(' ','')).replace('"','')).ToUpper()



	icm $webserver -scriptblock {

		param($argarray)

		#Import IIS Psh commands
		import-module WebAdministration
		#Create Binding
		New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https

		#Assign Certificate to SSL 443 port 
		cd IIS:\SslBindings
		Get-Item cert:\LocalMachine\MY\$argarray | new-item 0.0.0.0!443

	} -ArgumentList $thumbprint

}

#Close psessions
get-pssession -computername $webserver | remove-pssession

