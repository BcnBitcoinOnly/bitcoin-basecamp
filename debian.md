# Debian 10

Run as sudo from now onwards:
```
$ sudo su
```

### Install and config a firewall
Uncomplicated FireWall (UFW)

```
# apt install ufw
```


Config some [basic rules](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands)
```
# ufw default deny incoming
# ufw default allow outgoing
# ufw allow ssh
```

Enable the firewall
```
# ufw enable
```

### Mount Backups disks [1]
```

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

### Customize grub and update default settings
```
$ git clone https://github.com/vinceliuice/grub2-themes.git
```
```
$ sudo nano /etc/default/grub
```
```
$ sudo update-grub
```

[1]:https://www.raspberrypi.org/documentation/configuration/external-storage.md
