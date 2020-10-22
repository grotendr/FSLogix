#Vars
$List=@()                        #- Array with data
$FSLShare = '<\\SERVER\SHARE>'   #- Share with FSLogix Containers
$FFilter = '*.vhdx'              #- Container type
$Size = 10                       #- Find Containers greater than in GigaByte

$Files = Get-ChildItem -Path $FSLShare -Filter $FFilter -Recurse | Select-Object Name, Length, LastWriteTime

    ForEach ($File in $Files){
        If ([math]::Round($($File.Length)/1GB, 2) -gt $Size){
        
        $item = New-Object PSObject
        $item | Add-Member -MemberType NoteProperty -Name 'UserName' -Value $File.Name
        $item | Add-Member -MemberType NoteProperty -Name 'VHDX Size GB' -Value ([math]::Round($($File.Length)/1GB, 2))
        $item | Add-Member -MemberType NoteProperty -Name 'Last Access Date' -Value $File.LastWriteTime
         
        $List+=$item
        }
        }
$List | Out-GridView -Title "FSLogix DOWR: $(Get-Date) ---> Number of VHDX's greater then $Size Gb: $($List.Count) items" 
