<#
.SYNOPSIS
This cmdlet is used to backup the Windows Admin Center (WAC) Database


.DESCRIPTION
If you want this to cmdlet to be run in a Task on Task Scheduler you will need too ensure the script is run by a user who has Log On As Service permissions and can sign into the WAC web application. The Devices database that gets backed up only backs up the devices that are under that user account. This means you will need to sign in at least once with the user this cmdlet runs as to add devices from Active Directory to their account. The devices you add are the devices that will get backed up by this cmdlet when run by that user.


.PARAMETER Uri
This paramaeter defines the URI of the Windows Admin Center.

.PARAMETER Path
This paramaeter is used to define the file name and location to save the db info too.


.EXAMPLE
Backup-WindowsAdminCenterDB -Uri "https://wac.domain.com:6516" -Path "C:\WAC-Backups"
# This example backups up the contents of the Windows Admine Center device database at wac.domain.com on port 6516 to C:\WAC-Backups\2021.01.22.csv

    
.INPUTS
None
    
    
.OUTPUTS
None
    
    
.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://roberthsoborne.com
https://writeups.osbornepro.com
https://www.btps-secpack.com
https://github.com/tobor88
https://gitlab.com/tobor88
https://www.powershellgallery.com/profiles/tobor
https://www.linkedin.com/in/roberthosborne/
https://www.youracclaim.com/users/roberthosborne/badges
https://www.hackthebox.eu/profile/52286

#>
Function Backup-WindowsAdminCenterDB {
    [CmdletBinding()]
        param(
            [Parameter(
                Mandatory=$True,
                Position=0,
                ValueFromPipeline=$False,
                HelpMessage="`n[H] Define the URL to the Windows Admin Center web application`n[E] EXAMPLE: https://wac.domain.com:6516")]  # End Parameter
            [String]$Uri,
            
            [Parameter(
                Mandatory=$True,
                Position=1,
                ValueFromPipeline=$False,
                HelpMessage="`n[H] Define the path to save the db info. File will be saved in CSV format and named automatically based on the date `n[E] EXAMPLE: C:\WAC-Backups")]  # End Parameter
            [String]$Path)  # End param


    $Date = Get-Date -Format yyyy.MM.dd
    $FilePath = $Path + "\" + $Date + ".csv"
    
    If (Test-Path -Path "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools")
    {
    
        Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools"

    }  # End If
    Else
    {

        Throw "[x] $env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools does not exist"

    }  # End Else


    If (Test-Path -Path $FilePath)
    {

        Write-Output "[*] $FilePath already exists. Creating new file $FilePath"
        Export-Connection $Uri -FileName $FilePath

    }  # End If
    Else
    {

        Write-Output "[*] Creating file $FilePath"
        Export-Connection $Uri -FileName $FilePath

    }  # End Else

    If (Test-Path -Path $FilePath)
    {

        Write-Output "[*] Backup file successfully created"

    }  # End If
    Else
    {

        Write-Warning "[x] FAILURE: Backup file was not created"

    }  # End Else

}  # End Function Backup-WindowsAdminCenterDB
