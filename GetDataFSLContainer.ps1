########################################################################################################
#
#                                  GetDataFSLContainer.ps1
#
# By RoGr: 20-10-2020
#
# Use Script to get Info from within VHDX O365 FSLogix Containers
# Will show Size per SubFolder like ODFC,Onedrive,Sharepoint etc. also numbers of OST-files
# Script will mount / unmount every unlocked Container from Server and get the Info
#
########################################################################################################

#Array with Data
$AllData = @()

#Logging
$FileDate=(get-Date).ToString("s").Replace(":","-")
$LogPath = "<LOGFILEPATH>"
$LogName = "GetDataFSLContainer" + "_" + $FileDate + ".log"
$Log = $LogPath + "\" + $LogName

#Check and Create Path for Logging
If (-not( Test-Path "$LogPath")) { New-Item -Path "$LogPath" -ItemType Directory}
#Create File and start Logging
If (-not( Test-Path "$Log")) {New-Item -Path $LogPath -Name $LogName -ItemType File}
Add-Content -Path $Log -Value "[$([DateTime]::Now)] *** Start Logging VHDX Containers ***"

#Get All Unlocked VHDX Files on PATH TO FSLogix Folders with VHDX
$AllUnlockedFSLContainers = (Get-ChildItem -Filter '*.vhdx' -Path '<PATH TO FSLogix Folders with VHDX>' -recurse | ? { -not (Get-ChildItem $_.Directory -Recurse -File -Filter '*.lock')}).FullName | Sort
$UnlockedFSLContainersCount = ($AllUnlockedFSLContainers).Count
Add-Content -Path $Log -Value "[$([DateTime]::Now)] Total Unlocked Containers = $UnlockedFSLContainersCount"
        
        #Get the info per Container / VHDX
        ForEach ($1Container in $AllUnlockedFSLContainers){
        $1Container
        Add-Content -Path $Log -Value "[$([DateTime]::Now)] $1Container"
        $MountError = $()
        $MDiskImg =  Mount-DiskImage -ImagePath $1Container -NoDriveLetter -PassThru -ErrorAction SilentlyContinue -ErrorVariable +MountError
        If ($MountError[0] -ne ""){
            Add-Content -Path $Log -Value "[$([DateTime]::Now)] $MountError[0]"
            }
        $UserName = (Get-Item $1Container).BaseName
        $ContainerSize = [math]::round($((Get-Item $1Container).Length) /1Gb, 2)
        $O365DiskInfo = Get-Volume | Select-Object * | Where-Object {$_.FileSystemLabel -like "O365-*" -and $_.FileSystemLabel -notlike "O365-grotendr*"}
        $DiskStatus = $($O365DiskInfo.HealthStatus)
        $DiskSize = [math]::round($($O365DiskInfo.Size)/1Gb, 2)
        $DiskRemain = [math]::round($($O365DiskInfo.SizeRemaining)/1Gb, 2)
        $DiskUsed = [math]::round($($DiskSize - $DiskRemain)/1 ,2)
        $DiskWhite = [math]::round($($ContainerSize - $DiskUsed)/1, 2)
        $WhiteSpaceRatio = [math]::round($($DiskWhite / $DiskRemain * 100)/1, 2)
        #Get VHDX Info
        $FSLPath= $O365DiskInfo.Path
        $FSLFolders=Get-ChildItem -LiteralPath $FSLPath -ErrorAction SilentlyContinue
        #ODFC
        $ODFCPath=$FSLFolders[0].FullName
        $OSTFiles=Get-ChildItem -LiteralPath $ODFCPath -Filter '*.ost' -Recurse -ErrorAction SilentlyContinue -ErrorVariable +OSTError
        $ODFC=[math]::Round($((Get-ChildItem -LiteralPath $ODFCPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #ODFCPersonal
        $ODFCPersonalPath=$FSLFolders[1].FullName
        $ODFCPersonal=[math]::Round($((Get-ChildItem -LiteralPath $ODFCPersonalPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #OfficeFileCache
        $OfficeFileCachePath=$FSLFolders[2].FullName
        $OfficeFileCache=[math]::Round($((Get-ChildItem -LiteralPath $OfficeFileCachePath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #Onedrive
        $OneDrivePath=$FSLFolders[3].FullName
        $OneDrive=[math]::Round($((Get-ChildItem -LiteralPath $OneDrivePath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #OneNote
        $OneNotePath=$FSLFolders[4].FullName
        $OneNote=[math]::Round($((Get-ChildItem -LiteralPath $OneNotePath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #OneNoteUWP
        $OneNoteUWPPath=$FSLFolders[5].FullName
        $OneNoteUWP=[math]::Round($((Get-ChildItem -LiteralPath $OneNoteUWPPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #Search
        $SearchPath=$FSLFolders[6].FullName
        $Search=[math]::Round($((Get-ChildItem -LiteralPath $SearchPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #Sharepoint
        $SharepointPath=$FSLFolders[7].FullName
        $Sharepoint=[math]::Round($((Get-ChildItem -LiteralPath $SharepointPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #Skype4B
        $Skype4BPath=$FSLFolders[8].FullName
        $Skype4B=[math]::Round($((Get-ChildItem -LiteralPath $Skype4BPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #Skype4B_15
        $Skype4B_15Path=$FSLFolders[8].FullName
        $Skype4B_15=[math]::Round($((Get-ChildItem -LiteralPath $Skype4B_15Path -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #Teams
        $TeamsPath=$FSLFolders[10].FullName
        $Teams=[math]::Round($((Get-ChildItem -LiteralPath $TeamsPath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)/1,2)
        #Cleanup and dismount VHDX
        $DiskMountStatus = "$MountError[0]"
        $UDiskImg = Dismount-DiskImage -ImagePath $1Container
        
        
        Add-Content -Path $Log -Value "[$([DateTime]::Now)] Done"

            #Fill The Array with Data          
            $item = New-Object PSObject
            $item | Add-Member -MemberType NoteProperty -Name 'UserName' -Value $UserName
            $item | Add-Member -MemberType NoteProperty -Name 'DiskState' -Value $DiskStatus
            $item | Add-Member -MemberType NoteProperty -Name 'DiskSize in Gb' -Value $DiskSize
            $item | Add-Member -MemberType NoteProperty -Name 'DiskRemain in Gb' -Value $DiskRemain
            $item | Add-Member -MemberType NoteProperty -Name 'ContainerSize in Gb' -Value $ContainerSize
            $item | Add-Member -MemberType NoteProperty -Name 'DiskWhiteSpace in Gb' -Value $DiskWhite
            $item | Add-Member -MemberType NoteProperty -Name 'WhiteSpaceRatio in %' -Value $WhiteSpaceRatio
            $item | Add-Member -MemberType NoteProperty -Name 'ODFC in MB' -Value $ODFC
            $item | Add-Member -MemberType NoteProperty -Name 'OSTs' -Value $OSTFiles.Count
            $item | Add-Member -MemberType NoteProperty -Name 'ODFC_P in MB' -Value $ODFCPersonal
            $item | Add-Member -MemberType NoteProperty -Name 'OfficeFileCache in MB' -Value $OfficeFileCache
            $item | Add-Member -MemberType NoteProperty -Name 'Onedrive in MB' -Value $OneDrive
            $item | Add-Member -MemberType NoteProperty -Name 'OneNote in MB' -Value $OneNote
            $item | Add-Member -MemberType NoteProperty -Name 'OneNote UWP in MB' -Value $OneNoteUWP
            $item | Add-Member -MemberType NoteProperty -Name 'Search in MB' -Value $Search
            $item | Add-Member -MemberType NoteProperty -Name 'Sharepoint in MB' -Value $Sharepoint
            $item | Add-Member -MemberType NoteProperty -Name 'Skype4B in MB' -Value $Skype4B
            $item | Add-Member -MemberType NoteProperty -Name 'Skype4B_15 UWP in MB' -Value $Skype4B_15
            $item | Add-Member -MemberType NoteProperty -Name 'Teams in MB' -Value $Teams
            $item | Add-Member -MemberType NoteProperty -Name 'MountError Message' -Value $DiskMountStatus

            $AllData += $item
                       
     }
    
 $AllData | Out-GridView 
