#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 0
fi

# Install Tor
sudo apt update
sudo apt install -y tor

# Append configurations to torrc file
echo '## The port on which Tor will listen for local connections from Tor' | sudo tee -a /etc/tor/torrc
echo '## controller applications, as documented in control-spec.txt.' | sudo tee -a /etc/tor/torrc
echo 'ControlPort 9051' | sudo tee -a /etc/tor/torrc
echo 'CookieAuthentication 1' | sudo tee -a /etc/tor/torrc
echo 'CookieAuthFileGroupReadable 1' | sudo tee -a /etc/tor/torrc

# Restart the Tor service to apply the changes
sudo systemctl restart tor.service

# Get the hidden service directories
hidden_service_dirs=$(ls -1 /var/lib/tor/hidden_service/ 2>/dev/null)

# Check if there are any hidden services
if [ -z "$hidden_service_dirs" ]
then
    echo "No hidden services found"
fi

# Print the hidden service addresses
for dir in $hidden_service_dirs
do
   echo "Take note of hidden services:"
    echo "$dir: $(cat /var/lib/tor/hidden_service/$dir/hostname)"
done