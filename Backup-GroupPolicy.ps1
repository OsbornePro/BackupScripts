<#
.SYNOPSIS
Backup-GroupPolicy is used to backup up Group Policy settings and create a reference guide for the backed up policies.


.DESCRIPTION
Backs up group policies and creates a reference file for the backed up GPO's.


.PARAMETER Path
This parameter defines the Local path to save a copy of the Group Policy backups

.PARAMETER Destination
This parameter defines a network share location for temporary drive mappings to save the backed up GPOs


.EXAMPLE
Backup-GroupPolicy -Path "C:\GPOBackups" -Destination -Destination "\\networkshare\files$\GPOBackups"
# This example saves a copy of GPO backups too a folder named using todays date in C:\GPOBackups\ and saves a copy to the network share \\networkshare\files$\GPOBackups


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://roberthsoborne.com
https://osbornepro.com
https://btps-secpack.com
https://github.com/tobor88
https://gitlab.com/tobor88
https://www.powershellgallery.com/profiles/tobor
https://www.linkedin.com/in/roberthosborne/
https://www.youracclaim.com/users/roberthosborne/badges
https://www.hackthebox.eu/profile/52286

#>
Function Backup-GroupPolicy {
    [CmdletBinding()]
        param(
            [Parameter(
                Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True)]
            [System.IO.FileInfo]$Path,

            [Parameter(
                Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True)]
            [System.IO.FileInfo]$Destination
            
        ) # End param

    BEGIN
    {
    
        Import-Module -Name GroupPolicy

        $Date = Get-Date -Format M.d.yyyy
        $Paths = $Path, $Destination

        If ((Test-Path -Path $Paths) -eq $False)
        {

            Write-Verbose 'Backup has not been run today. Making a folder using todays date...'
            New-Item -Path $Paths -ItemType 'Directory'

        } # End If
        Else
        {

            Throw 'Backup has already been run today.'

        } # End Else

        Try 
        {
            
            Write-Verbose "Mapping network drive location as defined by the -Destination parameter..."
            New-PsDrive -Name 'G' -PSProvider 'FileSystem' -Root $Destination -Description 'Temp drive mapping for backing up GPOs.' -Scope 'Global' -Persist

        } # End Try
        Catch
        {

            Write-Warning "Drive G is already mapped. Press Ctrl+C to cancel script execution or press enter to continue.`nIf you have the G drive mapped to a network share or drive already this wont work. Change the cmdlet as I am not error handling that you Nancy."
            Pause

        } # End Catch

    } #End BEGIN 

    PROCESS
    {
        Try 
        {

            Write-Verbose "IN PROGRESS: Backing up GPO's to $Path\$Date..."
            Backup-Gpo -All -Path "$Path\$Date" | Out-Null

        } # End Try
        Catch
        {

            $Error[0]    
            Throw "Failed to backup GPO's to $Path\$Date"

        } # End Catch

        Try 
        {

            Write-Verbose "Creating GUID reference for the backed up Group Policies at $Path\$Date\GUIDReference.csv" 
            Get-GPO -All | Select-Object -Property 'DisplayName','GpoId' | Out-File "$Path\$Date\GUIDReference.csv"

            Write-Verbose "Adding GUID Folder descriptions to $Path\$Date\GUIDFolderDescription.csv"
            Get-ChildItem "$Path\$Date" -Directory -Recurse -Force | Out-String | Out-File "$Path\$Date\GUIDFolderDescription.csv"

         }# End Try
        Catch
        {

            Write-Error "There was an issue creating csv file containing GUID reference information."
            $Error[0]

        } # End Catch

    } # End PROCESS

    END 
    {

        Try
        {

            Write-Verbose "Copying $Path to $Destination"
            Copy-Item -Path "$Path\$Date" -Destination $Destination -Recurse -Force

        } # End Try
        Catch
        {

            Write-Error "There was an error copying $Path\$Date to $Destination."
            $Error[0]
        
        } #End Catch
        
        Try
        {

            Write-Verbose "Removing mapped destination drive...."
            Remove-PSDrive -Name 'G' -PSProvider 'FileSystem' -Scope 'Global' -Force

        } # End Try
        Catch
        {

            Write-Error "There was an error removing the mapped PSDrive"
            $Error[0]

        } # End Catch

    } # End END

} # End Function Backup-GroupPolicy
