#*------v Function stop-browsers v------
Function stop-browsers {

    <# 
    .SYNOPSIS
    stop-browsers - Cycle common browser proceses and close/kill them (as browsers frequently ignore close prompts from shell wo explicitly prompts, when trying to shutdown/reboot).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-11-14
    FileName    : stop-browsers.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-Desktop
    Tags        : GoogleDrive
    AddedCredit : mklement0
    AddedWebsite:	https://stackoverflow.com/users/45375/mklement0
    AddedTwitter:	
    REVISIONS   :
    * 8:26 AM 11/14/2022 init
    .DESCRIPTION
    stop-browsers - Cycle common browser proceses and close/kill them (as browsers frequently ignore close prompts from shell wo explicitly prompts, when trying to shutdown/reboot).
    .PARAMETER Whatif
    Whatif no-exec test
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    PS> if(stop-browsers -verbose -whatif){'y'} else { 'n'} ; 
    Confirm Gdrv running, with verbose and whatif 
    .LINK
    https://github.com/tostka/verb-Desktop
    #>
    [CmdletBinding()]
    [Alias('sbn')]
    Param(
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ; 
    BEGIN{
        $TargAppName="Firefox|Palemoon|Cyberfox|msEdge|Chrome" ;  # descriptive msg text
        # stop-process names to be killed
        $rgxPSTargetAppProc="^(firefox|palemoon|Cyberfox|chrome|msedge$)$" ;  
        # pskill/pslist select-sting pattern targets (as sysinternals don't emit objects, just text)
        $rgxPSETargetAppProc="(firefox|palemoon|Cyberfox|chrome|msedge)" ;  

    }
    PROCESS{
        w-h "Cycle common browser proceses and close/kill them (as browsers frequently ignore close prompts from shell)" ; 
        [array]$prcs = $prcE = @() ; 
        Try {
            write-verbose -verbose:$true "$(get-date -format 'yyyyMMdd-HHmmtt'): --PASS STARTED:$ScriptName --"
write-verbose -verbose:$true "killing $($TargAppName)"

            $prcs=get-process -ea silentlycontinue| ?{$_.name -match $rgxPSTargetAppProc} | sort name;
            if($prcs){
                $smsg = "TARGETS FOUND:`n$(($prcs | group Name | ft -a name,count |out-string).trim())`n" ; 
                write-host $smsg ; 
                if($prcs){ 
                    $prcs | stop-process -verbose -whatif:$($whatif) -erroraction silentlycontinue; 
                    start-sleep 2 ; 
                } else {
                    $smsg = "(no targets found)" ; 
                    write-host $smsg ; 
                } ; ; 
                # anything that survives above, pskill
                $prcE = pslist | select-string -pattern $rgxPSETargetAppProc ; 
                if($prcE){
                    # sysinternals has padded the output from 3 to 7 lines of baloney, including header line
                    #$prcE = $prcE | Select -Skip 7 |foreach-object{
                    # prefiltered, doesn't have headers, no need to skip 7
                    $prcE = $prcE | foreach-object{
                        $procinfo = $_ -split "\s+" ; 
                        [pscustomobject][ordered]@{
                            Name = $procInfo[0..($procInfo.Count -8)] -Join " "; 
                            Pid = $procInfo[-7].trim()  ; 
                            Pri = $procInfo[-6].trim() ; 
                            Thd = $procInfo[-5].trim()  ; 
                            Hnd = $procInfo[-4].trim() ; 
                            Priv = $procInfo[-3].trim()      ; 
                            "CPU Time" = $procInfo[-2].trim()   ; 
                            "Elapsed Time" = $procInfo[-1].trim()  ; 
                        }  ;                
                    } | sort name ; 
                    foreach($prc in $prcE){
                        write-verbose "pskill $($prc.pid) ($($prc.name))" ; 
                        if(!$whatif){
                        invoke-expression -command "pskill $($prc.pid)"
                        } else { 
                            write-host "(-whatif, skipping exec)" ; 
                        } ; 
                    } ; 
                    $smsg = "POST ZOMBIES RESULTS:`n$(($prcE = pslist | select-string -pattern $rgxPSETargetAppProc|out-string).trim())" ; 
                     write-host -foregroundcolor red $smsg ; 
                }
            }
        } Catch {
                $smsg = "ERROR!`n$($Error[0])"
                 write-warning $smsg ; throw $smsg ; 
                 #$false | write-output ; 
        } 
        Finally {
            
        } ;
    }  # PROC-E
    END{}
} #*------^ END Function stop-browsers ^------
