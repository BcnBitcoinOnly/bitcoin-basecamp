#!/bin/sh

borg_repo=/srv/backups/borgrepo
borg_pass='passphrase_2_change'

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=$borg_repo
export BORG_PASSPHRASE=$borg_pass

if pidof -x rclone >/dev/null; then
    echo "rclone is already running"
    exit 1
fi

# Check backup for consistency before syncing to the cloud
borg check -v $borg_repo

if [ "$?" -ne "0" ]; then
    echo "borg check failed"
    exit 2
fi

# you need to configure first backblaze, google drive, nextcloud, some other local drive, etc.
# Sync backup
rclone -v sync $borg_repo backblaze:repo

if [ "$?" -ne "0" ]; then
    echo "rclone sync failed"
    exit 3
fi

echo "Backup sync completed."
echo ""


# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi

exit ${global_exit}