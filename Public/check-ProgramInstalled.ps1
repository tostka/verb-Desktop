#*------v Function check-ProgramInstalled v------
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
} #*------^ END Function check-ProgramInstalled ^------
