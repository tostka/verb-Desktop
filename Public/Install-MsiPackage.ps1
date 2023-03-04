#*------v Function Install-MsiPackage v------
function Install-MsiPackage {
	<#
    .SYNOPSIS
    Install-MsiPackage.ps1 - Install MSI package via msiexec.exe
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : Install-MsiPackage.ps1
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
    Install-MsiPackage.ps1 - Install MSI package via msiexec.exe
    skatterbrainzz' function for box building, installation of msi pkgs.
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    PS> Install-MsiPackage "Microsoft Deployment Toolkit (6.3.8443.1000)" "$mdtSource\MicrosoftDeploymentToolkit_x64.msi" "";
    Typical install.
    .LINK
    https://github.com/tostka/verb-desktop
    https://skatterbrainz.wordpress.com/2016/12/19/building-an-sccm-1606-site-server-with-boxstarter-windows-server-2016-sql-server-2016/
    #>
    [CmdletBinding()]
	PARAM(
		[Parameter(Position=0,HelpMessage="Application Name substring[-ProductName 'Microsoft Deployment Toolkit (6.3.8443.1000)']")]
		[string]$ProductName, 
		[Parameter(Position=1,HelpMessage="Application MSI installable[-Install 'path-to\MicrosoftDeploymentToolkit_x64.msi']")]
		$Install, 
		[Parameter(Position=2,HelpMessage="Application Name substring[-Options '']")]
		$Options
	) ; 
	if (Test-AppInstalled "$ProductName") {
		write-output "info: $ProductName is already installed" ; 
	} else {
		if (Test-Path "$Install") {
			write-output "info: installing $ProductName..." ; 
			write-output "info: type...... msi" ; 
			write-output "info: package... $Install" ; 
			write-output "info: options... $Options" ; 
			$Arg2 = "/i ""$Install"" /qb! /norestart REBOOT=ReallySuppress" ; 
			if ($Options -ne "") {
				$Arg2 += " ""$Options""" ; 
			} ; 
			TRY {
				$res = (Start-Process -FilePath "msiexec.exe" -ArgumentList $Arg2 -Wait -Passthru).ExitCode ; 
				if ($res -ne 0) {
					write-output "error: exit code is $res" ; 
					$errmsg = [ComponentModel.Win32Exception] $res ; 
					write-output "error: $errmsg" ; 
					$Boxstarter.RebootOk = $False ; 
					break ; 
				}  else {
				  write-output "info: exit code is $res" ; 
				} ; 
			}  CATCH {
				$Boxstarter.RebootOk = $False ; 
				write-output "error: installation failed!" ; 
				break ; 
			} ; 
			write-output "info: installation successful" ; 
			if (Test-PendingReboot) { Invoke-Reboot }
		}  else {
		  write-output "error: unable to locate $Install" ; 
		  break ; 
		} ; 
	} ; 
} ; 
#*------^ END Function Install-MsiPackage ^------
