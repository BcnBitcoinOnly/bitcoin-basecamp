# Fresh-linux
Firsts steps for a fresh new installation of some UNIX distributions. Applies both for home servers and desktops.
General instructions for Debian/Ubuntu amd64, armhf and arm64. Some of these instructions are not neccesary if system is recovered from a backup. 

## Default usernames for some common distributions

| Username | Password |
| -------- |----------|
| root     |          |
| root     | toor     |
| ubuntu   | ubuntu   |
| pi       | raspberry|


## Edit hostname
Edit the following files and reboot
```
sudo nano /etc/hostname
sudo nano /etc/hosts
```

## Set the timezone and enable automatic synchronization
```
sudo timedatectl set-timezone
sudo apt install ntp
```

## Update the system
Debian based OS:
```
sudo apt update
sudo apt -y full-upgrade
```

Arch based OS:
```
sudo pacman -Syu
```


## Install and [config a firewall][1]
Uncomplicated FireWall (UFW)
```
sudo apt install -y ufw
```
Config some basic rules
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit from 192.168.0.0/16 to any port 22 proto tcp comment 'SSH server'
```

Enable the firewall
```
sudo ufw enable
```

## Harden OS
### Do some check routines:
- Ensure Only root Has UID of 0
```
awk -F: '($3=="0"){print}' /etc/passwd
```
- Check for Accounts with Empty Passwords
```
cat /etc/shadow | awk -F: '($2==""){print $1}'
```

### Change default user [more info][2]
Create new user and it to sudo and other groups
```
export NEW_USER=feder
sudo adduser $NEW_USER
sudo usermod -a -G adm,dialout,cdrom,floppy,sudo,audio,video,dip,plugdev,games,users,input,netdev,lxd $NEW_USER
sudo reboot now
```
Delete default "ubuntu" user and permission to sudo without password for pi.
```
sudo deluser -remove-home ubuntu
```


## Install some utilities:
Debian:
```
sudo apt install -y git tldr tree logrotate lnav dnsutils qrencode borgbackup rsync rclone net-tools ssh-askpass
sudo apt install -y locate debian-keyring
sudo apt install -y libraspberrypi-bin
```

ARCH:
```
sudo pacman -S git tldr tree logrotate lnav dnsutils qrencode borgbackup rsync rclone net-tools
```

### Configure Git
```
export GIT_USER='yourname'
export GIT_MAIL='yourmail'
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
Add instructions 2 and 3 to `/home/$USER/.bash_profile`(Headless) or `/home/$USER/.profile`(GUI) in order to always load your private key on boot.
  
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


## [Mount][3] a storage device
You can mount your storage device at a specific folder location. It is conventional to do this within the `/mnt` folder, for example `/mnt/mydisk`. Note that the folder must be empty.
Sometimes it is also convenient moving /home and /var folder to a [separate disk or partition][4].

1. Plug in the storage device.

2. List all the disk partitions on the Pi using the following command:
```
lsblk -o UUID,NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL
```

3. Create a target folder to be the mount point of the storage device. The mount point name used in this case is mydisk. You can specify a name of your choice:
```
sudo mkdir /mnt/usb
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
UUID=5C24-1453 /mnt/usb ext4 defaults,auto,users,rw,nofail 0 0
```
Replace fstype with the type of your file system, which you found in step 2 of 'Mounting a storage device' above, for example: ntfs.

5. OPTIONAL: If the filesystem type is FAT or NTFS, add `,umask=000` immediately after nofail - this will allow all users full read/write access to every file on the storage device.


### Harden' SSH security
Add authorized public SSH keys
```
mkdir /home/$USER/.ssh/
nano /home/$USER/.ssh/authorized_keys
```

[Edit][5] `/etc/ssh/sshd_config`

```
ListenAddress 0.0.0.0

PermitRootLogin no               
PasswordAuthentication no                                                                                                                

UsePAM no
```


#### Install Fail2ban
```
sudo apt install -y fail2ban
```

[Configure][6] fail2ban.


## Optional
### Lock root account
`#` `usermod -aG sudo $USER`
```
sudo passwd -l root
```

### Add missing [firmware][7]
```
mkdir firmware
cd firmware
wget -r -nd --no-parent -erobots=off -S '*.bin' https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/i915/
sudo mv *.bin /lib/firmware/i915/
sudo update-initramfs -c -k all
```

### Edit grub to use the right Intel firmware
```
sudo nano /etc/default/grub
```

Edit the following line in grub:
`GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i915.force_probe=4c8a"`

```
sudo update-grub
```

### Edit apt source lists
```
sudo apt edit-sources 
```

And edit / paste the following:
```
deb http://deb.debian.org/debian bullseye main contrib non-free
deb-src http://deb.debian.org/debian bullseye main contrib non-free

deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb-src http://deb.debian.org/debian-security/ bullseye-security main contrib non-free

deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb-src http://deb.debian.org/debian bullseye-updates main contrib non-free
```


## Additional guides:
- (Silverbox: GNU/Linux Home Server)[https://ovk.github.io/silverbox/]
- (The Debian Administrator's Handbook)[https://debian-handbook.info/browse/stable/]
- (Debian server)[https://servidordebian.org/]
- (Tips for your cyber hygiene)https://infosec-handbook.eu/specials/2019-ecsm/cyber-hygiene/
- (Ubuntu Server Hardening Guide)[https://www.nuharborsecurity.com/ubuntu-server-hardening-guide-2/]

[7]:https://wiki.debian.org/Firmware
[1]:https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands
[2]:https://www.raspberrypi.org/documentation/configuration/security.md
[3]:https://www.raspberrypi.org/documentation/configuration/external-storage.md
[4]:https://unix.stackexchange.com/questions/131311/moving-var-home-to-separate-partition
[5]:https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server
[6]:https://www.digitalocean.com/community/tutorials/how-fail2ban-works-to-protect-services-on-a-linux-server
