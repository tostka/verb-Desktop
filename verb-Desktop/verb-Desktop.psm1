# verb-desktop.psm1


  <#
  .SYNOPSIS
  verb-Desktop - Powershell Desktop generic functions module
  .NOTES
  Version     : 4.0.0.0
  Author      : Todd Kadrie
  Website     :	https://www.toddomation.com
  Twitter     :	@tostka
  CreatedDate : 3/1/2020
  FileName    : verb-Desktop.psm1
  License     : MIT
  Copyright   : (c) 3/1/2020 Todd Kadrie
  Github      : https://github.com/tostka
  AddedCredit : REFERENCE
  AddedWebsite:	REFERENCEURL
  AddedTwitter:	@HANDLE / http://twitter.com/HANDLE
  REVISIONS
  * 3/1/2020 - 1.0.0.0
  .DESCRIPTION
  verb-Desktop - Powershell Desktop generic functions module
  .PARAMETER  PARAMNAME
  PARAMDESC
  .PARAMETER  Mbx
  Mailbox identifier [samaccountname,name,emailaddr,alias]
  .PARAMETER  Computer
  Computer Name [-ComputerName server]
  .PARAMETER  ServerFqdn
  Server Fqdn (24-25char) [-serverFqdn lynms650.global.ad.toro.com)] 
  .PARAMETER  Server
  Server NBname (8-9chars) [-server lynms650)]
  .PARAMETER  SiteName
  Specify Site to analyze [-SiteName (USEA|GBMK|AUSYD]
  .PARAMETER  Ticket
  Ticket # [-Ticket nnnnn]
  .PARAMETER  Path
  Path [-path c:\path-to\]
  .PARAMETER  File
  File [-file c:\path-to\file.ext]
  .PARAMETER  String
  2-30 char string [-string 'word']
  .PARAMETER  Credential
  Credential (PSCredential obj) [-credential ]
  .PARAMETER  Logonly
  Run a Test no-change pass, and log results [-Logonly]
  .PARAMETER  FORCEALLPINS
  Reset All PINs (boolean) [-FORCEALLPINS:True]
  .PARAMETER Whatif
  Parameter to run a Test no-change pass, and log results [-Whatif switch]
  .PARAMETER ShowProgress
  Parameter to display progress meter [-ShowProgress switch]
  .PARAMETER ShowDebug
  Parameter to display Debugging messages [-ShowDebug switch]
  .INPUTS
  None
  .OUTPUTS
  None
  .EXAMPLE
  .EXAMPLE
  .LINK
  https://github.com/tostka/verb-Desktop
  #>


    $script:ModuleRoot = $PSScriptRoot ;
    $script:ModuleVersion = (Import-PowerShellDataFile -Path (get-childitem $script:moduleroot\*.psd1).fullname).moduleversion ;
    $runningInVsCode = $env:TERM_PROGRAM -eq 'vscode' ;

#*======v FUNCTIONS v======




#*------v .....ps1 v------
function .... { ...; .. }

#*------^ .....ps1 ^------


#*------v ....ps1 v------
function ... { ..; .. }

#*------^ ....ps1 ^------


#*------v ...ps1 v------
function .. { Set-Location .. }

#*------^ ...ps1 ^------


#*------v ~.ps1 v------
function ~ { Push-Location (Get-PSProvider FileSystem).Home }

#*------^ ~.ps1 ^------


#*------v Clean-Desktop.ps1 v------
function Clean-Desktop {
        <#
        .SYNOPSIS
        Clean-Desktop - Purges all .lnk files from user profile desktop
        .NOTES
        Author: Todd Kadrie
        Website:	http://www.toddomation.com
        Twitter:	@tostka, http://twitter.com/tostka
        REVISIONS   :
        * 12:56 PM 9/18/2019 added a catch echo to try clean-desktop as SID, and label the attempt
        * 8:18 AM 8/1/2019 added OD4B redir & a bunch of logic to leave my normal .lnks in place, also added -whatif & -showdebug, for testing, and extra echos.
        * 10:46 PM 5/31/2019 init vers
        .DESCRIPTION
        Clean-Desktop.ps1 - Purges all .lnk files from user profile desktop
        .INPUTS
        None. Does not accepted piped input.
        .OUTPUTS
        Dumps info to console, and copies to clipboard
        .EXAMPLE
        Clean-Desktop ;
        .LINK
        http://www.toddomation.com
        #>
        Param(
            [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")][switch] $whatIf,
            [Parameter(HelpMessage = "showDebug Flag  [-showDebug]")][switch] $showDebug
        ) ;
        $error.clear() ;
        TRY {
            $pDesktop = [Environment]::GetFolderPath('Desktop') ;
            $parkingDir = "$($env:USERPROFILE)\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\DesktopBU" ;
            if (-not(test-path $parkingDir)) {
                write-verbose -verbose:$true  "(creating missing:$($parkingDir))" ;
                mkdir $parkingDir ;
            } ;

            $lnkFiles = @() ; $movelinks = @() ;
            $lnkFiles = gci $env:USERPROFILE\Desktop\*lnk | select -exp fullname ;
            $lnkFiles += gci C:\Users\Public\Desktop\*lnk | select -exp fullname ;
            if ($pDesktop  ) {
                if ($showDebug) { write-host -foregroundcolor green "(detected OD4B)" };
                $lnkFiles += gci "$($pDesktop)\*lnk" | select -exp fullname ;
            } ;
            $lnkFiles = $lnkFiles | ? { $_ -notmatch '(\d{6}|ecco32\.exe|Kindle|Start\sMenu|BIG-IP|Chrome|Firefox|Microsoft\sEdge|PowerShell|cmd\.exe|Outlook|TeaTimer)' } ;
            foreach ($lnkFile in $lnkFiles) {
                if ($showDebug) { write-host "processing `$lnkfile:$($lnkfile)" } ;
                if ((gi (Get-Shortcut -path $lnkFile ).targetpath -ea 0).PSIsContainer) {
                }
                elseif ((get-shortcut $lnkFile).targetpath -match '.*(\.(txt|cmd)$)|(rundll32|Notepad2)\.exe$') {
                }
                elseif (!(get-shortcut $lnkFile).targetpath) {
                    # MS edge HAS NO TARGETPATH! - had to reexempt it on lnk name, this was still thowing 2 empty path errors
                }
                else {
                    if ($showDebug) { write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):adding $($lnkFile)" } ;
                    $movelinks += $lnkFile ;
                }
            } ;
            if ($movelinks) {
                write-verbose -verbose:$true  "(Clean-Desktop:moving $(($movelinks|measure).count) files from profile desktop to:$($parkingDir)...`n$(($move|out-string).trim()))" ;
                #move-Item -path $lnkFiles -Destination $parkingDir -Force -whatif:$($whatif);
                move-Item -path $movelinks -Destination $parkingDir -Force -whatif:$($whatif);
            } ;
        }
        CATCH {
            Write-Error "$(get-date -format 'HH:mm:ss'): Clean-Desktop:Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
            write-host -foregroundcolor yellow "(if perms, try SID: Clean-Desktop)";
            Exit ;
        } ;

    }

#*------^ Clean-Desktop.ps1 ^------


#*------v confirm-GoogleDriveRunning.ps1 v------
Function confirm-GoogleDriveRunning {

    <# 
    .SYNOPSIS
    confirm-GoogleDriveRunning - Confirm/Run Google Drive - Resolve Google Drive letter; test for drive letter present(running): start GD if drive not present (Resolve Google Drive .exe path from default installed Start Mnu .lnk) 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-11-11
    FileName    : confirm-GoogleDriveRunning.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-Desktop
    Tags        : GoogleDrive
    AddedCredit : mklement0
    AddedWebsite:	https://stackoverflow.com/users/45375/mklement0
    AddedTwitter:	
    REVISIONS   :
    # 11:14 AM 11/11/2022 my revisions: added [codewario](https://stackoverflow.com/users/584676/codewario)'s answer to M's question; added .exe resolution via default start mnu Google Drive.lnk expansion. Try catch, whatif, and now outputs boolean to pipeline, for testing 
    * 11:15 AM 9/1/21 mklement0's posted question code
    .DESCRIPTION
    confirm-GoogleDriveRunning - Confirm/Run Google Drive - Resolve Google Drive letter; test for drive letter present(running): start GD if drive not present (Resolve Google Drive .exe path from default installed Start Mnu .lnk) 
    
    Expanded version of mklement0's posted concept snippet from stackoverflow question:
    [powershell - Find the mapped google drive - Stack Overflow - stackoverflow.com/](https://stackoverflow.com/questions/69017164/find-the-mapped-google-drive)
    Added .exe resolution code; spliced in bender's answer to the original question. 
    
    .PARAMETER  Path
    Path to be overlayed over specified background
    .PARAMETER Whatif
    Whatif no-exec test
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    PS> if(confirm-GoogleDriveRunning -verbose -whatif){'y'} else { 'n'} ; 
    Confirm Gdrv running, with verbose and whatif 
    .LINK
    https://github.com/tostka/verb-Desktop
    #>
    [CmdletBinding()]
    #[Alias('')]
    Param(
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ; 
    write-verbose "Attempt to Resolve Google Drive PSDrive (local drive vs mounted)" ; 
    Try {
        If (!($gdrvDrive = Get-PSDrive -PSProvider FileSystem | 
            Where-Object {$_.Description -eq 'Google Drive' })) {
            write-verbose "Resolve Google Drive .exe loc from the stock launch .lnk" ; 
            $gdrvLnk = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Google Drive.lnk" ; 
            write-verbose "expand shortcut TargetPath" ; 
            $WScriptShell = New-Object -ComObject WScript.Shell ; 
            if (Test-Path $gdrvLnk) {
                $GdfsPath  = $WScriptShell.CreateShortcut((Resolve-Path $gdrvLnk)).targetpath ;
                if(!$whatif){
                    write-verbose "Start-Process resolved path:`n$($gdfsPath)`n(30s timeout)" ; 
                        Start-Process $GdfsPath | Wait-Process -Timeout 30 ;
                } else { 
                    write-host "-whatif: skipping run exeution of:`n$($GdfsPath)" ; 
                } ; 
            } else {
                $smsg = "Unable to resolve Google Drive.lnk to an exe path!`n$($gdrvLnk)" ; 
                write-warning $smsg ; throw $smsg ; 
            } ; 
        } else {
            write-verbose "Google drive present ($($gdrvDrive.Root):), returning `$true to pipeline" ; 
            $true | write-output ; 
        } ; 
    } Catch {
            $smsg = "Google Drive can't be mapped. Failed to load Gdrv: $($GdfsPath)"
             write-warning $smsg ; throw $smsg ; 
             $false | write-output ; 
    } 
    Finally {
        If (!(Get-PSDrive -PSProvider FileSystem | 
    Where-Object {$_.Description -eq 'Google Drive' })) {
            $smsg = "Google Drive can't be mapped. Failed to load Gdrv: $($GdfsPath)"
             write-warning $smsg ; throw $smsg ; 
             $false | write-output ; 
        } ;
    } ;
}

#*------^ confirm-GoogleDriveRunning.ps1 ^------


#*------v c-winsallk.ps1 v------
function c-winsallk {. C:\usr\work\ps\scripts\close-WinsAll.ps1 -kill  }

#*------^ c-winsallk.ps1 ^------


#*------v Define-MoveWindow.ps1 v------
function Define-MoveWindow {
    $signature = @'
[DllImport("user32.dll")]
public static extern bool MoveWindow(
IntPtr hWnd,
int X,
int Y,
int nWidth,
int nHeight,
bool bRepaint);
'@
    Add-Type -MemberDefinition $signature -Name MoveWindowUtil -Namespace MoveWindowUtil
}

#*------^ Define-MoveWindow.ps1 ^------


#*------v get-processTitled.ps1 v------
Function get-processTitled {
    <#
    .SYNOPSIS
    get-processTitled.ps1 - Postfilter get-process, to display only processes with a MainWindowTitle
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2024-12-09
    FileName    : get-processTitled
    License     : MIT License
    Copyright   : (c) 2024 Todd Kadrie
    Github      : https://github.com/tostka/verb-desktop
    Tags        : Powershell,Process,Management,Reporting
    REVISIONS
    * 3:44 PM 12/9/2024init vers
    .DESCRIPTION
    get-processTitled.ps1 - Postfilter get-process, to display only processes with a MainWindowTitle
    Handy for tracking down the single *hung* powershell_ise instance, based on it's Titlebar contents (to targeted kill the problem; leaving the others to continue running).
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object process to pipeline
    .EXAMPLE
    PS> get-processTitled ; 

      ProcessName       Id MainWindowTitle
      -----------       -- ---------------
      explorer        5960 D:\scripts\logs
      powershell     12352 PS ADMIN - TORO - EMSt
      powershell_ise 12244 PS ADMIN - TORO -
    
    Default usage & output 
    .LINK
    https://github.com/tostka/verb-desktop
    #>
    [CmdletBinding()]
    #[Alias('','')]
    PARAM() ;
    get-process | ?{$_.mainwindowtitle} | sort processname,mainwindowtitle,id | select-object processname,id,mainwindowtitle | write-output 
}

#*------^ get-processTitled.ps1 ^------


#*------v install-ChocoPkg.ps1 v------
Function Install-ChocoPkg {
    <#
.SYNOPSIS
Install-ChocoPkg - runs $Packages list of choco pkgs through choco upgrade commmand (installs, if not pre-installed), parses choco exit codes and evals status.
.NOTES
Version     : 1.0.0
Author      : Todd Kadrie
Website     :	http://www.toddomation.com
Twitter     :	@tostka / http://twitter.com/tostka
CreatedDate : 2019-03-14
FileName    : Install-ChocoPkg.ps1
License     : MIT License
Copyright   : (c) 2020 Todd Kadrie
Github      : https://github.com/tostka
Tags        : Powershell
AddedCredit : REFERENCE
AddedWebsite:	URL
AddedTwitter:	URL
REVISIONS
* 12:34 PM 2/21/2023 duped into verb-desktop
* 2:09 PM 4/21/2020 added Source param (alt sources)
* 10:33 AM 3/14/2019 swap from 'choco install'/cist -> 'choco upgrade'/cup, also added the choco boxstarter path too long hack
.DESCRIPTION
.PARAMETER  Packages
Array of Chocolatey packages to Install
.PARAMETER  Source
Alternate Source [-source WindowsFeature
.PARAMETER ShowDebug
Parameter to display Debugging messages [-ShowDebug switch]
.PARAMETER Whatif
Parameter to run a Test no-change pass [-Whatif switch]
.EXAMPLE
$bRet = Install-ChocoPkg -Packages $pkgs -showdebug:$($showdebug) -whatif:$($whatif) ;
.LINK
#>
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Array of Chocolatey packages to Install")]
        [ValidateNotNullOrEmpty()][array]$Packages,
        [Parameter(HelpMessage = "Alternate Source [-source WindowsFeature")]
        [ValidateNotNullOrEmpty()][array]$Source,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) # PARAM BLOCK END

    <# underlying Choco docs:
    Exit Codes

    Exit codes that normally result from running this command.

    Normal:
    -0: operation was successful, no issues detected
    --1 or 1: an error has occurred

    Package Exit Codes:
    -1641: success, reboot initiated
    -3010: success, reboot required
    -other (not listed): likely an error has occurred

    In addition to normal exit codes, packages are allowed to exit with their own codes when the feature 'usePackageExitCodes' is turned on. Uninstall command has additional valid exit codes. Available in v0.9.10+.

    Reboot Exit Codes:
    -350: pending reboot detected, no action has occurred
    -1604: install suspended, incomplete

    In addition to the above exit codes, you may also see reboot exit codes when the feature 'exitOnRebootDetected' is turned on. It typically requires the feature 'usePackageExitCodes' to also be turned on to work properly. Available in v0.10.12+.
    -----
    $chocoMsg = (choco install $myApp -y) -join('')

    if($chocoMsg -match "install of $myApp was successful.") {
        Write-Host -fo:green 'Success'
    } else {
        # handle errors
    }
    ----------
    Use exit codes to determine status.
    Chocolatey exits with 0 when everything worked appropriately and other exits codes like 1 when things error.
    There are package specific exit codes that are recommended to be used and reboot indicating exit codes as well.
    To check exit code when using PowerShell, immediately call $exitCode = $LASTEXITCODE to get the value choco exited with.

    Alternative Sources (-source)

    Available in 0.9.10+.
    Ruby
    This specifies the source is Ruby Gems and that we are installing a
    gem. If you do not have ruby installed prior to running this command,
    the command will install that first.
    e.g. choco install compass -source ruby
    WebPI
    This specifies the source is Web PI (Web Platform Installer) and that
    we are installing a WebPI product, such as IISExpress. If you do not
    have the Web PI command line installed, it will install that first and
    then the product requested.
    e.g. choco install IISExpress --source webpi
    Cygwin
    This specifies the source is Cygwin and that we are installing a cygwin
    package, such as bash. If you do not have Cygwin installed, it will
    install that first and then the product requested.
    e.g. choco install bash --source cygwin
    Python
    This specifies the source is Python and that we are installing a python
    package, such as Sphinx. If you do not have easy_install and Python
    installed, it will install those first and then the product requested.
    e.g. choco install sphinx --source python
    Windows Features
    This specifies that the source is a Windows Feature and we should
    install via the Deployment Image Servicing and Management tool (DISM)
    on the local machine.
    e.g. choco install IIS-WebServerRole --source windowsfeatures
    #>


    $ttl = ($Packages | measure).count ;
    $Procd = 0 ;
    $smsg = "Installing $($ttl)  Packages:" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
    foreach ($pkg in $Packages) {
        $Procd++ ;
        $error.clear() ;
        $chocoMsg = $null ;
        $sBnrS = "#*------v ($($Procd)/$($ttl)):choco upgrade -y $($pkg): v------" ;
        $smsg = "$($sBnrS)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
        TRY {
            if (!$whatif) {
                if (!$Source) {
                    $chocoMsg = (choco upgrade --cacheLocation="$ChocoCachePath" -y $pkg) -join ('')
                } else {
                    $chocoMsg = (choco upgrade --cacheLocation="$ChocoCachePath" --source="$Source" -y $pkg) -join ('')
                } ;
                $exitCode = $LASTEXITCODE ;
            } else {
                if (!$Source) {
                    $chocoMsg = (choco upgrade --cacheLocation="$ChocoCachePath" -y $pkg --noop) -join ('')
                } else {
                    $chocoMsg = (choco upgrade --cacheLocation="$ChocoCachePath" --source="$Source" -y $pkg --noop) -join ('')
                } ;
                $exitCode = $LASTEXITCODE ;
            }
        } CATCH {
            $err = $_ ;
            $msg = ": Error Details: $($err)";
            Write-Error "$(get-date -format "HH:mm:ss"): FAILURE!" ;
            Write-Error "$(get-date -format "HH:mm:ss"): Error in $($err.InvocationInfo.ScriptName)." ;
            Write-Error "$(get-date -format "HH:mm:ss"): -- Error information" ;
            Write-Error "$(get-date -format "HH:mm:ss"): Line Number: $($err.InvocationInfo.ScriptLineNumber)" ;
            Write-Error "$(get-date -format "HH:mm:ss"): Offset: $($err.InvocationInfo.OffsetInLine)" ;
            Write-Error "$(get-date -format "HH:mm:ss"): Command: $($err.InvocationInfo.MyCommand)" ;
            Write-Error "$(get-date -format "HH:mm:ss"): Line: $($err.InvocationInfo.Line)" ;
            #Write-Error "$(get-date -format "HH:mm:ss"): Error Details: $($err)" ;
            $msg = ": Error Details: $($err)" ;
            Write-Error  "$(get-date -format "HH:mm:ss"): $($msg)" ;
            # 1:00 PM 1/23/2015 autorecover from fail, STOP (debug), EXIT (close), or use Continue to move on in loop cycle
            Continue ;
        }; # try/catch-E

        switch -Regex ($exitCode) {
            "0" {
                # operation was successful, no issues detected
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Operation Was Successful, No Issues Detected" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
            }
            "((-)*)1" {
                # -1/1: an error has occurred
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):An Error Has Occurred" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } ; #Error|Warn
            } ;
            "1641" {
                # 1641: success, reboot initiated
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Success, Reboot Initiated" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } ; #Error|Warn
            }
            "3010" {
                # 3010: success, reboot required
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Success, Reboot Required" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } ; #Error|Warn
            }
            "350" {
                # 350: pending reboot detected, no action has occurred
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Pending Reboot Detected, No Action Has Occurred" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } ; #Error|Warn

            }
            "1604" {
                # 1604: install suspended, incomplete
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Install Suspended, Incomplete" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } ; #Error|Warn
            }
            default {
                # other (not listed): likely an error has occurred
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Unrecognized code - Likely An Error Has Occurred" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } ; #Error|Warn
            } ;
        } ;

        # 8:01 PM 3/18/2019 dump the output:
        if ($chocoMsg -match "install of $myApp was successful.") {
            Write-Host -fo:green 'Success' ;
        } else {
            # handle errors
        } ;

        if ($chocoMsg -match "A\spending\ssystem\sreboot\srequest\shas\sbeen\sdetected") {
            $smsg = "Pending Reboot detected." ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } ; #Error|Warn|Debug
            $chocoMsg -match "Chocolatey\sv\d{1,}\.\d{1,}\.\d{1,}((\s)*)(.*Upgrading\sthe\sfollowing\spackages\:\w{1,})" ;
            $OutputSummary = $matches[3] ;
        } ;
        if ($chocoMsg -match "\.\w{1,}\s\sis\snot\sinstalled.\sInstalling...") {
            $smsg = "Installing:$($matches[1])" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn|Debug
            $chocoMsg -match "Chocolatey\sv\d{1,}\.\d{1,}\.\d{1,}((\s)*)(.*\s\sis\snot\sinstalled\.\sInstalling\.)" ;
            $OutputSummary = $matches[3] ;
        } ;
        if ($chocoMsg -match "\.\w{1,}\sv.*\sis\sthe\slatest\sversion\savailable\sbased\son\syour\ssource\(s\)\.") {
            $smsg = "Latest version currently installed" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn|Debug
            $chocoMsg -match "Chocolatey\sv\d{1,}\.\d{1,}\.\d{1,}((\s)*)(.*Chocolatey\supgraded\s\d{1,}/\d{1,}\spackages\.)" ;
            $OutputSummary = $matches[3] ;
        } ;
        if ($chocoMsg -match "Installing\.\.\.\w{1,}\snot\sinstalled\.\sThe\spackage\swas\snot\sfound\swith\sthe\ssource\(s\)\slisted\.") {
            $smsg = "Installing: Not installed, the pkg was not found with the source(s) listed" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn|Debug
            $chocoMsg -match "(Chocolatey\supgraded\s\d{1,}/\d{1,}\spackages\.\s\d{1,}\spackages\sfailed\.)" ;
            $OutputSummary = $matches[1] ;
        } elseif ($chocoMsg -match "Installing\.\.\.\w{1,}\snot\sinstalled\.") {
            $smsg = "Installing: Not installed (unknown)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn|Debug
            $chocoMsg -match "Chocolatey\supgraded\s\d{1,}\/\d{1,}\spackages.\s\d{1,}\spackages\sfailed\." ;
            $OutputSummary = $matches[0] ;
        };

        #$chocoMsg -match "^Chocolatey\sv\d{1,3}\.\d{1,3}\.\d{1,3}((\s)*)(.*(Installing...|Upgrading\sthe\sfollowing\spackages).*\sis\sthe\slatest\sversion\savailable\sbased\son\syour\ssource\(s\).Chocolatey\supgraded\s\d{1,3}\/\d{1,3}\spackages)" | out-null
        #"^Chocolatey\sv\d{1,3}\.\d{1,3}\.\d{1,3}((\s)*)(.*(Installing...|Upgrading\sthe\sfollowing\spackages))"
        #"^Chocolatey\sv\d{1,3}\.\d{1,3}\.\d{1,3}\s(.*(Installing...|Upgrading\sthe\sfollowing\spackages))"
        #"^Chocolatey\sv\d{1,3}\.\d{1,3}\.\d{1,3}\s(.*Installing...)"
        # "^(Chocolatey\sv\d{1,3}\.\d{1,3}\.\d{1,3}\s.*Installing...)" | out-null ;
        #$OutputSummary=$matches[3] ;
        #$matches[1] ;

        if (!(test-path "alias:out-clipboard")) { set-alias -Name out-clipboard -Value "$($env:WINDIR)\System32\clip.exe" };
        if (!$OutputSummary) {
            $smsg = "***UNPARSED `$chocoMsg!***`n(copied to cb)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn|Debug
            $chocoMsg | out-clipboard ;
        } ;
        $smsg = "`n$($pkg):#*---v $($pkg) Output v---`n$($OutputSummary)`n#*---^ $($pkg) Output ^---`n" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn

        $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
    } ; # loop-E

}

#*------^ install-ChocoPkg.ps1 ^------


#*------v Install-ExePackage.ps1 v------
function Install-ExePackage {
	<#
    .SYNOPSIS
    Install-ExePackage.ps1 - Install EXE package via start-process
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : Install-ExePackage.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
	AddedCredit : skatterbrainzz
    AddedWebsite: https://skatterbrainz.wordpress.com/2016/12/19/building-an-sccm-1606-site-server-with-boxstarter-windows-server-2016-sql-server-2016/
    AddedTwitter: 
    REVISIONS
    * 3:13 PM 2/21/2023 added CBH, otb syntax. 
    * 12/19/2016 skatterbrainzz posted version
    .DESCRIPTION
    Install-ExePackage.ps1 - Install EXE package via start-process
    skatterbrainzz' function for box building, installation of .exe pkgs.
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
	PS>  $pltInstall = @{
	PS>  	prod    = "Windows Deployment Tools" ; 
	PS>  	appInst = "$adkSource\adksetup.exe" ; 
	PS>  	argList = " /Features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment OptionId.ImagingAndConfigurationDesigner OptionId.UserStateMigrationTool /norestart /quiet /ceip off" ; 
	PS>  } ; 
	PS>  Install-ExePackage @pltInstall ;
	Typical Install.
    .LINK
    https://github.com/tostka/verb-desktop
    https://skatterbrainz.wordpress.com/2016/12/19/building-an-sccm-1606-site-server-with-boxstarter-windows-server-2016-sql-server-2016/
    #>
    [CmdletBinding()]
	PARAM(
		[Parameter(Position=0,HelpMessage="Application Name substring[-ProductName 'Windows Deployment Tools']")]
		[string]$ProductName, 
		[Parameter(Position=1,HelpMessage="Application EXE installable[-Install 'path-to\adksetup.exe']")]
		$Install, 
		[Parameter(Position=2,HelpMessage="Application Name substring[-Options ' /Features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment OptionId.ImagingAndConfigurationDesigner OptionId.UserStateMigrationTool /norestart /quiet /ceip off']")]
		$Options
	) ; 
	if (Test-AppInstalled "$ProductName") {
		write-output "info: $ProductName is already installed." ; 
	}  else {
		write-output "info: installing $ProductName..." ; 
		write-output "info: type...... exe" ; 
		write-output "info: source.... $Install" ; 
		write-output "info: options... $Options" ; 
		try {
			$res = (Start-Process -FilePath "$Install" -ArgumentList "$Options" -Wait -PassThru).ExitCode ; 
			if ($res -ne 0) {
				write-output "error: exit code is $res" ; 
				$Boxstarter.RebootOk = $False ; 
				break ; 
			} else {
				write-output "info: exit code is $res" ; 
			} ; 
		}  catch {
			$ErrorMessage = $_.Exception.Message
			$FailedItem = $_.Exception.ItemName
			$Boxstarter.RebootOk = $False ; 
			write-output "error: installation failed... $ErrorMessage" ; 
			break ; 
		} ; 
		write-output "info: installation successful" ; 
		if (Test-PendingReboot) { Invoke-Reboot } ; 
	} ; 
}

#*------^ Install-ExePackage.ps1 ^------


#*------v Install-MsiPackage.ps1 v------
function Install-MsiPackage {
	<#
    .SYNOPSIS
    Install-MsiPackage.ps1 - Install MSI package via msiexec.exe
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : Install-MsiPackage.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
	AddedCredit : skatterbrainzz
    AddedWebsite: https://skatterbrainz.wordpress.com/2016/12/19/building-an-sccm-1606-site-server-with-boxstarter-windows-server-2016-sql-server-2016/
    AddedTwitter: 
    REVISIONS
    * 3:13 PM 2/21/2023 added CBH, otb syntax. 
    * 12/19/2016 skatterbrainzz posted version
    .DESCRIPTION
    Install-MsiPackage.ps1 - Install MSI package via msiexec.exe
    skatterbrainzz' function for box building, installation of msi pkgs.
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    PS> Install-MsiPackage "Microsoft Deployment Toolkit (6.3.8443.1000)" "$mdtSource\MicrosoftDeploymentToolkit_x64.msi" "";
    Typical install.
    .LINK
    https://github.com/tostka/verb-desktop
    https://skatterbrainz.wordpress.com/2016/12/19/building-an-sccm-1606-site-server-with-boxstarter-windows-server-2016-sql-server-2016/
    #>
    [CmdletBinding()]
	PARAM(
		[Parameter(Position=0,HelpMessage="Application Name substring[-ProductName 'Microsoft Deployment Toolkit (6.3.8443.1000)']")]
		[string]$ProductName, 
		[Parameter(Position=1,HelpMessage="Application MSI installable[-Install 'path-to\MicrosoftDeploymentToolkit_x64.msi']")]
		$Install, 
		[Parameter(Position=2,HelpMessage="Application Name substring[-Options '']")]
		$Options
	) ; 
	if (Test-AppInstalled "$ProductName") {
		write-output "info: $ProductName is already installed" ; 
	} else {
		if (Test-Path "$Install") {
			write-output "info: installing $ProductName..." ; 
			write-output "info: type...... msi" ; 
			write-output "info: package... $Install" ; 
			write-output "info: options... $Options" ; 
			$Arg2 = "/i ""$Install"" /qb! /norestart REBOOT=ReallySuppress" ; 
			if ($Options -ne "") {
				$Arg2 += " ""$Options""" ; 
			} ; 
			TRY {
				$res = (Start-Process -FilePath "msiexec.exe" -ArgumentList $Arg2 -Wait -Passthru).ExitCode ; 
				if ($res -ne 0) {
					write-output "error: exit code is $res" ; 
					$errmsg = [ComponentModel.Win32Exception] $res ; 
					write-output "error: $errmsg" ; 
					$Boxstarter.RebootOk = $False ; 
					break ; 
				}  else {
				  write-output "info: exit code is $res" ; 
				} ; 
			}  CATCH {
				$Boxstarter.RebootOk = $False ; 
				write-output "error: installation failed!" ; 
				break ; 
			} ; 
			write-output "info: installation successful" ; 
			if (Test-PendingReboot) { Invoke-Reboot }
		}  else {
		  write-output "error: unable to locate $Install" ; 
		  break ; 
		} ; 
	} ; 
}

#*------^ Install-MsiPackage.ps1 ^------


#*------v Install-ServerRoles.ps1 v------
function Install-ServerRoles {
	<#
    .SYNOPSIS
    Install-ServerRoles.ps1 - Install WindowsFeatures using saved xml file Add Roles and Features Wizard in Server Manager. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : Install-ServerRoles.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
	AddedCredit : skatterbrainzz
    AddedWebsite: https://skatterbrainz.wordpress.com/2016/12/19/building-an-sccm-1606-site-server-with-boxstarter-windows-server-2016-sql-server-2016/
    AddedTwitter: 
    REVISIONS
    * 3:13 PM 2/21/2023 added CBH, otb syntax. 
    * 12/19/2016 skatterbrainzz posted version
    .DESCRIPTION
    Install-ServerRoles.ps1 - Install WindowsFeatures using saved xml file Add Roles and Features Wizard in Server Manager.
    skatterbrainzz' function for box building, installation of WindowsFeatures.
    
    The XMLFile configuration file can be created by clicking Export configuration settings on the Confirm installation selections page of the Add Roles and Features Wizard in Server Manager.
    .PARAMETER XmlFile
	Path to xml file created by clicking Export configuration settings on the Confirm installation selections page of the Add Roles and Features Wizard in Server Manager[-XmlFile 'pathto\ServerRoles.xml']"
	.PARAMETER RoleNames
	Application Name substring[-RoleNames 'WDS']
	.PARAMETER sharedSource
	Path to common install share[-sharedSource '\\server\share\pathto\']
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    PS> Install-ServerRoles -XmlFile "$scriptsPath\ServerRoles.xml" -SharedSource $SharedSource ;
    Install saved .xml file of Server Manager Add Roles & Features Wiz Export
    .EXAMPLE
    Install-ServerRoles -RoleName "WDS"
    Install WindowsFeature by name
    .LINK
    https://github.com/tostka/verb-desktop
    https://skatterbrainz.wordpress.com/2016/12/19/building-an-sccm-1606-site-server-with-boxstarter-windows-server-2016-sql-server-2016/
    #>
	PARAM(
		[parameter(Mandatory=$False,Position=0,HelpMessage="Path to xml file created by clicking Export configuration settings on the Confirm installation selections page of the Add Roles and Features Wizard in Server Manager[-XmlFile 'pathto\ServerRoles.xml']")] 
		[string]$XmlFile = "", 
		[parameter(Mandatory=$False,Position=1,HelpMessage="Application Name substring[-RoleNames 'WDS']")] 
		[string[]]$RoleNames = "",
		[parameter(Mandatory=$False,HelpMessage="Path to common install share[-sharedSource '\\server\share\pathto\']")] 
		[string]$sharedSource = "\\FS1\Apps\Sources\2016\SXS" 
	) ; 
	if ($xmlFile -ne "") {
		if (Test-Path $xmlFile) {
			write-output "info: installing server roles and features from config file..." ; 
			Install-WindowsFeature -ConfigurationFilePath $xmlFile -Source $sharedSource ; 
			write-output "info: roles and features installation completed." ; 
		}  else {
			write-output "error: unable to locate configuration file: $xmlFile" ; 
			$Boxstarter.RebootOk = $False ; 
			break ; 
		} ; 
	}  else {
		write-output "info: installing server roles and features..." ; 
		try {
			Install-WindowsFeature -Name $RoleNames.Split(",") -IncludeManagementTools -Source $sharedSource -ErrorAction Stop ; 
		}  catch {
			$ErrorMessage = $_.Exception.Message
			$FailedItem = $_.Exception.ItemName
			$Boxstarter.RebootOk = $False ; 
			write-output "error: role names...... $RoleNames" ; 
			write-output "error: config file..... $XmlFile" ; 
			write-output "error: installation failed... $ErrorMessage" ; 
			break ; 
		} ; 
		Start-Sleep -s 10 ; 
	} ; 
}

#*------^ Install-ServerRoles.ps1 ^------


#*------v invoke-Explore.ps1 v------
Function invoke-Explore {
    <# 
    .SYNOPSIS
    invoke-Explore - Spawn explorer on designated path (aliased as 'explore')
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-04
    FileName    : invoke-Explore.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-Desktop
    Tags        : Powershell,explorer,Filesystem
    REVISIONS   :
    # 8:59 AM 8/25/2022 init
    .DESCRIPTION
    invoke-Explore - Spawn explorer on designated path
    .PARAMETER  Path
    Path to be overlayed over specified background    
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    PS> Explore c:\usr\local\bin\
    Invoke explorer.exe on specified path
    .LINK
    https://github.com/tostka/verb-Desktop
    #>
    [CmdletBinding()]
    [Alias('Explore')]
    Param(
        [Parameter(Mandatory=$true,Position = 0,ValueFromPipeline = $true,HelpMessage="Path to be 'explored'[-path 'c:\some\path']")]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    ) ; 
    if((get-variable -name IsWindows) -AND (-not $IsWindows)){
        write-warning "Ps `$isWindows:$($isWindows): This funcion is *only* supported on *Windows*" ; 
        Break ; 
    } ;
    write-verbose "invoking explorer with -path:$($path)" ; 
    $explorer = New-Object -ComObject shell.application ; 
    $explorer.Explore($path) ; 
}

#*------^ invoke-Explore.ps1 ^------


#*------v invoke-SpeakWords.ps1 v------
function invoke-speakwords {
    <#
    .SYNOPSIS
    invoke-speakwords - Text2Speech specified words
    .NOTES
    Author: Karl Prosser
    Website:	http://poshcode.org/835
    REVISIONS   :
    * 11:20 AM 12/9/2022 it's dumping a 1 into the pipeline, eat the output of $voice.speak; added cmdletbinding & moved alias into the body, instead of post-block; rename compliant verb: speak-words -> invoke-speakwords, alias speak-words
    * 2:02 PM 4/9/2015 - added to profile
    .PARAMETER  words
    Words or phrases to be spoken
    .PARAMETER  pause
    switch indicating whether to hold execution during speaking
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    invoke-speakwords "here we go now"  ;
    .EXAMPLE
    invoke-speakwords "$([datetime]::now)" ;
    Speak current date and time
    .EXAMPLE
    get-fortune | invoke-speakwords ;
    Speak output of get-fortune
    .LINK
    http://poshcode.org/835
    #>
    [CmdletBinding()]
    [Alias('speak-words','speak')]
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Specify text to speak")]
        [ValidateNotNullOrEmpty()]
        [string]$words
        ,
        [Parameter(Position = 1, Mandatory = $False, HelpMessage = "Specify to wait for text to finish speaking")]
        [switch]$pause = $true
    ) # PARAM BLOCK END
    # default to no-pause, unless specified
    $flag = 1 ; if ($pause) { $flag = 2 }  ;
    $voice = new-Object -com SAPI.spvoice ;
    $voice.speak($words, [int] $flag) | out-null ; # 2 means wait until speaking is finished to continue

}

#*------^ invoke-SpeakWords.ps1 ^------


#*------v Move-Window.ps1 v------
function Move-Window {
    PARAM ($Handle, [int]$X, [int]$Y, [int]$Width, [int]$Height);
    process {[void][MoveWindowUtil.MoveWindowUtil]::MoveWindow($Handle, $X, $Y, $Width, $Height, $true);} 
}

#*------^ Move-Window.ps1 ^------


#*------v Move-WindowByWindowTitle.ps1 v------
function Move-WindowByWindowTitle {
    PARAM (
        [string]$ProcessName,
        [string]$WindowTitleRegex,
        [int]$X, [int]$Y, [int]$Width, [int]$Height)
    process {
        $procs = Get-Process -Name $ProcessName | Where-Object { $_.MainWindowTitle -match $WindowTitleRegex } ;
        foreach ($proc in $procs) {Move-Window -Handle $proc.MainWindowHandle -X $X -Y $Y -Width $Width -Height $Height}  ; 
    } 
}

#*------^ Move-WindowByWindowTitle.ps1 ^------


#*------v new-WallpaperStatus.ps1 v------
Function New-WallpaperStatus {
    <# 
    .SYNOPSIS
    New-WallpaperStatus - Create desktop wallpaper with specified text overlaid over specified image or background color (PS Bginfo.exe alternative)
    .NOTES
    Version     : 1.0.4
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-06-27
    FileName    : New-WallpaperStatus.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-Desktop
    Tags        : Powershell
    AddedCredit : _Emin_
    AddedWebsite:	https://p0w3rsh3ll.wordpress.com/
    AddedTwitter:	URL
    REVISIONS   :
    # 10:46 AM 7/29/2021 ren'd New-WallpaperStatus -> New-WallpaperStatus (stuck orig in Alias); added updated Win10 PS console color scheme colors to themes list (they're precurated 'suitable' colors) ; 
        added $FS3 3rd size, revised FS1 (+1 point of -FontSize), FS2 (-1); added verbose support & echos ; revised CBH (expanded Notes tags)
    # 11:42 AM 7/28/2021 added Violet & Yellow themes, test for $env:userdomain -like '*lab*' to set violet, expanded CBH example
    # # 8:51 AM 6/28/2016 fixed ampm -uformat
    # 11:14 AM 6/27/2016: added get-LocalDiskFreeSpace, local-only version (for BGInfo) drops server specs and reporting, and sorts on Name/driveletter
    # 1:43 PM 6/27/2016 ln159 psv2 is crapping out here, Primary needs to be tested $primary -eq $true for psv2
    # 12:29 PM 6/27/2016 params Psv2 Mandatory requires =$true
    # 12:21 PM 6/27/2016 submain: BGInfo: switch font to courier new
    # 11:27 AM 6/27/2016  submain: switched AMPM fmt to T
    # 11:24 AM 6/27/2016  submain: added | out-string | out-default to the drive info
    # 11:23 AM 6/27/2016 submain: added timestamp and drivespace report
    * 11:00 AM 6/27/2016 extended to accommodate & detect and redadmin the exchangeadmin acct as well
    * 10:56 AM 6/27/2016 reflects additions (Current theme)from cemaphore's comments & sample @ http://pastebin.com/Fva47UKT
		along with the Red Admin Theme I added, and code to detect ucadmin/exchangeadmin 
		# 10:48 AM 6/27/2016 tweak the uptime fmt:
    * 9:12 AM 6/27/2016 TSK reformatted, added pshelp
    * September 5, 2014 - posted version
    .DESCRIPTION
    New-WallpaperStatus - Create desktop wallpaper with specified text overlaid over specified image or background color (PS Bginfo.exe alternative)
    .PARAMETER  Text
    Text to be overlayed over specified background
    .PARAMETER  OutFile
    Output file to be created (and then assigned separately to the desktop). Defaults to c:\temp\BGInfo.bmp
    .PARAMETER  Align
    Text alignment [Left|Center]
    .PARAMETER  Theme
    Desktop Color theme (defaults Current [Current|BrightBlue|Blue|DarkBlue|DarkWhite|Grey|LightGrey|BrightBlack|Black|BrightRed|Red|DarkRed|Purple|BrightYellow|Yellow|DarkYellow|BrightGreen|DarkGreen|BrightCyan|DarkCyan|BrightMagenta|DarkMagenta])[-Theme Red]
    .PARAMETER  FontName
    Text Font Name (Defaults Arial) [-FontName Arial]
    .PARAMETER  FontSize
    Integer Text Font Size (Defaults 12 point) [9-45]
    .PARAMETER  UseCurrentWallpaperAsSource
    Switch Param that specifies to recycle existing wallpaper [-UseCurrentWallpaperAsSource]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    Powershell.exe -noprofile -command "& {c:\scripts\set-AdminBG.ps1 }" ; 
    To launch on startup: Put above into C:\Users\LOGON\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\AdminBG.lnk file
    .EXAMPLE
    $BGInfo = @{
       Text  = $t ;
       Theme = "Black" ;
       FontName = "courier new" ;
       UseCurrentWallpaperAsSource = $false ;
    } ; 
    $WallPaper = New-WallpaperStatus @BGInfo ;
    Generate a wallpaper from  a splat of parameters
    .EXAMPLE
    Set-Wallpaper -Path "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -Style Fill ; 
    To Restore the default VM wallpaper (e.g. generally the Windows OS default)
    .LINK
    https://p0w3rsh3ll.wordpress.com/2014/08/29/poc-tatoo-the-background-of-your-virtual-machines/
    .LINK
    https://github.com/tostka/verb-Desktop
    #>
    [CmdletBinding()]
    [Alias('New-BGinfo')]
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Text to be overlayed over specified background[-text 'line1`nline2']")]
        [string] $Text,
        [Parameter(HelpMessage="Output file to be created (and then assigned separately to the desktop). Defaults to c:\temp\BGInfo.bmp[-OutFile c:\path-to\image.jpg]")]
        [string] $OutFile= "$($($env:temp))\BGInfo.bmp",
        [Parameter(HelpMessage="Text alignment [Left|Center][-Align Left]")]
        [ValidateSet("Left","Center")]
        [string]$Align="Center",
        [Parameter(HelpMessage="Desktop Color theme (defaults Current [Current|BrightBlue|Blue|DarkBlue|DarkWhite|Grey|LightGrey|BrightBlack|Black|BrightRed|Red|DarkRed|Purple|BrightYellow|Yellow|DarkYellow|BrightGreen|DarkGreen|BrightCyan|DarkCyan|BrightMagenta|DarkMagenta])[-Theme Red]")]
        [ValidateSet("Current","BrightBlue","Blue","DarkBlue","DarkWhite","Grey","LightGrey","BrightBlack","Black","BrightRed","Red","DarkRed","Purple","BrightYellow","Yellow","DarkYellow","BrightGreen","DarkGreen","BrightCyan","DarkCyan","BrightMagenta","DarkMagenta")]
        [string]$Theme="Current",
        [Parameter(HelpMessage="Text Font Name (Defaults Arial) [-FontName 'courier new']")]
        [string]$FontName="Arial",
        [Parameter(HelpMessage="Integer Text Font Size (Defaults 8 point) [9-45][-FontSize 12]")]
        [ValidateRange(9,45)]
        [int32]$FontSize = 8,
        [Parameter(HelpMessage="Switch Param that specifies to recycle existing wallpaper [-UseCurrentWallpaperAsSource]")]
        [switch]$UseCurrentWallpaperAsSource
    ) ; 
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
        # 9:59 AM 6/27/2016 add cmaphore's detection of Current Theme
        # Enumerate current wallpaper now, so we can decide whether it's a solid colour or not
        try {
            $wpath = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallPaper -ErrorAction Stop).WallPaper
            if ($wpath.Length -eq 0) {
                # Solid colour used
                $UseCurrentWallpaperAsSource = $false ; 
                $Theme = "Current" ; 
            } ; 
        } catch {
            $UseCurrentWallpaperAsSource = $false ; 
            $Theme = "Current" ; 
        } ; 
        # standardize colors (for easy uese in font colors as well as bg) - lifted many of these from updated Powershell console color scheme specs.
        $cBrightBlue = @(59,120,255) ;
        $cBlue = @(58,110,165) ; # default win desktop blue
        $cDarkBlue = @(0,55,218) ; 
        $cDarkWhite = @(204,204,204) ; 
        $cGrey = @(77,77,77) ; 
        $cLightGrey = @(176,176,176) ; 
        $cBrightBlack = @(118,118,118) ; 
        $cBlack = @(12,12,12) ; 
        $cBrightRed = @(231,72,86) ; 
        $cRed = @(184,40,50) ; 
        $cDarkRed = @(197,15,31) ; 
        $cPurple = @(192,32,214) ; 
        $cBrightYellow = @(249,241,165) ; 
        $cYellow = @(255,185,0) ; 
        $cDarkYellow = @(193,156,0) ; 
        $cBrightGreen = @(22,198,12) ; 
        $cDarkGreen = @(19,161,14) ; 
        $cBrightCyan = @(97,214,214) ; 
        $cDarkCyan = @(58,150,221) ; 
        $cBrightMagenta = @(180,0,158) ; 
        $cDarkMagenta = @(136,23,152) ; 
        $cWhite = @(242,242,242) ;
        $cDefaultWhite = @(254,253,254) ; 
        $cMedGrey = @(185,190,188) ; 
        
        
        Switch ($Theme) {
            # revised the stock colors to reflect PSConsole's revised color scheme [Updating the Windows Console Colors | Windows Command Line - devblogs.microsoft.com/](https://devblogs.microsoft.com/commandline/updating-the-windows-console-colors/)
            # 9:42 AM 6/27/2016 add cmaphore's idea of a 'Current' theme switch case, pulling current background color $RGB, and defaulting if not set
            # $FC1 is used for the first line of any text ; $FC2 is used for the remaining lines of text
            Current {
                $RGB = (Get-ItemProperty 'HKCU:\Control Panel\Colors' -ErrorAction Stop).BackGround ; 
                if ($RGB.Length -eq 0) {
                    $Theme = "Black" ; # Default to Black and don't break the switch
                } else {
                    $BG = $RGB -split " " ; 
                    $FC1 = $FC2 = $cWhite ; 
                    $FS1=$FS2=$FontSize ; 
                    break ; 
                } ; 
            } ; 
            BrightBlue { 
                $BG = $cBlue ; 
                $FC1 = $cYellow ; 
                $FC2 = $cMedGrey ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
                break ; 
            } ; 
            Blue { # default win desktop blue 
                $BG = $cBlue ; 
                $FC1 = $cDefaultWhite ; 
                $FC2 = $cMedGrey ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
                break ; 
            } ; 
            DarkBlue { # 
                $BG = $cDarkBlue ; 
                $FC1 = $cDefaultWhite ; 
                $FC2 = $cMedGrey ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
                break ; 
            } ; 
            DarkWhite {
                $BG = $cDarkWhite ; 
                $FC1 = $cYellow ; 
                $FC2 = $cBlack ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
                break ; 
            } ; 
            Grey {
                $BG = $cGrey ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
                break ; 
            } ; 
            LightGrey {
                $BG = $cLightGrey ; 
                $FC1 = $cYellow ; 
                $FC2 = $cBlack ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
                break ; 
            } ; 
            BrightBlack {
                $BG = $cBrightBlack; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite  ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            Black {
                $BG = $cBlack ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            BrightRed {
                $BG = $cBrightRed ; 
                $FC1 = $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            Red {
                $BG = $cRed ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            DarkRed {
                $BG = $cDarkRed ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            Purple {
                $BG = $cPurple ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            BrightYellow {
                $BG = $cBrightYellow ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            Yellow {
                $BG = $cYellow ; 
                $FC1 = $cDarkBlue ; 
                $FC2 = $cBlack ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            DarkYellow {
                $BG = $cDarkYellow ; 
                $FC1 = $cDarkBlue ; 
                $FC2 = $cBlack ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            BrightGreen {
                $BG = $cBrightGreen ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            DarkGreen {
                $BG = $cDarkGreen ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            BrightCyan {
                $BG = $cBrightCyan ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            DarkCyan {
                $BG = $cDarkCyan ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            BrightMagenta {
                $BG = $cBrightMagenta ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
            DarkMagenta {
                $BG = $cDarkMagenta ; 
                $FC1 = $cYellow ; 
                $FC2 = $cWhite ; 
                $FS1 = $FontSize+1 ; 
                $FS2 = $FontSize-1 ; 
                $FS3 = $FontSize-2 ; 
            } ; 
        } ;  # swtch-E
          
        Try {
            [system.reflection.assembly]::loadWithPartialName('system.drawing.imaging') | out-null ; 
            [system.reflection.assembly]::loadWithPartialName('system.windows.forms') | out-null ; 
            # Draw string > alignement
            $sFormat = new-object system.drawing.stringformat
            Switch ($Align) {
                Center {
                    $sFormat.Alignment = [system.drawing.StringAlignment]::Center ; 
                    $sFormat.LineAlignment = [system.drawing.StringAlignment]::Center ; 
                    break ; 
                } ; 
                Left {
                    $sFormat.Alignment = [system.drawing.StringAlignment]::Center ; 
                    $sFormat.LineAlignment = [system.drawing.StringAlignment]::Near ; 
                } ; 
            } ;  
     
            if ($UseCurrentWallpaperAsSource) {
                # 10:01 AM 6/27/2016 moved $wppath to top of begin
                if (Test-Path -Path $wpath -PathType Leaf) {
                    $bmp = new-object system.drawing.bitmap -ArgumentList $wpath ; 
                    $image = [System.Drawing.Graphics]::FromImage($bmp) ; 
                    $SR = $bmp | Select Width,Height ; 
                } else {
                    Write-Warning -Message "Failed cannot find the current wallpaper $($wpath)" ; 
                    break ; 
                } ; 
            } else {
                # 1:43 PM 6/27/2016 psv2 is crapping out here, Primary needs to be tested $primary -eq $true for psv2
                #$SR = [System.Windows.Forms.Screen]::AllScreens | Where Primary | Select -ExpandProperty Bounds | Select Width,Height ; 
                $SR = [System.Windows.Forms.Screen]::AllScreens |?{$_.Primary} | Select -ExpandProperty Bounds | Select Width,Height ; 
                #}
                Write-Verbose -Message "Screen resolution is set to $($SR.Width)x$($SR.Height)" -Verbose ; 
     
                # Create Bitmap
                $bmp = new-object system.drawing.bitmap($SR.Width,$SR.Height) ; 
                $image = [System.Drawing.Graphics]::FromImage($bmp) ; 
         
                $image.FillRectangle(
                    (New-Object Drawing.SolidBrush (
                        [System.Drawing.Color]::FromArgb($BG[0],$BG[1],$BG[2]) 
                    )),
                    (new-object system.drawing.rectanglef(0,0,($SR.Width),($SR.Height))) 
                ) ; 
            } ; 
            
        } Catch {
            Write-Warning -Message "Failed to $($_.Exception.Message)" ; 
            break ; 
        } ; 
    } ;  # BEG-E
    PROCESS {
        # Split our string as it can be multiline
        $artext = ($text -split "\r\n") ; 
        $i = 1 ; 
        Try {
            for ($i ; $i -le $artext.Count ; $i++) {
                if ($i -eq 1) {
                    $font1 = New-Object System.Drawing.Font($FontName,$FS1,[System.Drawing.FontStyle]::Bold) ; 
                    $Brush1 = New-Object Drawing.SolidBrush (
                        [System.Drawing.Color]::FromArgb($FC1[0],$FC1[1],$FC1[2]) 
                    ) ; 
                    $sz1 = [system.windows.forms.textrenderer]::MeasureText($artext[$i-1], $font1) ; 
                    $rect1 = New-Object System.Drawing.RectangleF (0,($sz1.Height),$SR.Width,$SR.Height) ; 
                    $image.DrawString($artext[$i-1], $font1, $brush1, $rect1, $sFormat) ; 
                } elseif ($i -eq 2) {
                    $font2 = New-Object System.Drawing.Font($FontName,$FS2,[System.Drawing.FontStyle]::Bold) ; 
                    $Brush2 = New-Object Drawing.SolidBrush (
                        [System.Drawing.Color]::FromArgb($FC2[0],$FC2[1],$FC2[2]) 
                    ) ; 
                    $sz2 = [system.windows.forms.textrenderer]::MeasureText($artext[$i-1], $font2) ; 
                    $rect2 = New-Object System.Drawing.RectangleF (0,($i*$FontSize*2 + $sz2.Height),$SR.Width,$SR.Height) ; 
                    $image.DrawString($artext[$i-1], $font2, $brush2, $rect2, $sFormat) ; 
                } else {
                    $font3 = New-Object System.Drawing.Font($FontName,$FS3,[System.Drawing.FontStyle]::Bold) ; 
                    $Brush3 = New-Object Drawing.SolidBrush (
                        [System.Drawing.Color]::FromArgb($FC2[0],$FC2[1],$FC2[2]) 
                    ) ; 
                    $sz3 = [system.windows.forms.textrenderer]::MeasureText($artext[$i-1], $font2) ; 
                    $rect3 = New-Object System.Drawing.RectangleF (0,($i*$FontSize*2 + $sz3.Height),$SR.Width,$SR.Height) ; 
                    $image.DrawString($artext[$i-1], $font3, $Brush3, $rect3, $sFormat) ; 
                } ; 
            } ;  # loop-E
            
        } Catch {
            Write-Warning -Message "Failed to $($_.Exception.Message)" ; 
            break ; 
        } ; 
        
    } ;  # PROC-E
    END {  
        Try {
            # Close Graphics
            $image.Dispose(); ; 
     
            # Save and close Bitmap
            $bmp.Save($OutFile, [system.drawing.imaging.imageformat]::Bmp); ; 
            $bmp.Dispose() ;      
            # Output our file path into the pipeline
            Get-Item -Path $OutFile ; 
        } Catch {
            Write-Warning -Message "Failed to $($_.Exception.Message)" ; 
            break ; 
        } ; 
    } ;  # END-E
}

#*------^ new-WallpaperStatus.ps1 ^------


#*------v Report-URL.ps1 v------
function Report-URL {
    <#
    .SYNOPSIS
    Report-URL.ps1 - Resolves url into "[Title] - [url]" summary string, and copies to clipboard - also expands shortened uri's to full target.
    .NOTES
    Author: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: Todd O. Klindt Resolve Short URLs with PowerShell - Todd Klindt's Office 365 Admin Blog
    Website:	https://www.toddklindt.com/blog/Lists/Posts/Post.aspx?ID=764
    REVISIONS   :
    * 8:05 AM 12/13/2019 Report-URL:added -md & -title, added formal param block, switched from dumps to explicit write-ouput
    * 1:44 PM 1/23/2019 init vers
    .DESCRIPTION
    Defaults to PM Copy Page Title & Location As, Plain text, output:
    -md triggers output in Markdown link format:
    [Base64 Encoding of Images via Powershell | LINQ to Fail](https://www.aaron-powell.com/posts/2010-11-07-base64-encoding-images-with-powershell/)
    .PARAMETER  Url
    Internet URL to be resolved
    .PARAMETER  md
    Output Markdown switch [-md]
    .PARAMETER title
    Output Title-only switch[-md]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Dumps info to console, and copies to clipboard
    .EXAMPLE
    report-url https://www.google.com ;
    returns: Google - https://www.google.com/
    .EXAMPLE
    .LINK
    #>
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Internet URL to be resolved[-url https://xxxxx]")]
        [ValidateNotNullOrEmpty()]$Url,
        [Parameter(HelpMessage="Output Markdown switch [-md]")]
        [switch] $md,
        [Parameter(HelpMessage="Output Title-only switch[-md]")]
        [switch] $title,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    $error.clear() ;
    TRY {
        $page=Invoke-WebRequest -Uri $url ;
        if($title) {
            $rpt = "$(($page.parsedhtml.title|out-string).trim())" ;
        } elseif($md){
            $rpt = "[$(($page.parsedhtml.title|out-string).trim())]($(($page.baseresponse.ResponseUri.AbsoluteUri |out-string).trim()))" ;
        } else {
            $rpt="$(($page.parsedhtml.title|out-string).trim()) - $(($page.baseresponse.ResponseUri.AbsoluteUri |out-string).trim())" ;
        } ;
        $rpt | write-output ;
        write-verbose -verbose:$true "(copied to CB)" ;
        $rpt | out-clipboard ;
    } CATCH {
        Write-Error "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
        Exit ;
    } ;

} ; #*------^ END Function Report-URL ^------
If (!(Test-Path ALIAS:Rpt-URL)) { new-Alias -Name Rpt-URL -Value report-url}

#*------^ Report-URL.ps1 ^------


#*------v restart-Shell.ps1 v------
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
    FileName    : restart-Shell
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Registry,Maintenance
    REVISIONS
    * 2:12 PM 2/21/2023 added legacy post-filter support (syntax); this is also in verb-io ; 
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
        Get-Process explorer | ?{$_.MainWindowTitle -eq ''} | stop-process -Force -whatif:$($whatif);
        sleep -sec 2 ;
        if (-not(Get-Process explorer | ?{$_.MainWindowTitle -eq ''} )) {
            # Only spawn a new explorer if a new 'shell' one didn't auto-load w/in 2secs (generally does on win10 ; avoids opening a spurious new explorer window)
            start explorer.exe ;
        } ;
        $true | write-output ;
    } CATCH {
        $ErrTrpd = $_ ;
        Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrTrpd.Exception.ItemName). `nError Message: $($ErrTrpd.Exception.Message)`nError Details: $($ErrTrpd)" ;
        $false | write-output ;
    } ;
}

#*------^ restart-Shell.ps1 ^------


#*------v Set.ps1 v------
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
}

#*------^ Set.ps1 ^------


#*------v Set-Wallpaper.ps1 v------
Function Set-Wallpaper {
    <# 
    .SYNOPSIS
    Set-Wallpaper - Set specified file as desktop wallpaper
    .NOTES
    Author: _Emin_
    Tweaked/Updated by: Todd Kadrie
    Website:	https://p0w3rsh3ll.wordpress.com/2014/08/29/poc-tatoo-the-background-of-your-virtual-machines/
    REVISIONS   :
    * 9:12 AM 6/27/2016 TSK reformatted & added pshelp
    * September 5, 2014 - posted version
    .DESCRIPTION
    .PARAMETER  Path
    Path to image to be set as desktop background
    .PARAMETER  Style
    Style to apply to wallpaper [Center|Stretch|Fill|Tile|Fit]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    Set-Wallpaper -Path $WallPaper.FullName -Style Fill ;
    Set wallpaper file to fill screen
    .LINK
    https://p0w3rsh3ll.wordpress.com/2014/08/29/poc-tatoo-the-background-of-your-virtual-machines/
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]$Path,
        [ValidateSet('Center','Stretch','Fill','Tile','Fit')]
        $Style = 'Stretch' 
    ) ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    Try {
        if (-not ([System.Management.Automation.PSTypeName]'Wallpaper.Setter').Type) {
            Add-Type -TypeDefinition @"
           using System;
            using System.Runtime.InteropServices;
            using Microsoft.Win32;
            namespace Wallpaper {
                public enum Style : int {
                Center, Stretch, Fill, Fit, Tile
                }
                public class Setter {
                    public const int SetDesktopWallpaper = 20;
                    public const int UpdateIniFile = 0x01;
                    public const int SendWinIniChange = 0x02;
                    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
                    private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
                    public static void SetWallpaper ( string path, Wallpaper.Style style ) {
                        SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
                        RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
                        switch( style ) {
                            case Style.Tile :
                                key.SetValue(@"WallpaperStyle", "0") ;
                                key.SetValue(@"TileWallpaper", "1") ;
                                break;
                            case Style.Center :
                                key.SetValue(@"WallpaperStyle", "0") ;
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
                            case Style.Stretch :
                                key.SetValue(@"WallpaperStyle", "2") ;
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
                            case Style.Fill :
                                key.SetValue(@"WallpaperStyle", "10") ;
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
                            case Style.Fit :
                                key.SetValue(@"WallpaperStyle", "6") ;
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
}
                        key.Close();
                    }
                }
            }
"@ -ErrorAction Stop ; 
            } else {
                Write-Verbose -Message "Type already loaded" -Verbose ; 
            } ; 
        # } Catch TYPE_ALREADY_EXISTS
        } Catch {
            Write-Warning -Message "Failed because $($_.Exception.Message)" ; 
        } ; 
     
    [Wallpaper.Setter]::SetWallpaper( $Path, $Style ) ; 
}

#*------^ Set-Wallpaper.ps1 ^------


#*------v show-TrayTip.ps1 v------
function show-TrayTip {
    <#
    .SYNOPSIS
    Show-TrayTip() - Display popup System Tray Tooltip
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    :
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    AddedCredit : Pat Richard (pat@innervation.com)
    AddedWebsite: http://www.ehloworld.com/1038
    AddedTwitter:
    REVISIONS
    * 2:23 PM 3/10/2016 reworked the $TrayIcon validation, to permit either a valid path to an .ico, or a variable of Icon type (of the type pulled from shell32.dll by Extract-Icon()); debugged and functional in check-kpconflict.ps1 ; added some concepts from the src Pat used: Dr. Tobias Weltner, http://www.powertheshell.com/balloontip/ (Pat was in the comments asking questions on the subject) ; added some concepts from Pat Richard http://www.ehloworld.com/1038
    * 11:19 AM 3/6/2016 - unknown original, updating with formatting, pshelp and updated params
    .DESCRIPTION
    Show-TrayTip() - Display popup System Tray Tooltip
    .PARAMETER Type
    Tip Icon type [Error|Info|Warning|None]
    .PARAMETER Text
    Tip Text to be displayed [string]
    .PARAMETER title
    Tip Title [string]
    .PARAMETER ShowTime
    Tip Display Time (secs, default:2)[int]
    .PARAMETER TrayIcon
    Specify variant Systray icon (defaults per type)
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    show-TrayTip -type "error" -text "$computer is still ONLINE; Check that reboot is initiated properly" -title "Computer is not rebooting"
    Show TrayTip with default (powershell) Systray Icon, Error-type balloon icon, and balloon title & text specified, for 30 seconds
    .EXAMPLE
    show-TrayTip -type "error" -title "CONFLICT!" -text "CONFLICTED KEEPASS DB FOUND!" -ShowTime 30 -TrayIcon $TrayIcon ;
    Show TrayTip with custom Systray Icon, Error-type balloon icon, and balloon title & text specified, for 30 seconds
    .EXAMPLE
    show-TrayTip -type info -text "PowerShell script has finished processing" -title "Completed"
    Basic Example using parameter names (rest defaults)
    .EXAMPLE
    show-TrayTip info "PowerShell script has finished processing" "Completed"
    Basic Example using positional parameters
    .EXAMPLE
    if($script:TrayTip) { $script:TrayTip.Dispose() ; Remove-Variable -Scope script -Name TrayTip ; }
    Cleanup code that should be used at script-end to cleanup the objects
    .LINK
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Tip Icon type [Error|Info|Warning|None]")][ValidateSet("Error","Info","Warning","None")]
        [string]$Type
        ,[Parameter(Position=1,Mandatory=$True,HelpMessage="Tip Text to be displayed [string]")][ValidateNotNullOrEmpty()]
        [string]$Text
        ,[Parameter(Position=2,Mandatory=$True,HelpMessage="Tip Title [string]")]
        [string]$Title
        ,[Parameter(HelpMessage="Tip Display Time (secs, default:2)[int]")][ValidateRange(1,30)]
        [int]$ShowTime=2
        ,[parameter(HelpMessage = "Specify variant Systray icon (defaults to Powershell)")]
        $TrayIcon
    )  ;
    BEGIN {
        if($TrayIcon){
            if( (test-path $TrayIcon) -OR ($TrayIcon.gettype().name -eq 'Icon') ){ }
            else {
                write-warning "Invalid TrayIcon, resetting to Default Icon" ;
                $TrayIcon =$null ;
            } ;
        } ;
    } ;
    PROCESS {
        if(!($NoTray)){
            #load Windows Forms and drawing assemblies
            [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null ; # used for TrayTip tips
            [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null ; # used for icon extraction
            #define an icon image pulled from PowerShell.exe
            #$icon=[system.drawing.icon]::ExtractAssociatedIcon((join-path $pshome powershell.exe)) ;
            # load the TrayTip
            if ($script:TrayTip -eq $null) {  $script:TrayTip = New-Object System.Windows.Forms.NotifyIcon } ;
            <# TrayIcon (BalloonTip): configurable property's:
              # the systray icon to be displayed (extracted from the PS path here)
              $path                    = Get-Process -id $pid | Select-Object -ExpandProperty Path ;
              $TrayTip.Icon            = [System.Drawing.Icon]::ExtractAssociatedIcon($path) ;
              # the following configure settings _within_ the balloon popup
              $TrayTip.BalloonTipIcon  = $Icon ;
              $TrayTip.BalloonTipText  = $Text ;
              $TrayTip.BalloonTipTitle = $Title ;
              # finally show the BalloonTip, with a specified timeout.
              $TrayTip.Visible         = $true ;
              $TrayTip.ShowBalloonTip($Timeout) ;
            #>
            if ($TrayIcon) { $TrayTip.Icon = $TrayIcon  }
            else {
                # use the extracted Powershell process icon
                $Path = Get-Process -id $pid | Select-Object -ExpandProperty Path ;
                $TrayTip.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) ;
            }
            $TrayTip.BalloonTipIcon  = $Type ;
            $TrayTip.BalloonTipText  = $Text ;
            $TrayTip.BalloonTipTitle = $Title ;
            $TrayTip.Visible         = $true ;
            # set timeout (in ms)
            $TrayTip.ShowBalloonTip($ShowTime*1000) ;
            write-verbose -verbose:$verbose "`$TrayTip:`n$(($TrayTip | fl * |out-string).trim())" ;
        } ;# if-E $NoTray ;
    } ;
    END {
        <# Cleanup code that should be used at script-end to cleanup the objects
            if($script:TrayTip) { $script:TrayTip.Dispose() ; Remove-Variable -Scope script -Name TrayTip ; }
        #>
    } ;
}

#*------^ show-TrayTip.ps1 ^------


#*------v start-ItunesPlaylist.ps1 v------
Function start-ItunesPlaylist {
    <#
    .SYNOPSIS
    Plays an iTunes playlist.
    .DESCRIPTION
    Opens the Apple iTunes application and starts playing the given iTunes playlist.
    .NOTES
    Author: Frank Peter (http://www.out-web.net/?p=1390)
    .PARAMETER  Source
    Identifies the name of the source.(["Library"|"Internet Radio"]
    .PARAMETER  Playlist
    Identifies the name of the playlist
    .PARAMETER  Shuffle
    Turns shuffle on (else don't care).
    .EXAMPLE
    C:\PS> .\Start-PlayList.ps1 -Source 'Library' -Playlist 'Party'
    .EXAMPLE
    C:\PS> .\Start-PlayList.ps1 -source 'Library' -Playlist "classical-streams"
    .INPUTS
    None
    .OUTPUTS
    None
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Source,
        [Parameter(Mandatory = $true)]
        $Playlist,
        [Switch]$Shuffle
    ) ;
    try {$iTunes = New-Object -ComObject iTunes.Application
    }catch {Write-Error 'Download and install Apple iTunes'return} ;
    <# source options (interegated to get)
    Name
    ----
    Library
    Internet Radio
    #>
    $src = $iTunes.Sources | Where-Object { $_.Name -eq $Source } ;
    if (!$src) {
        Write-Error "Unknown source - $Source" ;
        return ;
    } ; # if-E
    $ply = $src.Playlists | Where-Object { $_.Name -eq $Playlist } ;
    if (!$ply) {
        Write-Error "Unknown playlist - $Playlist" ;
        return ;
    } # if-E
    if ($Shuffle) {
        if (!$ply.Shuffle) {
            $ply.Shuffle = $true ;
        } # if-E
    } # if-E
    $ply.PlayFirstTrack() ;
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$iTunes) > $null ;
    [GC]::Collect() ;
}

#*------^ start-ItunesPlaylist.ps1 ^------


#*------v stop-browsers.ps1 v------
Function stop-browsers {

    <# 
    .SYNOPSIS
    stop-browsers - Cycle common browser proceses and close/kill them (as browsers frequently ignore close prompts from shell wo explicitly prompts, when trying to shutdown/reboot).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-11-14
    FileName    : stop-browsers.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-Desktop
    Tags        : GoogleDrive
    AddedCredit : mklement0
    AddedWebsite:	https://stackoverflow.com/users/45375/mklement0
    AddedTwitter:	
    REVISIONS   :
    * 8:26 AM 11/14/2022 init
    .DESCRIPTION
    stop-browsers - Cycle common browser proceses and close/kill them (as browsers frequently ignore close prompts from shell wo explicitly prompts, when trying to shutdown/reboot).
    .PARAMETER Whatif
    Whatif no-exec test
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    PS> if(stop-browsers -verbose -whatif){'y'} else { 'n'} ; 
    Confirm Gdrv running, with verbose and whatif 
    .LINK
    https://github.com/tostka/verb-Desktop
    #>
    [CmdletBinding()]
    [Alias('sbn')]
    Param(
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ; 
    BEGIN{
        $TargAppName="Firefox|Palemoon|Cyberfox|msEdge|Chrome" ;  # descriptive msg text
        # stop-process names to be killed
        $rgxPSTargetAppProc="^(firefox|palemoon|Cyberfox|chrome|msedge$)$" ;  
        # pskill/pslist select-sting pattern targets (as sysinternals don't emit objects, just text)
        $rgxPSETargetAppProc="(firefox|palemoon|Cyberfox|chrome|msedge)" ;  

    }
    PROCESS{
        w-h "Cycle common browser proceses and close/kill them (as browsers frequently ignore close prompts from shell)" ; 
        [array]$prcs = $prcE = @() ; 
        Try {
            write-verbose -verbose:$true "$(get-date -format 'yyyyMMdd-HHmmtt'): --PASS STARTED:$ScriptName --"
write-verbose -verbose:$true "killing $($TargAppName)"

            $prcs=get-process -ea silentlycontinue| ?{$_.name -match $rgxPSTargetAppProc} | sort name;
            if($prcs){
                $smsg = "TARGETS FOUND:`n$(($prcs | group Name | ft -a name,count |out-string).trim())`n" ; 
                write-host $smsg ; 
                if($prcs){ 
                    $prcs | stop-process -verbose -whatif:$($whatif) -erroraction silentlycontinue; 
                    start-sleep 2 ; 
                } else {
                    $smsg = "(no targets found)" ; 
                    write-host $smsg ; 
                } ; ; 
                # anything that survives above, pskill
                $prcE = pslist | select-string -pattern $rgxPSETargetAppProc ; 
                if($prcE){
                    # sysinternals has padded the output from 3 to 7 lines of baloney, including header line
                    #$prcE = $prcE | Select -Skip 7 |foreach-object{
                    # prefiltered, doesn't have headers, no need to skip 7
                    $prcE = $prcE | foreach-object{
                        $procinfo = $_ -split "\s+" ; 
                        [pscustomobject][ordered]@{
                            Name = $procInfo[0..($procInfo.Count -8)] -Join " "; 
                            Pid = $procInfo[-7].trim()  ; 
                            Pri = $procInfo[-6].trim() ; 
                            Thd = $procInfo[-5].trim()  ; 
                            Hnd = $procInfo[-4].trim() ; 
                            Priv = $procInfo[-3].trim()      ; 
                            "CPU Time" = $procInfo[-2].trim()   ; 
                            "Elapsed Time" = $procInfo[-1].trim()  ; 
                        }  ;                
                    } | sort name ; 
                    foreach($prc in $prcE){
                        write-verbose "pskill $($prc.pid) ($($prc.name))" ; 
                        if(!$whatif){
                        invoke-expression -command "pskill $($prc.pid)"
                        } else { 
                            write-host "(-whatif, skipping exec)" ; 
                        } ; 
                    } ; 
                    $smsg = "POST ZOMBIES RESULTS:`n$(($prcE = pslist | select-string -pattern $rgxPSETargetAppProc|out-string).trim())" ; 
                     write-host -foregroundcolor red $smsg ; 
                }
            }
        } Catch {
                $smsg = "ERROR!`n$($Error[0])"
                 write-warning $smsg ; throw $smsg ; 
                 #$false | write-output ; 
        } 
        Finally {
            
        } ;
    }  # PROC-E
    END{}
}

#*------^ stop-browsers.ps1 ^------


#*------v test-InstalledApplication.ps1 v------
Function test-InstalledApplication {
    <#
    .SYNOPSIS
    test-InstalledApplication.ps1 - Check registry for Installed status of specified application (checks x86 & x64 Uninstall hives, for substring matches on Name)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : test-InstalledApplication
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
    REVISIONS
    * 2:42 PM 2/21/2023 moved back to verb-desktop, vio is way too cluttered, and these are about system, not IO (with test-installedwindowsfeature)
    * 10:37 AM 11/11/2022 ren get-InstalledApplication -> test-InstalledApplication (better match for function, default is test -detailed triggers dump back); aliased orig name; also pulling in overlapping verb-desktop:check-ProgramInstalled(), aliased -Name with ported programNam ; CBH added expl output demo
    * 9:13 AM 4/15/2021 init vers
    .DESCRIPTION
    test-InstalledApplication.ps1 - Check registry for Installed status of specified application (checks x86 & x64 Uninstall hives, for substring matches on Name)
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    PS> if(test-InstalledApplication -name "powershell"){"yes"} else { "no"} ; 
    yes
    Default boolean test
    .EXAMPLE    
    PS> get-InstalledApplication -Name 'google drive' -detail
    DisplayName  DisplayVersion InstallLocation                                                      Publisher
    -----------  -------------- ---------------                                                      ---------
    Google Drive 63.0.5.0       C:\Program Files\Google\Drive File Stream\63.0.5.0\GoogleDriveFS.exe Google LLC
    Example returning detail (DisplayName and InstallLocation)
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('check-ProgramInstalled','get-InstalledApplication')]
    PARAM(
        [Parameter(Position=0,HelpMessage="Application Name substring[-Name Powershell]")]
        [Alias('programNam')]
        $Name,
        [Parameter(HelpMessage="Debugging Flag [-Return detailed object on match]")]
        [switch] $Detail
    ) ;
    $x86Hive = Get-ChildItem 'HKLM:Software\Microsoft\Windows\CurrentVersion\Uninstall' |
         % { Get-ItemProperty $_.PsPath } | ?{$_.displayname -like "*$($Name)*"} ;
    write-verbose "`$x86Hive:$([boolean]$x86Hive)" ; 
    if(Test-Path 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'){
        #$x64Hive = ((Get-ChildItem "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        #    Where-Object { $_.'Name' -like "*$($Name)*" } ).Length -gt 0;
        $x64Hive = Get-ChildItem 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
            % { Get-ItemProperty $_.PsPath } | ?{$_.displayname -like "*$($Name)*"} ;
         write-verbose "`$x64Hive:$([boolean]$x64Hive)" ; 
    }
    if(!$Detail){
        # boolean return:
        ($x86Hive -or $x64Hive) | write-output ; 
    } else { 
        $props = 'DisplayName','DisplayVersion','InstallLocation','Publisher' ;
        $x86Hive | Select $props | write-output ; 
        $x64Hive | Select $props | write-output ; 
    } ; 
}

#*------^ test-InstalledApplication.ps1 ^------


#*------v Test-InstalledWindowsFeature.ps1 v------
function Test-InstalledWindowsFeature {
	<#
    .SYNOPSIS
    Test-InstalledWindowsFeature - Check for Installed status of specified WindowsFeature
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : Test-InstalledWindowsFeature.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
    REVISIONS
    * 10:37 AM 11/11/2022 init vers
    .DESCRIPTION
    Test-InstalledWindowsFeature - Check for Installed status of specified WindowsFeature
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean
    .EXAMPLE    
    PS> Test-InstalledWindowsFeature -FeatureName 'RSAT-AD-Tools'
    Test for feature installation
    .LINK
    https://github.com/tostka/verb-io
    #>
	PARAM(
		[Parameter(Mandatory=$True,HelpMessage="WindowsFeature name to be Tested for installation[-FeatureName RSAT-AD-Tools")]
		$FeatureName
	) ; 
	[boolean]$(Get-WindowsFeature $FeatureName).Installed | write-output ; 
}

#*------^ Test-InstalledWindowsFeature.ps1 ^------


#*------v test-IsWindowsActivated.ps1 v------
function test-IsWindowsActivated {
    <#
    .SYNOPSIS
    test-IsWindowsActivated - Tests if local machine is properly License Activated.
    .NOTES
    Version     : 1.0.0.0
    Author: Todd Kadrie
    Website:	http://toddomation.com
    Twitter:	http://twitter.com/tostka
    CreatedDate : 2023-02-22
    FileName    : test-IsWindowsActivated
    License     : MIT License
    Copyright   : (c) 2023 Todd Kadrie
    AddedCredit : FoxDeploy
    AddedWebsite: https://stackoverflow.com/questions/29368414/need-script-to-find-server-activation-status
    AddedTwitter: 
    Github      : https://github.com/tostka/verb-desktop
    Tags        : Powershell,OS,License,Activiation
    REVISIONS
    * 12:06 PM 2/22/2023 init, from canned notes, and FoxDeploy's switchblock code for LicenseStatus values, added ISLicensed to the output. 
    .DESCRIPTION
    test-IsWindowsActivated - Tests if local machine is properly License Activated.
    .PARAMETER  User
    User security principal (defaults to current user)[-User `$SecPrinobj]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    PS>  if((test-IsWindowsActivated).IsLicensed){
    PS>  	write-host "$($env:computername) is Activated/Licensed" ; 
    PS>  } else { 
    PS>  	write-warning "$($env:computername) is NOT Activated/Licensed!" ; 
    PS>  } ; 
    Test standard windows activation
    .LINK
    https://stackoverflow.com/questions/29368414/need-script-to-find-server-activation-status
    https://github.com/tostka/verb-desktop
    #>
    [CmdletBinding()]
    #[Alias('')]
    PARAM(
		[Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = 'ComputerName to test[-ComputerName ServerName')]
		[string[]] $ComputerName=$env:COMPUTERNAME,
		[Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = 'ComputerName to test[-ComputerName ServerName')]
		[string] $ProductFilter="Name like 'Windows%'" 
    ) ;
    BEGIN{
		if ($PSCmdlet.MyInvocation.ExpectingInput) {
			write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
		} else {
			#write-verbose "Data received from parameter input: '$($InputObject)'" ; 
			write-verbose "(non-pipeline - param - input)" ; 
		} ; 
    }
    PROCESS{
		if(gcm get-ciminstance){
			$pltGCM=[ordered]@{
				ComputerName = $ComputerName ;ClassName = 'SoftwareLicensingProduct' ;Filter = $ProductFilter ; 
			} ; 
			$status = Get-CimInstance @pltGCM |
				?{ $_.PartialProductKey } | select Pscomputername,Name,
					@{Name='LicenseStatus';Exp={
						switch ($_.LicenseStatus) {
							0 {'Unlicensed'}
							1 {'licensed'}
							2 {'OOBGrace'}
							3 {'OOTGrace'}
							4 {'NonGenuineGrace'}
							5 {'Notification'}
							6 {'ExtendedGrace'}
							Default {'Undetected'}
						} 
				}},@{name="IsLicensed";expression={ if($_.LicenseStatus -eq 1){$true}else{$false}}} ; 
			$status | write-output ; 	
		} else { 
			$smsg = "MISSING DEPENDANT get-ciminstance CMD!" ; 
			if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
			else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
		} ; 
	} ;
}

#*------^ test-IsWindowsActivated.ps1 ^------


#*------v Test-IsWindowsTerminal.ps1 v------
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
}

#*------^ Test-IsWindowsTerminal.ps1 ^------


#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function ....,...,..,~,Clean-Desktop,confirm-GoogleDriveRunning,c-winsallk,Define-MoveWindow,get-processTitled,Install-ChocoPkg,Install-ExePackage,Install-MsiPackage,Install-ServerRoles,invoke-Explore,invoke-speakwords,Move-Window,Move-WindowByWindowTitle,New-WallpaperStatus,Report-URL,restart-Shell,Set,Set-Wallpaper,show-TrayTip,start-ItunesPlaylist,stop-browsers,test-InstalledApplication,Test-InstalledWindowsFeature,test-IsWindowsActivated,Test-IsWindowsTerminal -Alias *




# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUl2xG8FUhsVm65pbOBL/zDVzI
# cV+gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDEyMjkxNzA3MzNaFw0zOTEyMzEyMzU5NTlaMBUxEzARBgNVBAMTClRvZGRT
# ZWxmSUkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALqRVt7uNweTkZZ+16QG
# a+NnFYNRPPa8Bnm071ohGe27jNWKPVUbDfd0OY2sqCBQCEFVb5pqcIECRRnlhN5H
# +EEJmm2x9AU0uS7IHxHeUo8fkW4vm49adkat5gAoOZOwbuNntBOAJy9LCyNs4F1I
# KKphP3TyDwe8XqsEVwB2m9FPAgMBAAGjdjB0MBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MF0GA1UdAQRWMFSAEL95r+Rh65kgqZl+tgchMuKhLjAsMSowKAYDVQQDEyFQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEGwiXbeZNci7Rxiz/r43gVsw
# CQYFKw4DAh0FAAOBgQB6ECSnXHUs7/bCr6Z556K6IDJNWsccjcV89fHA/zKMX0w0
# 6NefCtxas/QHUA9mS87HRHLzKjFqweA3BnQ5lr5mPDlho8U90Nvtpj58G9I5SPUg
# CspNr5jEHOL5EdJFBIv3zI2jQ8TPbFGC0Cz72+4oYzSxWpftNX41MmEsZkMaADGC
# AWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZp
# Y2F0ZSBSb290AhBaydK0VS5IhU1Hy6E1KUTpMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRZUBZw
# cxeDfg1JmNckuEbkWq6WBzANBgkqhkiG9w0BAQEFAASBgIU9UJQKDCAgGfOiOYkJ
# JJVT7hHEtLSpSJvj43ywiJlg7WfEtYXeSbOPwGkNYmaLpG3264X/pQX0ioYvUosG
# 4obw9cUScAO7XGcWXxqp11SSes8NHrPWlE/OyAofXCg/rqazduaummqHqadFg3sF
# H8JknruQBiZL4vUNabHCYKPC
# SIG # End signature block
