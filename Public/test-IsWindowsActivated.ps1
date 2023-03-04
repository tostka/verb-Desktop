#*------v test-IsWindowsActivated v------
function test-IsWindowsActivated {
    <#
    .SYNOPSIS
    test-IsWindowsActivated - Tests if local machine is properly License Activated.
    .NOTES
    Version     : 1.0.0.0
    Author: Todd Kadrie
    Website:	http://toddomation.com
    Twitter:	http://twitter.com/tostka
    CreatedDate : 2023-02-22
    FileName    : test-IsWindowsActivated
    License     : MIT License
    Copyright   : (c) 2023 Todd Kadrie
    AddedCredit : FoxDeploy
    AddedWebsite: https://stackoverflow.com/questions/29368414/need-script-to-find-server-activation-status
    AddedTwitter: 
    Github      : https://github.com/tostka/verb-desktop
    Tags        : Powershell,OS,License,Activiation
    REVISIONS
    * 12:06 PM 2/22/2023 init, from canned notes, and FoxDeploy's switchblock code for LicenseStatus values, added ISLicensed to the output. 
    .DESCRIPTION
    test-IsWindowsActivated - Tests if local machine is properly License Activated.
    .PARAMETER  User
    User security principal (defaults to current user)[-User `$SecPrinobj]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    PS>  if((test-IsWindowsActivated).IsLicensed){
    PS>  	write-host "$($env:computername) is Activated/Licensed" ; 
    PS>  } else { 
    PS>  	write-warning "$($env:computername) is NOT Activated/Licensed!" ; 
    PS>  } ; 
    Test standard windows activation
    .LINK
    https://stackoverflow.com/questions/29368414/need-script-to-find-server-activation-status
    https://github.com/tostka/verb-desktop
    #>
    [CmdletBinding()]
    #[Alias('')]
    PARAM(
		[Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = 'ComputerName to test[-ComputerName ServerName')]
		[string[]] $ComputerName=$env:COMPUTERNAME,
		[Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = 'ComputerName to test[-ComputerName ServerName')]
		[string] $ProductFilter="Name like 'Windows%'" 
    ) ;
    BEGIN{
		if ($PSCmdlet.MyInvocation.ExpectingInput) {
			write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
		} else {
			#write-verbose "Data received from parameter input: '$($InputObject)'" ; 
			write-verbose "(non-pipeline - param - input)" ; 
		} ; 
    }
    PROCESS{
		if(gcm get-ciminstance){
			$pltGCM=[ordered]@{
				ComputerName = $ComputerName ;ClassName = 'SoftwareLicensingProduct' ;Filter = $ProductFilter ; 
			} ; 
			$status = Get-CimInstance @pltGCM |
				?{ $_.PartialProductKey } | select Pscomputername,Name,
					@{Name='LicenseStatus';Exp={
						switch ($_.LicenseStatus) {
							0 {'Unlicensed'}
							1 {'licensed'}
							2 {'OOBGrace'}
							3 {'OOTGrace'}
							4 {'NonGenuineGrace'}
							5 {'Notification'}
							6 {'ExtendedGrace'}
							Default {'Undetected'}
						} 
				}},@{name="IsLicensed";expression={ if($_.LicenseStatus -eq 1){$true}else{$false}}} ; 
			$status | write-output ; 	
		} else { 
			$smsg = "MISSING DEPENDANT get-ciminstance CMD!" ; 
			if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
			else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
		} ; 
	} ;
} ; 
#*------^ test-IsWindowsActivated ^------