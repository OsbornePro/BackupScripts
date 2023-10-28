#Requires -Version 3.0
#Requires -PSEdition Desktop
#Requires -RunAsAdministrator
<#
.SYNOPSIS
This script is used to keep a local admin password history for LAPS devices


.DESCRIPTION
This script can be used to create a backup of the Local Administrator Password Solution (LAPS) passwords in Active Directory. This needs to run on a domain controller in order to work without modification


.PARAMETER OutFile
Define the file path to save your backup password history too


.EXAMPLE
PS> .\BackupLAPS.ps1 -OutFile "C:\ProgramData\LAPS\LAPS-Backups.csv"
# This example backs up the LAPS passwords for all computer devices


.LINK
https://www.microsoft.com/en-us/download/details.aspx?id=46899
https://github.com/tobor88
https://github.com/osbornepro
https://www.powershellgallery.com/profiles/tobor
https://osbornepro.com
https://writeups.osbornepro.com
https://encrypit.osbornepro.com
https://btpssecpack.osbornepro.com
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges


.NOTES
Last Modified: 10/28/2023
Author: Robert H. Osborne (OsbornePro LLC.)
Contact: contact@osbornepro.com

At first glance you may believe this may not be a secure thing to do. 
However, this file is saved on a Domain Controller and requires SYSTEM or local Administrators group (Elevated Permissions) in order to read the file. 
If an attacker has admin access to a Domain Controller already they are already able to obtain this information on their own by querying Active Directory.


.INPUTS
None


.OUTPUTS
None
#>
[CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [ValidateScript({$_ -like "*.csv"})]
        [String]$OutFile = "C:\ProgramData\LAPS\$((Get-Date).Ticks).csv"
    )  # End param

    $TranscriptLogFile = "C:\Windows\Tasks\$(Get-Date -Format 'yyyy-MM-dd')_PSTranscript-LAPS-Backup.txt"
    Try { Start-Transcript -Path $TranscriptLogFile -Append -Force -WhatIf:$False -Verbose:$False -ErrorAction Stop | Out-Null } Catch { Write-Verbose -Message "[v] Transcript for this session is already being kept" }
    $Results = @()
    Write-Verbose -Message "[v] Verifying the parent directory you specified exists for export"
    New-Item -Path $OutFile -ItemType File -Force -ErrorAction Inquire -WhatIf:$False | Out-Null

    Write-Debug -Message "[D] Building LDAP query information to obtain LAPS password history"
    $Domain = (Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$False).Domain
    $DomainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    $PrimaryDC = ($DomainObj.PdcRoleOwner).Name
    $SearchString =  "LDAP://$($PrimaryDC):389/"
    $LdapFilter = '(objectCategory=computer)'
    $DirectoryEntry = New-Object -TypeName System.DirectoryServices.DirectoryEntry
    $Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)
       
    $DistinguishedName = "CN=$ComputerName,*,DC=$($DomainObj.Name.Replace('.',',DC='))"
    $SearchString += $DistinguishedName

    $Searcher.SearchRoot = $DirectoryEntry
    $Searcher.Filter = $LdapFilter
    $Searcher.SearchScope = "Subtree"
    $Searcher.FindAll() | ForEach-Object {

        Write-Information -MessageData "[i] Obtaining possible LAPS data for $($_.Properties.cn)"
        $Results += New-Object -TypeName PSCustomObject -Property @{
            HostName=$_.Properties.cn.Replace('{','').Replace('}','');
            Username="Administrator";
            Password=$(Try { $_.Properties.'ms-Mcs-AdmPwd'.Replace("{","").Replace("}","")} Catch { "LAPS Not Set" } );
            Domain=$Domain
        }  # End New-Object Property

    }  # End ForEach-Object
       
    If ($Null -ne $Results) {

        Write-Verbose -Message "[v] Updating devices and LAPS info"
        $Results | Export-Csv -Path $OutFile -Delimiter "," -Encoding UTF8 -NoTypeInformation -Force -Verbose:$False -WhatIf:$False

    } Else {

        Write-Error -Message "[x] No LAPS password found for $ComputerName on $Server"

    }  # End If Else


    Write-Verbose -Message "[v] Setting secure file permissions"
    $Acl = Get-Acl -Path $OutFile,$TranscriptLogFile -Verbose:$False
    $Acl.SetAccessRuleProtection($True, $False)

    $PermittedUsers = @('NT AUTHORITY\SYSTEM', 'BUILTIN\Administrators')
    ForEach ($User in $PermittedUsers) {

        $Permission = $User, 'FullControl', 'Allow'
        $AccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $Permission
        $Acl.AddAccessRule($AccessRule)

    }  # End ForEach

    $Acl.SetOwner((New-Object -TypeName System.Security.Principal.NTAccount('BUILTIN\Administrators')))
    $Acl | Set-Acl -Path $OutFile,$TranscriptLogFile -Verbose:$False -WhatIf:$False

    Try { Stop-Transcript -Verbose:$False -ErrorAction Stop | Out-Null } Catch { Write-Warning -Message "[!] No transcript was kept for this session" }
