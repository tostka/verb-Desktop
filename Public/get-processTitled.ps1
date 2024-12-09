#*------v Function get-processTitled v------
Function get-processTitled {
    <#
    .SYNOPSIS
    get-processTitled.ps1 - Postfilter get-process, to display only processes with a MainWindowTitle
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2024-12-09
    FileName    : get-processTitled
    License     : MIT License
    Copyright   : (c) 2024 Todd Kadrie
    Github      : https://github.com/tostka/verb-desktop
    Tags        : Powershell,Process,Management,Reporting
    REVISIONS
    * 3:44 PM 12/9/2024init vers
    .DESCRIPTION
    get-processTitled.ps1 - Postfilter get-process, to display only processes with a MainWindowTitle
    Handy for tracking down the single *hung* powershell_ise instance, based on it's Titlebar contents (to targeted kill the problem; leaving the others to continue running).
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object process to pipeline
    .EXAMPLE
    PS> get-processTitled ; 

      ProcessName       Id MainWindowTitle
      -----------       -- ---------------
      explorer        5960 D:\scripts\logs
      powershell     12352 PS ADMIN - TORO - EMSt
      powershell_ise 12244 PS ADMIN - TORO -
    
    Default usage & output 
    .LINK
    https://github.com/tostka/verb-desktop
    #>
    [CmdletBinding()]
    #[Alias('','')]
    PARAM() ;
    get-process | ?{$_.mainwindowtitle} | sort processname,mainwindowtitle,id | select-object processname,id,mainwindowtitle | write-output 
} #*------^ END Function get-processTitled ^------
