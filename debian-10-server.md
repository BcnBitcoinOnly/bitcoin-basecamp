# Debian 10
## Update the system
```
sudo apt update
sudo apt -y full-upgrade
sudo reboot now
```
## Install and config a firewall [1]
Uncomplicated FireWall (UFW)
```
sudo apt install -y ufw
```
Config some basic rules
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit ssh/tcp
```
Enable the firewall
```
sudo ufw enable
```
### Install some utilities:
```
sudo apt install -y tldr tree locate debian-keyring logrotate lnav net-tools curl
```
### Install Docker
See Docker docs. [2]
```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
#### Install Docker Compose
For Debian:
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
Add non-sudo user to docker group in order to use docker without sudo.
```
sudo usermod -aG docker $USER
```
### Install Git
```
sudo apt install -y git
```
#### Set Global Credentials
Set your username:
```
git config --global user.name "FIRST_NAME LAST_NAME"
```
Set your email address: 
```
git config --global user.email "MY_NAME@example.com"
```
#### Connect with GitHub by a SSH key
  1- Generate a SSH key
```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
  2- Add the SSH key to your SSH-key agent.
```
ssh-add ~/.ssh/id_rsa
```
  3- Add the SSH key to your GitHub account.
  Copy the content of the key and paste in the Github SSH keys section.
```
$ cat ~/.ssh/id_rsa.pub
```
## Harden' SSH security
Edit /etc/ssh/sshd_config with the following [3]
```
# Logging
SyslogFacility AUTH
LogLevel INFO

# Authentication:

#LoginGraceTime 2m
PermitRootLogin no               
#StrictModes yes
MaxAuthTries 6
MaxSessions 10

PubkeyAuthentication yes

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
AuthorizedKeysFile      .ssh/authorized_keys .ssh/authorized_keys2

# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no                                                                                                                
PermitEmptyPasswords no
```
## Install Fail2ban
```
sudo apt install -y fail2ban
```
Configure fail2ban as [following](https://www.digitalocean.com/community/tutorials/how-fail2ban-works-to-protect-services-on-a-linux-server):
## Install backups utilities
sudo apt install -y borgbackup rsync rclone
# Recover backups
To recover backups, always do it as `root` and with `cp -rp`. Only neccesary files. Watch out for `/etc/sudoers` and `/etc/passwd` specially. Don't override them.

# Sources
[1]:https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands
[2]:https://docs.docker.com/engine/install/debian/
[3]:https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server
