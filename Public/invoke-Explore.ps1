#*------v Function invoke-Explore v------

Function invoke-Explore {
    <# 
    .SYNOPSIS
    invoke-Explore - Spawn explorer on designated path (aliased as 'explore')
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-04
    FileName    : invoke-Explore.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-Desktop
    Tags        : Powershell,explorer,Filesystem
    REVISIONS   :
    # 8:59 AM 8/25/2022 init
    .DESCRIPTION
    invoke-Explore - Spawn explorer on designated path
    .PARAMETER  Path
    Path to be overlayed over specified background    
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    PS> Explore c:\usr\local\bin\
    Invoke explorer.exe on specified path
    .LINK
    https://github.com/tostka/verb-Desktop
    #>
    [CmdletBinding()]
    [Alias('Explore')]
    Param(
        [Parameter(Mandatory=$true,Position = 0,ValueFromPipeline = $true,HelpMessage="Path to be 'explored'[-path 'c:\some\path']")]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    ) ; 
    if((get-variable -name IsWindows) -AND (-not $IsWindows)){
        write-warning "Ps `$isWindows:$($isWindows): This funcion is *only* supported on *Windows*" ; 
        Break ; 
    } ;
    write-verbose "invoking explorer with -path:$($path)" ; 
    $explorer = New-Object -ComObject shell.application ; 
    $explorer.Explore($path) ; 
} #*------^ END Function invoke-Explore ^------
