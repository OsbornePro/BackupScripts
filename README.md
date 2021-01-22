# BackupScripts
Collection of PowerShell scripts that can be used to back different things up

### Backup-CA
This is used to backup a Certificate Authority's database and templates

### BackupLAPS
This is used to securely backup and keep a password history of Local Administrator Passwords assigned by LAPS

### Backup-GroupPolicy
This is used to backup group policy locally and too a network location. A GUID reference file is also created so you know the name of the GPO associated with the GUID

### Backup-WindowsAdminCenterDB
This is used to backup the devices added to a users Windows Admin Center. Devices are included on a per user basis so the user performing the backup is only backing up devices that show up when they sign in
