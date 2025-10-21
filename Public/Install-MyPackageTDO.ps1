# Install-MyPackageTDO.ps1


#region INSTALL_MYPACKAGETDO ; #*------v Install-MyPackageTDO v------
Function Install-MyPackageTDO {
            <#
            .SYNOPSIS
            Install-MyPackageTDO - MS patch/update installer, wraps Invoke-Process
            .NOTES
            Version     : 0.0.1
            Author      : Todd Kadrie
            Website     : http://www.toddomation.com
            Twitter     : @tostka / http://twitter.com/tostka
            CreatedDate : 2025-08-14
            FileName    : Install-MyPackageTDO.ps1
            License     : MIT License
            Copyright   : (c) 2025 Todd Kadrie
            Github      : https://github.com/tostka/verb-XXX
            Tags        : Powershell,FileSystem,Backup,Development,Build,Staging
            AddedCredit :  Michel de Rooij / michel@eightwone.com
            AddedWebsite: eightwone.com
            AddedTwitter: URL
            REVISIONS
            * 10:48 AM 10/6/2025 reworked demos; add var code for lack of $State[]; add alias Install-MyPackage
            * 12:06 PM 10/2/2025 ren Install-MyPackage -> Install-MyPackageTDO, alias original & 821 variant
            *11:15 AM 8/15/2025 add:explicit Position tags to params (PS default assumes in decl order, this codifies); fixed CBH param specs errors; brought in deferring $script varis from source; add: optional -FilePath, to backfill where $script scope $State['InstallPath'] isn't populated.
            * 5:17 PM 8/14/2025 add: CBH, fleshed out Parameter specs into formal well specified block. Added variety of working examples, for reuse adding future patches/packages to the mix.
            * 821's posted copy w/in install-Exchange15.ps1: Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func
            .DESCRIPTION
            Install-MyPackageTDO - MS patch/update installer, wraps Invoke-Process: Deps: Test-MyPackage, Get-MyPackage, Invoke-Extract, Write-MyOutput, Write-MyError, Write-MyVerbose'

            Tweaked variant of 821's function from his Install-Exchange15.ps1 script.
            
            ## DEMO update for a new package:

            # add the Exchange 2016 HU16 hotfix, sample at D:\cab\Ex2016CU23HU16-KB5057653\Exchange2016-KB5057653-x64-en.exe

            1. -PackageID: KBnnnnnn number - this is used by Test-MyPackage to do an HKLM reg install search, to verify install/pre-install. 
            2. -Package: Descriptive string from the KB doc article (used to echo/log status info).
            3. -FileName: copy the leaf filename to the filename spec;
            4. -OnlineURL: Hunt up an actual non-interactive download url from a scripting DSC/system automation forum or site. 
                (Doesn't work: find the spec page for it, click through the MSdownload link and grab the link on the download btn)
            5. -Arguments: suitable native install arguments supported by the package download (see other examples, or the package silent/passive installation docs).
            6. -NoDownload: seldom used, simply overrules existing package filename test, attempts to run the install direct from the download OnlineUrl (does not skip downloading, in spite of the name)  
            7. -FilePath: is an optional fall back outside of install-Exchange15.ps1 use, where InstallPath, $State['InstallPath'] is used as the RunFrom. 
                This is the directory the install package download is hosted from (or will be downloaded to).
              
            ```powershell
            PS> $PresenceKey= Test-MyPackage $PackageID ; 
            ```
            Test that checks for target kbnnnnn/guid

            [Download the package now](https://www.microsoft.com/download/details.aspx?familyID=1dcdfa24-ef09-483e-871e-28e699c7327c)
            => [Download](https://download.microsoft.com/download/1dcdfa24-ef09-483e-871e-28e699c7327c/Exchange2016-KB5057653-x64-en.exe)
           
            Raw download redirs into a form as: [Download](https://download.microsoft.com/download/1dcdfa24-ef09-483e-871e-28e699c7327c/Exchange2016-KB5057653-x64-en.exe)
            THATS the dl url, use it.

            ### Constructed call for the above:
            ```powershell
            PS> Install-MyPackageTDO -PackageID 'KB5057653' -Package 'Hotfix Update for Exchange Server 2016 CU23 HU16' -FileName 'Exchange2016-KB5057653-x64-en.exe' -OnlineURL 'https://download.microsoft.com/download/1dcdfa24-ef09-483e-871e-28e699c7327c/Exchange2016-KB5057653-x64-en.exe' -Arguments ('/passive')
            ```

            ###Splatted call
            ```powershell
            $pltisPkg=[ordered]@{
                PackageID = 'KB5057653' ;
                Package = 'Hotfix Update for Exchange Server 2016 CU23 HU16' ;
                FileName = 'Exchange2016-KB5057653-x64-en.exe' ;
                OnlineURL = 'https://download.microsoft.com/download/1dcdfa24-ef09-483e-871e-28e699c7327c/Exchange2016-KB5057653-x64-en.exe' ;
                Arguments = ('/passive') ; 
            } ;
            $smsg = "Install-MyPackageTDO w`n$(($pltisPkg|out-string).trim())" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            Install-MyPackageTDO @pltisPkg ; 
            ```

            .INPUTS
            None. Does not accepted piped input.(.NET types, can add description)
            .OUTPUTS
            None. Returns no objects or output (.NET types)
            
            .PARAMETER PackageID
            Microsoft KB number or {GUID} (e.g. {41D635FE-4F9D-47F7-8230-9B29D6D42D31} or KB3206632) for the update as used in the Registry under \Uninstall, \Products, \Updates keys (used for install confirmation/detection) [-PackageID KB5057653]
            .PARAMETER Package
            Microsoft's description for the update (used to echo status updates to log & console)[-Package 'Hotfix Update for Exchange Server 2016 CU23 HU16']            
            .PARAMETER FileName
            Filename of target .msu|.msi|.msp|.exe etc [-FileName 'some.exe']
            .PARAMETER Arguments
            Suitable native .msu|.msi|.msp|.exe package parameters for a silent/passive install etc (those supported by the patch itself) [-Arguments ('/passive')]
            .PARAMETER NoDownload
            Switch to suppress download behavior (Doesn't suppress the download, assumes there's no downlaoded local copy: split-paths the -OnlineURL parent into a RunFrom to be Invoke-Process() installed)[-FilePath c:\pathto\]  
            PARAMETER .FilePath
            Optional: Parent directory path containing target file to be installed (install-Exchange15.ps1 defaults to `$State['InstallPath'])[-FilePath c:\pathto\]
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID "-" -Package "Microsoft .NET Framework 4.8.1" -FileName "NDP481-x86-x64-AllOS-ENU.exe" -OnlineURL "https://download.microsoft.com/download/4/b/2/cd00d4ed-ebdd-49ee-8a33-eabc3d1030e3/NDP481-x86-x64-AllOS-ENU.exe" -Arguments ("/q", "/norestart")            
            Demo install of .NET Framework 4.8.1
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID "KB3206632" -Package "Cumulative Update for Windows Server 2016 for x64-based Systems" -FileName "windows10.0-kb3206632-x64_b2e20b7e1aa65288007de21e88cd21c3ffb05110.msu" -OnlineURL "http://download.windowsupdate.com/d/msdownload/update/software/secu/2016/12/windows10.0-kb3206632-x64_b2e20b7e1aa65288007de21e88cd21c3ffb05110.msu" -Arguments ("/quiet", "/norestart")
            Demo install of Cumulative Update for Windows Server 2016 kb3206632 OS patch 
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID "" -Package "Visual C++ 2012 Redistributable" -FileName "vcredist_x64_2012.exe" -OnlineURL "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe" -Arguments ("/install", "/quiet", "/norestart")
            Demo install of Visual C++ 2012 Redistributable
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID "" -Package "Visual C++ 2013 Redistributable" -FileName "vcredist_x64_2013.exe" -OnlineURL "https://aka.ms/highdpimfc2013x64enu" -Arguments ("/install", "/quiet", "/norestart")
            Demo install of Visual C++ 2013 Redistributable
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID "{9BCA2118-F753-4A1E-BCF3-5A820729965C}" -Package "URL Rewrite Module 2.1" -FileName "rewrite_amd64_en-US.msi" -OnlineURL "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" -Arguments ("/quiet", "/norestart")
            Demo install of URL Rewrite Module 2.1
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID "{41D635FE-4F9D-47F7-8230-9B29D6D42D31}" -Package "Unified Communications Managed API 4.0 Runtime (Core)" -FileName "Setup.exe" (Join-Path -Path $State['SourcePath'] -ChildPath 'UcmaRedist\Setup.exe') -OnlineURL "" -Arguments ("/passive", "/norestart") -NoDownload
            Demo install of Unified Communications Managed API 4.0 Runtime (Core) (from the unpacked Exchange setup ISO, blank -OnlineURL)
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID "{41D635FE-4F9D-47F7-8230-9B29D6D42D31}" -Package "Unified Communications Managed API 4.0 Runtime" -FileName "UcmaRuntimeSetup.exe" -OnlineURL "https://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe" -Arguments ("/passive", "/norestart")
            Demo install of Unified Communications Managed API 4.0 Runtime
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID "" -Package "Microsoft Edge Enterprise x64" -FileName "MicrosoftEdgeEnterpriseX64.msi" -OnlineURL "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/35f200dc-46f7-46fc-8f97-f29bf1babe1e/MicrosoftEdgeEnterpriseX64.msi" -Arguments @("/quiet", "/norestart") -NoDownload:$false
            Demo install of Microsoft Edge Enterprise x64
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID 'KB5049233' -Package 'Security Update For Exchange Server 2019 CU14 SU3 V2' -FileName 'Exchange2019-KB5049233-x64-en.exe' 'https://download.microsoft.com/download/8/0/b/80b356e4-f7b1-4e11-9586-d3132a7a2fc3/Exchange2019-KB5049233-x64-en.exe' -Arguments ('/passive')
            Demo install of Security Update For Exchange Server 2019 CU14 SU3 V2
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID 'KB5049233' -Package 'Security Update For Exchange Server 2019 CU13 SU7 V2' -FileName 'Exchange2019-KB5049233-x64-en.exe' -OnlineURL 'https://download.microsoft.com/download/4/e/5/4e5cbbcc-5894-457d-88c4-c0b2ff7f208f/Exchange2019-KB5049233-x64-en.exe' -Arguments ('/passive')
            Demo install of Security Update For Exchange Server 2019 CU13 SU7 V2
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID 'KB5049233' -Package 'Security Update For Exchange Server 2016 CU23 SU14 V2' -FileName 'Exchange2016-KB5049233-x64-en.exe' -OnlineURL 'https://download.microsoft.com/download/0/9/9/0998c26c-8eb6-403a-b97a-ae44c4db5e20/Exchange2016-KB5049233-x64-en.exe' -Arguments ('/passive')
            Demo install of Security Update For Exchange Server 2016 CU23 SU14 V2
            .EXAMPLE
            PS> Install-MyPackageTDO -PackageID 'KB5057653' -Package 'Hotfix Update for Exchange Server 2016 CU23 HU16' -FileName 'Exchange2016-KB5057653-x64-en.exe' -OnlineURL 'https://download.microsoft.com/download/1dcdfa24-ef09-483e-871e-28e699c7327c/Exchange2016-KB5057653-x64-en.exe' -Arguments ('/passive')
            Demo install of Hotfix Update for Exchange Server 2016 CU23 HU16
            .LINK
            https://github.com/tostka/verb-dev
            .LINK
            https://github.com/tostka/powershellbb/
            #>
            [CmdletBinding()]
            [Alias('Install-MyPackage')]
            PARAM ( 
                [Parameter(Position=0, HelpMessage="Microsoft KB number or {GUID} (e.g. {41D635FE-4F9D-47F7-8230-9B29D6D42D31} or KB3206632) for the update as used in the Registry under \Uninstall, \Products, \Updates keys (used for install confirmation/detection) [-PackageID KB5057653]")]
                    [String]$PackageID, 
                [Parameter(Position=1, HelpMessage="Microsoft's description for the update (used to echo status updates to log & console)[-Package 'Hotfix Update for Exchange Server 2016 CU23 HU16']")]
                    [string]$Package, 
                [Parameter(Position=2, HelpMessage="Microsoft's filename for the downloaded file (used to check for local copy and avoid redownload)[-FileName 'Exchange2016-KB5057653-x64-en.exe']")]
                    [String]$FileName, 
                [Parameter(Position=3, HelpMessage="Microsoft's direct download URL for direct download, if local copy is unavailable (unprompted, no confirm prompt; may need to research into scripting & desktop automation cites to find the working url)[-OnlineURL 'https://download.microsoft.com/download/1dcdfa24-ef09-483e-871e-28e699c7327c/Exchange2016-KB5057653-x64-en.exe']")]
                    [String]$OnlineURL, 
                [Parameter(Position=4, HelpMessage="Suitable native .msu|.msi|.msp|.exe package parameters for a silent/passive install etc (those supported by the patch itself) [-Arguments ('/passive')]")]
                    [array]$Arguments, 
                [Parameter(Position=5, HelpMessage="Switch to suppress download behavior (Doesn't suppress the download, assumes there's no downlaoded local copy: split-paths the -OnlineURL parent into a RunFrom to be Invoke-Process() installed)[-FilePath c:\pathto\]")]
                    [switch]$NoDownload,
                [Parameter(Position=6, HelpMessage="Optional: Parent directory path containing target file to be installed (install-Exchange15.ps1 defaults to `$State['InstallPath'])[-FilePath c:\pathto\]")]
                    [string]$FilePath
            )
            # dependant constants            
            if(-not $ERR_PROBLEMPACKAGESETUP){$ERR_PROBLEMPACKAGESETUP        = 1121} ; 
            if(-not $ERR_PROBLEMPACKAGEDL){$ERR_PROBLEMPACKAGEDL           = 1120};
            if(-not $ERR_PROBLEMPACKAGEEXTRACT){$ERR_PROBLEMPACKAGEEXTRACT      = 1122};
                        
            If( $PackageID) {
                $smsg = "Processing $Package ($PackageID)"
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } ;
                # pretest for installation: 
                $PresenceKey= Test-MyPackage $PackageID
            }
            Else {
                # Just install, don't detect
                $smsg = "Processing $Package"
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } ;
                $PresenceKey= $false
            }
            #$RunFrom= $State['InstallPath']
            # $State['InstallPath'] is a hashtable configured by install-Exchange15-TTC.ps1. In it's absence, fall back to local -FilePath.
            if($State['InstallPath']){
                $RunFrom= $State['InstallPath']
            }elseif($FilePath){
                $RunFrom = $FilePath
            }else{
                $smsg = "Neither `$State['InstallPath'] found, nor -FilePath specified!`nPlease specify at least one of the two!"
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
                Exit "No RunFrom/InstallPath/FilePath specified" ; 
            }
            If( -not( $PresenceKey )){

                If( $FileName.contains('|')) {
                    # Filename contains filename (dl) and package name (after extraction)
                    $PackageFile= ($FileName.Split('|'))[1]
                    $FileName= ($FileName.Split('|'))[0]
                    If( -not( Get-MyPackage $Package '' $FileName $RunFrom)) {
                        # Download & Extract
                        If( -not( Get-MyPackage $Package $OnlineURL $PackageFile $RunFrom)) {
                            $smsg = "Problem downloading/accessing $Package"
                            if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                            Exit $ERR_PROBLEMPACKAGEDL
                        }
                        $smsg = "Extracting Hotfix Package $Package"
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        Invoke-ExtractTDO $RunFrom $PackageFile

                        If( -not( Get-MyPackage $Package $OnlineURL $PackageFile $RunFrom)) {
                            $smsg = "Problem downloading/accessing $Package"
                            if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                            Exit $ERR_PROBLEMPACKAGEEXTRACT
                        }
                    }
                }
                Else {
                    If( $NoDownload) {
                        $RunFrom= Split-Path -Path $OnlineURL -Parent
                        $smsg = "Will run $FileName straight from $RunFrom"
                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                        } ;

                    }
                    If( -not( Get-MyPackage $Package $OnlineURL $FileName $RunFrom)) {
                        $smsg = "Problem downloading/accessing $Package"
                        if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        Exit $ERR_PROBLEMPACKAGEDL
                    }
                }

                $smsg = "Installing $Package from $RunFrom"
                if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } ;
                $rval= Invoke-ProcessTDO $RunFrom $FileName $Arguments

                If( $PackageID) {
                    $PresenceKey= Test-MyPackage $PackageID
                }
                Else {
                    # Don't check post-installation
                    $PresenceKey= $true
                }
                If( ( @(3010,-2145124329) -contains $rval) -or $PresenceKey)  {
                    switch ( $rval) {
                        3010: {
                            $smsg = "Installation $Package successful, reboot required"
                            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                        }
                        -2145124329: {
                            $smsg = "$Package not applicable or blocked - ignoring"
                            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                        }
                        default: {
                            $smsg = "Installation $Package successful"
                            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ;
                        }
                    }
                }
                Else {
                    $smsg = "Problem installing $Package - For fixes, check $($ENV:WINDIR)\WindowsUpdate.log; For .NET Framework issues, check 'Microsoft .NET Framework 4 Setup' HTML document in $($ENV:TEMP)"
                    if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    Exit $ERR_PROBLEMPACKAGESETUP
                }
            }
            Else {
                $smsg = "$Package already installed"
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
            }
        }
#endregion INSTALL_MYPACKAGETDO ; #*------^ END Install-MyPackageTDO ^------

