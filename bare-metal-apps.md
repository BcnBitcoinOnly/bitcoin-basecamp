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
sudo ufw allow 51820/udp comment Wireguard
```

[Configure][1] a wg0.conf file. 

Start Wireguard on boot:
```
sudo systemctl enable wg-quick@wg0
```

Allow IP forwarding (to allow DNS request in a different subnet)
Edit `/etc/sysctl.conf` and uncomment `net.ipv4.ip_forward=1`.


## Install[6] a LEMP stack (Linux + Nginx + MariaDB + PHP) and secure it [2]
### Install Nginx (webserver)
```
sudo apt install -y nginx certbot python-certbot-nginx python3-certbot-nginx
```

Generate a wildcard SSL certificate following [this guide.][7]
More details in this in [Certbot][3].

Allow Nginx in the firewall
```
sudo ufw allow 80/tcp comment Nginx_HTTP
sudo ufw allow 443/tcp comment Nginx_HTTPS
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

Restore all databases
```
sudo mysql -u root --one-database db1 < all_databases.sql
```


### Install PHP and some modules
```
sudo apt install -y php-fpm php-mysql php-bcmath php-gmp php-imagick
```


## Install Pi-Hole
### Install and configure the [prerequisites][4]
```
sudo apt install -y nginx php-fpm php-cgi php-xml php-sqlite3 php-intl apache2-utils
```

```
wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh
sudo usermod -aG pihole www-data
```

Allow ports in firewall
```
sudo ufw allow from 192.168.0.0/16 to any port 53 proto tcp comment 'DNS Pi-Hole'
sudo ufw allow from 192.168.0.0/16 to any port 53 proto udp comment 'DNS Pi-Hole'
```

## Install Unbound
```
sudo apt install -y unbound
```

See [Pi-Hole Docs][5] to config Unbound and Pi-Hole.


[1]:https://www.wireguard.com/quickstart/
[6]https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mariadb-php-lamp-stack-on-debian-10
[2]:https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-debian-10
[7]:https://medium.com/@alitou/getting-a-wildcard-ssl-certificate-using-certbot-and-deploy-on-nginx-15b8ffa34157
[3]:https://certbot.eff.org/lets-encrypt/debianbuster-nginx
[4]:https://docs.pi-hole.net/guides/webserver/nginx/
[5]:https://docs.pi-hole.net/guides/dns/unbound/


## Sources
[5]:https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server
[6]:https://www.raspberrypi.org/documentation/configuration/security.md
[7]:https://www.digitalocean.com/community/tutorials/how-fail2ban-works-to-protect-services-on-a-linux-server
[8]:https://unix.stackexchange.com/questions/131311/moving-var-home-to-separate-partition
[9]:
[10]:https://www.nuharborsecurity.com/ubuntu-server-hardening-guide-2/


[9]:https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mariadb-php-lamp-stack-on-debian-10
