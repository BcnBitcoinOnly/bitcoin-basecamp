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
over_voltage=6
arm_freq=2000
```


### Install some utilities:
```
sudo apt install -y tldr tree locate debian-keyring
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


## Install a LEMP stack (Linux + Nginx + MariaDB + PHP)

### Install Nginx (webserver)
```
sudo apt install -y nginx
```

Allow Nginx in the firewall
```
sudo ufw allow 'Nginx HTTP'
```

### Install Maria DB (SQL server)
```
sudo apt install -y mariadb-server
```

Configurar db root user and answer "Y" to all the questions
```
sudo mysql_secure_installation
```



[1]:https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands
[2]:https://www.raspberrypi.org/documentation/configuration/external-storage.md
[3]:https://magpi.raspberrypi.org/articles/how-to-overclock-raspberry-pi-4
[4]:https://docs.docker.com/engine/install/debian/
[5]:https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server
