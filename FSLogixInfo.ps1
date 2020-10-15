#FSL Version
$FSLVersion = (Get-ItemProperty -Path "C:\Program Files\FSLogix\Apps\frxccd.sys").VersionInfo

#Get VHDX Size from Primary FSLogix Server
$USER = $env:fullusername
$SID = (New-Object System.Security.Principal.NTAccount($USER)).Translate([System.Security.Principal.SecurityIdentifier]).value
$VHDXOnline= "<SHARENAME>" + $($user) + "_" + $($SID)
#Size of Conatiner on Server in Gb
$VHDXOnlineSize= [math]::round($((Get-ChildItem -Filter '*.vhdx' -Path $VHDXOnline).Length) /1Gb,2)


#Get VHDX Info for connected User from local connected VHDX
$O365DiskInfo = Get-Volume | Select-Object * | Where-Object {$_.FileSystemLabel -like "O365-*"}
$DiskStatus = $O365DiskInfo.HealthStatus
$DiskSize = [math]::round($($O365DiskInfo.Size)/1Gb, 2)
$DiskRemain = [math]::round($($O365DiskInfo.SizeRemaining)/1Gb, 2)
$DiskUsed = [math]::round($($DiskSize - $DiskRemain)/1 ,2)
$DiskWhite = [math]::round($($VHDXOnlineSize - $DiskUsed)/1, 2)
$WhiteSpaceRatio = [math]::round($($DiskWhite / $DiskRemain * 100)/1, 2)

#FSLogix Operational Log File Last 15 Events
$FSLogixOperationalLog = Get-WinEvent -ProviderName 'FSLogix-Apps' -MaxEvents 15


#Show all gathered Data to User
Write-Host "MS FSLogix Version      : " $($FSLVersion.FileVersion) -ForegroundColor Green
Write-Host "Info for User           : " $USER -ForegroundColor Green
Write-Host ""
Write-Host "FSL Apps Services       : " (Get-Service -Name frxsvc).Status
Write-Host "FSL Cloud Cache Service : " (Get-Service -Name frxccds).Status
Write-Host ""
Write-Host "VHDX Status             : " $DiskStatus
Write-Host "VHDX Container Size     : " $VHDXOnlineSize "Gb"
Write-Host "VHDX Disk Size          : " $DiskSize "Gb"
Write-Host "VHDX Remaining Size     : " $DiskRemain "Gb"
Write-Host "VHDX White Space Size   : " $DiskWhite "Gb"
Write-Host "VHDX White Space Ratio  : " $WhiteSpaceRatio "%"
Write-Host ""
Write-Host "Last 15 Operational FSLogix Events" -ForegroundColor Green -NoNewline
$FSLogixOperationalLog
Write-Host ""
Write-Host ""
[void](Read-Host 'Press [Enter] to continue')
