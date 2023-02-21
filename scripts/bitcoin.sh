 #!/bin/bash

# Clone the Bitcoin Core repository
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin

# Install dependencies
sudo apt-get update
sudo apt-get install \
    automake \
    autotools-dev \
    bsdmainutils \
    build-essential \
    ccache \
    clang \
    gcc \
    git \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libboost-test-dev \
    libevent-dev \
    libminiupnpc-dev \
    libnatpmp-dev \
    libqt5gui5 \
    libqt5core5a \
    libqt5dbus5 \
    libsqlite3-dev \
    libtool \
    libzmq3-dev \
    pkg-config \
    python3 \
    qttools5-dev \
    qttools5-dev-tools \
    qtwayland5 \
    systemtap-sdt-dev

# Build the dependencies
./autogen.sh
./contrib/install_db4.sh $(pwd)
echo "You can run ./configure --help to see all the various configuration options"
./configure \
        BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" \
        BDB_CFLAGS="-I${BDB_PREFIX}/include" \
        --disable-bench \
        --disable-gui-tests \
        --disable-maintainer-mode \
        #--disable-man \
        --disable-tests \
        --disable-zmq \
        --enable-lto \
        --with-daemon=yes \
        --with-gui=no \
        --with-libmultiprocess=no \
        --with-libs=no \
        --with-miniupnpc=no \
        --with-mpgen=no \
        --with-natpmp=no \
        --with-qrencode=no \
        --with-utils=yes

# Compile
make -j$(nproc)

echo "Tests can be run with: make -j "$(($(nproc)+1))" check"