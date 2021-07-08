<#
.SYNOPSIS
This cmdlet is used to update the Unitrends appliance with the use of it's API


.DESCRIPTION
This cmdlet updates the Unitrends appliance by creating an authenticated session to the Unitrends appliance. The auth token is then used to contact the API and update the appliance.


.PARAMETER Server
This parameter is used to define the FQDN or IP address of the Unitrends appliance

.PARAMETER Port
This parameter defines the HTTP or HTTPS port that is open on your Unitrends appliance. The default value is 443

.PARAMETER Protocol
This parameter defines whether you are using HTTP or HTTPS. The default value is HTTPS

.PARAMETER Username
This parameter is used to define the user you wish to authenticate as

.PARAMETER Passwd
This parameter accepts the password used to authenticate the -Username user you define


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://roberthosborne.com/f/dns-protections-and-applications
https://roberthsoborne.com
https://writeups.osbornepro.com
https://github.com/tobor88
https://gitlab.com/tobor88
https://www.powershellgallery.com/profiles/tobor
https://www.linkedin.com/in/roberthosborne/
https://www.youracclaim.com/users/roberthosborne/badges
https://www.hackthebox.eu/profile/52286


.INPUTS
None


.OUTPUTS
None

#>
Function Update-Unitrends {
    [CmdletBinding()]
        param(
            [Parameter(
                Position=0,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="`n[H] Define the FQDN or IP address of your Unitrends Appliance. `n[E] EXAMPLE: unitrends.domain.com")]  # End Parameter
            [String]$Server,

            [Parameter(
                Mandatory=$False,
                ValueFromPipeline=$False)]  # End Parameter
            [Int32]$Port = 443,

            [Parameter(
                Mandatory=$False,
                ValueFromPipeline=$False)]  # End Parameter
            [ValidateSet('http','https')]
            [String]$Protocol = 'https',

            [Parameter(
                Position=1,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="`n[H] Enter the username you wish to authenticate to your Unitrends appliance with. `n[E] EXAMPLE: root")]  # End Parameter
            [String]$Username,

            [Parameter(
                Position=2,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="`n[H] Enter the password for the username you are authenticating as, EXAMPLE: Password123!")]  # End Parameter
            [String]$Passwd

        )  # End param

    Write-Verbose "Sending authentication request to appliance"

    $LoginURL = "$Protocol" + "://" + "$Server" + ":" + "$Port" + "/api/login"
    $Headers = New-Object -TypeName "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add('User-Agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36')
    $Headers.Add("Host","$Server")
    $Body = @{username=$Username;password=$Passwd} | ConvertTo-Json

    $LoginRequest = Invoke-WebRequest -Method POST -UseBasicParsing -Uri $LoginURL -SessionVariable $WebSession -Headers $Headers -Body $Body -ContentType "application/json"
    
    If ($LoginRequest.StatusCode -eq 201)
    {

        Write-Output "[*] Successfully authenticated to appliance"

    }  # End If
    Else
    {

        Throw "[x] Invalid credentials entered"

    }  # End Else



    Write-Verbose "Checking for available updates"

    $AuthToken = ($LoginRequest.Content | ConvertFrom-Json).auth_token
    $UpdateURL = "$Protocol" + "://" + "$Server" + ":" + "$Port" + "/api/updates"
    $Headers = New-Object -TypeName "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add('User-Agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36')
    $Headers.Add("Host","$Server")
    $Headers.Add("AuthToken","$AuthToken")
 
    $CheckUpdateRequest = Invoke-WebRequest -Method GET -Uri $UpdateURL -WebSession $WebSession -Headers $Headers -ContentType "application/json"
    $UpdatesAvailable = ($CheckUpdateRequest.Content | ConvertFrom-Json).data.updates

    If ($Null -eq $UpdatesAvailable)
    {

        Write-Output "[*] Unitrends appliance fully up to date"

    }  # End If
    Else 
    {  

        $InstallUpdates = Invoke-WebRequest -UseBasicParsing -Method POST -Uri $UpdateURL -WebSession $WebSession -Headers $Headers -ContentType "application/json"
        If ($InstallUpdates.StatusCode -eq 201)
        {

            Write-Output "[*] Update request successfully initiated"

            If (0 -ne (($InstallUpdates.Content | ConvertFrom-Json).result.code))
            {

                $Results = ($InstallUpdates.Content | ConvertFrom-Json).result

                $Css = @"
<style>
table {
    font-family: verdana,arial,sans-serif;
        font-size:11px;
        color:#333333;
        border-width: 1px;
        border-color: #666666;
        border-collapse: collapse;
}
th {
        border-width: 1px;
        padding: 8px;
        border-style: solid;
        border-color: #666666;
        background-color: #dedede;
}
td {
        border-width: 1px;
        padding: 8px;
        border-style: solid;
        border-color: #666666;
        background-color: #ffffff;
}
</style>
"@ # End CSS 
                $PreContent = "<Title>Unitrends Appliance Updated</Title>"
                $NoteLine = "This Message was Sent on $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')"
                $PostContent = "<br><p><font size='2'><i>$NoteLine</i></font>"
                $MailBody = $Results | ConvertTo-Html -Head $Css -PostContent $PostContent -PreContent $PreContent -Body "<br>This email has been sent to inform you that the Unitrends appliance update request has been initated successfully.<br><br><hr><br><br>" | Out-String

                # Below output can be generated using https://github.com/tobor88/PowerShell/blob/master/Hide-PowerShellScriptPassword.ps1
                $Var1 = 'BBBBBBBBBBBBBBBBBBBB'
                $User1 = "from-email@domain.com"
                $PasswordFile1 = "C:\Users\Public\Documents\PwdHide\$Var1.AESpassword.txt"
                $KeyFile1 = "C:\Users\Public\Documents\PwdHide\$Var1"
                $Key1 = Get-Content -Path $KeyFile1
                $Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User1, (Get-Content -Path $PasswordFile1 | ConvertTo-SecureString -Key $Key1)

                Send-MailMessage -From $User1 -To $To -Subject "Unitrends Appliance Updated" -BodyAsHtml -Body "$MailBody" -Credential $Cred -UseSSL -Port 587 -SmtpServer smtp.office365.com

            }  # End If

        }  # End If
        ElseIf ($InstallUpdates.StatusCode -eq 500)
        {

            Write-Output "[x] Reference returned error code at https://github.com/unitrends/unitrends-api-doc/wiki/API-Document#result-format"
            $Code = ($InstallUpdates.Content | ConvertFrom-Json).result.code | Out-String

            Write-Warning "[!] ERROR CODE: $Code `nUpdate request failed"

            $Results = ($InstallUpdates.Content | ConvertFrom-Json).result

            $Css = @"
<style>
table {
    font-family: verdana,arial,sans-serif;
        font-size:11px;
        color:#333333;
        border-width: 1px;
        border-color: #666666;
        border-collapse: collapse;
}
th {
        border-width: 1px;
        padding: 8px;
        border-style: solid;
        border-color: #666666;
        background-color: #dedede;
}
td {
        border-width: 1px;
        padding: 8px;
        border-style: solid;
        border-color: #666666;
        background-color: #ffffff;
}
</style>
"@ # End CSS 
            $PreContent = "<Title>Failed Unitrends Appliance Update</Title>"
            $NoteLine = "This Message was Sent on $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')"
            $PostContent = "<br><p><font size='2'><i>$NoteLine</i></font>"
            $MailBody = $Results | ConvertTo-Html -Head $Css -PostContent $PostContent -PreContent $PreContent -Body "<br>This email has been sent to inform you that the Unitrends appliance update request has failed. Please update manually and verify the update script is working. A password may need to be updated.<br> ERROR CODE: $Code <br>Error code reference at https://github.com/unitrends/unitrends-api-doc/wiki/API-Document#result-format<br><br><hr><br><br>" | Out-String

            # Below output can be generated for your user using https://github.com/tobor88/PowerShell/blob/master/Hide-PowerShellScriptPassword.ps1
            $Var1 = 'BBBBBBBBBBBBBBBBBBBB'
            $User1 = "from-user@domain.com"
            $PasswordFile1 = "C:\Users\Public\Documents\PwdHide\$Var1.AESpassword.txt"
            $KeyFile1 = "C:\Users\Public\Documents\PwdHide\$Var1"
            $Key1 = Get-Content -Path $KeyFile1
            $Cred1 = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User1, (Get-Content -Path $PasswordFile1 | ConvertTo-SecureString -Key $Key1)

            Send-MailMessage -From $From -To $To -Subject "FAILED Unitrends Appliance Update Request" -BodyAsHtml -Body "$MailBody" -Credential $Cred1 -UseSSL -Port 587 -SmtpServer smtp.office365.com

        }  # End Else

    }  # End Else

}  # End Function Update-Unitrends


# Update these values. $Username is the user that authenticates to Unitrends and $To is the email address to send notifications too
$Username = 'root'
$To = "to-user@domain.com"

# Below Output can be generated for your user using https://github.com/tobor88/PowerShell/blob/master/Hide-PowerShellScriptPassword.ps1
$Var = 'AAAAAAAAAAAAAAAAAAAA'
$PasswordFile = "C:\Users\Public\Documents\PwdHide\$Var.AESpassword.txt"
$KeyFile = "C:\Users\Public\Documents\PwdHide\$Var"
$Key = Get-Content -Path $KeyFile
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, (Get-Content -Path $PasswordFile | ConvertTo-SecureString -Key $Key)
$SecurePass = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Cred.Password)
$PassString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($SecurePass)


Update-Unitrends -Server $UnitrendServer -Port 443 -Protocol https -Username $Username -Passwd $PassString

Remove-Variable -Name PassString,PasswordFile
