#Data Array
$AllData=@()

#UserInfo
$User='<USERNAME>'
$UserSID=((Get-ADUser -Identity $User -ErrorAction Stop).SID).Value 

#FSLogix VHDX Server / Storage
$FSLServer='<FSLogix Share with VHDX Folders/Files>'
#VHDX Folder
$UserFSLPath= $FSLServer + '\' + $User + '_' + $UserSID

#Full path and name to the users VHDX
$VHDXFile=(Get-ChildItem -Path $UserFSLPath -Filter '*.vhdx').FullName

#Check for container lock
$VHDXLock=(Get-ChildItem -Path $UserFSLPath -Filter '*.lock' -ErrorAction SilentlyContinue).FullName
    If ($VHDXLock -eq $null){
        Write-Host 'No Lock on VHDX:' $VHDXFile -ForegroundColor Green
        $MountError = $()
        #Mount the VHDX
        Mount-DiskImage $VHDXFile -PassThru -NoDriveLetter -ErrorAction SilentlyContinue -ErrorVariable +MountError | out-null
        #Get VHDX Info
        $O365DiskInfo = Get-Volume | Select-Object * | Where-Object {$_.FileSystemLabel -like "O365-*" -and $_.FileSystemLabel -notlike "O365-grotendorst"} 
        $OSTPath= $O365DiskInfo.Path + 'ODFC\'
        Set-Location $OSTPath
        $OSTFiles=Get-ChildItem -Filter '*.ost' -Recurse -ErrorAction SilentlyContinue -ErrorVariable +OSTError
        $OSTSize=$null
        $OSTTotalSize=$null
        $DiskMountStatus = "$MountError[0]"
        ForEach ($OST in $OSTFiles){
            $OSTSize+=$OST.Length
            $OSTSize
            }
            
            $OSTTotalSize=[math]::round($($OSTSize)/1Gb, 2)
            #Fill The DataArray        
            $item = New-Object PSObject
            $item | Add-Member -MemberType NoteProperty -Name 'UserName' -Value $User
            $item | Add-Member -MemberType NoteProperty -Name 'DiskState' -Value $O365DiskInfo.HealthStatus
            $item | Add-Member -MemberType NoteProperty -Name 'Number of OSTs' -Value $OSTFiles.Count
            $item | Add-Member -MemberType NoteProperty -Name 'Total Size of OSTs in GB' -Value $OSTTotalSize
            $item | Add-Member -MemberType NoteProperty -Name 'VHDX MountError Message' -Value $DiskMountStatus

            $AllData += $item
            $UDiskImg = Dismount-DiskImage -ImagePath $VHDXFile
        }
    Else{
        Write-Host 'VHDX is Locked:' $VHDXFile -ForegroundColor Red}

$AllData | Out-GridView 
