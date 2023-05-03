<#
    .SYNOPSIS
    This function displays all stored WIFI passwords on the client
    .DESCRIPTION
    This function gets the output of netsh command and will trim it to display all SSID`s and also the passwords.
    If a profile has no password it will inform the user.
    .EXAMPLE
    Get-WIFIPassword
#>
function Get-WifiPassword {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        try {
            # Export all Wifi profiles and collect their XML file paths
            $netshOutput = $(netsh wlan export profile key=clear)
            $XmlFilePaths = foreach($line in $netshOutput){
                if($line -match '\"(.*?\\.*?\.xml)(?=\")'){
                    $matches[1]
                }
            }
        }
        catch {
            Write-Error "Failed to export Wifi profiles: $($_.Exception.Message)"
            return
        }
        
    }
    
    process {
        foreach ($XmlFilePath in $XmlFilePaths) {
            try {
                # Read the XML file and extract the Wifi profile name and password
                $Xml = [xml](Get-Content -Path $XmlFilePath)

                # Output the profile name, password, and whether the operation succeeded
                [PSCustomObject]@{
                    Name = $Xml.WLANProfile.Name
                    Password = $Password = $Xml.WLANProfile.MSM.Security.SharedKey.KeyMaterial
                    Succeed = [bool]$Password
                }
                # Remove the XML file
                Remove-Item $XmlFilePath -ErrorAction Stop
            }
            catch {
                Write-Error "Failed to read Wifi profile from '$XmlFilePath': $($_.Exception.Message)"
            }
        }
    }
    
    end {
        
    }
}