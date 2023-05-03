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
        #Exports all Wifi profiles to the current directory
        try {
            $WifiProfileExport = $(netsh wlan export profile key=clear)
        }
        catch {
            Write-Error $PSItem.Exception.Message
            Write-Error "Could not export the Wifi profiles"
            return
            
        }
        #Collect all profile XML export paths
        $WifiProfileExportPaths = foreach($ExportPath in $WifiProfileExport){
            if($ExportPath -match '\"(.*?\\.*?\.xml)(?=\")'){
                $matches[1]
            }
        }
        
    }
    
    process {
        foreach($WifiProfileExportPath in $WifiProfileExportPaths){
            #read the XMLFile
            $XMLFile = (select-xml -path $WifiProfileExportPath -xpath "/").Node.WLANProfile
            [PSCustomObject]@{
                Name = $XMLFile.name
                Password = $Password = $XMLFile.MSM.Security.SharedKey.KeyMaterial
                Succeed = [bool]$Password
            }
            #remove the created xml file
            try {
                remove-item $WifiProfileExportPath -ErrorAction Stop
            }
            catch {
                Write-Error $PSItem.Exception.Message
                Write-Error "Could not delete $WifiProfileExportPath"
            }
            
        }
    }
    
    end {
        
    }
}