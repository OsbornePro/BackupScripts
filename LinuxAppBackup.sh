#!/bin/bash
# CRONTAB EXAMPLE: 
#59 11 15 * * /bin/bash /root/backups/LinuxAppBackup.sh

# Script may require some customization on your part. Script was written on a Raspberry PI. Your command absolute paths may differ on different Linux distros

# This script is used for backing up important application and service files. To add more directories or files to the backup simply add more them to the BACKUP_FILES variable.
# This saves a backup of files to /root/backups and mounts any drive connected called "backups" and saves a copy there as well



/usr/bin/printf "[*] Script exectiion started at $(date +%Y-%m-%d::%H:%M:%s)\n"

DATE=$(date +%Y-%m-%d-%H%M%S)
BACKUP_DIR="/media/backups"

BACKUP_FILES=('/etc/postfix' '/etc/mailname' '/etc/postfix/sasl_passwd.db' '/etc/postfix/sasl_passwd' '/etc/aliases')
STAGING_DIR="/root/backups"


# Ensure external drive is mounted
if [ ! -d $BACKUP_DIR ]; then
        /bin/mount -a || /usr/bin/printf "[!] Failed to mount drive\n"
else
        /usr/bin/printf "[*] Mounted file system found\n"
fi


# Creating the staging directory to save files
if [ ! -d $STAGING_DIR ]; then
        /bin/mkdir -p $STAGING_DIR
fi


# Verify the directory exists before attempting backup
if [ -d $STAGING_DIR ] && [ -d $BACKUP_DIR  ]; then
        /usr/bin/printf "[*] Backing up files...\n"
        /bin/tar czpf $STAGING_DIR/file-backups_$DATE.tar.gz ${BACKUP_FILES[@]}

        
        if [ -f $STAGING_DIR/file-backups_$DATE.tar.gz ]; then
                /bin/cp $STAGING_DIR/file-backups_$DATE.tar.gz $BACKUP_DIR/file-backups_$DATE.tar.gz && /usr/bin/printf "[*] File backup transfers have completed\n"
        else
                /usr/bin/printf "[!] Backup file did not exist in $STAGING_DIR so file backups can not be moved to backup share.\n"
        fi
else
        /usr/bin/printf "[!] Staging or Backup directory is non-existent\n"
fi


# Setting permissions on the backed up files
/bin/chown root:root $BACKUP_DIR
/bin/chown root:root $BACKUP_DIR/*.tar.gz
/bin/chmod 600 $BACKUP_DIR
/bin/chmod 600 $BACKUP_DIR/*.tar.gz


/usr/bin/printf "[*] Script execution completed $(date +%Y-%m-%d::%H:%M:%s)\n"
