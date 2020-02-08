# Debian 10 Gnome
* ### Install and config a firewall
Install for example: UFW
```
$ apt-get install ufw
```
Enable the firewall
```
$ ufw enable
```
Config some [basic rules](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands)
```
$ sudo ufw default deny incoming
$ sudo ufw default allow outgoing
$ sudo ufw allow ssh
$ sudo ufw allow http
$ sudo ufw allow https
```

* ### Install Git

`$ sudo apt-get install git`

* ### Connect with GitHub by a SSH key
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

* ### Customize grub and update default settings
```
$ git clone https://github.com/vinceliuice/grub2-themes.git
```
```
$ sudo nano /etc/default/grub
```
```
$ sudo update-grub
```
