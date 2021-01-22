# BackupScripts
Collection of PowerShell scripts that can be used to back different things up

### Backup-CA
This is used to backup a Certificate Authority's database and templates
```powershell
Backup-CA -Path '\\fileshare\Backups'
```

### BackupLAPS
This is used to securely backup and keep a password history of Local Administrator Passwords assigned by LAPS
```powershell
.\BackupLAPS.ps1
```

### Backup-GroupPolicy
This is used to backup group policy locally and too a network location. A GUID reference file is also created so you know the name of the GPO associated with the GUID
```powershell
Backup-GroupPolicy -Path "C:\GPOBackups" -Destination "\\networkshare\files$\GPOBackups"
```

### Backup-WindowsAdminCenterDB
This is used to backup the devices added to a users Windows Admin Center. Devices are included on a per user basis so the user performing the backup is only backing up devices that show up when they sign in
```powershell
Backup-WindowsAdminCenterDB -Uri "https://wac.domain.com:6516" -Path "C:\WAC-Backups"
```
### LinuxAppBackup.sh
This script can be used on Linux devices to backup important files or configurations you would like saved.
Below is a root user crontab entry example to run the script on the 15th of every month. It is a good idea to set the file permissons on the script too chmod 600 for the root user
```bash
59 11 15 * * /bin/bash /root/scripts/LinuxAppBackup.sh
```
