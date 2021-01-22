# DESCRIPTION: This script can be used to create a backup of the Local Administrator Password Solution (LAPS) passwords in Active Directory. This needs to run on a domain controller in order to work without modification
#
# PURPOSE: LAPS does not keep a history of previously set passwords. There may be situations that require a password from a 30+ days ago for a device. This creates a new CSV file for each month to provide you with that ability.
#
# SECURITY: At first glance you may believe this may not be a secure thing to do. However, this file is saved on a Domain Controller and requires SYSTEM or local Administrators group (Elevated Permissions) in order to read the file. If an attacker has admin access to a Domain Controller already they are already able to obtain this information on their own by querying Active Directory. To add or remove permissions for a group feel free to add the user or group at line 30.


$FileName = (Get-Date).Ticks
$FilePath = 'C:\DB\' + $FileName + '.csv'

New-Item -Path $FilePath -ItemType File -Value "ComputerName,AdmPwd"

$Computers = Get-ADComputer -Filter 'Enabled -eq "True"' -Properties "ms-Mcs-AdmPwd"

Write-Output "[*] Updating computer and LAPS info"
ForEach ($C in $Computers)
{

    If ($Null -ne $msMcsAdmPwd)
    {
    
        $Name = $C.Name
        $msMcsAdmPwd = $C.'ms-Mcs-AdmPwd'
        $OutString = $Name + ',' + $msMcsAdmPwd
        
        $OutString | Out-File -FilePath $FilePath -Append
        
    }  # End If

}  # End ForEach


Write-Output "[*] Setting file permissions"
$Acl = Get-Acl -Path $FilePath
$Acl.SetAccessRuleProtection($True, $False)

$PermittedUsers = @('NT AUTHORITY\SYSTEM', 'BUILTIN\Administrators')
ForEach ($User in $PermittedUsers) 
{

    $Permission = $User, 'FullControl', 'Allow'
    $AccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $Permission
    $Acl.AddAccessRule($AccessRule)

}  # End ForEach

$Acl.SetOwner((New-Object -TypeName System.Security.Principal.NTAccount('BUILTIN\Administrators')))
$Acl | Set-Acl -Path $FilePath
