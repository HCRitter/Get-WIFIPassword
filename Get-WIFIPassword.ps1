<#
    .SYNOPSIS
    This function displays all stored WIFI passwords on the client
    .DESCRIPTION
    This function gets the output of netsh command and will trim it to display all SSID`s and also the passwords.
    If a profile has no password it will inform the user.
    .EXAMPLE
    Get-WIFIPassword
#>
function Get-WIFIPassword {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        #Regex-Pattern for GER/EN netsh.exe to search for the password
        $Pattern = "Key Content|Schlüsselinhalt"
    }
    
    process {
        $WifiProfileNames = foreach($ProfileName in $(netsh.exe wlan show profiles | Select-String -pattern " : ")){
            (($ProfileName -split ":")[1]).Trim()
        }
        $WifiProfileObjects = foreach($WifiProfileName in $WifiProfileNames){
            [PSCustomObject]@{
                ProfileName = $WifiProfileName
                ProfilePassword = $ProfilePassword = $(
                    try{
                        (((netsh.exe wlan show profiles name="$WifiProfileName" key=clear | select-string -Pattern $Pattern) -split ":")[1]).Trim()
                    }Catch{
                        $null 
                    }
                )
                Succeeded = $(
                    ($Null -eq $ProfilePassword) ? ($false) : ($true)
                )
            }
        }
    }
    
    end {
        return $WifiProfileObjects
    }
}
