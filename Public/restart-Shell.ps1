#*------v Function restart-Shell v------
function restart-Shell {
    <#
    .SYNOPSIS
    restart-Shell - Close and restart windows'shell'/desktop explorer process
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-05-01
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Registry,Maintenance
    REVISIONS
    * 12:55 PM 5/1/2020 init vers
    .DESCRIPTION
    restart-Shell - Close and restart windows'shell'/desktop explorer process
    Identifies 'Taskbar'/Shell explorer process, as the one with no MainWindowTitle. Using Ctrl+Shift+r-click Taskbar > Exit Windows is cleaner - propertly saves shell config changes. But this is a scriptable alt.
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .OUTPUT
    System.Object[]
    .EXAMPLE
    restart-Shell -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0
    Update the desktop AutoColorization property to the value 0 
    .EXAMPLE
    restart-Shell 
    Close and restart explorer shell
    .EXAMPLE
    restart-Shell -verbose -whatif
    Close and restart explorer shell with whatif and verbose output
    .LINK
    https://github.com/tostka
    #>
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    $error.clear() ;
    TRY {
        Get-Process explorer | ? MainWindowTitle -eq '' | stop-process -Force -whatif:$($whatif); 
        sleep -sec 2 ; 
        if(!(Get-Process explorer | ? MainWindowTitle -eq '' )){
            # Only spawn a new explorer if a new 'shell' one didn't auto-load w/in 2secs (generally does on win10 ; avoids opening a spurious new explorer window)
            start explorer.exe ; 
        } ; 
        $true | write-output ; 
    } CATCH {
        $ErrTrpd = $_ ; 
        Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrTrpd.Exception.ItemName). `nError Message: $($ErrTrpd.Exception.Message)`nError Details: $($ErrTrpd)" ;
        $false | write-output ; 
    } ; 
} ;#*------^ END Function restart-Shell ^------ ;
