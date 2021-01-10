# Debian 10


## Update the system
```
sudo apt update
sudo apt -y full-upgrade
sudo reboot now
```

Quick alternative to avoid all apt-updates:
```
sudo apt install -y ufw tldr tree locate debian-keyring logrotate lnav git fail2ban nginx certbot python-certbot-nginx webhook mariadb-server php-fpm php-mysql php-bcmath php-gmp php-imagick phpmyadmin php-mbstring php-zip php-gd php-json php-curl php-apcu php-intl php-ldap php7.3-mbstring nginx php7.3-fpm php7.3-cgi php7.3-xml php7.3-sqlite3 php7.3-intl apache2-utils unbound unattended-upgrades borgbackup rsync rclone
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
sudo usermod -aG docker pi
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
sudo mount /dev/sda1 /mnt/usb
```

5. Verify that the storage device is mounted successfully by listing the contents:
```
sudo ls /mnt/usb
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


## Disable passwordless sudo
Edit with visudo `/etc/sudoers.d/010_pi-nopasswd` and change it to:
```
pi ALL=(ALL) PASSWD: ALL
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
sudo apt install -y nginx certbot python-certbot-nginx webhook
```

More details in this [tutorial](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-debian-10) and in [Certbot](https://certbot.eff.org/lets-encrypt/debianbuster-nginx).

Recover config files from Backup.


Allow Nginx in the firewall
```
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'
```

#### Restore Nginx configurations
Restore from backup `etc/nginx` and generate new SSL certificates for each site.


### Install Maria DB (SQL server)
```
sudo apt install -y mariadb-server
```

Configurar db root user and answer "Y" to all the questions
```
sudo mysql_secure_installation
```


####  Restore Mysql databases
Restore mysqldump file (.sql) from backup (see `var/lib/mysql/backups`).
Uncompress backup and:
```
gzip -dk db.gz
```

Restore all databases
```
sudo mysql -u root < db.sql
```


### Install PHP and some modules
```
sudo apt install -y php-fpm php-mysql php-bcmath php-gmp php-imagick
```

PHP 7.4 not available from official repositories for Raspbian as per Dec-2020. Unnoficial one from [here](https://janw.me/2019/installing-php7-4-rapsberry-pi/).


#### Install phpMyAdmin
```
sudo apt install -y phpmyadmin php-mbstring php-zip php-gd php-json php-curl php7.3-mbstring
```


## Install Pi-Hole
### Install and configure the [prerequisites](https://docs.pi-hole.net/guides/nginx-configuration/)
```
sudo apt install -y nginx php7.3-fpm php7.3-cgi php7.3-xml php7.3-sqlite3 php7.3-intl apache2-utils
```

```
wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh
sudo usermod -aG pihole www-data
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

See [Pi-Hole Docs](https://docs.pi-hole.net/guides/unbound/) to config Unbound and Pi-Hole. (Alternative recover from backups)


## Install Unattended Upgrades
```
sudo apt install -y unattended-upgrades
```

Configure as [following](https://libre-software.net/ubuntu-automatic-updates/). (Alternative recover from backups)


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


Allow IP forwarding (to allow DNS request in a different subnet)
Edit `/etc/sysctl.conf` and uncomment `net.ipv4.ip_forward=1`. (Alternative recover from backups)


## Install Nextcloud
Restore files and databases from backup.
Comment out Memcache line to recovery.

Install APCu (data cache)
```
sudo apt install -y php-apcu php-intl
```


## Install Webmin
Edit `/etc/apt/sources.list` and add the following line:
```
deb https://download.webmin.com/download/repository sarge contrib 
```

Fetch and install the GPG key with which the repository is signed:
```
wget https://download.webmin.com/jcameron-key.asc & sudo apt-key add jcameron-key.asc 
```

Install Webmin
```
sudo apt-get -y install apt-transport-https 
sudo apt-get update 
sudo apt-get -y install webmin 
```

Recover `/etc/webmin/miniserv.conf` configuration file from backup.


## Install backups utilities
sudo apt install -y borgbackup rsync rclone


# Recover backups
To recover backups, always do it as `root` and with `cp -rp`. Only neccesary files. Watch out for `/etc/sudoers` and `/etc/passwd` specially. Don't override them.


[1]:https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands
[2]:https://www.raspberrypi.org/documentation/configuration/external-storage.md
[3]:https://magpi.raspberrypi.org/articles/how-to-overclock-raspberry-pi-4
[4]:https://docs.docker.com/engine/install/debian/
[5]:https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server
