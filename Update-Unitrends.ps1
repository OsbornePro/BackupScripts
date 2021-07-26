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
https://osbornepro.com/f/dns-protections-and-applications
https://osbornepro.com
https://writeups.osbornepro.com
https://github.com/tobor88
https://gitlab.com/tobor88
https://www.powershellgallery.com/profiles/tobor
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges
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

# SIG # Begin signature block
# MIIM9AYJKoZIhvcNAQcCoIIM5TCCDOECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2F+7ruC1X/MWc+8PAzSDxwjE
# Ci2gggn7MIIE0DCCA7igAwIBAgIBBzANBgkqhkiG9w0BAQsFADCBgzELMAkGA1UE
# BhMCVVMxEDAOBgNVBAgTB0FyaXpvbmExEzARBgNVBAcTClNjb3R0c2RhbGUxGjAY
# BgNVBAoTEUdvRGFkZHkuY29tLCBJbmMuMTEwLwYDVQQDEyhHbyBEYWRkeSBSb290
# IENlcnRpZmljYXRlIEF1dGhvcml0eSAtIEcyMB4XDTExMDUwMzA3MDAwMFoXDTMx
# MDUwMzA3MDAwMFowgbQxCzAJBgNVBAYTAlVTMRAwDgYDVQQIEwdBcml6b25hMRMw
# EQYDVQQHEwpTY290dHNkYWxlMRowGAYDVQQKExFHb0RhZGR5LmNvbSwgSW5jLjEt
# MCsGA1UECxMkaHR0cDovL2NlcnRzLmdvZGFkZHkuY29tL3JlcG9zaXRvcnkvMTMw
# MQYDVQQDEypHbyBEYWRkeSBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IC0g
# RzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC54MsQ1K92vdSTYusw
# ZLiBCGzDBNliF44v/z5lz4/OYuY8UhzaFkVLVat4a2ODYpDOD2lsmcgaFItMzEUz
# 6ojcnqOvK/6AYZ15V8TPLvQ/MDxdR/yaFrzDN5ZBUY4RS1T4KL7QjL7wMDge87Am
# +GZHY23ecSZHjzhHU9FGHbTj3ADqRay9vHHZqm8A29vNMDp5T19MR/gd71vCxJ1g
# O7GyQ5HYpDNO6rPWJ0+tJYqlxvTV0KaudAVkV4i1RFXULSo6Pvi4vekyCgKUZMQW
# OlDxSq7neTOvDCAHf+jfBDnCaQJsY1L6d8EbyHSHyLmTGFBUNUtpTrw700kuH9zB
# 0lL7AgMBAAGjggEaMIIBFjAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIB
# BjAdBgNVHQ4EFgQUQMK9J47MNIMwojPX+2yz8LQsgM4wHwYDVR0jBBgwFoAUOpqF
# BxBnKLbv9r0FQW4gwZTaD94wNAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC5nb2RhZGR5LmNvbS8wNQYDVR0fBC4wLDAqoCigJoYkaHR0cDov
# L2NybC5nb2RhZGR5LmNvbS9nZHJvb3QtZzIuY3JsMEYGA1UdIAQ/MD0wOwYEVR0g
# ADAzMDEGCCsGAQUFBwIBFiVodHRwczovL2NlcnRzLmdvZGFkZHkuY29tL3JlcG9z
# aXRvcnkvMA0GCSqGSIb3DQEBCwUAA4IBAQAIfmyTEMg4uJapkEv/oV9PBO9sPpyI
# BslQj6Zz91cxG7685C/b+LrTW+C05+Z5Yg4MotdqY3MxtfWoSKQ7CC2iXZDXtHwl
# TxFWMMS2RJ17LJ3lXubvDGGqv+QqG+6EnriDfcFDzkSnE3ANkR/0yBOtg2DZ2HKo
# cyQetawiDsoXiWJYRBuriSUBAA/NxBti21G00w9RKpv0vHP8ds42pM3Z2Czqrpv1
# KrKQ0U11GIo/ikGQI31bS/6kA1ibRrLDYGCD+H1QQc7CoZDDu+8CL9IVVO5EFdkK
# rqeKM+2xLXY2JtwE65/3YR8V3Idv7kaWKK2hJn0KCacuBKONvPi8BDABMIIFIzCC
# BAugAwIBAgIIXIhNoAmmSAYwDQYJKoZIhvcNAQELBQAwgbQxCzAJBgNVBAYTAlVT
# MRAwDgYDVQQIEwdBcml6b25hMRMwEQYDVQQHEwpTY290dHNkYWxlMRowGAYDVQQK
# ExFHb0RhZGR5LmNvbSwgSW5jLjEtMCsGA1UECxMkaHR0cDovL2NlcnRzLmdvZGFk
# ZHkuY29tL3JlcG9zaXRvcnkvMTMwMQYDVQQDEypHbyBEYWRkeSBTZWN1cmUgQ2Vy
# dGlmaWNhdGUgQXV0aG9yaXR5IC0gRzIwHhcNMjAxMTE1MjMyMDI5WhcNMjExMTA0
# MTkzNjM2WjBlMQswCQYDVQQGEwJVUzERMA8GA1UECBMIQ29sb3JhZG8xGTAXBgNV
# BAcTEENvbG9yYWRvIFNwcmluZ3MxEzARBgNVBAoTCk9zYm9ybmVQcm8xEzARBgNV
# BAMTCk9zYm9ybmVQcm8wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDJ
# V6Cvuf47D4iFITUSNj0ucZk+BfmrRG7XVOOiY9o7qJgaAN88SBSY45rpZtGnEVAY
# Avj6coNuAqLa8k7+Im72TkMpoLAK0FZtrg6PTfJgi2pFWP+UrTaorLZnG3oIhzNG
# Bt5oqBEy+BsVoUfA8/aFey3FedKuD1CeTKrghedqvGB+wGefMyT/+jaC99ezqGqs
# SoXXCBeH6wJahstM5WAddUOylTkTEfyfsqWfMsgWbVn3VokIqpL6rE6YCtNROkZq
# fCLZ7MJb5hQEl191qYc5VlMKuWlQWGrgVvEIE/8lgJAMwVPDwLNcFnB+zyKb+ULu
# rWG3gGaKUk1Z5fK6YQ+BAgMBAAGjggGFMIIBgTAMBgNVHRMBAf8EAjAAMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIHgDA1BgNVHR8ELjAsMCqgKKAm
# hiRodHRwOi8vY3JsLmdvZGFkZHkuY29tL2dkaWcyczUtNi5jcmwwXQYDVR0gBFYw
# VDBIBgtghkgBhv1tAQcXAjA5MDcGCCsGAQUFBwIBFitodHRwOi8vY2VydGlmaWNh
# dGVzLmdvZGFkZHkuY29tL3JlcG9zaXRvcnkvMAgGBmeBDAEEATB2BggrBgEFBQcB
# AQRqMGgwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmdvZGFkZHkuY29tLzBABggr
# BgEFBQcwAoY0aHR0cDovL2NlcnRpZmljYXRlcy5nb2RhZGR5LmNvbS9yZXBvc2l0
# b3J5L2dkaWcyLmNydDAfBgNVHSMEGDAWgBRAwr0njsw0gzCiM9f7bLPwtCyAzjAd
# BgNVHQ4EFgQUkWYB7pDl3xX+PlMK1XO7rUHjbrwwDQYJKoZIhvcNAQELBQADggEB
# AFSsN3fgaGGCi6m8GuaIrJayKZeEpeIK1VHJyoa33eFUY+0vHaASnH3J/jVHW4BF
# U3bgFR/H/4B0XbYPlB1f4TYrYh0Ig9goYHK30LiWf+qXaX3WY9mOV3rM6Q/JfPpf
# x55uU9T4yeY8g3KyA7Y7PmH+ZRgcQqDOZ5IAwKgknYoH25mCZwoZ7z/oJESAstPL
# vImVrSkCPHKQxZy/tdM9liOYB5R2o/EgOD5OH3B/GzwmyFG3CqrqI2L4btQKKhm+
# CPrue5oXv2theaUOd+IYJW9LA3gvP/zVQhlOQ/IbDRt7BibQp0uWjYaMAOaEKxZN
# IksPKEJ8AxAHIvr+3P8R17UxggJjMIICXwIBATCBwTCBtDELMAkGA1UEBhMCVVMx
# EDAOBgNVBAgTB0FyaXpvbmExEzARBgNVBAcTClNjb3R0c2RhbGUxGjAYBgNVBAoT
# EUdvRGFkZHkuY29tLCBJbmMuMS0wKwYDVQQLEyRodHRwOi8vY2VydHMuZ29kYWRk
# eS5jb20vcmVwb3NpdG9yeS8xMzAxBgNVBAMTKkdvIERhZGR5IFNlY3VyZSBDZXJ0
# aWZpY2F0ZSBBdXRob3JpdHkgLSBHMgIIXIhNoAmmSAYwCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FIX++jw+yibM7/YnEh728bSWOT/nMA0GCSqGSIb3DQEBAQUABIIBAK2wZSXNzMMv
# UuUbKGFGjNYIIAMt4v3KuDO45Bhscs7az7Yb2YfNiYNfrDlAKUxFxvO4YrUDppWZ
# oDmMfCueCl5457o9Csx+hwvuyecXb0FBIzWfVFZCnmxGvj8dEV6wMD2JJq8lImPL
# 7RAvzYKjl3Dm0+2f2Y6fcO3P3LREN1vFkzhdpfV6uZO/AqsBCLR4cJaqt8ejzsMm
# qUJ4xxE4TlfK+/GrHc192P6OYhSATbBGVFjaMjuhYi7MHb1kUXHjHgpJXnwYZkwS
# zmjQx0zgPZjpjK2XtCov2/G2KS8tuRQt4efEBp0mWRo9WaFrFKSbLnYMK01fBBAv
# LziYjzzORsA=
# SIG # End signature block
