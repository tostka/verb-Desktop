#*------v Function Speak-words v------
function Speak-words {
    <#
    .SYNOPSIS
    speak-words - Text2Speech specified words
    .NOTES
    Author: Karl Prosser
    Website:	http://poshcode.org/835
    REVISIONS   :
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
    speak-words "here we go now"  ;
    .EXAMPLE
    speak-words "$([datetime]::now)" ;
    Speak current date and time
    .EXAMPLE
    get-fortune | speak-words ;
    Speak output of get-fortune
    .LINK
    http://poshcode.org/835
    #>
    Param(
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
    $voice.speak($words, [int] $flag) # 2 means wait until speaking is finished to continue

} #*======^ END Function Speak-words ^====== ;
# 10:29 AM 2/19/2016
if (!(get-alias -name "speak" -ea 0 )) { Set-Alias -Name 'speak' -Value 'speak-words' ; } ;