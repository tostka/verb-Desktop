# resolve-CommonFolderCurrentLocation.ps1

#region TEST_ISPROFILEREDIRECTED ; #*------v resolve-CommonFolderCurrentLocation v------
function resolve-CommonFolderCurrentLocation {
    <#
    .SYNOPSIS
    resolve-CommonFolderCurrentLocation - Resolve common folder current location (through Known Folder Move/redirection (OneDrive), and Environement::getFolderPath() lookup)
    .NOTES
    Version     : 1.0.0.0
    Author: Todd Kadrie
    Website:	http://toddomation.com
    Twitter:	http://twitter.com/tostka
    CreatedDate : 2026-05-08
    FileName    : resolve-CommonFolderCurrentLocation
    License     : MIT License
    Copyright   : (c) 2026 Todd Kadrie
    AddedCredit : 
    AddedWebsite: 
    AddedTwitter: 
    Github      : https://github.com/tostka/verb-desktop
    Tags        : Powershell,OS,KnownFolderMove,KFM,Profile,ProfileRedirection,Test
    REVISIONS
    * 11:37 AM 5/8/2026 init
    .DESCRIPTION
    resolve-CommonFolderCurrentLocation - Resolve common folder current location (through Known Folder Move/redirection (OneDrive), and Environement::getFolderPath() lookup)
    
    # Expanding coverage to the [Environment]::GetFolderPath("MyDocuments") .dotnet call: 
    # dumping the full list of folders available for resolution: 
    ([Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])) -join ", " ; 

        Desktop
        Programs
        MyDocuments
        Personal
        Favorites
        Startup
        Recent
        SendTo
        StartMenu
        MyMusic
        MyVideos
        DesktopDirectory
        MyComputer
        NetworkShortcuts
        Fonts
        Templates
        CommonStartMenu
        CommonPrograms
        CommonStartup
        CommonDesktopDirectory
        ApplicationData
        PrinterShortcuts
        LocalApplicationData
        InternetCache
        Cookies
        History
        CommonApplicationData
        Windows
        System
        ProgramFiles
        MyPictures
        UserProfile
        SystemX86
        ProgramFilesX86
        CommonProgramFiles
        CommonProgramFilesX86
        CommonTemplates
        CommonDocuments
        CommonAdminTools
        AdminTools
        CommonMusic
        CommonPictures
        CommonVideos
        Resources
        LocalizedResources
        CommonOemLinks
        CDBurning

        ## folders only on the ShellFolder list:
        NetHood                <=        
        Cache                  <=
        PrintHood              <=

        # items that are renamed between the lists (rename and defer to Env resoloution)
        Local AppData          <= <> LocalApplicationData
        AppData                <= <> ApplicationData
        My Music               <= <> MyMusic
        My Video               <= <> MyVideos
        Start Menu             <= <> StartMenu
        My Pictures            <= <> MyPictures
        Local AppData          <= <> LocalApplicationData
        AppData                <= <> ApplicationData
        My Music               <= <> MyMusic
        My Video               <= <> MyVideos
        Start Menu             <= <> StartMenu
        My Pictures            <= <> MyPictures

        ## folders on both lists:
        Programs               ==
        Templates              ==
        Favorites              ==
        History                ==
        Cookies                ==
        Desktop                ==
        Personal               ==
        Recent                 ==
        Startup                ==
        SendTo                 ==
        => defer those to the Environment resolution

    .PARAMETER FolderName
    FolderName (full OS spec dynamically supported: common items: AppData|LocalAppData|Programs|StartMenu|Startup|Templates|Documents|Desktop|Favorites|MyPictures|MyMusic|MyVideo|) to resolve[-FolderName Documents]
    .PARAMETER TestRedirected
    Switch to run a test for redirection: If detected redirected, return resolved redirected location, otherwise return boolean $false[-testRedirected]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    PS>  if(resolve-CommonFolderCurrentLocation -folderName Desktop -testredirection ){
    PS>  	write-host "$($env:computername) is Activated/Licensed" ; 
    PS>  } else { 
    PS>  	write-warning "$($env:computername) is NOT Activated/Licensed!" ; 
    PS>  } ; 
    Test standard windows activation
    .EXAMPLE
    PS> $rgxGuid = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}" ;
    PS> (Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders").Property | ?{$_ -notmatch $rgxGuid} ;

        AppData
        Cache
        Cookies
        History
        Local AppData
        NetHood
        PrintHood
        Programs
        Recent
        SendTo
        Start Menu
        Startup
        Templates
        Desktop
        Favorites
        My Pictures
        My Music
        My Video
        Personal

    Dump full list of folder names/properties configured on local HKCU (excluding GUID-named folders), for configuration of the ValidatePattern on the TargetFolder parameter
    .EXAMPLE
    PS> write-verbose "static lists" ; 
    PS> $shellFolders = 'AppData','Cache','Cookies','History','Local AppData','NetHood','PrintHood','Programs','Recent','SendTo','Start Menu','Startup','Templates','Desktop','Favorites','My Pictures','My Music','My Video','Personal'
    PS> $envFolders = 'Desktop','Programs','MyDocuments','Personal','Favorites','Startup','Recent','SendTo','StartMenu','MyMusic','MyVideos','DesktopDirectory','MyComputer','NetworkShortcuts','Fonts','Templates','CommonStartMenu','CommonPrograms','CommonStartup','CommonDesktopDirectory','ApplicationData','PrinterShortcuts','LocalApplicationData','InternetCache','Cookies','History','CommonApplicationData','Windows','System','ProgramFiles','MyPictures','UserProfile','SystemX86','ProgramFilesX86','CommonProgramFiles','CommonProgramFilesX86','CommonTemplates','CommonDocuments','CommonAdminTools','AdminTools','CommonMusic','CommonPictures','CommonVideos','Resources','LocalizedResources','CommonOemLinks','CDBurning'
    PS> write-verbose "queried lists (current for local OS)" ; 
    PS> $shellFolders = (Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders").Property ; 
    PS> $envFolders = ([Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])) ; 
    PS> Compare-Object -ReferenceObject $shellFolders -DifferenceObject $envFolders -IncludeEqual | sort sideindicator ; 
    Obtain and compare the population and overlap, between the observed registry ShellFolder contents, and the dotNet EnvironmentFolder feature support.
    .LINK
    https://stackoverflow.com/questions/29368414/need-script-to-find-server-activation-status
    https://github.com/tostka/verb-desktop
    #>
    [CmdletBinding()]
    #[Alias('')]
    PARAM(
        [Parameter(Mandatory = $True,Position = 0,HelpMessage = 'FolderName (full OS spec dynamically supported: common items: AppData|LocalAppData|Programs|StartMenu|Startup|Templates|Documents|Desktop|Favorites|MyPictures|MyMusic|MyVideo|) to resolve[-FolderName Documents]')]
            #[ValidateSet('AppData','Cache','Cookies','History','LocalAppData','NetHood','PrintHood','Programs','Recent','SendTo','StartMenu','Startup','Templates','Desktop','Favorites','MyPictures','MyMusic','MyVideo','Personal','Documents')]
            [ValidateScript({
                $suppFolderNames = $(@('NetHood','Cache','PrintHood');@([Environment+SpecialFolder]::GetNames([Environment+SpecialFolder]))) | sort ; 
                if($suppFolderNames -contains $_){
                    $true ;
                }else{
                    $smsg = "Unsupported FolderName! (needs to be supported by Environment::GetNames(), or HKCU ShellFolders)" ; 
                    $smsg += "`nPlease use a supported folder designator:`n$(($suppFolderNames -join ', '|out-string).trim())" ; 
                    throw $smsg ; 
                }                
            })]
            [string[]] $FolderName,
        [Parameter(Mandatory = $False,Position = 1,HelpMessage = 'Switch to run a test for redirection: If detected redirected, return resolved redirected location, otherwise return boolean $false[-testRedirected]')]
            [switch]$TestRedirected
    ) ;
    BEGIN{
        $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" ; 
        # collect current contents of the key
        $redirectedFolders = Get-ItemProperty -Path $registryPath ; 
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
          write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
          #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
          write-verbose "(non-pipeline - param - input)" ; 
        } ;         
    }
    PROCESS{
        foreach ($folder in $FolderName) {
            # push no-space param specs back to in-use strings for matching - shellfolders supports spacees in names, but that doesn't work for parameters -> use the Enviro folder designators
            #if($redirectedFolders.PsObject.Properties.name -contains $foldername){
            switch -regex ($FolderName){
                # items only supported by the shellfolder (e.g. unsupported by [Environment]::GetFolderPath())
                'NetHood|Cache|PrintHood'{$path = $redirectedFolders.$FolderName }
                default{$Path = [Environment]::GetFolderPath($FolderName)} ; 
            }
            if ($path -match "OneDrive") {
                Write-Host "[+] $folder is REDIRECTED to: $path" -ForegroundColor Green
                $path | write-output  ; 
            } else {
                Write-Host "[-] $folder is NOT redirected (Local path: $path)" -ForegroundColor Yellow
                if($test){$false | write-output } else {$path | write-output }
            } ; 
        }
    } ;
} ; 
#endregion TEST_ISPROFILEREDIRECTED ; #*------^ END resolve-CommonFolderCurrentLocation ^------