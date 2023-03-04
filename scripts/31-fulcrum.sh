#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

script_loc=$(pwd)

# Update repositories and install prerequisites
sudo apt update
sudo apt install libssl-dev

# Create a firewall rule - Fulcrum traffic (TCP)
read -p "Do you want to allow Fulcrum traffic over TCP? (Y/n): " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo ufw allow 50002/tcp comment "Fulcrum"
fi

# Get the lastest tag
version=$(curl -s https://api.github.com/repos/cculianu/Fulcrum/tags | grep '"name":' | head -n 1 | awk -F '"' '{print $4}' | sed 's/^v//')

# Change to the Fulcrum directory
sudo mkdir /opt/fulcrum
cd /opt/fulcrum

# Download the application, checksums, and signature files
sudo curl -sSL -O "https://github.com/cculianu/Fulcrum/releases/download/v$version/Fulcrum-$version-x86_64-linux.tar.gz"
sudo curl -sSL -O "https://github.com/cculianu/Fulcrum/releases/download/v$version/Fulcrum-$version-x86_64-linux.tar.gz.asc"
sudo curl -sSL -O "https://github.com/cculianu/Fulcrum/releases/download/v$version/Fulcrum-$version-x86_64-linux.tar.gz.sha256sum"

# Verify the signature
sudo curl https://raw.githubusercontent.com/Electron-Cash/keys-n-hashes/master/pubkeys/calinkey.txt | gpg --import
gpg --verify "Fulcrum-$version-x86_64-linux.tar.gz.asc" "Fulcrum-$version-x86_64-linux.tar.gz"

# Verify the checksums
sha256sum -c "Fulcrum-$version-x86_64-linux.tar.gz.sha256sum"

# Extract the Fulcrum archive
sudo tar -xvf Fulcrum-$version-x86_64-linux.tar.gz

# Install the Fulcrum and FulcrumAdmin binaries to /usr/local/bin
sudo install -m 0755 -o root -g root -t /usr/local/bin Fulcrum-$version-x86_64-linux/Fulcrum Fulcrum-$version-x86_64-linux/FulcrumAdmin

# Create the config file if it doesn't exist
if [ ! -f "/etc/fulcrum/fulcrum.conf" ]; then
    sudo mkdir -p /etc/fulcrum
    sudo mkdir -p /var/lib/fulcrum
    sudo chown -R fulcrum:fulcrum /var/lib/fulcrum/
    sudo cp -rp $script_loc/../config/etc/fulcrum/fulcrum.conf /etc/fulcrum/
    sudo cp -rp $script_loc/../config/etc/fulcrum/fulcrum-banner.txt /etc/fulcrum/
fi

# Create an UFW rule
read -p "Do you want to allow Fulcrum traffic over TCP? (Y/n): " REPLY
if [[ $REPLY != "n" ]]; then
    sudo ufw allow 50002/tcp comment "Fulcrum SSL"
fi

# Check if bitcoind is already running
if sudo systemctl is-active --quiet fulcrum; then
    echo "fulcrum is already running"
else
    # Reload systemd files and activate bitcoind
    sudo cp -rp $script_loc/../config/etc/systemd/system/fulcrum.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable fulcrum
    sudo systemctl start fulcrum
    sudo systemctl status fulcrum
fi