﻿# verb-Desktop.psm1


  <#
  .SYNOPSIS
  verb-Desktop - Powershell Desktop generic functions module
  .NOTES
  Version     : 1.0.4.0
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

#*------v Compare-ObjectsSideBySide.ps1 v------
function Compare-ObjectsSideBySide ($lhs, $rhs) {
    <#
    .SYNOPSIS
    Compare-ObjectsSideBySide() - Displays a pair of objects side-by-side comparatively in console
    .NOTES
    Author: Richard Slater
    Website:	https://stackoverflow.com/users/74302/richard-slater
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	URL
    Twitter:	URL
    REVISIONS   :
    * 10:18 AM 11/2/2018 reformatted, tightened up, shifted params to body, added pshelp
    * May 7 '16 at 20:55 posted version
    .DESCRIPTION
    Compare-ObjectsSideBySide() - Displays a pair of objects side-by-side comparatively in console
    .PARAMETER  col1
    Object to be displayed in Left Column [-col1 $PsObject1]
    .PARAMETER  col2
    Object to be displayed in Right Column [-col2 $PsObject2]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    Acceptes piped input.
    .OUTPUTS
    Outputs specified object side-by-side on console
    .EXAMPLE
    $object1 = New-Object PSObject -Property @{
      'Forename' = 'Richard';
      'Surname' = 'Slater';
      'Company' = 'Amido';
      'SelfEmployed' = $true;
    } ;
    $object2 = New-Object PSObject -Property @{
      'Forename' = 'Jane';
      'Surname' = 'Smith';
      'Company' = 'Google';
      'MaidenName' = 'Jones' ;
    } ;
    Compare-ObjectsSideBySide $object1 $object2 | Format-Table Property, col1, col2;
    Display $object1 & $object2 in comparative side-by-side columns
    .LINK
    https://stackoverflow.com/questions/37089766/powershell-side-by-side-objects
    #>
    $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $combinedMembers = ($col1Members + $col2Members) | Sort-Object -COque ;
    $combinedMembers | ForEach-Object {
        $properties = @{'Property' = $_} ;
        if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
        if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
        New-Object PSObject -Property $properties ;
    } ;
}

#*------^ Compare-ObjectsSideBySide.ps1 ^------

#*------v Compare-ObjectsSideBySide3.ps1 v------
function Compare-ObjectsSideBySide3 ($col1, $col2, $col3) {
    <#
    .SYNOPSIS
    Compare-ObjectsSideBySide3() - Displays three objects side-by-side comparatively in console
    .NOTES
    Author: Richard Slater
    Website:	https://stackoverflow.com/users/74302/richard-slater
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	URL
    Twitter:	URL
    REVISIONS   :
    * 10:18 AM 11/2/2018 Extension of base model, to 3 columns
    * May 7 '16 at 20:55 posted version
    .DESCRIPTION
    Compare-ObjectsSideBySide3() - Displays three objects side-by-side comparatively in console
    .PARAMETER  col1
    Object to be displayed in Column1 [-col1 $PsObject1]
    .PARAMETER  col2
    Object to be displayed in Column2 [-col2 $PsObject2]
    .PARAMETER  col3
    Object to be displayed in Column3 [-col3 $PsObject3]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    Acceptes piped input.
    .OUTPUTS
    Outputs specified object side-by-side on console
    .EXAMPLE
    $object1 = New-Object PSObject -Property @{
      'Forename' = 'Richard';
      'Surname' = 'Slater';
      'Company' = 'Amido';
      'SelfEmployed' = $true;
    } ;
    $object2 = New-Object PSObject -Property @{
      'Forename' = 'Jane';
      'Surname' = 'Smith';
      'Company' = 'Google';
      'MaidenName' = 'Jones' ;
    } ;
    $object3 = New-Object PSObject -Property @{
      'Forename' = 'Zhe';
      'Surname' = 'Person';
      'Company' = 'Apfel';
      'MaidenName' = 'NunaUBusiness' ;
    } ;
    Compare-ObjectsSideBySide3 $object1 $object2 $object3 | Format-Table Property, col1, col2, col3;
    Display $object1 & $object2 in comparative side-by-side columns
    .LINK
    https://stackoverflow.com/questions/37089766/powershell-side-by-side-objects
    #>
    $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col3Members = $col3 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $combinedMembers = ($col1Members + $col2Members + $col3Members ) | Sort-Object -COque ;
    $combinedMembers | ForEach-Object {
        $properties = @{'Property' = $_} ;
        if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
        if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
        if ($col3Members.Contains($_)) {$properties['Col3'] = $col3 | Select-Object -ExpandProperty $_} ;
        New-Object PSObject -Property $properties ;
    } ;
}

#*------^ Compare-ObjectsSideBySide3.ps1 ^------

#*------v Compare-ObjectsSideBySide4.ps1 v------
function Compare-ObjectsSideBySide4 ($col1, $col2, $col3, $col4) {
    <#
    .SYNOPSIS
    Compare-ObjectsSideBySide4() - Displays four objects side-by-side comparatively in console
    .NOTES
    Author: Richard Slater
    Website:	https://stackoverflow.com/users/74302/richard-slater
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	URL
    Twitter:	URL
    REVISIONS   :
    * 10:18 AM 11/2/2018 Extension of base model, to 4 columns
    * May 7 '16 at 20:55 posted version
    .DESCRIPTION
    Compare-ObjectsSideBySide4() - Displays four objects side-by-side comparatively in console
    .PARAMETER  col1
    Object to be displayed in Column1 [-col1 $PsObject1]
    .PARAMETER  col2
    Object to be displayed in Column2 [-col2 $PsObject2]
    .PARAMETER  col3
    Object to be displayed in Column3 [-col3 $PsObject3]
    .PARAMETER  col4
    Object to be displayed in Column4 [-col4 $PsObject4]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    Acceptes piped input.
    .OUTPUTS
    Outputs specified object side-by-side on console
    .EXAMPLE
    $object1 = New-Object PSObject -Property @{
      'Forename' = 'Richard';
      'Surname' = 'Slater';
      'Company' = 'Amido';
      'SelfEmployed' = $true;
    } ;
    $object2 = New-Object PSObject -Property @{
      'Forename' = 'Jane';
      'Surname' = 'Smith';
      'Company' = 'Google';
      'MaidenName' = 'Jones' ;
    } ;
    $object3 = New-Object PSObject -Property @{
      'Forename' = 'Zhe';
      'Surname' = 'Person';
      'Company' = 'Apfel';
      'MaidenName' = 'NunaUBusiness' ;
    } ;
    $object4 = New-Object PSObject -Property @{
      'Forename' = 'Zir';
      'Surname' = 'NPC';
      'Company' = 'Facemook';
      'MaidenName' = 'Not!' ;
    } ;
    Compare-ObjectsSideBySide4 $object1 $object2 $object3 $object4 | Format-Table Property, col1, col2, col3, col4;
    Display $object1,2,3 & 4 in comparative side-by-side columns
    .LINK
    https://stackoverflow.com/questions/37089766/powershell-side-by-side-objects
    #>
    $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col3Members = $col3 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col4Members = $col4 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $combinedMembers = ($col1Members + $col2Members + $col3Members + $col4Members) | Sort-Object -COque ;
    $combinedMembers | ForEach-Object {
        $properties = @{'Property' = $_} ;
        if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
        if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
        if ($col3Members.Contains($_)) {$properties['Col3'] = $col3 | Select-Object -ExpandProperty $_} ;
        if ($col4Members.Contains($_)) {$properties['col4'] = $col4 | Select-Object -ExpandProperty $_} ;
        New-Object PSObject -Property $properties ;
    } ;
}

#*------^ Compare-ObjectsSideBySide4.ps1 ^------

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

#*------v Get-FsoShortName.ps1 v------
Function Get-FsoShortName {
    <#
    .SYNOPSIS
    Get-FsoShortName - Return ShortName (8.3) for specified Filesystem object
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 7:40 AM 3/29/2016 - added string->path conversion
    * 2:16 PM 3/28/2016 - functional version, no param block
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns Shortname for specified FSO('s) to the pipeline
    .EXAMPLE
    get-childitem "C:\Program Files\DellTPad\Dell.Framework.Library.dll" | get-fsoshortname ;
    # Retrieve ShortName for a file
    .EXAMPLE
    get-childitem ${env:ProgramFiles(x86)} | get-fsoshortname ;
    Retrieve Shortname for contents of the folder specified by the 'Program Files(x86)' environment variable
    .EXAMPLE
    $blah="C:\Program Files (x86)\Log Parser 2.2","C:\Program Files (x86)\Log Parser 2.2\SyntaxerHighlightControl.dll" ;
    $blah | get-fsoshortname ;
    Resolve path specification(s) into ShortNames
    .LINK
    https://blogs.technet.microsoft.com/heyscriptingguy/2013/08/01/use-powershell-to-display-short-file-and-folder-names/
    #>
    BEGIN { $fso = New-Object -ComObject Scripting.FileSystemObject } ;
    PROCESS {
        if($_){
            $fo=$_;
            # 7:25 AM 3/29/2016 add string-path support
            switch ($fo.gettype().fullname){
                "System.IO.FileInfo" {write-output $fso.getfile($fo.fullname).ShortName}
                "System.IO.DirectoryInfo" {write-output $fso.getfolder($fo.fullname).ShortName}
                "System.String" {
                    # if it's a gci'able path, convert to fso object and then recurse back through
                    if($fio=get-childitem -Path $fo -ea 0){$fio | Get-FsoShortName }
                    else{write-error "$($fo) is a string variable, but does not reflect the location of a filesystem object"}
                }
                default { write-error "$($fo) is not a filesystem object" }
            } ;
        } else { write-error "$($fo) is not a filesystem object" } ;
    }  ;
}

#*------^ Get-FsoShortName.ps1 ^------

#*------v Get-FsoTypeObj.ps1 v------
Function Get-FsoTypeObj {
    <#
    .SYNOPSIS
    Get-FsoTypeObj()- convert file/dir object or path string to an fso obj
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Website:	URL
    Twitter:	URL
    REVISIONS   :
    * 1:37 PM 10/23/2017 Get-FsoTypeObj: simple reworking of get-fsoshortpath() to convert file/dir object or path string to an fso obj
    .DESCRIPTION
    .PARAMETER  PARAMNAME
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Resolves Dir/File/path string into an fso object
    .EXAMPLE
    Get-FsoTypeObj "C:\usr\work\exch\scripts\get-dbmbxsinfo.ps1"
    Resolve a path string into an fso file object
    .EXAMPLE
    Get-FsoTypeObj "C:\usr\work\exch\scripts\"
    Resolve a path string into an fso container object
    .EXAMPLE
    gci "C:\usr\work\exch\scripts\" | Get-FsoTypeObj ;
    Validates and returns an fso container object
    .EXAMPLE
    gci "C:\usr\work\exch\scripts\_.txt" | Get-FsoTypeObj ;
    Validates input is fso and returns an fso file object
    .LINK
    #>
    Param([Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Path or object to be resoved to fso")]$path) ;
    BEGIN {  } ;
    PROCESS {
        if($path){
            $fo=$path;
            switch ($fo.gettype().fullname){
                "System.IO.FileInfo" {$fo | write-output ; } ;
                "System.IO.DirectoryInfo" {$fo | write-output ; } ;
                "System.String" {
                    # if it's a gci'able path, convert to fso object and then recurse back through
                    if($fio=get-childitem -Path $fo -ea 0){$fio | Get-FsoTypeObj }
                    else{write-error "$($fo) is a string variable, but does not reflect the location of a filesystem object"} ;
                } ;
                default { write-error "$($fo) is not a filesystem object" } ;
            } ;
        } else { write-error "$($fo) is not a filesystem object" } ;
    }  ; # PROC-E
}

#*------^ Get-FsoTypeObj.ps1 ^------

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
Set-Alias p Pop-Location

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

#*------v openInput.ps1 v------
function openInput { $sExc = $TextEd + " " + (join-path $binpath input.txt); Invoke-Expression $sExc; }

#*------^ openInput.ps1 ^------

#*------v openTmpps1.ps1 v------
function openTmpps1 { $sExc = $TextEd + " C:\tmp\tmp.ps1"; Invoke-Expression $sExc; }

#*------^ openTmpps1.ps1 ^------

#*------v Out-Excel.ps1 v------
function Out-Excel {
    PARAM($Path = "$env:temp\$(Get-Date -Format yyyyMMddHHmmss).csv")
    $input | Export-CSV -Path $Path -UseCulture -Encoding UTF8 -NoTypeInformation
    Invoke-Item -Path $Path
}

#*------^ Out-Excel.ps1 ^------

#*------v Out-Excel-Events.ps1 v------
function Out-Excel-Events {
    PARAM($Path = "$env:temp\$(Get-Date -Format yyyyMMddHHmmss).csv")
    $input | Select -Property * |
    ForEach-Object {
        $_.ReplacementStrings = $_.ReplacementStrings -join ','
        $_.Data = $_.Data -join ','
        $_
    } | Export-CSV -Path $Path -UseCulture -Encoding UTF8 -NoTypeInformation
    Invoke-Item -Path $Path
}

#*------^ Out-Excel-Events.ps1 ^------

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

Export-ModuleMember -Function ....,...,..,~,Clean-Desktop,Compare-ObjectsSideBySide,Compare-ObjectsSideBySide3,Compare-ObjectsSideBySide4,c-winsallk,Define-MoveWindow,Get-FsoShortName,Get-FsoTypeObj,Go,gotoDbox,gotoDboxDb,gotoDownloads,gotoIncid,Move-Window,Move-WindowByWindowTitle,openInput,openTmpps1,Out-Excel,Out-Excel-Events,Report-URL,Set,show-TrayTip,Speak-words,start-ItunesPlaylist -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSBcmsP+zBkNdGHSr/m32GL/C
# 3DWgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRs1u5G
# lJ0NscO+d9AB7e5j2eAypDANBgkqhkiG9w0BAQEFAASBgHKjEwCMNcVUmNFWhWXa
# 5S3aMX2DjCdqOD2JshBTnk99w6XJcg0bzNyhRHOpDHy1j475Mg1ihpXZUy/pJnRc
# mic9sBwy+qPpwqW7HtoW6CSb5h/Qrts3OhZrhrBg/g1+es+aPpP9pRd/38Uz634i
# f4z2M6R+hTcLtPe9AbKOoZ3I
# SIG # End signature block