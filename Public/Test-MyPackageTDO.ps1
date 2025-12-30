# Test-MyPackageTDO.ps1


#region TEST_MYPACKAGETDO ; #*------v Test-MyPackageTDO v------
Function Test-MyPackageTDO{
    <#
    .SYNOPSIS
    Test-MyPackageTDO - Given a PackageID or pipe-delimted ('|') array of PackageIDs as used in the Registry under \Uninstall, \Products, or \Updates keys (e.g. {41D635FE-4F9D-47F7-8230-9B29D6D42D31} or KB3206632), this Tests-for/Confirms install status, and returns a string (variously the DisplayName HotfixID, or PackageName as stored on the matched key value) to the pipeline.
    .NOTES
    Version     : 0.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2025-08-15
    FileName    : Test-MyPackageTDO.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,FileSystem,Backup,Development,Build,Staging
    AddedCredit :  Michel de Rooij / michel@eightwone.com
    AddedWebsite: https://eightwone.com / https://github.com/michelderooij/Install-Exchange15
    AddedTwitter: URL
    REVISIONS  
    * 1:31 PM 12/19/2025 coded in alts to $State dep (defers to $global varis, discovered during xopBuildLibrary.psm1 load)
    * 9:10 AM 10/7/2025 added default pull via get-ciminstance, with fallback to Get-WMIObject; 
    * 11:47 AM 10/2/2025 port to C:\sc\powershell\PSScripts\build\Test-MyPackageTDO_func.ps1 - niche use, doesn't bear building into verb-io mod etc, but useful for patch verifications; also in xopBuildLibrary.psm1      
        substantially updated the CBH demos, citing specific pkg test examples that can be easily reused.
    * 11:34 AM 8/15/2025 ren: Test-MyPackage -> Test-MyPackageTDO and alias the orig name; add: CBH, fleshed out Parameter specs into formal well specified block. Added variety of working examples, for reuse adding future patches/packages to the mix.
    * 821's posted copy w/in install-Exchange15.ps1: Version 4.13, July 17th, 2025 821 install-Exchange15.ps1 func
    .DESCRIPTION
    Test-MyPackageTDO - Given a PackageID or pipe-delimted ('|') array of PackageIDs as used in the Registry under \Uninstall, \Products, or \Updates keys (e.g. {41D635FE-4F9D-47F7-8230-9B29D6D42D31} or KB3206632), this Tests-for/Confirms install status, and returns a string (variously the DisplayName HotfixID, or PackageName as stored on the matched key value) to the pipeline. 

    Usage relies on *knowing* the KBnnnnnnn number or GUID {nnDnnnFE-nFnD-nnFn-nnnn-nBnnDnDnnDnn} stored in the registry, that confirms patch/package install. 
    But with that data, this will check the stack of nested registry locations for the matching package install record.

    Self contained, has no dependancies.

    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS            
    System.String On a successful confirmation: Returns the DisplayName, HotfixID, or PackageName as stored on the matched key value
    .PARAMETER PackageID
    Microsoft KB number or {GUID} (e.g. {41D635FE-4F9D-47F7-8230-9B29D6D42D31} or KB3206632) for the update, as used in the Registry under \Uninstall, \Products, \Updates keys (used for install confirmation/detection) [-PackageID KB5057653]
    .EXAMPLE            
    PS> $PackageID = 'KB5049233' ; $PackageName = "Security Update For Exchange Server 2016 CU23 SU14 V2" ;             
    PS> if(Test-MyPackage -PackageID "KB3206632"){write-host "$($PackageID) : $($Package) is installed"} ; 
    Demo Test of Security Update For Exchange Server 2016 CU23 SU14 V2 package
    .EXAMPLE
    PS> $PackageID = "KB3206632"; $Package = "Cumulative Update for Windows Server 2016 for x64-based Systems" ; 
    PS> if(Test-MyPackage -PackageID "KB3206632"){write-host "$($PackageID) : $($Package) is installed"} ; 
    Demo Test of Cumulative Update for Windows Server 2016 kb3206632 OS patch 
    .EXAMPLE
    PS> $PackageID = "{9BCA2118-F753-4A1E-BCF3-5A820729965C}" ; $Package = "URL Rewrite Module 2.1"
    PS> if(Test-MyPackage -PackageID $PackageID){write-host "$($PackageID) : $($Package) is installed"} ; 
    Demo Test of URL Rewrite Module 2.1
    .EXAMPLE
    PS> $PackageID = "{41D635FE-4F9D-47F7-8230-9B29D6D42D31}" ; $Package = "Unified Communications Managed API 4.0 Runtime (Core)" ; 
    PS> if(Test-MyPackage -PackageID $PackageID){write-host "$($PackageID) : $($Package) is installed"} ; 
    Demo Test of Unified Communications Managed API 4.0 Runtime (Core) (from the unpacked Exchange setup ISO, blank -OnlineURL)
    .EXAMPLE
    PS> $PackageID = "{41D635FE-4F9D-47F7-8230-9B29D6D42D31}" ; $Package = "Unified Communications Managed API 4.0 Runtime" ; 
    PS> if(Test-MyPackage -PackageID $PackageID){write-host "$($PackageID) : $($Package) is installed"} ; 
    Demo Test of Unified Communications Managed API 4.0 Runtime
    .EXAMPLE
    PS> $PackageID = 'KB5049233' ; $Package = 'Security Update For Exchange Server 2019 CU14 SU3 V2' ;
    PS> if(Test-MyPackage -PackageID $PackageID){write-host "$($PackageID) : $($Package) is installed"} ; 
    Demo Test of Security Update For Exchange Server 2019 CU14 SU3 V2
    .EXAMPLE
    PS> $PackageID = 'KB5049233' ; $Package = 'Security Update For Exchange Server 2019 CU13 SU7 V2'; 
    PS> if(Test-MyPackage -PackageID $PackageID){write-host "$($PackageID) : $($Package) is installed"} ; 
    Demo Test of Security Update For Exchange Server 2019 CU13 SU7 V2
    .EXAMPLE
    PS> $PackageID = 'KB5049233' ; $Package = 'Security Update For Exchange Server 2016 CU23 SU14 V2';
    PS> if(Test-MyPackage -PackageID $PackageID){write-host "$($PackageID) : $($Package) is installed"} ; 
    Demo Test of Security Update For Exchange Server 2016 CU23 SU14 V2
    .EXAMPLE
    PS> $PackageID = 'KB5057653' ; $Package = 'Hotfix Update for Exchange Server 2016 CU23 HU16'; 
    PS> if(Test-MyPackage -PackageID $PackageID){write-host "$($PackageID) : $($Package) is installed"} ; 
    Demo Test of Hotfix Update for Exchange Server 2016 CU23 HU16          
    .LINK
    https://github.com/michelderooij/Install-Exchange15
    .LINK
    https://github.com/tostka/verb-io
    .LINK
    https://github.com/tostka/powershellbb/
    #>
    [CmdletBinding()]
    [Alias('Test-MyPackage')]
    PARAM( 
        [Parameter(HelpMessage="Microsoft KB number or {GUID} (e.g. {41D635FE-4F9D-47F7-8230-9B29D6D42D31} or KB3206632) for the update, as used in the Registry under \Uninstall, \Products, \Updates keys (used for install confirmation/detection) [-PackageID KB5057653]")]
            [String]$PackageID
    ) 
    if(-not $State -AND  -not $MajorSetupVersion -AND $global:InstalledExSetupVersion){
        $MajorSetupVersion =  "{0}.{1}" -f $global:InstalledExSetupVersion.Major,$global:InstalledExSetupVersion.Minor
    }
    $PackageSet= $PackageID.split('|')
    $PresenceKey= $null
    ForEach( $ID in $PackageSet) {
        $smsg = "Checking if package $ID is installed .."
        if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
        } ;
        if (get-command get-ciminstance -ea 0) {
            $PresenceKey = (get-ciminstance win32_quickfixengineering | Where-Object { $_.HotfixID -eq $ID }).HotfixID
        } else {
            $PresenceKey= (Get-WmiObject win32_quickfixengineering | Where-Object { $_.HotfixID -eq $ID }).HotfixID
        }
        If( -not( $PresenceKey)) {
            $PresenceKey= (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$ID" -Name 'DisplayName' -ErrorAction SilentlyContinue).DisplayName
            If(-not( $PresenceKey)) {
                # Alternative (seen KB2803754, 2802063 register here)
                $PresenceKey= (Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$ID" -Name 'DisplayName' -ErrorAction SilentlyContinue).DisplayName
                If( -not( $PresenceKey)){
                    # Alternative (eg Office2010FilterPack SP1)
                    $PresenceKey= (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$ID" -Name 'DisplayName' -ErrorAction SilentlyContinue).DisplayName
                    If( -not( $PresenceKey)){
                        # Check for installed Exchange IUs
                        if(get-variable -name State -ea 0){
                            Switch( $State["MajorSetupVersion"]) {
                                $EX2016_MAJOR {
                                    $IUPath= 'Exchange 2016'
                                }
                                default {
                                    $IUPath= 'Exchange 2019'
                                }
                            }
                        }elseif($MajorSetupVersion){
                            Switch( $MajorSetupVersion) {
                                $EX2016_MAJOR {
                                    $IUPath= 'Exchange 2016'
                                }
                                default {
                                    $IUPath= 'Exchange 2019'
                                }
                            }
                        }else{
                            $smsg = "Missing Dep vari:Neither `$State['MajorSetupVersion'] -nor `$MajorSetupVersion FOUND!"
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                            break ; 
                        } ; 
                        $PresenceKey= (Get-ItemProperty -Path ('HKLM:\Software\Microsoft\Updates\{0}\{1}' -f $IUPath, $ID) -Name 'PackageName' -ErrorAction SilentlyContinue).PackageName
                    }
                }
            }
        }
    } # loop-E
    return $PresenceKey
}
#endregion TEST_MYPACKAGETDO ; #*------^ END Test-MyPackageTDO ^------

