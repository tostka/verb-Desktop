# Disable-AutoLogonTDO.ps1


#region DISABLE_AUTOLOGONTDO ; #*------v Disable-AutoLogonTDO v------
function Disable-AutoLogonTDO{
        <#
        .SYNOPSIS
        Disable-AutoLogonTDO - Deconfigures autologon of the specified credential, after reboots (reverses Enable-AutoLogon821))
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Disable-AutoLogonTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-desktop
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
            remove the write-my*() support (defer to native w-l support)
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
        .DESCRIPTION
        Disable-AutoLogonTDO - Deconfigures autologon of the specified credential, after reboots (reverses Enable-AutoLogon821))
        .PARAMETER Credential
        Use specific Credentials[-Credentials [credential object]
        .OUTPUTS
        None
        .EXAMPLE ; 
        PS> Disable-AutoLogon
        .LINK
        https://github.org/tostka/verb-Desktop/
        #>
        [CmdletBinding()]
        [alias('Disable-AutoLogon821')]
        PARAM() ;
        $smsg = 'Disabling Automatic Logon'
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -ErrorAction SilentlyContinue| out-null
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' ;
            Name = "AutoAdminLogon" ;          
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "Remove-ItemProperty w`n$(($pltrvIP|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            Remove-ItemProperty @pltrvIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ; 
        #Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -ErrorAction SilentlyContinue| out-null
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' ;
            Name = "DefaultUserName" ;
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "Remove-ItemProperty w`n$(($pltrvIP|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            Remove-ItemProperty @pltrvIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;  
        # Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -ErrorAction SilentlyContinue| out-null
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' ;
            Name = "DefaultPassword" ;       
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "Remove-ItemProperty w`n$(($pltrvIP|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            Remove-ItemProperty @pltrvIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;
    }
#endregion DISABLE_AUTOLOGONTDO ; #*------^ END Disable-AutoLogonTDO ^------

