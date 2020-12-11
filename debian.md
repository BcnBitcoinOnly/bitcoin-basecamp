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


## Overclock CPU [3]
Edit /boot/config.txt and change the following:
```
over_voltage=2
arm_freq=1750
```


### Install some utilities:
```
sudo apt install -y tldr tree locate debian-keyring logrotate lnav
```


### Install Docker
See Docker docs. [4]

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

Alternative, for Raspbian OS:
First install dependencies (and PIP):
```
sudo apt install -y libffi-dev libssl-dev
sudo apt install -y python3-pip
```

Then, install with PIP:
```
sudo pip3 install -y docker-compose
```

Add non-sudo user to docker group in order to use docker without sudo.
```
sudo usermod -aG docker YOUR-USER
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
sudo mkdir /mnt/mydisk
```

4. Mount the storage device at the mount point you created:
```
sudo mount /dev/sda1 /mnt/mydisk
```

5. Verify that the storage device is mounted successfully by listing the contents:
```
sudo ls /mnt/mydisk
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
Edit /etc/ssh/sshd_config with the following [5]
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



## Install a LEMP stack (Linux + Nginx + MariaDB + PHP)


### Install Nginx (webserver)
```
sudo apt install -y nginx
```

Allow Nginx in the firewall
```
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'
```


### Install Maria DB (SQL server)
```
sudo apt install -y mariadb-server
```

Configurar db root user and answer "Y" to all the questions
```
sudo mysql_secure_installation
```


### Install PHP
```
sudo apt install -y php-fpm php-mysql
```


## Install Pi-Hole
```
wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh
```

Allow ports in firewall
```
sudo ufw allow 53/tcp comment DNS
sudo ufw allow 53/udp comment DNS
sudo ufw allow 67/tcp comment DHCP
sudo ufw allow 67/udp comment DHCP
sudo ufw allow 546:547/udp comment "DHCP IPv6"
```


## Install Unbound
```
sudo apt install -y unbound
```

See [Pi-Hole Docs](https://docs.pi-hole.net/guides/unbound/) to config Unbound and Pi-Hole.


## Install Unattended Upgrades
```
sudo apt install -y unattended-upgrades
```

Configure as [following](https://libre-software.net/ubuntu-automatic-updates/):


## Install Wireguard VPN
Wireguard is still not available in stable repositories. It is neccesary to [install from Debian Backports](https://backports.debian.org/Instructions/).

Add Debian Backports to sources.list and then accept GPG keys:
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
```

Now, install Wireguard
```
sudo apt update
sudo apt install -y wireguard linux-headers
```

Allow firewall rules
```
sudo ufw allow 51820/udp comment Wireguard
```

Initiate Wireguard interface
```
sudo dkms status
sudo dkms build wireguard/1.0.20200520
sudo dkms install wireguard/1.0.20200520
sudo modprobe wireguard
sudo wg-quick up wg0
```

Start Wireguard on boot
```
sudo systemctl enable wg-quick@wg0
```


## Install backups utilities
sudo apt install -y borgbackup rsync rclone

[1]:https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands
[2]:https://www.raspberrypi.org/documentation/configuration/external-storage.md
[3]:https://magpi.raspberrypi.org/articles/how-to-overclock-raspberry-pi-4
[4]:https://docs.docker.com/engine/install/debian/
[5]:https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server
