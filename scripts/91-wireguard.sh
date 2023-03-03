#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install Wireguard
sudo apt update
sudo apt install -y wireguard qrencode

# Generate private and public keys
PRIVATE_KEY=$(wg genkey)
PUBLIC_KEY=$(echo $PRIVATE_KEY | wg pubkey)

# Create WireGuard configuration file
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.0.0.1/24
PrivateKey = $PRIVATE_KEY

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
EOF

# Replace <CLIENT_PUBLIC_KEY> with the actual public key of the client

# Create an UFW rule
read -p "Do you want to allow Wireguard traffic over TCP? (Y/n): " REPLY
if [[ $REPLY != "n" ]]; then
    sudo ufw allow 51820/udp comment "Wireguard"
fi

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# Start the WireGuard interface
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0