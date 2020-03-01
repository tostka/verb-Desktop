#*------v Function Go v------
function Go {
    <#
    .SYNOPSIS
    Go - CD to common system locations
    .NOTES
    # vers: 8:49 AM 3/27/2014 - tuned destinations
    .EXAMPLE
    PS C:\> Go <location keyword>
    .OUTPUTS
    [none]
    #>
    [CmdletBinding()]
    Param([string] $Location) ; 
    BEGIN { 
        $verbose = ($VerbosePreference -eq "Continue") 
        if ( $GLOBAL:go_locations -eq $null ) {
            $GLOBAL:go_locations = @{ };
            #$GLOBAL:go_locations =[Ordered]@{}; # psv3+
        } 
    } ;
    PROCESS {
        if ($go_locations.ContainsKey($Location)) {
            #write-output $go_locations[$Location]
            Set-Location $go_locations[$Location];
            # 10:37 AM 3/27/2014this lists everything in the dir... NAH!
            #Get-ChildItem;
        } else {
            write-verbose -verbose:$true "---";
            write-verbose -verbose:$true "The following locations are defined:";
            write-verbose -verbose:$true $go_locations;
        } 
    } ;
    END {} ;
} # function block end
#*------^ END Function Go ^------