## Update the system
```
sudo apt update
sudo apt -y full-upgrade
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
sudo ufw limit $SSH_PORT/tcp comment SSH
```

Enable the firewall
```
sudo ufw enable
```


## Install some utilities:
```
sudo apt install -y tldr tree locate debian-keyring logrotate lnav dnsutils docker docker-compose qrencode
```

### Install backups utilities
```
sudo apt install -y borgbackup rsync rclone
```


Export variables
```
export GIT_USER='Federico'
export GIT_MAIL='me@federicociro.com'
```

### Install Git
```
sudo apt install -y git
```
#### Set Global Credentials
Set your username:
```
git config --global user.name $GIT_USER
```

Set your email address: 
```
git config --global user.email $GIT_MAIL
```


#### Connect with GitHub by a SSH key
  1- Generate a SSH key
```
ssh-keygen -t rsa -b 4096 -C $GIT_MAIL
```
  
  2- Initiate the SSH-key agent.
```
eval `ssh-agent -s`
```

  3- Add the SSH key to your SSH-key agent.
```
ssh-add ~/.ssh/github.com
```
  
  4- Add the SSH key to your GitHub account.
  Copy the content of the key and paste in the Github SSH keys section.
```
cat ~/.ssh/github.com.pub
```
