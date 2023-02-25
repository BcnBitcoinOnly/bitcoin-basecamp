#!/bin/bash

# Clone the Bitcoin Core repository
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin

# Install dependencies
sudo apt-get update
echo "Install Build requirements"
sudo apt-get install build-essential libtool autotools-dev automake pkg-config bsdmainutils python3
echo "Install required dependencies"
sudo apt-get install libevent-dev libboost-dev

# Build the dependencies
echo "Building the dependencies..."
sleep 1
./autogen.sh
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

# Create the config file
sudo mkdir -p /etc/bitcoin
cp -rp ../config/etc/bitcoin/bitcoin.conf /etc/bitcoin/
cp -rp ../config/etc/systemd/system/bitcoind.service /etc/systemd/system/

# Reload systemd files and activate bitcoind
sudo systemctl daemon-reload
sudo systemctl enable bitcoind
sudo systemctl start bitcoind
sudo systemctl status bitcoind