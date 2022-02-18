# Bare metal apps
For systems where containers are not preferred, bare metal can be the right choice.


## Set up a VPN server
Wireguard is choosen over OpenVPN. Install it:
```
sudo apt update
sudo apt install -y wireguard linux-headers
```

Allow firewall rules
```
sudo ufw allow to any port 51820 proto udp comment 'VPN Wireguard'
```

[Configure][1] a wg0.conf file. 

Start Wireguard on boot:
```
sudo systemctl enable wg-quick@wg0
```

Allow IP forwarding (to allow DNS request in a different subnet)
Edit `/etc/sysctl.conf` and uncomment `net.ipv4.ip_forward=1`.


## Install[2] a LEMP stack (Linux + Nginx + MariaDB + PHP) and secure it [3]
### Install Nginx (webserver)
```
sudo apt install -y nginx certbot python-certbot-nginx python3-certbot-nginx
```

Generate a wildcard SSL certificate following [this guide.][4]
TLDR: `sudo certbot certonly --manual --server https://acme-v02.api.letsencrypt.org/directory --preferred-challenges dns-01 -d "*.<DOMAIN_NAME>"`
More details in this in [Certbot][5].

Allow Nginx in the firewall
```
sudo ufw allow 80/tcp comment 'Webserver Nginx HTTP'
sudo ufw allow 443/tcp comment 'Webserver Nginx HTTPS'
```


### Install Maria DB (SQL server)
```
sudo apt install -y mariadb-server
```

Configurar db root user and answer "Y" to all the questions
```
sudo mysql_secure_installation
```

###  (OPTIONAL) Restore data from backups.
To recover backups, always do it as `root` and with `cp -rp`. Only neccesary files. Watch out for `/etc/sudoers` and `/etc/passwd` specially. Don't override them.

#### Restore mysql databases from mysqldumps
Restore mysqldump file (.sql) from backup (see `var/lib/mysql/backups`).

Uncompress backup:
```
gzip -dk all_databases.gz
```

Restore all databases
```
sudo mysql -u root < all_databases.sql
```

Restore one databases
```
sudo mysql -u root --one-database db1 < all_databases.sql
```


### Install PHP and some modules
```
sudo apt install -y php php-{cli,zip,gd,fpm,json,common,mysql,zip,mbstring,curl,xml,bcmath,imap,ldap,intl,gmp,imagick,cgi,sqlite3}
```


## Install Pi-Hole
### Install and configure the [prerequisites][6]
```
sudo apt install -y nginx apache2-utils
```

```
wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh

sudo usermod -aG pihole www-data
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
```

Allow ports in firewall
```
sudo ufw allow from 192.168.0.0/16 to any port 53 proto tcp comment 'DNS Pi-Hole'
sudo ufw allow from 192.168.0.0/16 to any port 53 proto udp comment 'DNS Pi-Hole'
```

Optional for DCHP server:
```
sudo ufw allow from 192.168.0.0/16 to any port 67 proto tcp comment 'DHCP Pi-Hole'
sudo ufw allow from 192.168.0.0/16 to any port 67 proto udp comment 'DHCP Pi-Hole'
sudo ufw allow 546:547/udp comment 'DHCP6 Pi-Hole'
```

## Install Unbound
```
sudo apt install -y unbound
```

See [Pi-Hole Docs][7] to config Unbound and Pi-Hole.

## Install Docker
```
sudo apt install docker docker-compose
```

Then, create the docker group and add the local user to it.
```
sudo groupadd docker
sudo usermod -aG docker $USER
```

## [Install MPD][8]
```
sudo apt install  mpd

sudo touch /var/lib/mpd/db
sudo touch /var/lib/mpd/state
sudo touch /var/lib/mpd/sticker.sql
sudo touch /var/log/mpd.log
sudo touch /run/mpd/pid
```

Add exception to firewall:
```
sudo ufw allow 6600/tcp comment "Music Player Daemon"
```

## [Install Spotify Daemon][9]
Download the binarie or compile from source. Tested in armhf and arm64 (compìled).
Use backup config files.

Add exception to firewall:
```
sudo ufw allow 10200/tcp comment "Spotify connect 1"
sudo ufw allow 10201/tcp comment "Spotify connect 2"
```
More info over [RPI as audio receiver][10].


## Install [HACS][11] inside the Home Assistant Container
Download and execute HACS script inside the homeassistant docker container.
```
docker exec -it homeassistant bash
wget -O - https://get.hacs.xyz | bash -
exit
```


Sources:
- [1]: https://www.wireguard.com/quickstart/
- [2]: https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mariadb-php-lamp-stack-on-debian-10
- [3]: https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-debian-10
- [4]: https://medium.com/@alitou/getting-a-wildcard-ssl-certificate-using-certbot-and-deploy-on-nginx-15b8ffa34157
- [5]: https://certbot.eff.org/lets-encrypt/debianbuster-nginx
- [6]: https://docs.pi-hole.net/guides/webserver/nginx/
- [7]: https://docs.pi-hole.net/guides/dns/unbound/
- [8]: https://wiki.archlinux.org/title/Music_Player_Daemon_(Espa%C3%B1ol)#Procedimiento_de_Instalaci%C3%B3n_del_demonio
- [9]: https://github.com/Spotifyd/spotifyd
- [10]: https://github.com/nicokaiser/rpi-audio-receiver
- [11]: https://hacs.xyz/docs/setup/download#option-2-run-the-downloader-inside-the-container
