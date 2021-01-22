<#
.SYNOPSIS
This cmdlet was created to easily or automatically backup all needed information to restore a CA from backup or move to a new server.


.DESCRIPTION
Uses certutil, Backup-CARoleService, and reg export to backup all needed information and certificates as well as templates.


.PARAMETER Path
This parameter defines a directory location that should be used to save the collection of Certificate Authority Backups.


.EXAMPLE
Backup-CA -Path '\\fileshare\Backups'


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
Function Backup-CA 
{
    [CmdletBinding()]
        param(
            [Paraneter(
                Position=0,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="`n[H] Define a network share location to save your backup. This location is going to be mapped as a temporary drive T: `n[E] EXAMPLE: \\files.domain.com\networkshare$")]  # End Parameter
            [String]$Path
        )  # End param

    $Date = Get-Date -Format yyyy.MM.dd
    New-PSDrive -Name T -Root $Path -PSProvider FileSystem -Scope Global -Persist -ErrorAction SilentlyContinue

    If (!(Test-Path -Path "T:\$Date"))
    {

        Write-Verbose "Creating folder $Date because it does not already exist."
        New-Item -Path "T:\" -Name $Date -ItemType Directory -Force

        reg export HKLM\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration “T:\$Date\CAregsettings.reg”

        certutil –catemplates > “T:\$Date\CaTemplates.txt”

        Try 
        {
        
            Backup-CARoleService -Path "T:\$Date\CABackup" -KeepLog -Force

        } # End Try
        Catch
        {

            Write-Warning 'Could not backup the CA role service to network location. Backup occuring locally. Script will attempt the action with the password defined.'
            Backup-CARoleService -Path "T:\" -Password (ConvertTo-SecureString 'D0ntForgetT0SetYourPassw0rdHere!' -AsPlainText -Force) -KeepLog -Force

        } # End Catch

    } # End If
    Else
    {

        Write-Verbose "Task has already been run and backups already been obtained."

    } # End Else

} # End Function Backup-CA
