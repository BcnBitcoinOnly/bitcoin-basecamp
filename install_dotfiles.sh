# /bin/bash

echo "Linking non-root files"
ln -s /home/$USER/git/fresh-linux/dotfiles/server/not-root/.bash_aliases /home/$USER/.bash_aliases
rm /home/$USER/.bashrc
ln -s /home/$USER/git/fresh-linux/dotfiles/server/not-root/.bashrc /home/$USER/.bashrc
rm /home/$USER/.bash_profile
ln -s /home/$USER/git/fresh-linux/dotfiles/server/not-root/.bash_profile /home/$USER/.bash_profile
ln -s /home/$USER/git/fresh-linux/dotfiles/server/not-root/.nanorc /home/$USER/.nanorc

echo "Linking root files"
sudo ln -s /home/$USER/git/fresh-linux/dotfiles/server/root/.bash_aliases /root/.bash_aliases
sudo rm /root/.bashrc
sudo ln -s /home/$USER/git/fresh-linux/dotfiles/server/root/.bashrc /root/.bashrc
sudo rm /root/.bash_profile
sudo ln -s /home/$USER/git/fresh-linux/dotfiles/server/not-root/.bash_profile /root/.bash_profile
