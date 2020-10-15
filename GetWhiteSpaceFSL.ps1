########################################################################################################
#
#                                  GetWhiteSpaceFSL.ps1
#
# By RoGr: 14-10-2020
#
# Use Script to get the FSLogix Containers (VHDX) white Space
# Script will mount / unmount every unlocked Container from <SHARE> and get Info
#
########################################################################################################

#Array with Data
$AllData = @()

#Logging
$FileDate=(get-Date).ToString("s").Replace(":","-")
$LogPath = "<SHARE\FOLDER>"
$LogName = "GetFSLWhiteSpace" + "_" + $FileDate + ".log"
$Log = $LogPath + "\" + $LogName

#Check and Create Path for Logging
If (-not( Test-Path "$LogPath")) { New-Item -Path "$LogPath" -ItemType Directory}
#Create File and start Logging
If (-not( Test-Path "$Log")) {New-Item -Path $LogPath -Name $LogName -ItemType File}
Add-Content -Path $Log -Value "[$([DateTime]::Now)] *** Start Logging VHDX Containers ***"

#Get All Unlocked VHDX Files from <SHARE>
$AllUnlockedFSLContainers = (Get-ChildItem -Filter '*.vhdx' -Path '<SHARE>' -recurse | ? { -not (Get-ChildItem $_.Directory -Recurse -File -Filter '*.lock')}).FullName | Sort
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
        $O365DiskInfo = Get-Volume | Select-Object * | Where-Object {$_.FileSystemLabel -like "O365-*" -and $_.FileSystemLabel -notlike "O365-grotendorst*"}
        $DiskStatus = $($O365DiskInfo.HealthStatus)
        $DiskSize = [math]::round($($O365DiskInfo.Size)/1Gb, 2)
        $DiskRemain = [math]::round($($O365DiskInfo.SizeRemaining)/1Gb, 2)
        $DiskUsed = [math]::round($($DiskSize - $DiskRemain)/1 ,2)
        $DiskWhite = [math]::round($($ContainerSize - $DiskUsed)/1, 2)
        $WhiteSpaceRatio = [math]::round($($DiskWhite / $DiskRemain * 100)/1, 2)
        $UDiskImg = Dismount-DiskImage -ImagePath $1Container
        $DiskMountStatus = "$MountError[0]"
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
            $item | Add-Member -MemberType NoteProperty -Name 'MountError Message' -Value $DiskMountStatus

            $AllData += $item
                       
     }
    
 $AllData | Out-GridView 

