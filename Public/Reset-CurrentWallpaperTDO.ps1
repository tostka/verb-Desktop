# Reset-CurrentWallpaperTDO.ps1

#region RESET_CURRENTWALLPAPERTDO ; #*------v Reset-CurrentWallpaperTDO v------
Function Reset-CurrentWallpaperTDO {
    <#
    .SYNOPSIS
    Reset-CurrentWallpaperTDO - Tests for, and clears any configured HKCU:\Control Panel\Desktop WallPaper Value to $NULL, and refreshes the desktop
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2025-07-30
    FileName    : Reset-CurrentWallpaperTDO.ps1
    License     : MIT License
    Copyright   : (c) 2025 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Math,Round,Ceiling,Floor,Truncate,Number,Decimal
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 4:06 PM 9/3/2025 init
    .DESCRIPTION
    Reset-CurrentWallpaperTDO - Tests for, and clears any configured HKCU:\Control Panel\Desktop WallPaper Value to $NULL, and refreshes the desktop
    .OUTPUT
    System.Boolean Returns True if it found the key populated, and cleared it. Returns False if no change was made.
    .EXAMPLE
    PS> $result = Reset-CurrentWallpaperTDO 
    Demo call
    .LINK
    https://github.com/tostka/verb-desktop
    #>
    PARAM()
    PROCESS{
        $CurrentWallPaperValue = (Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallPaper").WallPaper ; 
        if($CurrentWallPaperValue){
            $smsg = "HKCU:\Control Panel\Desktop\ WallPaper Value is currently set to: $($CurrentWallPaperValue)" ;
            if(test-path -path $CurrentWallPaperValue -PathType Leaf){
                $smsg += "`n(which exists)" ;                    
            } else{
                $smsg += "`n(which does not exist)" ;
            }; 
            $smsg += "`nClearing the value..." ;
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallPaper" -Value $NULL -verbose ; 
            $CurrentWallPaperValue = (Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallPaper").WallPaper ; 
            $smsg = "HKCU:\Control Panel\Desktop\ WallPaper value is now set: $($CurrentWallPaperValue)" ;
            $smsg += "`nIssuing desktop reset:rundll32.exe user32.dll, UpdatePerUserSystemParameters..." ;
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;              
            } ;
            rundll32.exe user32.dll, UpdatePerUserSystemParameters ; 
        } else{
            $smsg = "HKCU:\Control Panel\Desktop\ WallPaper Value is currently UNSET (NULL) (no change)" ; 
            if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;
        } ; 
    }
} ; 
#endregion RESET_CURRENTWALLPAPERTDO ; #*------^ END Reset-CurrentWallpaperTDO ^------
