# New-WallpaperStatusTDO.ps1


#region NEW_WALLPAPERSTATUSTDO ; #*------v New-WallpaperStatusTDO v------
Function New-WallpaperStatusTDO {
        <# 
        .SYNOPSIS
        New-WallpaperStatusTDO - Create desktop wallpaper with specified text overlaid over specified image or background color (PS Bginfo.exe alternative)
        .NOTES
        Version     : 1.0.4
        Author      : Todd Kadrie
        Website     :	http://www.toddomation.com
        Twitter     :	@tostka / http://twitter.com/tostka
        CreatedDate : 2020-06-27
        FileName    : New-WallpaperStatusTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-Desktop
        Tags        : Powershell
        AddedCredit : _Emin_
        AddedWebsite:	https://p0w3rsh3ll.wordpress.com/
        AddedTwitter:	URL
        REVISIONS   :
        * 4:08 PM 9/3/2025 update name to new tagged standard: ren Set-Wallpaper => Set-WallpaperTDO (alias orig name)
        # 10:46 AM 7/29/2021 ren'd New-BGinfo -> New-WallpaperStatus (stuck orig in Alias); added updated Win10 PS console color scheme colors to themes list (they're precurated 'suitable' colors) ; 
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
        New-WallpaperStatusTDO - Create desktop wallpaper with specified text overlaid over specified image or background color (PS Bginfo.exe alternative)
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
        PS> $BGInfo = @{
        PS>     Text  = $t ;
        PS>     Theme = "Black" ;
        PS>     FontName = "courier new" ;
        PS>     UseCurrentWallpaperAsSource = $false ;
        PS> } ; 
        PS> $WallPaper = New-WallpaperStatusTDO @BGInfo ;
        Generate a wallpaper from  a splat of parameters        
        .LINK
        https://p0w3rsh3ll.wordpress.com/2014/08/29/poc-tatoo-the-background-of-your-virtual-machines/
        .LINK
        https://github.com/tostka/verb-Desktop
        #>
        [CmdletBinding()]
        [Alias('New-BGinfo','New-WallpaperStatus')]
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
                Get-Item -Path $OutFile | write-output ; 
            } Catch {
                Write-Warning -Message "Failed to $($_.Exception.Message)" ; 
                break ; 
            } ; 
        } ;  # END-E
    }
#endregion NEW_WALLPAPERSTATUSTDO ; #*------^ END New-WallpaperStatusTDO ^------

