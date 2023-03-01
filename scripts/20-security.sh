 #!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# Prompt the user to install ufw.
echo "--------------------------------------------------"
echo "Installing a firewall:"
read -p "Install 'ufw' for a front-end for iptables? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
  sudo apt install ufw -y
  sudo ufw limit ssh comment "Secure Shell"
  sudo ufw enable
  echo "ufw installed and enabled. SSH traffic is limited."
else
  echo "ufw not installed. SSH traffic not limited."
fi

# Rule 1 - VPN Wireguard traffic
read -p "Do you want to allow VPN Wireguard traffic? (Y/n): " allow_vpn_wireguard
if [[ ${allow_vpn_wireguard,,} != "n" ]]; then
    sudo ufw allow 51820/udp comment "VPN Wireguard"
fi

# Show UFW status
sudo ufw status verbose

# Prompt for domain name
read -p "Enter the domain name you wish to use (e.g. example.com,*.example.com for wildcard): " DOMAIN

# Check if certificate already exists
if sudo certbot certificates | grep -q "$DOMAIN"; then
   echo "--------------------------------------------------"
   echo "Certificate already exists for domain $DOMAIN"
   echo "--------------------------------------------------"
   sudo certbot certificates
else
   # Prompt for Cloudflare email and API key
   read -p "Enter your Cloudflare email address: " CF_EMAIL
   read -p "Enter your Cloudflare API key: " CF_API_KEY
   
   # Create the Cloudflare credentials file
   echo "dns_cloudflare_api_key = $CF_API_KEY" > /root/.secrets/certbot/cloudflare.ini
   echo "dns_cloudflare_email = $CF_EMAIL" >> /root/.secrets/certbot/cloudflare.ini
   chmod 600 /root/.secrets/certbot/cloudflare.ini

   # Request a certificate using the Cloudflare DNS challenge
   sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/certbot/cloudflare.ini -d $DOMAIN -m $CF_EMAIL --agree-tos --no-eff-email --preferred-challenges dns-01
   $DOMAIN >> /root/.secrets/certbot/domain.txt
fi

# Create a stream configuration file for Nginx
sudo mkdir -p /etc/nginx/stream-available
sudo mkdir -p /etc/nginx/stream-enabled

if [ -f /etc/nginx/stream-available/fulcrum-stream.conf ]; then
  echo "File fulcrum-stream.conf already exists in /etc/nginx/stream-available. Skipping copy."
else
  sudo cp ../config/etc/nginx/stream-available/fulcrum-stream.conf /etc/nginx/stream-available/fulcrum-stream.conf
fi

sudo sed -i "s/_DOMAIN_/$DOMAIN/g" /etc/nginx/stream-available/fulcrum-stream.conf

if [ -L /etc/nginx/stream-enabled/fulcrum-stream.conf ]; then
  echo "--------------------------------------------------"
  echo "Symbolic link fulcrum-stream.conf already exists in /etc/nginx/stream-enabled. Skipping creation."
  echo "--------------------------------------------------"
else
  sudo ln -s /etc/nginx/stream-available/fulcrum-stream.conf /etc/nginx/stream-enabled/fulcrum-stream.conf
fi

# Restart nginx to apply the new configuration
sudo systemctl restart nginx