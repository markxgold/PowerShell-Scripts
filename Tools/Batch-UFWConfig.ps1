<#
.SYNOPSIS
  Create ufw config batch.

.DESCRIPTION
  The script will convert a batch list of IPs to be pasted into UFW config.
  I often use this for geoIP allow lists.

.PARAMETER path
  Path to text file. Each IP or subnet needs to be a new line.

.PARAMETER port
  Port allowed. If left blank allows all ports for IPs in file.

.PARAMETER protocol
  TCP, UDP, or both
#>

[cmdletbinding()]
param (
    [Parameter(Mandatory=$True)]
    [string]$path,
    [int]$port,
    [string]$protocol
)
$ConvertText=[System.IO.StreamWriter]"$($path.TrimEND('.txt'))-converted.txt"
$TextFile=Get-Content $path
$TotalLines=$($TextFile | Measure-Object -Line).Lines
$LinesDone=0

New-Item -Path $ConvertText -Force | Out-Null

if ($port){
    if (!$protocol){
        Write-Error "Protocol is a required parameter if port is used"
    }else{
        if ($protocol -eq "tcp"){
            foreach($line in $TextFile){
                $percent = [math]::Round($LinesDone/$TotalLines*100)
                Write-Progress -Activity Converting -Status "$percent% completed" -PercentComplete $percent
                $ConvertText.WriteLine("### tuple ### allow tcp $Port 0.0.0.0/0 any $line in`n"+`
                "-A ufw-user-input -p tcp --dport $Port -s $line -j ACCEPT`n")
                $LinesDone++
            }
        }elseif ($protocol -eq "udp"){
            foreach($line in $TextFile){
                $percent = [math]::Round($LinesDone/$TotalLines*100)
                Write-Progress -Activity Converting -Status "$percent% completed" -PercentComplete $percent
                $ConvertText.WriteLine("### tuple ### allow udp $Port 0.0.0.0/0 any $line in`n"+`
                "-A ufw-user-input -p udp --dport $Port -s $line -j ACCEPT`n")
                $LinesDone++
            }
        }elseif ($protocol -eq "both"){
            foreach($line in $TextFile){
                $percent = [math]::Round($LinesDone/$TotalLines*100)
                Write-Progress -Activity Converting -Status "$percent% completed" -PercentComplete $percent
                $ConvertText.WriteLine("### tuple ### allow any any 0.0.0.0/0 $Port $line in`n"+`
                "-A ufw-user-input -p tcp -s $line --dport $Port -j ACCEPT`n"+`
                "-A ufw-user-input -p udp -s $line --dport $Port -j ACCEPT`n")
                $LinesDone++
            }
        }else{
            Write-Error "Only tcp, udp, or both are acepted protocols"
        }
    }
}
else{
    foreach($line in $TextFile){
        $percent = [math]::Round($LinesDone/$TotalLines*100)
        Write-Progress -Activity Converting -Status "$percent% completed" -PercentComplete $percent
        $ConvertText.WriteLine("### tuple ### allow any any 0.0.0.0/0 any $line in`n-A ufw-user-input -s $line -j ACCEPT`n")
        $LinesDone++
    }
}
if ($LinesDone -ne 0){
    $ConvertText.close()
}
