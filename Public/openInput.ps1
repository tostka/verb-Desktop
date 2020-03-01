#*------v Function openInput v------
function openInput { $sExc = $TextEd + " " + (join-path $binpath input.txt); Invoke-Expression $sExc; }
#*------^ END Function openInput ^------