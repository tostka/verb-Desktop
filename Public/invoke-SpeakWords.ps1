#*------v Function invoke-speakwords v------
function invoke-speakwords {
    <#
    .SYNOPSIS
    invoke-speakwords - Text2Speech specified words
    .NOTES
    Author: Karl Prosser
    Website:	http://poshcode.org/835
    REVISIONS   :
    * 11:20 AM 12/9/2022 it's dumping a 1 into the pipeline, eat the output of $voice.speak; added cmdletbinding & moved alias into the body, instead of post-block; rename compliant verb: speak-words -> invoke-speakwords, alias speak-words
    * 2:02 PM 4/9/2015 - added to profile
    .PARAMETER  words
    Words or phrases to be spoken
    .PARAMETER  pause
    switch indicating whether to hold execution during speaking
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    invoke-speakwords "here we go now"  ;
    .EXAMPLE
    invoke-speakwords "$([datetime]::now)" ;
    Speak current date and time
    .EXAMPLE
    get-fortune | invoke-speakwords ;
    Speak output of get-fortune
    .LINK
    http://poshcode.org/835
    #>
    [CmdletBinding()]
    [Alias('speak-words','speak')]
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Specify text to speak")]
        [ValidateNotNullOrEmpty()]
        [string]$words
        ,
        [Parameter(Position = 1, Mandatory = $False, HelpMessage = "Specify to wait for text to finish speaking")]
        [switch]$pause = $true
    ) # PARAM BLOCK END
    # default to no-pause, unless specified
    $flag = 1 ; if ($pause) { $flag = 2 }  ;
    $voice = new-Object -com SAPI.spvoice ;
    $voice.speak($words, [int] $flag) | out-null ; # 2 means wait until speaking is finished to continue

} #*======^ END Function invoke-speakwords ^====== ;