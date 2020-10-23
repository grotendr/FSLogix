$Host.UI.RawUI.WindowTitle = "Microsoft FSLogix (Office Container) Info v1.0 --- $(Get-Date -Format "dddd dd/MM/yyyy HH:mm")"

#FSL Version
$FSLVersion = (Get-ItemProperty -Path "C:\Program Files\FSLogix\Apps\frxccd.sys").VersionInfo

#Get VHDX Size from Primary FSLogix Server
$USER = $env:fullusername
$SID = (New-Object System.Security.Principal.NTAccount($USER)).Translate([System.Security.Principal.SecurityIdentifier]).value
$VHDXOnline= "<SERVERNAME\SHARENAME>" + $($user) + "_" + $($SID)
#Size of Conatiner on Server in Gb
$VHDXOnlineSize= [math]::round($((Get-ChildItem -Filter '*.vhdx' -Path $VHDXOnline).Length) /1Gb,2)


#Get VHDX Info for connected User from local connected VHDX
$O365DiskInfo = Get-Volume | Select-Object * | Where-Object {$_.FileSystemLabel -like "O365-*"}
$DiskID=$O365DiskInfo.Path
$FSLRootFolderInfo = Get-ChildItem -LiteralPath $DiskID -ErrorAction SilentlyContinue
        #ODFC
        $ODFCPath=$FSLRootFolderInfo[0].FullName
        $OSTFiles=Get-ChildItem -LiteralPath $ODFCPath -Filter '*.ost' -Recurse -ErrorAction SilentlyContinue -ErrorVariable +OSTError
        $ODFC=[math]::Round($((Get-ChildItem -LiteralPath $ODFCPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
        #ODFCPersonal
        $ODFCPersonalPath=$FSLRootFolderInfo[1].FullName
        $ODFCPersonal=[math]::Round($((Get-ChildItem -LiteralPath $ODFCPersonalPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
        #OfficeFileCache
        $OfficeFileCachePath=$FSLRootFolderInfo[2].FullName
        $OfficeFileCache=[math]::Round($((Get-ChildItem -LiteralPath $OfficeFileCachePath -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
        #Onedrive
        $OneDrivePath=$FSLRootFolderInfo[3].FullName
        $OneDrive=[math]::Round($((Get-ChildItem -LiteralPath $OneDrivePath -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
        $OnedriveLF=(Get-ChildItem -recurse -LiteralPath $OneDrivePath | Where-Object {$_.Attributes -eq 'Archive, ReparsePoint'}).Count
        #OneNote
        $OneNotePath=$FSLRootFolderInfo[4].FullName
        $OneNote=[math]::Round($((Get-ChildItem -LiteralPath $OneNotePath -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
        #OneNoteUWP
        $OneNoteUWPPath=$FSLRootFolderInfo[5].FullName
        $OneNoteUWP=[math]::Round($((Get-ChildItem -LiteralPath $OneNoteUWPPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
        #Search
        #$SearchPath=$FSLRootFolderInfo[6].FullName
        #$Search=[math]::Round($((Get-ChildItem -LiteralPath $SearchPath -Recurse -Force | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
        #Sharepoint
        $SharepointPath=$FSLRootFolderInfo[7].FullName
        $Sharepoint=[math]::Round($((Get-ChildItem -LiteralPath $SharepointPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
        $SharepointLF=(Get-ChildItem -recurse -LiteralPath $SharepointPath | Where-Object {$_.Attributes -eq 'Archive, ReparsePoint'}).Count
        #Skype4B
        $Skype4BPath=$FSLRootFolderInfo[8].FullName
        $Skype4B=[math]::Round($((Get-ChildItem -LiteralPath $Skype4BPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
        #Skype4B_15
        $Skype4B_15Path=$FSLRootFolderInfo[8].FullName
        $Skype4B_15=[math]::Round($((Get-ChildItem -LiteralPath $Skype4B_15Path -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
        #Teams
        $TeamsPath=$FSLRootFolderInfo[10].FullName
        $Teams=[math]::Round($((Get-ChildItem -LiteralPath $TeamsPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)/1,2)
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
#FSLogix RootFolder Info
Write-Host "FSLogix Content Information" -ForegroundColor Green
Write-Host "Outlook Folder Size     : " $ODFC "MB"           
Write-Host "Outlook OST File(s)     : " $OSTFiles.Count
Write-Host "OneDrive Folder Size    : " $OneDrive "MB | " $OnedriveLF "Local File(s)"
Write-Host "Sharepoint Folder Size  : " $Sharepoint "MB | " $SharepointLF "Local File(s)"
Write-Host "Teams Folder Size       : " $Teams "MB"

#FSLogix Operational Log Info
Write-Host""
Write-Host "Last 15 Operational FSLogix Events" -ForegroundColor Green -NoNewline
$FSLogixOperationalLog
Write-Host ""
Write-Host ""
[void](Read-Host 'Press [Enter] to continue') 

