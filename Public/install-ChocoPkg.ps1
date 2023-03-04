# Install-ChocoPkg.ps1

#*------v Function Install-ChocoPkg v------
Function Install-ChocoPkg {
    <#
.SYNOPSIS
Install-ChocoPkg - runs $Packages list of choco pkgs through choco upgrade commmand (installs, if not pre-installed), parses choco exit codes and evals status.
.NOTES
Version     : 1.0.0
Author      : Todd Kadrie
Website     :	http://www.toddomation.com
Twitter     :	@tostka / http://twitter.com/tostka
CreatedDate : 2019-03-14
FileName    : Install-ChocoPkg.ps1
License     : MIT License
Copyright   : (c) 2020 Todd Kadrie
Github      : https://github.com/tostka
Tags        : Powershell
AddedCredit : REFERENCE
AddedWebsite:	URL
AddedTwitter:	URL
REVISIONS
* 12:34 PM 2/21/2023 duped into verb-desktop
* 2:09 PM 4/21/2020 added Source param (alt sources)
* 10:33 AM 3/14/2019 swap from 'choco install'/cist -> 'choco upgrade'/cup, also added the choco boxstarter path too long hack
.DESCRIPTION
.PARAMETER  Packages
Array of Chocolatey packages to Install
.PARAMETER  Source
Alternate Source [-source WindowsFeature
.PARAMETER ShowDebug
Parameter to display Debugging messages [-ShowDebug switch]
.PARAMETER Whatif
Parameter to run a Test no-change pass [-Whatif switch]
.EXAMPLE
$bRet = Install-ChocoPkg -Packages $pkgs -showdebug:$($showdebug) -whatif:$($whatif) ;
.LINK
#>
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Array of Chocolatey packages to Install")]
        [ValidateNotNullOrEmpty()][array]$Packages,
        [Parameter(HelpMessage = "Alternate Source [-source WindowsFeature")]
        [ValidateNotNullOrEmpty()][array]$Source,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) # PARAM BLOCK END

    <# underlying Choco docs:
    Exit Codes

    Exit codes that normally result from running this command.

    Normal:
    -0: operation was successful, no issues detected
    --1 or 1: an error has occurred

    Package Exit Codes:
    -1641: success, reboot initiated
    -3010: success, reboot required
    -other (not listed): likely an error has occurred

    In addition to normal exit codes, packages are allowed to exit with their own codes when the feature 'usePackageExitCodes' is turned on. Uninstall command has additional valid exit codes. Available in v0.9.10+.

    Reboot Exit Codes:
    -350: pending reboot detected, no action has occurred
    -1604: install suspended, incomplete

    In addition to the above exit codes, you may also see reboot exit codes when the feature 'exitOnRebootDetected' is turned on. It typically requires the feature 'usePackageExitCodes' to also be turned on to work properly. Available in v0.10.12+.
    -----
    $chocoMsg = (choco install $myApp -y) -join('')

    if($chocoMsg -match "install of $myApp was successful.") {
        Write-Host -fo:green 'Success'
    } else {
        # handle errors
    }
    ----------
    Use exit codes to determine status.
    Chocolatey exits with 0 when everything worked appropriately and other exits codes like 1 when things error.
    There are package specific exit codes that are recommended to be used and reboot indicating exit codes as well.
    To check exit code when using PowerShell, immediately call $exitCode = $LASTEXITCODE to get the value choco exited with.

    Alternative Sources (-source)

    Available in 0.9.10+.
    Ruby
    This specifies the source is Ruby Gems and that we are installing a
    gem. If you do not have ruby installed prior to running this command,
    the command will install that first.
    e.g. choco install compass -source ruby
    WebPI
    This specifies the source is Web PI (Web Platform Installer) and that
    we are installing a WebPI product, such as IISExpress. If you do not
    have the Web PI command line installed, it will install that first and
    then the product requested.
    e.g. choco install IISExpress --source webpi
    Cygwin
    This specifies the source is Cygwin and that we are installing a cygwin
    package, such as bash. If you do not have Cygwin installed, it will
    install that first and then the product requested.
    e.g. choco install bash --source cygwin
    Python
    This specifies the source is Python and that we are installing a python
    package, such as Sphinx. If you do not have easy_install and Python
    installed, it will install those first and then the product requested.
    e.g. choco install sphinx --source python
    Windows Features
    This specifies that the source is a Windows Feature and we should
    install via the Deployment Image Servicing and Management tool (DISM)
    on the local machine.
    e.g. choco install IIS-WebServerRole --source windowsfeatures
    #>


    $ttl = ($Packages | measure).count ;
    $Procd = 0 ;
    $smsg = "Installing $($ttl)  Packages:" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
    foreach ($pkg in $Packages) {
        $Procd++ ;
        $error.clear() ;
        $chocoMsg = $null ;
        $sBnrS = "#*------v ($($Procd)/$($ttl)):choco upgrade -y $($pkg): v------" ;
        $smsg = "$($sBnrS)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
        TRY {
            if (!$whatif) {
                if (!$Source) {
                    $chocoMsg = (choco upgrade --cacheLocation="$ChocoCachePath" -y $pkg) -join ('')
                } else {
                    $chocoMsg = (choco upgrade --cacheLocation="$ChocoCachePath" --source="$Source" -y $pkg) -join ('')
                } ;
                $exitCode = $LASTEXITCODE ;
            } else {
                if (!$Source) {
                    $chocoMsg = (choco upgrade --cacheLocation="$ChocoCachePath" -y $pkg --noop) -join ('')
                } else {
                    $chocoMsg = (choco upgrade --cacheLocation="$ChocoCachePath" --source="$Source" -y $pkg --noop) -join ('')
                } ;
                $exitCode = $LASTEXITCODE ;
            }
        } CATCH {
            $err = $_ ;
            $msg = ": Error Details: $($err)";
            Write-Error "$(get-date -format "HH:mm:ss"): FAILURE!" ;
            Write-Error "$(get-date -format "HH:mm:ss"): Error in $($err.InvocationInfo.ScriptName)." ;
            Write-Error "$(get-date -format "HH:mm:ss"): -- Error information" ;
            Write-Error "$(get-date -format "HH:mm:ss"): Line Number: $($err.InvocationInfo.ScriptLineNumber)" ;
            Write-Error "$(get-date -format "HH:mm:ss"): Offset: $($err.InvocationInfo.OffsetInLine)" ;
            Write-Error "$(get-date -format "HH:mm:ss"): Command: $($err.InvocationInfo.MyCommand)" ;
            Write-Error "$(get-date -format "HH:mm:ss"): Line: $($err.InvocationInfo.Line)" ;
            #Write-Error "$(get-date -format "HH:mm:ss"): Error Details: $($err)" ;
            $msg = ": Error Details: $($err)" ;
            Write-Error  "$(get-date -format "HH:mm:ss"): $($msg)" ;
            # 1:00 PM 1/23/2015 autorecover from fail, STOP (debug), EXIT (close), or use Continue to move on in loop cycle
            Continue ;
        }; # try/catch-E

        switch -Regex ($exitCode) {
            "0" {
                # operation was successful, no issues detected
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Operation Was Successful, No Issues Detected" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
            }
            "((-)*)1" {
                # -1/1: an error has occurred
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):An Error Has Occurred" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } ; #Error|Warn
            } ;
            "1641" {
                # 1641: success, reboot initiated
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Success, Reboot Initiated" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } ; #Error|Warn
            }
            "3010" {
                # 3010: success, reboot required
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Success, Reboot Required" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } ; #Error|Warn
            }
            "350" {
                # 350: pending reboot detected, no action has occurred
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Pending Reboot Detected, No Action Has Occurred" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } ; #Error|Warn

            }
            "1604" {
                # 1604: install suspended, incomplete
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Install Suspended, Incomplete" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } ; #Error|Warn
            }
            default {
                # other (not listed): likely an error has occurred
                $smsg = "$($pkg):`$LASTEXITCODE:$($exitCode):Unrecognized code - Likely An Error Has Occurred" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } ; #Error|Warn
            } ;
        } ;

        # 8:01 PM 3/18/2019 dump the output:
        if ($chocoMsg -match "install of $myApp was successful.") {
            Write-Host -fo:green 'Success' ;
        } else {
            # handle errors
        } ;

        if ($chocoMsg -match "A\spending\ssystem\sreboot\srequest\shas\sbeen\sdetected") {
            $smsg = "Pending Reboot detected." ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } ; #Error|Warn|Debug
            $chocoMsg -match "Chocolatey\sv\d{1,}\.\d{1,}\.\d{1,}((\s)*)(.*Upgrading\sthe\sfollowing\spackages\:\w{1,})" ;
            $OutputSummary = $matches[3] ;
        } ;
        if ($chocoMsg -match "\.\w{1,}\s\sis\snot\sinstalled.\sInstalling...") {
            $smsg = "Installing:$($matches[1])" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn|Debug
            $chocoMsg -match "Chocolatey\sv\d{1,}\.\d{1,}\.\d{1,}((\s)*)(.*\s\sis\snot\sinstalled\.\sInstalling\.)" ;
            $OutputSummary = $matches[3] ;
        } ;
        if ($chocoMsg -match "\.\w{1,}\sv.*\sis\sthe\slatest\sversion\savailable\sbased\son\syour\ssource\(s\)\.") {
            $smsg = "Latest version currently installed" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn|Debug
            $chocoMsg -match "Chocolatey\sv\d{1,}\.\d{1,}\.\d{1,}((\s)*)(.*Chocolatey\supgraded\s\d{1,}/\d{1,}\spackages\.)" ;
            $OutputSummary = $matches[3] ;
        } ;
        if ($chocoMsg -match "Installing\.\.\.\w{1,}\snot\sinstalled\.\sThe\spackage\swas\snot\sfound\swith\sthe\ssource\(s\)\slisted\.") {
            $smsg = "Installing: Not installed, the pkg was not found with the source(s) listed" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn|Debug
            $chocoMsg -match "(Chocolatey\supgraded\s\d{1,}/\d{1,}\spackages\.\s\d{1,}\spackages\sfailed\.)" ;
            $OutputSummary = $matches[1] ;
        } elseif ($chocoMsg -match "Installing\.\.\.\w{1,}\snot\sinstalled\.") {
            $smsg = "Installing: Not installed (unknown)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn|Debug
            $chocoMsg -match "Chocolatey\supgraded\s\d{1,}\/\d{1,}\spackages.\s\d{1,}\spackages\sfailed\." ;
            $OutputSummary = $matches[0] ;
        };

        #$chocoMsg -match "^Chocolatey\sv\d{1,3}\.\d{1,3}\.\d{1,3}((\s)*)(.*(Installing...|Upgrading\sthe\sfollowing\spackages).*\sis\sthe\slatest\sversion\savailable\sbased\son\syour\ssource\(s\).Chocolatey\supgraded\s\d{1,3}\/\d{1,3}\spackages)" | out-null
        #"^Chocolatey\sv\d{1,3}\.\d{1,3}\.\d{1,3}((\s)*)(.*(Installing...|Upgrading\sthe\sfollowing\spackages))"
        #"^Chocolatey\sv\d{1,3}\.\d{1,3}\.\d{1,3}\s(.*(Installing...|Upgrading\sthe\sfollowing\spackages))"
        #"^Chocolatey\sv\d{1,3}\.\d{1,3}\.\d{1,3}\s(.*Installing...)"
        # "^(Chocolatey\sv\d{1,3}\.\d{1,3}\.\d{1,3}\s.*Installing...)" | out-null ;
        #$OutputSummary=$matches[3] ;
        #$matches[1] ;

        if (!(test-path "alias:out-clipboard")) { set-alias -Name out-clipboard -Value "$($env:WINDIR)\System32\clip.exe" };
        if (!$OutputSummary) {
            $smsg = "***UNPARSED `$chocoMsg!***`n(copied to cb)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn|Debug
            $chocoMsg | out-clipboard ;
        } ;
        $smsg = "`n$($pkg):#*---v $($pkg) Output v---`n$($OutputSummary)`n#*---^ $($pkg) Output ^---`n" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn

        $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
    } ; # loop-E

} ; 
#*------^ END Function Install-ChocoPkg ^------