#*------v Function Out-Excel v------
# http://blogs.technet.com/b/heyscriptingguy/archive/2014/01/10/powershell-and-excel-fast-safe-and-reliable.aspx
# Simple func() to deliver Excel as a out-gridview alternative.
# vers: 1/10/2014
function Out-Excel {
    PARAM($Path = "$env:temp\$(Get-Date -Format yyyyMMddHHmmss).csv")
    $input | Export-CSV -Path $Path -UseCulture -Encoding UTF8 -NoTypeInformation
    Invoke-Item -Path $Path
}#*------^ END Function Out-Excel ^------