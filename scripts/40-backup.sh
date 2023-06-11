#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

script_loc=$(pwd)

sudo apt-get update

# borgbackup: Deduplicated and encrypted backups
# rsync: Efficient file synchronization
# rclone: Sync files and directories to/from cloud services
sudo apt install -y borgbackup rsync rclone

sudo mkdir /srv/backups
sudo mkdir /var/log/backups
sudo mkdir /etc/borg

# Create borg repository
sleep 1
echo "--------------------------------------------------"
echo "After this, you will be prompted for a passphrase that will be used to generate encryption key for the backups."
echo "WRITE DOWN YOUR PASSPHRASE!"
echo "--------------------------------------------------"
sleep 1
sudo borg init --encryption=repokey /srv/backups/borgrepo

# Copy configuration file
sudo cp $script_loc/../config/etc/borg/backup.sh /etc/borg/backup.sh
sudo cp $script_loc/../config/etc/borg/rclone-backup.sh /etc/borg/rclone-backup.sh
sudo ln -s /etc/borg/backup.sh /usr/local/bin/borg-backup.sh

# Restrict permissions and copy the new password
sudo chmod 0700 /etc/borg/backup.sh
sudo chmod 0700 /etc/borg/rclone-backup.sh
echo "Enter again the PASSPHRASE used to generate the Borg repository. Password will be stored in the borg backup script."
read -s -p "Enter the passphrase to use for Borg backup: " password
sudo sed -i "s/passphrase_2_change/$password/g" /etc/borg/backup.sh
sudo sed -i "s/passphrase_2_change/$password/g" /etc/borg/rclone-backup.sh

# Copy, reload systemd files and activate mempool
sudo cp -rp $script_loc/../config/etc/systemd/system/borg-backup.service /etc/systemd/system/
sudo cp -rp $script_loc/../config/etc/systemd/system/borg-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable borg-backup.timer
sudo systemctl start borg-backup.timer
sudo systemctl status borg-backup.timer
sudo systemctl status borg-backup.service

echo "Configuration complete."