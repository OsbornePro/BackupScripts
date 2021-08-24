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
https://osbornepro.com
https://writeups.osbornepro.com
https://btpssecpack.osbornepro.com
https://github.com/tobor88
https://gitlab.com/tobor88
https://www.powershellgallery.com/profiles/tobor
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges
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

    If (Test-Path -Path "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools") {

        Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools"

    }  # End If
    Else {

        Throw "[x] $env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools does not exist"

    }  # End Else


    If (Test-Path -Path $FilePath) {

        Write-Output "[*] $FilePath already exists. Creating new file $FilePath"
        Export-Connection $Uri -FileName $FilePath

    }  # End If
    Else {

        Write-Output "[*] Creating file $FilePath"
        Export-Connection $Uri -FileName $FilePath

    }  # End Else

    If (Test-Path -Path $FilePath) {

        Write-Output "[*] Backup file successfully created"

    }  # End If
    Else {

        Write-Warning "[x] FAILURE: Backup file was not created"

    }  # End Else

}  # End Function Backup-WindowsAdminCenterDB

# SIG # Begin signature block
# MIIM9AYJKoZIhvcNAQcCoIIM5TCCDOECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoqX6XJsD8oYf70ZrasjpsbBA
# 9zSgggn7MIIE0DCCA7igAwIBAgIBBzANBgkqhkiG9w0BAQsFADCBgzELMAkGA1UE
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
# FHA7z9KNDNZIeDv/NSbwREovqWiSMA0GCSqGSIb3DQEBAQUABIIBABRfs4xN3RFc
# cY9rLBaBViV6CPXtNCoEuUk8yFdoB1h1Tr/qCiVq3w6+osher5llecKrh1PIDK1+
# vfrrft/f6O1GnmI1pGQElN0TJ3ueNEzAn7jbgZ+6yHv2qJ4heCZY0imFx/lHGa1I
# M6YNC0XDkLpLuTK0v53Kpm3hYOhX6fhBGAXaUYdOn+TOcvvupNPdgXJEmW0fpKUF
# RyB1U85CdBPRFKdKL0qFFJKZWfCrnboTQejeha4S78yeUBZYbp+uSHQFvVu9VJs8
# MOh7vfj8cpfj9HXUHXK4Q99+O2dER2KFCa/Uxapntm01z9oOQqgKxpSKKxxyj2MX
# DTwx/5IkhmQ=
# SIG # End signature block
