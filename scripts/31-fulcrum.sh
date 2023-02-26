 #!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update repositories and install prerequisites
sudo apt update
sudo apt install libssl-dev

# Create a firewall rule - Fulcrum traffic (TCP)
read -p "Do you want to allow Fulcrum traffic over TCP? (Y/n): " allow_fulcrum_tcp
if [[ ${allow_fulcrum_tcp,,} != "n" ]]; then
    sudo ufw allow 50002/tcp comment "Fulcrum"
fi