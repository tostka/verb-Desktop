#*------v Function confirm-GoogleDriveRunning v------
Function confirm-GoogleDriveRunning {

    <# 
    .SYNOPSIS
    confirm-GoogleDriveRunning - Confirm/Run Google Drive - Resolve Google Drive letter; test for drive letter present(running): start GD if drive not present (Resolve Google Drive .exe path from default installed Start Mnu .lnk) 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-11-11
    FileName    : confirm-GoogleDriveRunning.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-Desktop
    Tags        : GoogleDrive
    AddedCredit : mklement0
    AddedWebsite:	https://stackoverflow.com/users/45375/mklement0
    AddedTwitter:	
    REVISIONS   :
    # 11:14 AM 11/11/2022 my revisions: added [codewario](https://stackoverflow.com/users/584676/codewario)'s answer to M's question; added .exe resolution via default start mnu Google Drive.lnk expansion. Try catch, whatif, and now outputs boolean to pipeline, for testing 
    * 11:15 AM 9/1/21 mklement0's posted question code
    .DESCRIPTION
    confirm-GoogleDriveRunning - Confirm/Run Google Drive - Resolve Google Drive letter; test for drive letter present(running): start GD if drive not present (Resolve Google Drive .exe path from default installed Start Mnu .lnk) 
    
    Expanded version of mklement0's posted concept snippet from stackoverflow question:
    [powershell - Find the mapped google drive - Stack Overflow - stackoverflow.com/](https://stackoverflow.com/questions/69017164/find-the-mapped-google-drive)
    Added .exe resolution code; spliced in bender's answer to the original question. 
    
    .PARAMETER  Path
    Path to be overlayed over specified background
    .PARAMETER Whatif
    Whatif no-exec test
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    PS> if(confirm-GoogleDriveRunning -verbose -whatif){'y'} else { 'n'} ; 
    Confirm Gdrv running, with verbose and whatif 
    .LINK
    https://github.com/tostka/verb-Desktop
    #>
    [CmdletBinding()]
    #[Alias('')]
    Param(
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ; 
    write-verbose "Attempt to Resolve Google Drive PSDrive (local drive vs mounted)" ; 
    Try {
        If (!($gdrvDrive = Get-PSDrive -PSProvider FileSystem | 
            Where-Object {$_.Description -eq 'Google Drive' })) {
            write-verbose "Resolve Google Drive .exe loc from the stock launch .lnk" ; 
            $gdrvLnk = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Google Drive.lnk" ; 
            write-verbose "expand shortcut TargetPath" ; 
            $WScriptShell = New-Object -ComObject WScript.Shell ; 
            if (Test-Path $gdrvLnk) {
                $GdfsPath  = $WScriptShell.CreateShortcut((Resolve-Path $gdrvLnk)).targetpath ;
                if(!$whatif){
                    write-verbose "Start-Process resolved path:`n$($gdfsPath)`n(30s timeout)" ; 
                        Start-Process $GdfsPath | Wait-Process -Timeout 30 ;
                } else { 
                    write-host "-whatif: skipping run exeution of:`n$($GdfsPath)" ; 
                } ; 
            } else {
                $smsg = "Unable to resolve Google Drive.lnk to an exe path!`n$($gdrvLnk)" ; 
                write-warning $smsg ; throw $smsg ; 
            } ; 
        } else {
            write-verbose "Google drive present ($($gdrvDrive.Root):), returning `$true to pipeline" ; 
            $true | write-output ; 
        } ; 
    } Catch {
            $smsg = "Google Drive can't be mapped. Failed to load Gdrv: $($GdfsPath)"
             write-warning $smsg ; throw $smsg ; 
             $false | write-output ; 
    } 
    Finally {
        If (!(Get-PSDrive -PSProvider FileSystem | 
    Where-Object {$_.Description -eq 'Google Drive' })) {
            $smsg = "Google Drive can't be mapped. Failed to load Gdrv: $($GdfsPath)"
             write-warning $smsg ; throw $smsg ; 
             $false | write-output ; 
        } ;
    } ;
} #*------^ END Function confirm-GoogleDriveRunning ^------
