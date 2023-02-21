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
./autogen.sh
echo "You can run ./configure --help to see all the various configuration options"
./configure --disable-wallet

# Compile
make -j$(nproc)

echo "Tests can be run with: make -j "$(($(nproc)+1))" check"