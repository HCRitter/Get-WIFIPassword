#======================================================================================================================
# Name:		Get-WifiPassword
# Author:	HCRitter
# Date:		2023-05-25
# Version:	1.1
# Comment:	* forked from https://github.com/HCRitter/Get-WIFIPassword on 2023-05-25
#           * improved file handling
#======================================================================================================================

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
            $ExportPath = New-Item -Path $HOME -Name ('GetWifiPassword_' + (New-Guid).Guid) -ItemType Directory
            $CurrentPath = (Get-Location).path
            Set-Location $ExportPath
            netsh wlan export profile key=clear
            $XmlFilePaths = Get-ChildItem -Path $ExportPath -File
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
                $Xml = [xml]::new()).Load((Convert-Path -LiteralPath $xmlPath))

                # Output the profile name, password, and whether the operation succeeded
                [PSCustomObject]@{
                    Name     = $Xml.WLANProfile.Name
                    Password = $Password = $Xml.WLANProfile.MSM.Security.SharedKey.KeyMaterial
                    Succeed  = [bool]$Password
                }
            }
            catch {
                Write-Error "Failed to read Wifi profile from '$XmlFilePath': $($_.Exception.Message)"
            }
        }
    }
    
    end {
        Set-Location $CurrentPath
        Remove-Item $ExportPath -Confirm:$false -Recurse
    }
}
