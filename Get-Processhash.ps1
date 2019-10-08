function Get-ProcessHash 

($name="*" , $Algorithm = "MD5", $virustotal = "False") {
$ErrorActionPreference = "SilentlyContinue"

$process = get-process $name | select -Property Name,Path -Unique
#This hashing is needed for the Virustotal submission
$File = $process | %{get-filehash -Algorithm MD5 -path ($_.Path) | select -Unique} | select -Property Hash,Path

if ($virustotal -like "true" -or "y" -or "yes"){
<#
Currently a work in progress...
Replace conten of the variable with your apikey
A Public API will only accept 4 requests/min. If you have a public API it is recommended you run
command naming one process to submit. Multiple processes can be queried using names separated by a comma.
#>
$apikey = "40abbdbb3a05d071073121fbfb1a16e8c064b9e923937c7fb4b7891f0c6c4576"
$body = @{}
$body = @{resource = $file.hash; apikey = $apikey}
$VTresult = Invoke-RestMethod -Method GET -Uri "https://www.virustotal.com/vtapi/v2/file/report?" -Body $body
}


$item = $null
$result = @()
$process |%{
$item = New-Object PSObject @{
 Process =  $_.Name
 Hash = Get-FileHash -Algorithm $Algorithm -Path $_.path | select -Property Hash -ExpandProperty Hash
 Path = $_.Path
 Virustotal = $VTresult.positives
}
$result += $item
}

$result 



}

