# Enable-RunOnceTDO.ps1


#region ENABLE_RUNONCETDO ; #*------v Enable-RunOnceTDO v------
function Enable-RunOnceTDO{
        <#
        .SYNOPSIS
        Enable-RunOnceTDO - Configures specified ScriptFullname powershell script into the local RunOnce registrykey (will autorun one time, on next startup)
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250917-0114PM
        FileName    : Enable-RunOnceTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,ActiveDirectory,Forest,Domain
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL        
        REVISIONS
        * 3:00 PM 9/18/2025 port to vdesk from xopBuildLibrary; add CBH, and Adv Function specs ; 
            add splatting on the new-itemprop, to store the settings being set;  
            remove the write-my*() support (defer to native w-l support)
        * 10:45 AM 8/6/2025 added write-myOutput|Warning|Verbose support (for xopBuildLibrary/install-Exchange15.ps1 compat) 
        .DESCRIPTION
        Enable-RunOnceTDO - Configures specified ScriptFullname powershell script into the local RunOnce registrykey (will autorun one time, on next startup)
        .PARAMETER ScriptFullName
        Powershell script fullpath to be run at next startup   
        .PARAMETER Arguments
        String of commandline Arguments to be used with specified ScriptFullName
        .INPUTS
        None, no piped input.
        .OUTPUTS
        None
        .EXAMPLE ; 
        PS> Enable-RunOnce -ScriptFullName c:\pathto\scripttorun.ps1 -Arguments $Arguments
        .LINK
        https://github.org/tostka/verb-Network/
        #>
        [CmdletBinding()]
        [alias('Enable-RunOnce821')]
        PARAM(
            [Parameter(HelpMessage = "Powershell script fullpath to be run at next startup")]
                [system.io.fileinfo]$ScriptFullName,
            [Parameter(HelpMessage = "String of commandline Arguments to be used with specified ScriptFullName")]
                [string]$Arguments
        ) ;
        $smsg = "Set script to run once after reboot" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        <# 
        ### powershell.exe commandline params:
        -NoProfile
        This is a parameter that starts a PowerShell session without loading the user's PowerShell profile scripts ($PROFILE). A profile script is a file that runs automatically when a new PowerShell session is started to customize the environment.
            Purpose: Ensures a clean, consistent PowerShell environment, which is especially useful for automated tasks, scripts, or troubleshooting.
            Command example: powershell.exe -NoProfile
        -ExecutionPolicy
        This is a parameter that sets the execution policy for a specific PowerShell session. The execution policy is a safety feature that controls the conditions under which PowerShell loads configuration files and runs scripts.
            Purpose: Temporarily overrides the system's configured execution policy for a single session.
            Command example: powershell.exe -ExecutionPolicy Bypass
            Important note: The -ExecutionPolicy parameter for powershell.exe only affects the current session and does not change the permanent system setting.
        -Command
        This parameter instructs PowerShell to run specific commands or scripts and then exit the session, unless the -NoExit parameter is also used.
            Purpose: Execute commands directly from the command line without having to open an interactive PowerShell session.
            Command example: powershell.exe -Command "& {Get-Process}"
            Usage: For complex commands or script blocks, enclose them in curly braces {}. For simple commands or scripts, you can pass them as a string.
        InstallPath
        This term refers to the location where PowerShell stores modules and is not a command-line argument for powershell.exe. You can find these paths by checking the $env:PSModulePath environment variable.
            Default module paths on Windows:
                All users: %ProgramFiles%\PowerShell\Modules (for PowerShell 7) or %ProgramFiles%\WindowsPowerShell\Modules (for Windows PowerShell 5.1).
                Current user: $HOME\Documents\PowerShell\Modules (for PowerShell 7) or $HOME\Documents\WindowsPowerShell\Modules (for Windows PowerShell 5.1).
        #>
        <# If just running script, no params, use -file:        
        –noprofile –executionpolicy bypass –file "pathtoscript.ps1" ;

        #If need passed in params use -command and '&' invoke :
        Add argument (optional): 
        –noprofile –executionpolicy bypass  -Command "& c:\scripts\hello.ps1 -a 2 -b 3"
        Use nested quote/single-quotes if needed to accom spaces in parms/paths 
        –noprofile –executionpolicy bypass  -Command "& 'c:\path with spaces\hello.ps1' -a 2 -b 3 -c 'param with spaces'" 
        -noprofile -executionpolicy Unrestricted -Command "& c:\scripts\monitor-ADAccountLock.ps1 -NoLoop -verbose"
        #>
        $cmdline = "'$($ScriptFullName.fullname)'" ;         
        #$RunOnce= "$PSHome\powershell.exe -NoProfile -ExecutionPolicy Unrestricted -Command `"& `'$ScriptFullName.fullname`' -InstallPath `'$InstallPath`'`""
        # -installpath above is the 'arguments' on the specified runonce command/script, not a required parameter of powershell
        if($Arguments){
            #$RunOnce= "$PSHome\powershell.exe -NoProfile -ExecutionPolicy Unrestricted -Command `"& `'$ScriptFullName.fullname`' $($Arguments)`""
            $cmdline += " $($Arguments) " ; 
            $RunOnce= "$PSHome\powershell.exe -NoProfile -ExecutionPolicy Unrestricted -Command $($cmdline)" ; 
        } else { 
            $RunOnce= "$PSHome\powershell.exe -NoProfile -ExecutionPolicy Unrestricted -File $($cmdline)" ; 
        }
        $smsg = "RunOnce: $RunOnce"
        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
        } ;
        # scriptname specs the key name below RunOnce, it's an arbitrary identifer for the runonce target: split the $ScriptFullName  to get the value dyn
        #New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name "$ScriptName"  -Value "$RunOnce" -ErrorAction SilentlyContinue| out-null        
        # flip to asplat        
        $pltnIP=[ordered]@{
            Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' ;
            Name = "$(split-path $ScriptFullName.fullname -leaf)" ;
            Value = "$RunOnce"            
            erroraction = 'SilentlyContinue' ; 
        } ;        
        $smsg = "New-ItemProperty w`n$(($pltnIP|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY{
            New-ItemProperty @pltnIP ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ;     
    }
#endregion ENABLE_RUNONCETDO ; #*------^ END Enable-RunOnceTDO ^------

