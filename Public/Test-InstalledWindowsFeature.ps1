#*------v Function Test-InstalledWindowsFeature v------
function Test-InstalledWindowsFeature {
	<#
    .SYNOPSIS
    Test-InstalledWindowsFeature - Check for Installed status of specified WindowsFeature
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : Test-InstalledWindowsFeature.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
    REVISIONS
    * 10:37 AM 11/11/2022 init vers
    .DESCRIPTION
    Test-InstalledWindowsFeature - Check for Installed status of specified WindowsFeature
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean
    .EXAMPLE    
    PS> Test-InstalledWindowsFeature -FeatureName 'RSAT-AD-Tools'
    Test for feature installation
    .LINK
    https://github.com/tostka/verb-io
    #>
	PARAM(
		[Parameter(Mandatory=$True,HelpMessage="WindowsFeature name to be Tested for installation[-FeatureName RSAT-AD-Tools")]
		$FeatureName
	) ; 
	[boolean]$(Get-WindowsFeature $FeatureName).Installed | write-output ; 
} ; 
#*------^ END Function Test-InstalledWindowsFeature ^------