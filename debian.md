# Debian 10

Run as sudo from now onwards:
```
sudo su
```


## Update the system
```
apt update
apt full-upgrade
```


## Install and config a firewall [1]
Uncomplicated FireWall (UFW)

```
apt install ufw
```


Config some basic rules
```
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
```

Enable the firewall
```
ufw enable
```


## Install some utilities:
```
apt install -y tldr tree locate debian-keyring
```


## Install Docker
See [Docker docs](https://docs.docker.com/engine/install/debian/)

Add non-sudo user to docker group in order to use docker without sudo.
```
sudo usermod -aG docker your-user
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
mkdir /mnt/mydisk
```

4. Mount the storage device at the mount point you created:
```
mount /dev/sda1 /mnt/mydisk
```

5. Verify that the storage device is mounted successfully by listing the contents:
```
ls /mnt/mydisk
```


### Setting up automatic mounting
1. Get the UUID of the disk partition:
```
blkid
```

2. Find the disk partition from the list and note the UUID. For example, `5C24-1453`.

3. Open the fstab file using a command line editor:
```
nano /etc/fstab
```

4. Add the following line in the fstab file:
```
UUID=5C24-1453 /mnt/mydisk fstype defaults,auto,users,rw,nofail 0 0
```
Replace fstype with the type of your file system, which you found in step 2 of 'Mounting a storage device' above, for example: ntfs.

5. If the filesystem type is FAT or NTFS, add `,umask=000` immediately after nofail - this will allow all users full read/write access to every file on the storage device.


### Install Git
```apt install git
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


[1]:https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands
[2]:https://www.raspberrypi.org/documentation/configuration/external-storage.md
