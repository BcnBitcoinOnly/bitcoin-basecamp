#!/bin/sh
# Docs: https://borgbackup.readthedocs.io/en/stable/index.html

set -e

if pidof borg >/dev/null; then
    echo "borg is already running"
    exit 1
fi

borg_repo=/srv/backups/borgrepo
borg_pass='passphrase_2_change'

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=$borg_repo
export BORG_PASSPHRASE=$borg_pass

# Prepare Nextcloud container to backup database
#OCC_OUTPUT=$(docker exec --user www-data nextcloud-fpm php occ maintenance:mode)
#OCC_OUTPUT=$(sudo -u www-data php /srv/http/nextcloud/occ maintenance:mode)
#if [ "$?" -ne "0" ]; then
#    echo "failed to check if Nextcloud is already in maintenance mode"
#    exit 1
#fi

#if ! printf "%s" "$OCC_OUTPUT" | grep -q "Maintenance mode is currently disabled"; then
#    echo "unexpected occ output: $OCC_OUTPUT"
#    exit 1
#fi

#if ! sudo -u  www-data php /srv/http/nextcloud/occ maintenance:mode --on; then
#    echo "failed to enable Nextcloud maintenance mode"
#    exit 1
#fi

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"
date +"%Y-%m-%d %T"

#Before doing any other backup, dump into a .sql file all the mysql databases:
#mysqldump --all-databases --single-transaction --dump-date > /var/lib/mysql/backups/full-backup-$(date +\%F).sql

# Backup the most important directories into an archive named after
# the machine this script is currently running on:

# Create backup
borg create                                        \
                --verbose                               \
                --filter AME                            \
                --list                                  \
                --stats                                 \
                --show-rc                               \
                --compression lz4                       \
                --exclude-caches                        \
                $borg_repo::'{hostname}-{now}'          \
                /boot                                   \
                /etc                                    \
                /home                                   \
                --exclude '/home/*/.npm'                \
                --exclude '/home/*/.cache'
                
backup_exit=$?

if [ "$?" -ne "0" ]; then
    echo "borg create failed"
    exit 2
fi

#if ! docker exec --user www-data nextcloud-fpm php occ maintenance:mode --off; then
#if ! sudo -u www-data php7.4 /srv/http/drive.federicociro.com/nextcloud/occ maintenance:mode --off; then
#    echo "failed to disable Nextcloud maintenance mode"
#    exit 1
#fi

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

borg prune                              \
        --list                          \
        --prefix '{hostname}-'          \
        --show-rc                       \
        --keep-daily    7               \
        --keep-weekly   4               \
        --keep-monthly  6               \
        $borg_repo

prune_exit=$?

echo "Backup sync completed."

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