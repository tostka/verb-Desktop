# Disable-OpenFileSecurityWarningTDO.ps1

    #region DISABLE_OPENFILESECURITYWARNINGTDO ; #*------v Disable-OpenFileSecurityWarningTDO v------
    function Disable-OpenFileSecurityWarningTDO{
        <#
        .SYNOPSIS
        Disable-OpenFileSecurityWarningTDO - Suppresses Open File - Security Warning popup prompts
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Disable-OpenFileSecurityWarningTDO.ps1
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
        Disable-OpenFileSecurityWarningTDO - Suppresses Open File - Security Warning popup prompts        
        .OUTPUTS
        None
        .EXAMPLE ; 
        PS> Disable-OpenFileSecurityWarning
        .LINK
        https://github.org/tostka/verb-Desktop/
        #>
        [CmdletBinding()]
        [alias('Disable-OpenFileSecurityWarning821')]
        PARAM() ;
        $smsg = 'Disabling File Security Warning dialog'
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        # New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' -ErrorAction SilentlyContinue |out-null
        $pltnItm=[ordered]@{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' ;                       
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "New-Item w`n$(($pltnItm|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            New-Item @pltnItm | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;  
        #New-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' -name 'LowRiskFileTypes' -value '.exe;.msp;.msu;.msi' -ErrorAction SilentlyContinue |out-null
        $pltnIP=[ordered]@{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' ;
            Name = "LowRiskFileTypes" ;
            Value = '.exe;.msp;.msu;.msi' ;            
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "New-ItemProperty w`n$(($pltnIP|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            New-ItemProperty @pltnIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;  
        #New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' -ErrorAction SilentlyContinue |out-null
        $pltnItm=[ordered]@{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' ;                       
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "New-Item w`n$(($pltnItm|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            New-Item @pltnItm | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;  
        #New-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' -name 'SaveZoneInformation' -value 1 -ErrorAction SilentlyContinue |out-null
        $pltnIP=[ordered]@{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' ;
            Name = "SaveZoneInformation" ;
            Value = 1 ;            
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "New-ItemProperty w`n$(($pltnIP|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            New-ItemProperty @pltnIP | out-null ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;  
        # Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' -Name 'LowRiskFileTypes' -ErrorAction SilentlyContinue
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations' ;   
            Name = 'LowRiskFileTypes' ;
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
        # Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' -Name 'SaveZoneInformation' -ErrorAction SilentlyContinue
        $pltrvIP=[ordered]@{
            Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments' ;   
            Name = 'SaveZoneInformation' ; 
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
    #endregion DISABLE_OPENFILESECURITYWARNINGTDO ; #*------^ END Disable-OpenFileSecurityWarningTDO ^------