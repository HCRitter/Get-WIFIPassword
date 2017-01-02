Function Get-WLANPassword{
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
        #get the output for the specified profile name and trim the output to receive the password
        $WLANProfilePassword = (((netsh.exe wlan show profiles name="$WLANProfileName" key=clear | select-string -Pattern "Key Content") -split ":")[1]).Trim()
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
