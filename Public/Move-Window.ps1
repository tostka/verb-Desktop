#*------v Function Move-Window v------
function Move-Window {
    PARAM ($Handle, [int]$X, [int]$Y, [int]$Width, [int]$Height);
    process {[void][MoveWindowUtil.MoveWindowUtil]::MoveWindow($Handle, $X, $Y, $Width, $Height, $true);} 
} #*------^ END Function Move-Window ^------