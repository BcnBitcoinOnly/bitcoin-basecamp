# Debian 10

## Update the system
```
sudo apt update
sudo apt -y full-upgrade
sudo reboot now
```

## Quick alternative to avoid all apt-updates:
```
sudo apt install -y 
```

## Export variables
```
export SSH_PORT=nnnn
export WG_PORT=nnnn
export GIT_USER='Federico'
export GIT_MAIL='me@federicociro.com'
export NEW_USER=feder
```


## Harden server
### Change default user [6]
Create new user and it to sudo and other groups
```
sudo adduser $NEW_USER
sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi alice
sudo su - alice
```
Delete default "pi" user and permission to sudo without password for pi.
```
sudo pkill -u pi
sudo deluser pi
sudo deluser -remove-home pi
sudo rm sudoers.d/010_pi-nopasswd
```

### Harden' SSH security
Edit `/etc/ssh/sshd_config` with the following [5]
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

### Install and config a firewall [1]
Uncomplicated FireWall (UFW)
```
sudo apt install -y ufw
```
Config some basic rules
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit $SSH_PORT/tcp
```

Enable the firewall
```
sudo ufw enable
```

### Install Fail2ban
```
sudo apt install -y fail2ban
```

Configure fail2ban as [following](https://www.digitalocean.com/community/tutorials/how-fail2ban-works-to-protect-services-on-a-linux-server):

## Overclock CPU [3] (optional)
Edit /boot/config.txt and change the following:
```
over_voltage=2
arm_freq=1750
```

## Install some utilities:
```
sudo apt install -y tldr tree locate debian-keyring logrotate lnav
```

### Install backups utilities
```
sudo apt install -y borgbackup rsync rclone
```

### Install Docker
See Docker docs. [4]

```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Install Docker Compose
For Debian:
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Alternative, for Raspbian OS:
First install dependencies (and PIP):
```
sudo apt install -y libffi-dev libssl-dev
sudo apt install -y python3-pip
```

Then, install with PIP:
```
sudo pip3 install docker-compose
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
  
  2- Add the SSH key to your SSH-key agent.
```
ssh-add ~/.ssh/github.com
```
  
  3- Add the SSH key to your GitHub account.
  Copy the content of the key and paste in the Github SSH keys section.
```
cat ~/.ssh/github.com.pub
```


## Mount a storage device (i.e.: USB)[2]
You can mount your storage device at a specific folder location. It is conventional to do this within the /mnt folder, for example /mnt/mydisk. Note that the folder must be empty.
1. Plug the storage device into a USB port on the Raspberry Pi.
2. List all the disk partitions on the Pi using the following command:
```
lsblk -o UUID,NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL
```
3. Create a target folder to be the mount point of the storage device. The mount point name used in this case is mydisk. You can specify a name of your choice:
```
sudo mkdir /mnt/$DISKNAME
```
4. Mount the storage device at the mount point you created:
```
sudo mount /dev/sda1 /mnt/$DISKNAME
```
5. Verify that the storage device is mounted successfully by listing the contents:
```
sudo ls /mnt/$DISKNAME
```

### Setting up automatic mounting
1. Get the UUID of the disk partition:
```
blkid
```
2. Find the disk partition from the list and note the UUID. For example, `5C24-1453`.
3. Open the fstab file using a command line editor:
```
sudo nano /etc/fstab
```
4. Add the following line in the fstab file:
```
UUID=5C24-1453 /mnt/mydisk fstype defaults,auto,users,rw,nofail 0 0
```
Replace fstype with the type of your file system, which you found in step 2 of 'Mounting a storage device' above, for example: ntfs.
5. If the filesystem type is FAT or NTFS, add `,umask=000` immediately after nofail - this will allow all users full read/write access to every file on the storage device.

## Install Wireguard VPN
Wireguard is still not available in stable repositories. It is neccesary to [install from Debian Backports](https://backports.debian.org/Instructions/).

Add Debian Backports to sources.list and then accept GPG keys:
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
```

Add `deb http://deb.debian.org/debian buster-backports main` to file `/etc/apt/sources.list`. (Alternative recover from backups)

Now, install Wireguard
```
sudo apt update
sudo apt install -y wireguard linux-headers
```

Allow firewall rules
```
sudo ufw allow $WG_PORT/udp comment Wireguard
```

Initiate Wireguard interface
```
sudo dkms status
sudo dkms build wireguard/xxxxxx
sudo dkms install wireguard/xxxxxx
sudo modprobe wireguard
sudo wg-quick up wg0
```

If problem persist after rebuilding it for new kernel, try reinstalling it with `sudo dpkg-reconfigure wireguard-dkms`.


Start Wireguard on boot
```
sudo systemctl enable wg-quick@wg0
```


Allow IP forwarding (to allow DNS request in a different subnet)
Edit `/etc/sysctl.conf` and uncomment `net.ipv4.ip_forward=1`. (Alternative recover from backups)

# Recover backups
To recover backups, always do it as `root` and with `cp -rp`. Only neccesary files. Watch out for `/etc/sudoers` and `/etc/passwd` specially. Don't override them.

##  Restore Mysql databases
Restore mysqldump file (.sql) from backup (see `var/lib/mysql/backups`).
Uncompress backup and:
```
gzip -dk db.gz
```

Restore all databases
```
sudo mysql -u root < db.sql
```



[1]:https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands
[2]:https://www.raspberrypi.org/documentation/configuration/external-storage.md
[3]:https://magpi.raspberrypi.org/articles/how-to-overclock-raspberry-pi-4
[4]:https://docs.docker.com/engine/install/debian/
[5]:https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server
[6]:https://www.raspberrypi.org/documentation/configuration/security.md
