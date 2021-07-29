#*------v Function Set-Wallpaper v------
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
} ; #*------^ END Function Set-Wallpaper ^------