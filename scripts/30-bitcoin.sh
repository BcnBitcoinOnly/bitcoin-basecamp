#!/bin/bash

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

# Create the config file if it doesn't exist
if [ ! -f "/etc/bitcoin/bitcoin.conf" ]; then
    sudo mkdir -p /etc/bitcoin
    sudo cp -rp ../config/etc/bitcoin/bitcoin.conf /etc/bitcoin/
fi

# Create the systemd service file if it doesn't exist
if [ ! -f "/etc/systemd/system/bitcoind.service" ]; then
    sudo cp -rp ../config/etc/systemd/system/bitcoind.service /etc/systemd/system/
fi

# Check if bitcoind is already running
if sudo systemctl is-active --quiet bitcoind; then
  echo "bitcoind is already running"
else
  # Reload systemd files and activate bitcoind
  sudo systemctl daemon-reload
  sudo systemctl enable bitcoind
  sudo systemctl start bitcoind
  sudo systemctl status bitcoind
fi