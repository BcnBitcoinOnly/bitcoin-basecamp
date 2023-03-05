#!/bin/bash
# Install and configure Prometheus

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

script_loc=$(pwd)

# Retrieve the latest Prometheus release from GitHub
LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/prometheus/prometheus/releases/latest)
LATEST_VERSION=$(echo "${LATEST_RELEASE}" | sed -e 's/.*"tag_name":"v\([^"]*\)".*/\1/')

# Download the Prometheus binary directly to /opt/prometheus
cd /opt/prometheus
sudo wget https://github.com/prometheus/prometheus/releases/download/v${LATEST_VERSION}/prometheus-${LATEST_VERSION}.linux-amd64.tar.gz -P /opt/prometheus

# Extract the downloaded file
sudo tar xvfz /opt/prometheus/prometheus-${LATEST_VERSION}.linux-amd64.tar.gz -C /opt/prometheus --strip-components=1

# Create a system user for Prometheus
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
sudo mkdir /etc/prometheus

# Copy the Prometheus configuration file to the /etc/prometheus directory
sudo cp /opt/prometheus/prometheus.yml /etc/prometheus/prometheus.yml
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Configure Prometheus to run as a systemd service
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to pick up the new service definition
sudo systemctl daemon-reload

# Start Prometheus
sudo systemctl start prometheus

# Enable Prometheus to start at boot time
sudo systemctl enable prometheus

# Check if bitcoind is already running
if sudo systemctl is-active --quiet prometheus; then
    echo "prometheus is already running"
else
    # Reload systemd files and activate bitcoind
    sudo cp -rp $script_loc/../config/etc/systemd/system/prometheus.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable prometheus
    sudo systemctl start prometheus
    sudo systemctl status prometheus
fi