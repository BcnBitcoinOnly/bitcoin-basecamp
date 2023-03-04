#!/bin/bash

script_loc=$(pwd)

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Clone Mempool Repository
# repo with .cookie connection capability
sudo git clone https://github.com/mempool/mempool /opt/mempool
sudo chown -R mempool:mempool /opt/mempool
cd /opt/mempool
latestrelease=$(curl -s https://api.github.com/repos/mempool/mempool/releases/latest|grep tag_name|head -1|cut -d '"' -f4)
sudo git checkout $latestrelease

# Install NPM
sudo apt update
sudo apt install -y npm

# Check the Node.js version
NODE_VERSION=$(node -v)
REQUIRED_VERSION="v16.0.0"

if [[ $NODE_VERSION != $REQUIRED_VERSION* ]]; then
    echo "Current Node.js version is $NODE_VERSION, which is not compatible with Mempool."
    echo "Upgrading to the latest version..."

    # Clean the npm cache and install the 'n' package
    npm cache clean -f
    npm install -g n

    # Use the 'n' package to install the latest stable Node.js version
    sudo n stable

    # Verify the new Node.js version
    NODE_VERSION=$(node -v)
    if [[ $NODE_VERSION != $REQUIRED_VERSION* ]]; then
        echo "Node.js upgrade failed. Current version is $NODE_VERSION"
        exit 1
    fi

    echo "Node.js upgrade successful. New version is $NODE_VERSION"
else
    echo "Node.js version is compatible with Mempool: $NODE_VERSION"
fi

# Create a database and grant privileges (db, user and password = mempool)
if ! sudo mysql -e "use mempool" ; then 
    sudo mysql -e "create database mempool; grant all privileges on mempool.* to 'mempool'@'%' identified by 'mempool';" ; 
fi

# Build and configure Mempool Backend
cd backend
sudo -u mempool npm install --prod
sudo -u mempool npm run build

# Copy configuration file
sudo cp $script_loc/../config/etc/mempool/mempool-config.json /opt/mempool/backend/mempool-config.json
sudo chmod 600 /opt/mempool/backend/mempool-config.json
sudo cp $script_loc/../config/etc/nginx/sites-available/mempool.conf /etc/nginx/sites-available/mempool.conf
sudo ln -s /etc/nginx/sites-available/mempool.conf /etc/nginx/sites-enabled/

# Specify Website
echo "Which website do you want to configure the frontend for?"
echo "1. Mempool.space"
echo "2. Liquid.network"
echo "3. Bisq.markets"
read -p "Enter your choice [1-3]: " choice

case $choice in
    1)
        sudo -u mempool npm run config:defaults:mempool
        ;;
    2)
        sudo -u mempool npm run config:defaults:liquid
        ;;
    3)
        sudo -u mempool npm run config:defaults:bisq
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

# Install and run the Frontend
if ! command -v node &> /dev/null
then
    echo "Node.js is not installed. Please install Node.js 16.10 or later and try again."
    exit 1
fi

if ! command -v npm &> /dev/null
then
    echo "npm is not installed. Please install npm 7 or later and try again."
    exit 1
fi

cd ../frontend
sudo -u mempool npm install --prod
sudo -u mempool npm run build

# Test
echo "Do you want to run the Cypress end-to-end tests?"
read -p "Enter y/N: " choice

if [ "$choice" == "y" ]
then
    echo "Running Cypress tests..."
    sudo -u mempool npm run cypress:run
    echo "Cypress tests complete."
else
    echo "Skipping Cypress tests."
fi

echo "Installation complete."

# Copy frontend to /var/www folder
sudo rsync -av --delete /opt/mempool/frontend/dist/mempool/ /var/www/mempool/
sudo chown -R www-data:www-data /var/www/mempool

# Restart nginx to apply the new configuration
sudo systemctl restart nginx

# Check if mempool is already running
if sudo systemctl is-active --quiet mempool; then
    echo "mempool is already running"
else
    # Reload systemd files and activate mempool
    sudo cp -rp $script_loc/../config/etc/systemd/system/mempool.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable mempool
    sudo systemctl start mempool
    sudo systemctl status mempool
fi