# Get-MyPackageTDO.ps1


#region GET_MYPACKAGETDO ; #*------v Get-MyPackageTDO v------
Function Get-MyPackageTDO () {
            <#
            .SYNOPSIS
            Get-MyPackageTDO - Given 1) an installable's downloaded source Url, 2) the matching downloaded installable FileName, and 3) the Path that the download should be findable within: This tests for a pre-downloaded Filename at the InstallPath specified, and if not found, downloads the specified URL (via Start-BitsTransfer), to the InstallPath\Filename. 
            .NOTES
            Version     : 0.0.1
            Author      : Todd Kadrie
            Website     : http://www.toddomation.com
            Twitter     : @tostka / http://twitter.com/tostka
            CreatedDate : 2025-08-15
            FileName    : Get-MyPackageTDO.ps1
            License     : (none asserted)
            Copyright   : (none asserted)
            Github      : https://github.com/tostka/verb-IO
            Tags        : Powershell,FileSystem,Backup,Development,Build,Staging
            AddedCredit :  Michel de Rooij / michel@eightwone.com
            AddedWebsite: https://eightwone.com / https://github.com/michelderooij/Install-Exchange15
            AddedTwitter: URL
            REVISIONS
            * 11:34 AM 8/15/2025 ren: Get-MyPackage -> Get-MyPackageTDO and alias the orig name;  add: CBH, fleshed out Parameter specs into formal well specified block. Added variety of working examples, for reuse adding future patches/packages to the mix.
            * 821's posted copy w/in install-Exchange15.ps1: Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func
            .DESCRIPTION
            Get-MyPackageTDO - Given 1) an installable's downloaded source Url, 2) the matching downloaded installable FileName, and 3) the Path that the download should be findable within: This tests for a pre-downloaded Filename at the InstallPath specified, and if not found, downloads the specified URL (via Start-BitsTransfer), to the InstallPath\Filename. 

            .INPUTS
            None. Does not accepted piped input.(.NET types, can add description)
            .OUTPUTS            
            System.Boolean
            .PARAMETER Package
            Microsoft's description for the update (used to echo status updates to log & console)[-Package 'Hotfix Update for Exchange Server 2016 CU23 HU16']
            .PARAMETER URL
            Microsoft's direct download URL for direct download, if local copy is unavailable (unprompted, no confirm prompt; may need to research into scripting & desktop automation cites to find the working url)[-URL 'https://download.microsoft.com/download/1dcdfa24-ef09-483e-871e-28e699c7327c/Exchange2016-KB5057653-x64-en.exe']
            .PARAMETER FileName
            Microsoft's filename for the downloaded file (used to check for local copy and avoid redownload)[-FileName 'Exchange2016-KB5057653-x64-en.exe']
            .PARAMETER InstallPath
            Parent directory path containing target .msu|.msi|.msp|.exe etc [-InstallPath c:\pathto\]
            .EXAMPLE
            PS> Get-MyPackageTDO -Package "Microsoft .NET Framework 4.8.1" -FileName "NDP481-x86-x64-AllOS-ENU.exe" '' -FileName "NDP481-x86-x64-AllOS-ENU.exe" -InstallPath $RunFrom
            Demo Test of .NET Framework 4.8.1 package             
            .LINK
            https://github.com/michelderooij/Install-Exchange15
            .LINK
            https://github.com/tostka/verb-io
            .LINK
            https://github.com/tostka/powershellbb/
            #>
            [CmdletBinding()]
            [Alias('Get-MyPackage')]
            PARAM ( 
                [Parameter(Position=0, HelpMessage="Microsoft's description for the update (used to echo status updates to log & console)[-Package 'Hotfix Update for Exchange Server 2016 CU23 HU16']")]
                    [string]$Package, 
                [Parameter(Position=1, HelpMessage="Microsoft's direct download URL for direct download, if local copy is unavailable (unprompted, no confirm prompt; may need to research into scripting & desktop automation cites to find the working url)[-URL 'https://download.microsoft.com/download/1dcdfa24-ef09-483e-871e-28e699c7327c/Exchange2016-KB5057653-x64-en.exe']")]
                    [String]$URL, 
                [Parameter(Position=2, HelpMessage="Microsoft's filename for the downloaded file (used to check for local copy and avoid redownload)[-FileName 'Exchange2016-KB5057653-x64-en.exe']")]
                    [String]$FileName, 
                [Parameter(Position=3, HelpMessage="Parent directory path containing target .msu|.msi|.msp|.exe etc [-InstallPath c:\pathto\]")]
                    [String]$InstallPath
            )
            $res= $true
            If( -not( Test-Path $(Join-Path $InstallPath $Filename))) {
                If( $URL) {
                    $smsg = "Package $Package not found, downloading to $FileName"
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    Try{
                        $smsg = "Source: $URL"
                        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                        } ;
                        Start-BitsTransfer -Source $URL -Destination $(Join-Path $InstallPath $Filename)
                    }
                    Catch{
                        $smsg = "Problem downloading package from URL"
                        if(gcm Write-MyError -ea 0){Write-MyError $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} else{ write-ERROR "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        $res= $false
                    }
                }
                Else {
                    $smsg = "$FileName not present, skipping"
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                    $res= $false
                }
            }
            Else {
                $smsg = "Located $Package ($InstallPath\$FileName)"
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                    if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                } ;
            }
            Return $res
        }
#endregion GET_MYPACKAGETDO ; #*------^ END Get-MyPackageTDO ^------

