Function Get-WLANPassword{
    <#
        .SYNOPSIS
        This function displays all stored WLAN passwords on the client
        .DESCRIPTION
        This function gets the output of netsh command and will trim it to display all SSID`s and also the passwords.
        If a profile has no password it will inform the user.
        .EXAMPLE
        Get-WLANPassword
    #>
    $WLANProfileNames =@()
    #Get all the WLAN profile names
    $Output = netsh.exe wlan show profiles | Select-String -pattern " : "
    #Trim the output to receive only the name
    Foreach($WLANProfileName in $Output){
        $WLANProfileNames += (($WLANProfileName -split ":")[1]).Trim()
    }
    $WLANProfileObjects =@()
    #Bind the WLAN profile names and also the password to a custom object
    Foreach($WLANProfileName in $WLANProfileNames){
        #get the output for the specified profile name and trim the output to receive the password if there is no password it will inform the user
        try{
            $WLANProfilePassword = (((netsh.exe wlan show profiles name="$WLANProfileName" key=clear | select-string -Pattern "Key Content") -split ":")[1]).Trim()
        }Catch{
            Write-Warning "[!] The password is not stored in this profile"
        }
        #Build the object and add this to an array
        $WLANProfileObject = New-Object PSCustomobject 
        $WLANProfileObject | Add-Member -Type NoteProperty -Name "ProfileName" -Value $WLANProfileName
        $WLANProfileObject | Add-Member -Type NoteProperty -Name "ProfilePassword" -Value $WLANProfilePassword
        $WLANProfileObjects += $WLANProfileObject
        Remove-Variable WLANProfileObject
    }
    Write-Output $WLANProfileObjects
}
Get-WLANPassword
