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

echo "Linking non-root files"
ln -s /home/$non_root/git/fresh-linux/dotfiles/server/not-root/.bash_aliases /home/$non_root/.bash_aliases
rm -f /home/$non_root/.bashrc
ln -s /home/$non_root/git/fresh-linux/dotfiles/server/not-root/.bashrc /home/$non_root/.bashrc
rm -f /home/$non_root/.bash_profile
ln -s /home/$non_root/git/fresh-linux/dotfiles/server/not-root/.bash_profile /home/$non_root/.bash_profile
ln -s /home/$non_root/git/fresh-linux/dotfiles/server/not-root/.nanorc /home/$non_root/.nanorc


echo "Linking root files"
if [ -f "/home/$non_root/git/fresh-linux/dotfiles/server/root/.bash_aliases" ]; then
    sudo ln -s /home/$non_root/git/fresh-linux/dotfiles/server/root/.bash_aliases /root/.bash_aliases
fi
if [ -f "/home/$non_root/git/fresh-linux/dotfiles/server/root/.bashrc" ]; then
    sudo rm -f /root/.bashrc
    sudo ln -s /home/$non_root/git/fresh-linux/dotfiles/server/root/.bashrc /root/.bashrc
fi
if [ -f "/home/$non_root/git/fresh-linux/dotfiles/server/root/.bash_profile" ]; then
    sudo rm -f /root/.bash_profile
    sudo ln -s /home/$non_root/git/fresh-linux/dotfiles/server/root/.bash_profile /root/.bash_profile
fi

echo "Copying system configuration files"
if [ -f "/root/config/etc/asound.conf" ]; then
    sudo ln -s /root/config/etc/asound.conf /etc/asound.conf
fi
if [ -f "/root/config/etc/mpd.conf" ]; then
    sudo ln -s /root/config/etc/mpd.conf /etc
