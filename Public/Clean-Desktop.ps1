    #*------v Function Clean-Desktop v------
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

    } ; #*------^ END Function Clean-Desktop ^------