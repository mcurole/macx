Write-Debug "Running alias.ps1 to create function start-rdsclient"

#set-alias putty "C:\Program Files (x86)\putty\putty.exe"
set-alias zip write-zip
set-alias unzip expand-archive
set-alias xn "C:\Program Files (x86)\XML Notepad 2007\XmlNotepad.exe"
set-alias rh Resolve-DnsName

#Export-ModuleMember -alias putty
Export-ModuleMember -alias zip
Export-ModuleMember -alias unzip
Export-ModuleMember -alias xn
Export-ModuleMember -alias rh