#*------v Function start-ItunesPlaylist v------
Function start-ItunesPlaylist {
    <#
    .SYNOPSIS
    Plays an iTunes playlist.
    .DESCRIPTION
    Opens the Apple iTunes application and starts playing the given iTunes playlist.
    .NOTES
    Author: Frank Peter (http://www.out-web.net/?p=1390)
    .PARAMETER  Source
    Identifies the name of the source.(["Library"|"Internet Radio"]
    .PARAMETER  Playlist
    Identifies the name of the playlist
    .PARAMETER  Shuffle
    Turns shuffle on (else don't care).
    .EXAMPLE
    C:\PS> .\Start-PlayList.ps1 -Source 'Library' -Playlist 'Party'
    .EXAMPLE
    C:\PS> .\Start-PlayList.ps1 -source 'Library' -Playlist "classical-streams"
    .INPUTS
    None
    .OUTPUTS
    None
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Source,
        [Parameter(Mandatory = $true)]
        $Playlist,
        [Switch]$Shuffle
    ) ;
    try {$iTunes = New-Object -ComObject iTunes.Application
    }catch {Write-Error 'Download and install Apple iTunes'return} ;
    <# source options (interegated to get)
    Name
    ----
    Library
    Internet Radio
    #>
    $src = $iTunes.Sources | Where-Object { $_.Name -eq $Source } ;
    if (!$src) {
        Write-Error "Unknown source - $Source" ;
        return ;
    } ; # if-E
    $ply = $src.Playlists | Where-Object { $_.Name -eq $Playlist } ;
    if (!$ply) {
        Write-Error "Unknown playlist - $Playlist" ;
        return ;
    } # if-E
    if ($Shuffle) {
        if (!$ply.Shuffle) {
            $ply.Shuffle = $true ;
        } # if-E
    } # if-E
    $ply.PlayFirstTrack() ;
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$iTunes) > $null ;
    [GC]::Collect() ;
} #*------^ END Function start-ItunesPlaylist ^------