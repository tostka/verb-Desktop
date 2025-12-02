# show-processWindow.ps1

#*------v Function show-processWindow v------
Function show-processWindow {
    <#
    .SYNOPSIS
    show-processWindow - show specified process Window in foreground for specified -id. If an array of processes/identifiers are specified, each will be foregrounded in order specified.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2025-12-02
    FileName    : show-processWindow.ps1
    License     : MIT License
    Copyright   : (c) 2025 Todd Kadrie
    Github      : https://github.com/tostka/verb-desktop
    Tags        : Powershell,Process,Management,Reporting
    REVISIONS
    * 9:33 AM 12/2/2025 💩 🚧 init vers, wrapped & functionalized GeminiAI referred sample code, works fine in ISE, throws Method invocation failed because [Win32.NativeMethods] does not
contain a method named 'ShowWindowAsync' in native ps.
    
    .DESCRIPTION
    show-processWindow - show specified process Window in foreground for specified -process. If an array of processes/identifiers are specified, each will be foregrounded in order specified.
    Intent is to use get-process with post filtering to isolate a given window, and then use that pre-filtered spec to feed this function to foreground the application window (if exists), 
    leveraging the user32.dll SetForegroundWindow call. 
    (relies on the running powershell session having sufficient permissions/elevation to interact with the target window)
    .PARAMETER process
    Process or Process ID array : Specifies one or more processes by process ID (PID). To specify multiple IDs, use commas to separate the IDs. To find the PID of a process, type `Get-Process`.[-id 8788]
    .INPUTS
    Accepts piped input (id/pid, process object)
    .OUTPUTS
    None
    .EXAMPLE
    PS> $proc = get-process -ProcessName notepad2 | sort mainwindowtitle | ?{$_.mainwindowtitle -match 'psparamt'} ; 
    PS> if($proc){show-processWindow -process $proc -verbose} ; 
    Typical usage with a stored process object variable
    .EXAMPLE
    PS> show-processWindow -process 8788 -verbose ; 
    Typical usage specifying an id/pid for the process identifier
    PS> show-processWindow -process @('31408','8788') -verbose 
    Typical usage specifying an id/pid array for the process identifier
    .EXAMPLE
    PS> $proc = get-process -ProcessName notepad2 | sort mainwindowtitle | ?{$_.mainwindowtitle -match 'psparamt'} ; 
    PS> $proc | show-processWindow -verbose ; 
    Pipeline usage fed a stored process object variable
    .LINK
    https://github.com/tostka/verb-desktop
    #>
    [CmdletBinding()]
    [Alias('show-process')]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Process or Process ID array : Specifies one or more processes by process ID (PID). To specify multiple IDs, use commas to separate the IDs. To find the PID of a process, type `Get-Process`.[-id 8788]")]
          #[System.Int32[]]$Id
          $process
    ) ;
    BEGIN{
        # Define the Windows API functions
        #TRY{
            Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool SetForegroundWindow(IntPtr hWnd);
[DllImport("user32.dll")]
public static extern bool c(IntPtr hWnd, int nCmdShow);
'@ -Name "NativeMethods" -Namespace "Win32" ; 
        #}CATCH{} ; 
        # eat dupe load errors
    }
    PROCESS{
        foreach($proc in $process){
            switch -regex ($proc.gettype().fullname){                
                'System\.Int32\[]|System\.Int32|System\.String'{
                    $smsg = "detected -Process is System.Int32[]: assuming it's an ID/PID(s)" ; 
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    #TRY{
                        $tProc = get-process -id $proc -ea STOP ; 
                    #} CATCH {
                        $ErrTrapd=$Error[0] ;
                        write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
                        $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                        write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                     #} ;                    
                }
                'System\.Diagnostics\.Process'{
                    $smsg = "detected -Process is System.Diagnostics.Process: a process object(s)" ; 
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    $tProc = $proc ; 
                }
                'System\.Object\[]'{
                    $smsg = "detected -Process is System.Object[]: assuming it's a process object(s)" ; 
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    $tProc = $proc ; 
                }
                default{
                    $smsg = "unrecognized/unsupported `$process.gettype().fullname: $($proc.gettype().fullname)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    
                }
            }
            # Check if the process has a main window handle
            if ($tProc.MainWindowHandle -ne [System.IntPtr]::Zero) {
                # Restore the window if minimized (SW_RESTORE = 9)
                <# generating error:
                    #-=-=-=-=-=-=-=-=
                    Method invocation failed because [Win32.NativeMethods] does not contain a method named 'ShowWindowAsync'.
                    At C:\sc\verb-Desktop\Public\show-processWindow.ps1:106 char:17
                    + ...             [Win32.NativeMethods]::ShowWindowAsync($tProc.MainWindowH ...
                    +                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
                        + FullyQualifiedErrorId : MethodNotFound
                    #-=-=-=-=-=-=-=-=                
                , trycatch past to eat it (if foreground is sufficient)
                #>
                TRY{
                    [Win32.NativeMethods]::ShowWindowAsync($tProc.MainWindowHandle, 9) | Out-Null
                    $smsg = "Restore any minimized: '$($tProc.MainWindowTitle)'" ; 
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                }CATCH{} ; 
                #} CATCH {$ErrTrapd=$Error[0] ;   write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;   $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;   write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ; } ;
                
                # Set the window to the foreground
                TRY{
                    [Win32.NativeMethods]::SetForegroundWindow($tProc.MainWindowHandle) | Out-Null
                    $smsg = "Foroeground: '$($tProc.MainWindowTitle)'" ;
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                } CATCH {$ErrTrapd=$Error[0] ;   write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;   $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;   write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ; } ;
                
            } else {
                Write-Warning "Process '$($tProc.Name)' does not have a main window handle."
            } ; 
        } ; 
    }
} #*------^ END Function show-processWindow ^------
