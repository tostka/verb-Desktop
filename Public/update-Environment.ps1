#*------v update-Environment.ps1 v------
function update-Environment {
    <#
    .SYNOPSIS
    update-Environment - Refresh environment variables from the registry for powershell.exe. (wraps choco's refreshenv -> chocolateyProfile\Update-SessionEnvironment)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20250303-1230PM
    FileName    : update-Environment
    License     : MIT License
    Copyright   : (c) 2024 Todd Kadrie
    Github      : https://github.com/tostka/verb-dev
    Tags        : Powershell,ISE,development,debugging,backup
    REVISIONS
	* 12:30 PM 3/3/2025 init
    .DESCRIPTION
    update-Environment - Refresh environment variables from the registry for powershell.exe. (wraps choco's refreshenv -> chocolateyProfile\Update-SessionEnvironment)

	Simple easily recalled mnenomic verb-noun wrapper for chocolatey's native 'refreshenv' command (which is an alias of  chocolateyProfile\Update-SessionEnvironment)
	
    .EXAMPLE
    PS> update-Environment ;
    
		Refreshing environment variables from the registry for powershell.exe. Please wait...
		Finished		

    Update powershell session enivronment variables
    .LINK
    https://github.com/tostka/verb-desktop
    #>
    [CmdletBinding()]
    #[Alias('')]
    PARAM() ;
	#if(-not (get-module chocolateyprofile -list )){
	if(-not (get-command Update-SessionEnvironment) -AND -not (get-command choco.exe)){
		throw "Missing dependant module!" ; 
	} else {
		Update-SessionEnvironment -verbose; 
	}; 
}; 
#*------^ update-Environment.ps1 ^------
