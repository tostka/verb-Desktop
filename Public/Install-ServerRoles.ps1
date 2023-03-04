#*------v Function Install-ServerRoles v------
function Install-ServerRoles {
	<#
    .SYNOPSIS
    Install-ServerRoles.ps1 - Install WindowsFeatures using saved xml file Add Roles and Features Wizard in Server Manager. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : Install-ServerRoles.ps1
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
    Install-ServerRoles.ps1 - Install WindowsFeatures using saved xml file Add Roles and Features Wizard in Server Manager.
    skatterbrainzz' function for box building, installation of WindowsFeatures.
    
    The XMLFile configuration file can be created by clicking Export configuration settings on the Confirm installation selections page of the Add Roles and Features Wizard in Server Manager.
    .PARAMETER XmlFile
	Path to xml file created by clicking Export configuration settings on the Confirm installation selections page of the Add Roles and Features Wizard in Server Manager[-XmlFile 'pathto\ServerRoles.xml']"
	.PARAMETER RoleNames
	Application Name substring[-RoleNames 'WDS']
	.PARAMETER sharedSource
	Path to common install share[-sharedSource '\\server\share\pathto\']
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    PS> Install-ServerRoles -XmlFile "$scriptsPath\ServerRoles.xml" -SharedSource $SharedSource ;
    Install saved .xml file of Server Manager Add Roles & Features Wiz Export
    .EXAMPLE
    Install-ServerRoles -RoleName "WDS"
    Install WindowsFeature by name
    .LINK
    https://github.com/tostka/verb-desktop
    https://skatterbrainz.wordpress.com/2016/12/19/building-an-sccm-1606-site-server-with-boxstarter-windows-server-2016-sql-server-2016/
    #>
	PARAM(
		[parameter(Mandatory=$False,Position=0,HelpMessage="Path to xml file created by clicking Export configuration settings on the Confirm installation selections page of the Add Roles and Features Wizard in Server Manager[-XmlFile 'pathto\ServerRoles.xml']")] 
		[string]$XmlFile = "", 
		[parameter(Mandatory=$False,Position=1,HelpMessage="Application Name substring[-RoleNames 'WDS']")] 
		[string[]]$RoleNames = "",
		[parameter(Mandatory=$False,HelpMessage="Path to common install share[-sharedSource '\\server\share\pathto\']")] 
		[string]$sharedSource = "\\FS1\Apps\Sources\2016\SXS" 
	) ; 
	if ($xmlFile -ne "") {
		if (Test-Path $xmlFile) {
			write-output "info: installing server roles and features from config file..." ; 
			Install-WindowsFeature -ConfigurationFilePath $xmlFile -Source $sharedSource ; 
			write-output "info: roles and features installation completed." ; 
		}  else {
			write-output "error: unable to locate configuration file: $xmlFile" ; 
			$Boxstarter.RebootOk = $False ; 
			break ; 
		} ; 
	}  else {
		write-output "info: installing server roles and features..." ; 
		try {
			Install-WindowsFeature -Name $RoleNames.Split(",") -IncludeManagementTools -Source $sharedSource -ErrorAction Stop ; 
		}  catch {
			$ErrorMessage = $_.Exception.Message
			$FailedItem = $_.Exception.ItemName
			$Boxstarter.RebootOk = $False ; 
			write-output "error: role names...... $RoleNames" ; 
			write-output "error: config file..... $XmlFile" ; 
			write-output "error: installation failed... $ErrorMessage" ; 
			break ; 
		} ; 
		Start-Sleep -s 10 ; 
	} ; 
} ; 
#*------^ END Function Install-ServerRoles ^------
