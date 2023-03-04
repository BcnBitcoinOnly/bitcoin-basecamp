#!/bin/bash

script_loc=$(pwd)

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install script into local folder
sudo install 82-cloudflare_ddns.sh /usr/local/bin/update_ip.sh

# Copy the service and timer files to the systemd folder
sudo cp $script_loc/../config/etc/systemd/system/cloudflare-ddns.service /etc/systemd/system/
sudo cp $script_loc/../config/etc/systemd/system/cloudflare-ddns.timer /etc/systemd/system/

# Reload the systemd daemon to pick up the new service and timer files
sudo systemctl daemon-reload

# Start and enable the timer to run the service every 5 minutes
sudo systemctl start cloudflare-ddns.timer
sudo systemctl enable cloudflare-ddns.timer