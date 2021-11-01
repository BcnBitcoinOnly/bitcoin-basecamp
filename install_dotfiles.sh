# /bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

echo "This script will isntall dotfiles in both non-root and root users"
echo "Type the non-root user"
read non_root

echo "Linking non-root files"
ln -s /home/$non_root/git/fresh-linux/dotfiles/server/not-root/.bash_aliases /home/$non_root/.bash_aliases
rm /home/$non_root/.bashrc
ln -s /home/$non_root/git/fresh-linux/dotfiles/server/not-root/.bashrc /home/$non_root/.bashrc
ln -s /home/$non_root/git/fresh-linux/dotfiles/server/not-root/.bash_profile /home/$non_root/.bash_profile
ln -s /home/$non_root/git/fresh-linux/dotfiles/server/not-root/.nanorc /home/$non_root/.nanorc


echo "Linking root files"
sudo ln -s /home/$non_root/git/fresh-linux/dotfiles/server/not-root/.bash_aliases /root/.bash_aliases
sudo rm /root/.bashrc
sudo ln -s /home/$non_root/git/fresh-linux/dotfiles/server/root/.bashrc /root/.bashrc
sudo ln -s /home/$non_root/.bash_profile /root/.bash_profile
