﻿# verb-desktop.psm1


  <#
  .SYNOPSIS
  verb-Desktop - Powershell Desktop generic functions module
  .NOTES
  Version     : 1.0.9.0
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

#*------v check-ProgramInstalled.ps1 v------
Function check-ProgramInstalled {
    <# 
    .SYNOPSIS
    check-ProgramInstalled - Checkregistry for installed software (via Uninstall record)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-04
    FileName    : check-ProgramInstalled.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-Desktop
    Tags        : Powershell
    AddedCredit : Morgan
    AddedWebsite:	https://morgantechspace.com/2018/02/check-if-software-program-is-installed-powershell.html
    AddedTwitter:	URL
    REVISIONS   :
    # 
    * - posted version
    .DESCRIPTION
    check-ProgramInstalled - Create desktop wallpaper with specified text overlaid over specified image or background color (PS Bginfo.exe alternative)
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
    if(check-ProgramInstalled -prog Notepad2){"Y"} else { "N" } ; 
    Check for install of notepad2
    .LINK
    https://morgantechspace.com/2018/02/check-if-software-program-is-installed-powershell.html
    .LINK
    https://github.com/tostka/verb-Desktop
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Name of the program to be checked for[-programNam 'notepad2']")]
        [string] $programNam
    ) ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    $x86_check = ((Get-ChildItem "HKLM:Software\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_."Name" -like "*$programName*" } ).Length -gt 0;
    write-verbose "`$x86_check:$([boolean]$x86_check)" ; 
    if(Test-Path 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'){
        $x64_check = ((Get-ChildItem "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
            Where-Object { $_."Name" -like "*$programName*" } ).Length -gt 0;
            write-verbose "`$x64_check:$([boolean]$x64_check)" ; 
    } ; 
    return $x86_check -OR $x64_check;        
}

#*------^ check-ProgramInstalled.ps1 ^------

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

#*------v Go.ps1 v------
function Go {
    <#
    .SYNOPSIS
    Go - CD to common system locations
    .NOTES
    # vers: 8:49 AM 3/27/2014 - tuned destinations
    .EXAMPLE
    PS C:\> Go <location keyword>
    .OUTPUTS
    [none]
    #>
    [CmdletBinding()]
    Param([string] $Location) ; 
    BEGIN { 
        $verbose = ($VerbosePreference -eq "Continue") 
        if ( $GLOBAL:go_locations -eq $null ) {
            $GLOBAL:go_locations = @{ };
            #$GLOBAL:go_locations =[Ordered]@{}; # psv3+
        } 
    } ;
    PROCESS {
        if ($go_locations.ContainsKey($Location)) {
            #write-output $go_locations[$Location]
            Set-Location $go_locations[$Location];
            # 10:37 AM 3/27/2014this lists everything in the dir... NAH!
            #Get-ChildItem;
        } else {
            write-verbose -verbose:$true "---";
            write-verbose -verbose:$true "The following locations are defined:";
            write-verbose -verbose:$true $go_locations;
        } 
    } ;
    END {} ;
}

#*------^ Go.ps1 ^------

#*------v gotoDbox.ps1 v------
function gotoDbox { set-location c:\usr\home\dropbox }

#*------^ gotoDbox.ps1 ^------

#*------v gotoDboxDb.ps1 v------
function gotoDboxDb { set-location c:\usr\home\dropbox\db }

#*------^ gotoDboxDb.ps1 ^------

#*------v gotoDownloads.ps1 v------
function gotoDownloads { set-location C:\usr\home\ftp }

#*------^ gotoDownloads.ps1 ^------

#*------v gotoIncid.ps1 v------
function gotoIncid { set-location c:\usr\work\incid }

#*------^ gotoIncid.ps1 ^------

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

#*------v openInput.ps1 v------
function openInput { $sExc = $TextEd + " " + (join-path $binpath input.txt); Invoke-Expression $sExc; }

#*------^ openInput.ps1 ^------

#*------v openTmpps1.ps1 v------
function openTmpps1 { $sExc = $TextEd + " C:\tmp\tmp.ps1"; Invoke-Expression $sExc; }

#*------^ openTmpps1.ps1 ^------

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

#*------v Speak-words.ps1 v------
function Speak-words {
    <#
    .SYNOPSIS
    speak-words - Text2Speech specified words
    .NOTES
    Author: Karl Prosser
    Website:	http://poshcode.org/835
    REVISIONS   :
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
    speak-words "here we go now"  ;
    .EXAMPLE
    speak-words "$([datetime]::now)" ;
    Speak current date and time
    .EXAMPLE
    get-fortune | speak-words ;
    Speak output of get-fortune
    .LINK
    http://poshcode.org/835
    #>
    Param(
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
    $voice.speak($words, [int] $flag) # 2 means wait until speaking is finished to continue

} #*======^ END Function Speak-words ^====== ;
# 10:29 AM 2/19/2016
if (!(get-alias -name "speak" -ea 0 )) { Set-Alias -Name 'speak' -Value 'speak-words' ; }

#*------^ Speak-words.ps1 ^------

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

#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function ....,...,..,~,check-ProgramInstalled,Clean-Desktop,c-winsallk,Define-MoveWindow,Go,gotoDbox,gotoDboxDb,gotoDownloads,gotoIncid,Move-Window,Move-WindowByWindowTitle,New-WallpaperStatus,openInput,openTmpps1,Report-URL,restart-Shell,Set,Set-Wallpaper,show-TrayTip,Speak-words,start-ItunesPlaylist -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPmKq6Em19VI82qdloW9hp0Y7
# 7dagggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSb4ZMy
# KCcOKSXx2lq5O+oZO+VyiTANBgkqhkiG9w0BAQEFAASBgKDtu2OLVV8nF8PrO6gP
# cAln0ntaHH23m2oYGfGbFbSrD98LTvIAR+Dhwo2Dsup/3U5FuXWuWXh/lO3+i/a+
# LaxoLjYxfkxmtP3uhzZ9LlcuMLAYUzXc8qtqLKggyemM5f+vecIzC0K1kBNhwQGg
# wpeQ5SEeXCbGtTxkSzOpDaWh
# SIG # End signature block
