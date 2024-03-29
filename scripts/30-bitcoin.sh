#!/bin/bash

script_loc=$(pwd)

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Check if Bitcoin Core is already installed
if [ -d "/opt/bitcoin" ]; then
    echo "Bitcoin Core is already installed in /opt/bitcoin"
else
    # Clone the Bitcoin Core repository
    echo "Cloning the Bitcoin Core repository..."
    sudo git clone https://github.com/bitcoin/bitcoin.git /opt/bitcoin

    # Install dependencies
    sudo apt-get update
    echo "Install Build requirements"
    sudo apt-get install build-essential libtool autotools-dev automake pkg-config bsdmainutils python3
    echo "Install required dependencies"
    sudo apt-get install libevent-dev libboost-dev

    # Build the dependencies
    cd /opt/bitcoin
    echo "Building the dependencies..."
    sudo ./autogen.sh
    echo "You can run ./configure --help to see all the various configuration options"
    ./configure --disable-wallet

    # Compile
    echo "Compiling..."
    sleep 1
    make -j$(nproc)

    # Test
    echo "Testing the build..."
    sleep 1
    make -j "$(($(nproc)+1))" check

    # Install the binaries
    sudo make install
fi

# Generate RPC auth credentials
# Read the username and password from user input
read -p "Enter username: " username
read -s -p "Enter password: " password

# Generate the rpcauth line with the provided username and password
rpcauth=$(python3 /opt/bitcoin/share/rpcauth/rpcauth.py $username $password | grep rpcauth)

# Append the rpcauth line to the bitcoin.conf file
echo "$rpcauth" >> $script_loc/../config/etc/bitcoin/bitcoin.conf

# Output the generated rpcauth line for reference
echo "rpcauth line: $rpcauth"

# Create the config file if it doesn't exist
if [ ! -f "/etc/bitcoin/bitcoin.conf" ]; then
    sudo mkdir -p /etc/bitcoin
    sudo cp -rp $script_loc/../config/etc/bitcoin/bitcoin.conf /etc/bitcoin/
    sudo chmod 600 /etc/bitcoin/bitcoin.conf
    sudo chown bitcoin:bitcoin /etc/bitcoin/bitcoin.conf
fi

# Create an UFW rule
read -p "Do you want to allow Bitcoin Core traffic over TCP? (Y/n): " REPLY
if [[ $REPLY != "n" ]]; then
    sudo ufw allow 8333/tcp comment "Bitcoin Core"
fi

# Check if bitcoind is already running
if sudo systemctl is-active --quiet bitcoind; then
    echo "bitcoind is already running"
else
    # Reload systemd files and activate bitcoind
    sudo cp -rp $script_loc/../config/etc/systemd/system/bitcoind.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable bitcoind
    sudo systemctl start bitcoind
    sudo systemctl status bitcoind
fi

