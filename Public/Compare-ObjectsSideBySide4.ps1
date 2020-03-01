﻿#*------v Function Compare-ObjectsSideBySide4 v------
function Compare-ObjectsSideBySide4 ($col1, $col2, $col3, $col4) {
    <#
    .SYNOPSIS
    Compare-ObjectsSideBySide4() - Displays four objects side-by-side comparatively in console
    .NOTES
    Author: Richard Slater
    Website:	https://stackoverflow.com/users/74302/richard-slater
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	URL
    Twitter:	URL
    REVISIONS   :
    * 10:18 AM 11/2/2018 Extension of base model, to 4 columns
    * May 7 '16 at 20:55 posted version
    .DESCRIPTION
    Compare-ObjectsSideBySide4() - Displays four objects side-by-side comparatively in console
    .PARAMETER  col1
    Object to be displayed in Column1 [-col1 $PsObject1]
    .PARAMETER  col2
    Object to be displayed in Column2 [-col2 $PsObject2]
    .PARAMETER  col3
    Object to be displayed in Column3 [-col3 $PsObject3]
    .PARAMETER  col4
    Object to be displayed in Column4 [-col4 $PsObject4]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    Acceptes piped input.
    .OUTPUTS
    Outputs specified object side-by-side on console
    .EXAMPLE
    $object1 = New-Object PSObject -Property @{
      'Forename' = 'Richard';
      'Surname' = 'Slater';
      'Company' = 'Amido';
      'SelfEmployed' = $true;
    } ;
    $object2 = New-Object PSObject -Property @{
      'Forename' = 'Jane';
      'Surname' = 'Smith';
      'Company' = 'Google';
      'MaidenName' = 'Jones' ;
    } ;
    $object3 = New-Object PSObject -Property @{
      'Forename' = 'Zhe';
      'Surname' = 'Person';
      'Company' = 'Apfel';
      'MaidenName' = 'NunaUBusiness' ;
    } ;
    $object4 = New-Object PSObject -Property @{
      'Forename' = 'Zir';
      'Surname' = 'NPC';
      'Company' = 'Facemook';
      'MaidenName' = 'Not!' ;
    } ;
    Compare-ObjectsSideBySide4 $object1 $object2 $object3 $object4 | Format-Table Property, col1, col2, col3, col4;
    Display $object1,2,3 & 4 in comparative side-by-side columns
    .LINK
    https://stackoverflow.com/questions/37089766/powershell-side-by-side-objects
    #>
    $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col3Members = $col3 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col4Members = $col4 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $combinedMembers = ($col1Members + $col2Members + $col3Members + $col4Members) | Sort-Object -COque ;
    $combinedMembers | ForEach-Object {
        $properties = @{'Property' = $_} ;
        if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
        if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
        if ($col3Members.Contains($_)) {$properties['Col3'] = $col3 | Select-Object -ExpandProperty $_} ;
        if ($col4Members.Contains($_)) {$properties['col4'] = $col4 | Select-Object -ExpandProperty $_} ;
        New-Object PSObject -Property $properties ;
    } ;
} ; #*------^ END Function Compare-ObjectsSideBySide4 ^------