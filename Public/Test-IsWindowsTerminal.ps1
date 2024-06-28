#*------v Test-IsWindowsTerminal v------
function Test-IsWindowsTerminal {
    <#
    .SYNOPSIS
    Test-IsWindowsTerminal - Tests if the current session is running inside Windows Terminal.
    .NOTES
    Version     : 1.0.0.0
    Author: Mike F. Robbins
    Website:	https://mikefrobbins.com/
    Twitter:	@mikefrobbins / https://twitter.com/mikefrobbins
    CreatedDate : 2023-02-22
    FileName    : Test-IsWindowsTerminal.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    AddedCredit : Todd Kadrie
    AddedWebsite: http://toddomation.com
    AddedTwitter: tostka / http://twitter.com/tostka
    Github      : https://github.com/tostka/verb-desktop
    Tags        : Powershell,WindowsTerminal,Session,Environment,Terminal,Host
    REVISIONS
    * 8:27 AM 6/27/2024 added CBH, flattened spaces & syntax
    5/16/24 MF's posted article. 
    .DESCRIPTION
    Test-IsWindowsTerminal - Tests if the current session is running inside Windows Terminal.
    .INPUTS
    Does not accept piped input.
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    PS> if(Test-IsWindowsTerminal){
    PS>     write-host "$($env:computername) is Activated/Licensed" ; 
    PS> } else { 
    PS>     write-warning "$($env:computername) is NOT Activated/Licensed!" ; 
    PS> } ; 
    Test WinTerm session
    .LINK
    https://gist.github.com/mikefrobbins/2f3085a18f78330e37a5188444e79bc8
    https://mikefrobbins.com/2024/05/16/detecting-windows-terminal-with-powershell/
    https://github.com/tostka/verb-desktop
    #>
    [CmdletBinding()]
    #[Alias('')]
    PARAM ()
    <# variant approaches
#-=-=-=-=-=-=-=-=
# https://github.com/marvhen
# Checking the parent process doesn't work if WT is the Default Terminal Application, and you launch a console app from a graphical UI app.
function IsWindowsTerminal ($childProcess) {
    if (!$childProcess) {
        return $false
    } elseif ($childProcess.ProcessName -eq 'WindowsTerminal') {
        return $true
    } else {
        return IsWindowsTerminal -childProcess $childProcess.Parent
    }
}
return IsWindowsTerminal -childProcess (Get-Process -Id $PID)
#-=-=-=-=-=-=-=-=
#-=-=-=-=-=-=-=-=
# https://github.com/oising
function Test-WindowsTerminal { test-path env:WT_SESSION }
# or
if ($env:WT_SESSION) {
    # yes, windows terminal
} else {
    # nope
} ; 
#-=-=-=-=-=-=-=-=
#-=-=-=-=-=-=-=-=
# [TitoAldarondo](https://github.com/TitoAldarondo)
#So I too initially headed down the route of checking $Env:WT_SESSION, but quickly realized that this wouldn't work when SSHing to other hosts.
#-=-=-=-=-=-=-=-=
    #>
    if ($PSVersionTable.PSVersion.Major -le 5 -or $IsWindows -eq $true) {
        $currentPid = $PID
        # Loop through parent processes to check if Windows Terminal is in the hierarchy
        while ($currentPid) {
            try {$process = Get-CimInstance Win32_Process -Filter "ProcessId = $currentPid" -ErrorAction Stop -Verbose:$false}
            catch {return $false} ; 
            Write-Verbose -Message "ProcessName: $($process.Name), Id: $($process.ProcessId), ParentId: $($process.ParentProcessId)"
            if ($process.Name -eq 'WindowsTerminal.exe') {return $true} # if WinTerm
            else {$currentPid = $process.ParentProcessId}  ; # Move to the parent process
        }  ; # loop-E
        return $false  ;  # Return false if Windows Terminal is not found in the hierarchy
    } else {
        Write-Verbose -Message 'Exiting due to non-Windows environment' ; 
        return $false ; 
    } ; 
} ; 
#*------^ Test-IsWindowsTerminal ^------