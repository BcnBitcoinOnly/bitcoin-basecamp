#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

non_root=$1

if [[ -z "$non_root" ]]; then
    echo "Please provide a non-root user as an argument:"
    echo "sudo $0 <non-root user>"
    exit 1
fi

if id "$non_root" >/dev/null 2>&1; then
    echo "User $non_root exists"
else
    echo "User $non_root does not exist"
    exit 1
fi

script_loc=$(pwd)

echo "Linking non-root files"
rm -f /home/$non_root/.bashrc
cp $script_loc/../home/user/.bashrc /home/$non_root/.bashrc
rm -f /home/$non_root/.bash_profile
cp $script_loc/../home/user/.bash_profile /home/$non_root/.bash_profile
cp $script_loc/../home/user/.bash_aliases /home/$non_root/.bash_aliases
cp $script_loc/../home/user/.nanorc /home/$non_root/.nanorc