 #!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# Install Nginx, Certbot and Fail2ban
sudo apt install -y nginx certbot python3-certbot-nginx python3-certbot-dns-cloudflare fail2ban

# Prompt for domain name
read -p "Enter the domain name you wish to use (e.g. example.com,*.example.com for wildcard): " DOMAIN

# Check if certificate already exists
if sudo certbot certificates | grep -q "$DOMAIN"; then
   echo "Certificate already exists for domain $DOMAIN"
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
fi

# Create a stream configuration file for Nginx
sudo mkdir -p /etc/nginx/stream-available
sudo mkdir -p /etc/nginx/stream-enabled

if [ -f /etc/nginx/stream-available/electrs-stream.conf ]; then
  echo "File electrs-stream.conf already exists in /etc/nginx/stream-available. Skipping copy."
else
  sudo cp config/etc/nginx/stream-available/electrs-stream.conf /etc/nginx/stream-available/electrs-stream.conf
fi

sudo sed -i "s/_DOMAIN_/$DOMAIN/g" /etc/nginx/stream-available/electrs-stream.conf

if [ -L /etc/nginx/stream-enabled/electrs-stream.conf ]; then
  echo "Symbolic link electrs-stream.conf already exists in /etc/nginx/stream-enabled. Skipping creation."
else
  sudo ln -s /etc/nginx/stream-available/electrs-stream.conf /etc/nginx/stream-enabled/electrs-stream.conf
fi

# Restart nginx to apply the new configuration
sudo systemctl restart nginx