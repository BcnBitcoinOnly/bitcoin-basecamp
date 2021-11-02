# Fresh-linux
Firsts steps for a fresh new installation of some UNIX distributions. Applies both for home servers and desktops.
General instructions for Debian/Ubuntu amd64, armhf and arm64. Some of these instructions are not neccesary if system is recovered from a backup. 


## Default usernames for some common distributions

| Username | Password |
| -------- |----------|
| root     |          |
| root     | toor     |
| ubuntu   | ubuntu   |
| raspberry| pi       |


## Update the system
```
sudo apt update
sudo apt -y full-upgrade
```


## Install and [config a firewall] [1]
Uncomplicated FireWall (UFW)
```
sudo apt install -y ufw
```
Config some basic rules
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit 22/tcp comment SSH
```

Enable the firewall
```
sudo ufw enable
```


## Install some utilities:
```
sudo apt install -y git tldr tree locate debian-keyring logrotate lnav dnsutils qrencode borgbackup rsync rclone libraspberrypi-bin net-tools
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


## Mount a storage device (i.e.: USB)[2]
You can mount your storage device at a specific folder location. It is conventional to do this within the `/mnt` folder, for example `/mnt/mydisk`. Note that the folder must be empty.

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
UUID=5C24-1453 /mnt/usb fat32 defaults,auto,users,rw,nofail 0 0
```
Replace fstype with the type of your file system, which you found in step 2 of 'Mounting a storage device' above, for example: ntfs.

5. OPTIONAL: If the filesystem type is FAT or NTFS, add `,umask=000` immediately after nofail - this will allow all users full read/write access to every file on the storage device.




[1]:https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands
[2]:https://www.raspberrypi.org/documentation/configuration/external-storage.md
