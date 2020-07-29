
Function Get-RelatedFiles {
param($Path,$Offset,$SearchDir,
[parameter(Mandatory=$true)]
[ValidateSet("Seconds","Minutes","Hours","Days")]
[string[]]
$Unit)

#Get time of source file
$File = (Get-ChildItem "$Path").CreationTimeUtc

#Change human preferred to proper format
if($Unit -match "Seconds"){$Time ="AddSeconds"}
elseif($Unit -match "Minutes"){$Time = "AddMinutes"}
elseif ($Unit -match "Hours") {$Time = "AddHours"}
elseif ($Unit -match "Days"){$Time = "AddDays"}
else{"Invalid input. Please use Seconds, Minutes, Hours, or Days"}     

#Fix time offset if user request 1sec, 1min, 1hr, 1day window. Halve the input time and reduce the unit.
#1hr becomes 30min before and 30min after original creation time
if($Offset -eq 1 -and $Time -eq "AddSeconds"){$Time = "AddMilliseconds";$Offsetcor = 500}
elseif($Offset -eq 1 -and $Time -eq "AddMinutes"){$Time = "AddSeconds";$offsetcor = 30}
elseif($offset -eq 1 -and $Time -eq "AddHours"){ $Time = "AddMinutes"; $Offsetcor = 30}
elseif($Offset -eq 1 -and $Time -eq "AddDays"){$Time = "AddHours"; $Offsetcor = 12}
else{$Offsetcor = $Offset}

#Main Action
$action = (
Get-ChildItem $Searchdir -Include * -Recurse -Force -ErrorAction SilentlyContinue |
Where-Object{$_.CreationTimeUtc -gt $File.$Time(-$Offsetcor) -and $_.CreationTimeUtc -le $File.$Time($Offsetcor)} |
select -Property CreationTimeUtc,FullName
)

#Output
if($null -ne $action){$action}
else{ #Provide confirmation the search window was correctly recognized, but files were not found.
     Write-host "There weren't any files created between " $file.$Time(-$Offsetcor) " and " $File.$Time($Offsetcor)
}

}