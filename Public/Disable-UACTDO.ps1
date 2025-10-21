# Disable-UACTDO.ps1

    #region DISABLE_UACTDO ; #*------v Disable-UACTDO v------
    function Disable-UACTDO{
        <#
        .SYNOPSIS
        Disable-UACTDO - Disables User Account Control
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Disable-UACTDO.ps1
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
        Disable-UACTDO - Disables User Account Control        
        .OUTPUTS
        None
        .EXAMPLE ; 
        PS> Disable-UAC
        .LINK
        https://github.org/tostka/verb-Desktop/
        #>
        [CmdletBinding()]
        [alias('Disable-UAC821')]
        PARAM( ) ;
        $smsg = 'Disabling User Account Control'
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLUA -Value 0 -ErrorAction SilentlyContinue| out-null
        $pltnIP=[ordered]@{
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' ;
            Name = "EnableLUA" ;
            Value = 0            
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
    } ; 
    #endregion DISABLE_UACTDO ; #*------^ END Disable-UACTDO ^------