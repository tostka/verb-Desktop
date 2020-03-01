#*------v Function Report-URL v------
function Report-URL {
    <#
    .SYNOPSIS
    Report-URL.ps1 - Resolves url into "[Title] - [url]" summary string, and copies to clipboard - also expands shortened uri's to full target.
    .NOTES
    Author: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: Todd O. Klindt Resolve Short URLs with PowerShell - Todd Klindt's Office 365 Admin Blog
    Website:	https://www.toddklindt.com/blog/Lists/Posts/Post.aspx?ID=764
    REVISIONS   :
    * 8:05 AM 12/13/2019 Report-URL:added -md & -title, added formal param block, switched from dumps to explicit write-ouput
    * 1:44 PM 1/23/2019 init vers
    .DESCRIPTION
    Defaults to PM Copy Page Title & Location As, Plain text, output:
    -md triggers output in Markdown link format:
    [Base64 Encoding of Images via Powershell | LINQ to Fail](https://www.aaron-powell.com/posts/2010-11-07-base64-encoding-images-with-powershell/)
    .PARAMETER  Url
    Internet URL to be resolved
    .PARAMETER  md
    Output Markdown switch [-md]
    .PARAMETER title
    Output Title-only switch[-md]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Dumps info to console, and copies to clipboard
    .EXAMPLE
    report-url https://www.google.com ;
    returns: Google - https://www.google.com/
    .EXAMPLE
    .LINK
    #>
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Internet URL to be resolved[-url https://xxxxx]")]
        [ValidateNotNullOrEmpty()]$Url,
        [Parameter(HelpMessage="Output Markdown switch [-md]")]
        [switch] $md,
        [Parameter(HelpMessage="Output Title-only switch[-md]")]
        [switch] $title,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    $error.clear() ;
    TRY {
        $page=Invoke-WebRequest -Uri $url ;
        if($title) {
            $rpt = "$(($page.parsedhtml.title|out-string).trim())" ;
        } elseif($md){
            $rpt = "[$(($page.parsedhtml.title|out-string).trim())]($(($page.baseresponse.ResponseUri.AbsoluteUri |out-string).trim()))" ;
        } else {
            $rpt="$(($page.parsedhtml.title|out-string).trim()) - $(($page.baseresponse.ResponseUri.AbsoluteUri |out-string).trim())" ;
        } ;
        $rpt | write-output ;
        write-verbose -verbose:$true "(copied to CB)" ;
        $rpt | out-clipboard ;
    } CATCH {
        Write-Error "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
        Exit ;
    } ;

} ; #*------^ END Function Report-URL ^------
If (!(Test-Path ALIAS:Rpt-URL)) { new-Alias -Name Rpt-URL -Value report-url} ;