# This PowerShell script can be used as a task that checks for and updates devices in a Nimble Group. 
# REQUIREMENTS: PowerShell Module HPENimblePowerShellToolKit
$NimbleGroup = "nimble-group.domain.com"
Write-Output "[*] Importing required commands"
Import-Module -Name HPENimblePowerShellToolkit -Force

# Lines 6-11 can be created using another PS script I wrote https://github.com/tobor88/PowerShell/blob/master/Hide-PowerShellScriptPassword.ps1
Write-Output "[*] Authenticating to Nimble device"
$Var = "AAAAAAAAAAAAAAAAAAAA"
$User = "user@domain.com"
$PasswordFile = "C:\Users\Public\Documents\PwdHide\$Var.AESpassword.txt"
$KeyFile = "C:\Users\Public\Documents\PwdHide\$Var"
$Key = Get-Content -Path $KeyFile
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content -Path $PasswordFile | ConvertTo-SecureString -Key $Key)
 
Connect-NsGroup –Group $NimbleGroup -ImportServerCertificate -Credential (Get-Credential -Credential $Cred)

Write-Output "[*] Checking for available versions"
$Versions = Get-NSSoftwareVersion -ErrorAction SilentlyContinue | Select-Object -Property Name,Version
$Available = $Versions | Where-Object -Property Name -eq "available"
$Installed = $Versions | Where-Object -Property Name -eq "installed"

If ($Available.version -ne $Installed.version)
{

    Write-Output "[*] New version has been found to exist. Performing update"
    $Id = Get-NsGroup | Select-Object -ExpandProperty Id
    Start-NSGroupSoftwareDownload -Id $Id -Version $Available.version -Force

    $Result = Start-NSGroupSoftwareUpdate -Id $Id
    While ($Result.error -eq "SM_einprogrress")
    {

        $Result = Start-NSGroupSoftwareUpdate -Id $Id
        Start-Sleep -Seconds 60

    }  # End While

}  # End If
