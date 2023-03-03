#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

script_loc=$(pwd)

sudo mkdir -p /srv/www/homer
cd /srv/www/homer
sudo wget https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip
sudo unzip homer.zip
cd homer

sudo mkdir /etc/homer
sudo cp $script_loc/../config/etc/homer/config.yml /srv/www/homer/assets/config.yml
sudo ln -s /etc/homer/config.yml /srv/www/homer/assets/
sudo cp $script_loc/../config/etc/nginx/sites-available/homer.conf /etc/nginx/sites-available/homer.conf
sudo ln -s /etc/nginx/sites-available/homer.conf /etc/nginx/sites-enabled/

# Restart nginx to apply the new configuration
sudo systemctl restart nginx