# Set-WallpaperTDO.ps1

#region SET_WALLPAPERTDO ; #*------v Set-WallpaperTDO v------
    Function Set-WallpaperTDO {
        <# 
        .SYNOPSIS
        Set-WallpaperTDO - Set specified file as desktop wallpaper
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-
        FileName    : VERB-NOUN.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-desktop
        Tags        : Powershell,Wallpaper,Status
        AddedCredit : _Emin_
        AddedWebsite: https://p0w3rsh3ll.wordpress.com/2014/08/29/poc-tatoo-the-background-of-your-virtual-machines/
        AddedTwitter: URL
        REVISIONS   :
        * 2:59 PM 9/4/2025 strongly type params, add parameter tags and helpmessage, update CBH
        * 4:08 PM 9/3/2025 update name to new tagged standard: ren Set-Wallpaper => Set-WallpaperTDO (alias orig name)
        * 9:12 AM 6/27/2016 TSK reformatted & added pshelp
        * September 5, 2014 - posted version
        .DESCRIPTION
        .PARAMETER  Path
        Path to image to be set as desktop backgroun[-Path c:\pathto\bg.bmp]
        .PARAMETER  Style
        Wallpaper image display style (Center|Stretch|Fill|Tile|Fit, default:Stretch)[-Style Fill]
        .INPUTS
        None. Does not accepted piped input.
        .OUTPUTS
        None. Returns no objects or output.
        .EXAMPLE
        PS> Set-WallpaperTDO -Path $WallPaper.FullName -Style Fill ;
        Set wallpaper file to fill screen
        .EXAMPLE
        PS> Set-Wallpaper -Path "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -Style Fill ; 
        To Restore the default VM wallpaper (e.g. generally the Windows OS default)
        .LINK
        https://p0w3rsh3ll.wordpress.com/2014/08/29/poc-tatoo-the-background-of-your-virtual-machines/
        .LINK
        https://github.com/tostka/verb-desktop
        #>
        [CmdletBinding()]
        [Alias('Set-Wallpaper')]
        Param(
            [Parameter(Mandatory=$true,HelpMessage="Path to image to be set as desktop backgroun[-Path c:\pathto\bg.bmp]")]
                [ValidateScript({Test-Path $_ -pathtype Leaf})]
                [string]$Path,
            [Parameter(HelpMessage="Wallpaper image display style (Center|Stretch|Fill|Tile|Fit, default:Stretch)[-Style Fill]")]
                [ValidateSet('Center','Stretch','Fill','Tile','Fit')]
                [string]$Style = 'Stretch' 
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
    } ; 
    #endregion SET_WALLPAPERTDO ; #*------^ END Set-WallpaperTDO ^------