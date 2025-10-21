# Enable-OpenFileSecurityWarningTDO.ps1

    #region ENABLE_OPENFILESECURITYWARNING ; #*------v Enable-OpenFileSecurityWarningTDO v------
    function Enable-OpenFileSecurityWarningTDO{
        <#
        .SYNOPSIS
        Enable-OpenFileSecurityWarningTDO - Restores Open File - Security Warning popup prompts.
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Enable-OpenFileSecurityWarningTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
            remove the write-my*() support (defer to native w-l support)
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
        .DESCRIPTION
        Enable-OpenFileSecurityWarningTDO - Restores Open File - Security Warning popup prompts.

        Re-enables default behavior for popups like:
        ```text
        Title: Open File - Security Warning
        [app icon]
        Name: d:\programs...\xxx.exe
        Publisher: Unknown Publisher
        Type: Application
        From: d:\programs...\xxx.exe
        [Run] [Cancel]
        [ ] Always ask before opening this file
        [x shield icon] This file does not have a valid digital signature that verifies its
        publisher. You should only run software form publishers you trust. 
        ```
        Effectively clears added entries from the LowRiskFileTypes reg key, used after completion of build/updates.        

        .OUTPUTS
        None
        .EXAMPLE ; 
        PS> Enable-OpenFileSecurityWarning
        .LINK
        https://github.org/tostka/verb-Desktop/
        #>
        [CmdletBinding()]
        [alias('Enable-OpenFileSecurityWarning821')]
        PARAM() ;
        $smsg = "Enabling File Security Warning dialog"
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' -Name 'LowRiskFileTypes' -ErrorAction SilentlyContinue
        $pltrvIP=[ordered]@{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' ;
            Name = "LowRiskFileTypes" ;          
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
        #Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' -Name 'SaveZoneInformation' -ErrorAction SilentlyContinue
        $pltrvIP=[ordered]@{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' ;
            Name = "SaveZoneInformation" ;
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
        # Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' -Name 'LowRiskFileTypes' -ErrorAction SilentlyContinue
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' ;
            Name = "LowRiskFileTypes" ;       
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
        #Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' -Name 'SaveZoneInformation' -ErrorAction SilentlyContinue
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' ;
            Name = "SaveZoneInformation" ;       
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
    } ; 
    #endregion ENABLE_OPENFILESECURITYWARNING ; #*------^ END Enable-OpenFileSecurityWarningTDO ^------