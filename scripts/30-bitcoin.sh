/*
* This file is part of Bitcoin Basecamp
* Bitcoin Basecamp is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Bitcoin Basecamp is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Bitcoin Basecamp.  If not, see <https://www.gnu.org/licenses/>.
*/
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