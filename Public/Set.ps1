#*------v Function Set v------
# If an alias exists, remove it.
If (Test-Path ALIAS:set) { Remove-Item ALIAS:set } ;
Function Set {
    <#
    .SYNOPSIS
    Set() - Emulate the DOS Set e-vari-handling cmd in PS
    .NOTES
    Author: Bill Stewart
    Website:	http://windowsitpro.com/powershell/powershell-how-emulating-cmdexes-set-command
    REVISIONS   :
    * 6:53 AM 8/9/2016 minor comment typo fix
    * 8:42 AM 4/10/2015 reformatted, added help
    * Dec 12, 2011 posted
    .DESCRIPTION
    Note:  You can't use the Set function as part of a PowerShell expression, such as
    (Set processor_level).GetType()
    But it has two advantages over Cmd.exe's Set command. First, it outputs DictionaryEntry objects, just like when you use the command...
    Get-ChildItem ENV:
    Second, the Set function uses wildcard matching. For example, the command...
    Set P
    ...matches only a variable named P. Use Set P* to output all evari's beginning with P.
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    No formatting appears to have been put int, results are output to the pipeline.
    .EXAMPLE
    Set
    To list all of the current $env: (equiv to gci $env:)
    .LINK
    http://windowsitpro.com/powershell/powershell-how-emulating-cmdexes-set-command
    #>
    If (-Not $ARGS) {
        Get-ChildItem ENV: | Sort-Object Name ;
        Return ;
    } ;
    $myLine = $MYINVOCATION.Line ;
    $myName = $MYINVOCATION.InvocationName ;
    $myArgs = $myLine.Substring($myLine.IndexOf($myName) + $myName.Length + 1) ;
    $equalPos = $myArgs.IndexOf("=") ;
    # If the "=" character isn't found, output the variables.
    If ($equalPos -eq -1) {
        $result = Get-ChildItem ENV: | Where-Object { $_.Name -like "$myArgs" } |
        Sort-Object Name ;
        If ($result) { $result } Else { Throw "Environment variable not found" } ;
    }
    ElseIf ($equalPos -lt $myArgs.Length - 1) {
        # If the "=" character is found before the end of the string, set the variable.
        $varName = $myArgs.Substring(0, $equalPos) ;
        $varData = $myArgs.Substring($equalPos + 1) ;
        Set-Item ENV:$varName $varData ;
    }
    Else {
        # If the "=" character is found at the end of the string, remove the variable.
        $varName = $myArgs.Substring(0, $equalPos) ;
        If (Test-Path ENV:$varName) { Remove-Item ENV:$varName } ;
    } # if-E
} #*------^ END Function Set ^------