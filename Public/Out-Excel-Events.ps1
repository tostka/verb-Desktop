#*------v Function Out-Excel-Events v------
# http://blogs.technet.com/b/heyscriptingguy/archive/2014/01/10/powershell-and-excel-fast-safe-and-reliable.aspx
# Simple func() to deliver Excel as a out-gridview alternative, this variant massages array ReplacementStrings with a comma-delimited string.
# vers: 1/10/2014
function Out-Excel-Events {
    PARAM($Path = "$env:temp\$(Get-Date -Format yyyyMMddHHmmss).csv")
    $input | Select -Property * |
    ForEach-Object {
        $_.ReplacementStrings = $_.ReplacementStrings -join ','
        $_.Data = $_.Data -join ','
        $_
    } | Export-CSV -Path $Path -UseCulture -Encoding UTF8 -NoTypeInformation
    Invoke-Item -Path $Path
}#*------^ END Function Out-Excel-Events ^------