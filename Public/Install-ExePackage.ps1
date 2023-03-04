#*------v Function Install-ExePackage v------
function Install-ExePackage {
	<#
    .SYNOPSIS
    Install-ExePackage.ps1 - Install EXE package via start-process
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : Install-ExePackage.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
	AddedCredit : skatterbrainzz
    AddedWebsite: https://skatterbrainz.wordpress.com/2016/12/19/building-an-sccm-1606-site-server-with-boxstarter-windows-server-2016-sql-server-2016/
    AddedTwitter: 
    REVISIONS
    * 3:13 PM 2/21/2023 added CBH, otb syntax. 
    * 12/19/2016 skatterbrainzz posted version
    .DESCRIPTION
    Install-ExePackage.ps1 - Install EXE package via start-process
    skatterbrainzz' function for box building, installation of .exe pkgs.
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
	PS>  $pltInstall = @{
	PS>  	prod    = "Windows Deployment Tools" ; 
	PS>  	appInst = "$adkSource\adksetup.exe" ; 
	PS>  	argList = " /Features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment OptionId.ImagingAndConfigurationDesigner OptionId.UserStateMigrationTool /norestart /quiet /ceip off" ; 
	PS>  } ; 
	PS>  Install-ExePackage @pltInstall ;
	Typical Install.
    .LINK
    https://github.com/tostka/verb-desktop
    https://skatterbrainz.wordpress.com/2016/12/19/building-an-sccm-1606-site-server-with-boxstarter-windows-server-2016-sql-server-2016/
    #>
    [CmdletBinding()]
	PARAM(
		[Parameter(Position=0,HelpMessage="Application Name substring[-ProductName 'Windows Deployment Tools']")]
		[string]$ProductName, 
		[Parameter(Position=1,HelpMessage="Application EXE installable[-Install 'path-to\adksetup.exe']")]
		$Install, 
		[Parameter(Position=2,HelpMessage="Application Name substring[-Options ' /Features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment OptionId.ImagingAndConfigurationDesigner OptionId.UserStateMigrationTool /norestart /quiet /ceip off']")]
		$Options
	) ; 
	if (Test-AppInstalled "$ProductName") {
		write-output "info: $ProductName is already installed." ; 
	}  else {
		write-output "info: installing $ProductName..." ; 
		write-output "info: type...... exe" ; 
		write-output "info: source.... $Install" ; 
		write-output "info: options... $Options" ; 
		try {
			$res = (Start-Process -FilePath "$Install" -ArgumentList "$Options" -Wait -PassThru).ExitCode ; 
			if ($res -ne 0) {
				write-output "error: exit code is $res" ; 
				$Boxstarter.RebootOk = $False ; 
				break ; 
			} else {
				write-output "info: exit code is $res" ; 
			} ; 
		}  catch {
			$ErrorMessage = $_.Exception.Message
			$FailedItem = $_.Exception.ItemName
			$Boxstarter.RebootOk = $False ; 
			write-output "error: installation failed... $ErrorMessage" ; 
			break ; 
		} ; 
		write-output "info: installation successful" ; 
		if (Test-PendingReboot) { Invoke-Reboot } ; 
	} ; 
} ; 
#*------^ END Function Install-ExePackage ^------
