#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Create an UFW rule - DNS Pi-Hole traffic
read -p "Do you want to allow DNS Pi-Hole traffic? (Y/n): " allow_dns_tcp
if [[ ${allow_dns_tcp,,} != "n" ]]; then
    sudo ufw allow from 192.168.0.0/16 to any port 53 comment "DNS Pi-Hole"
    sudo ufw allow from fe80::/64 to any port 53 comment "DNS Pi-Hole (IPv6)"
fi

# Download the Pi-hole installer
curl -sSL https://install.pi-hole.net | bash

sudo usermod -aG pihole www-data
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# It's recommended to install and configure Unbound to use it with PiHole too: https://docs.pi-hole.net/guides/dns/unbound/