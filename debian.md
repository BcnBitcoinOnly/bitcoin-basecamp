# Debian 10

Run as sudo from now onwards:
```
sudo su
```

### Install and config a firewall [1]
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


### Mount a storage device (i.e.: USB)[2]
You can mount your storage device at a specific folder location. It is conventional to do this within the /mnt folder, for example /mnt/mydisk. Note that the folder must be empty.

1. Plug the storage device into a USB port on the Raspberry Pi.

2. List all the disk partitions on the Pi using the following command:
```
lsblk -o UUID,NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL
```

3. Run the following command to get the location of the disk partition:
```
blkid
```

4. Create a target folder to be the mount point of the storage device. The mount point name used in this case is mydisk. You can specify a name of your choice:
```
mkdir /mnt/mydisk
```

5. Mount the storage device at the mount point you created:
```
mount /dev/sda1 /mnt/mydisk
```

6. Verify that the storage device is mounted successfully by listing the contents:
```
ls /mnt/mydisk
```


### Install Git

$ `sudo apt install git`

#### Connect with GitHub by a SSH key
  1- Generate a SSH key
```
$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
  
  2- Add the SSH key to your SSH-key agent.
```
$ ssh-add ~/.ssh/id_rsa
```
  
  3- Add the SSH key to your GitHub account.
  Copy the content of the key and paste in the Github SSH keys section.
```
$ cat ~/.ssh/id_rsa.pub
```


[1]:https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands
[2]:https://www.raspberrypi.org/documentation/configuration/external-storage.md
