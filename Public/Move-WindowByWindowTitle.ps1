#*------v Function Move-WindowByWindowTitle v------
function Move-WindowByWindowTitle {
    PARAM (
        [string]$ProcessName,
        [string]$WindowTitleRegex,
        [int]$X, [int]$Y, [int]$Width, [int]$Height)
    process {
        $procs = Get-Process -Name $ProcessName | Where-Object { $_.MainWindowTitle -match $WindowTitleRegex } ;
        foreach ($proc in $procs) {Move-Window -Handle $proc.MainWindowHandle -X $X -Y $Y -Width $Width -Height $Height}  ; 
    } 
} #*------^ END Function Move-WindowByWindowTitle ^------