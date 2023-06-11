#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

script_loc=$(pwd)

# Install and configure Grafana
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common
sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana

# Reverse proxy
sudo mkdir -p /etc/grafana/provisioning/datasources
sudo cp $script_loc/../etc/grafana/provisioning/datasources/prometheus.yaml /etc/grafana/provisioning/datasources/
sudo cp $script_loc/../config/etc/nginx/sites-available/grafana.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/grafana.conf /etc/nginx/sites-enabled/

# Start the server with systemd
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
sudo systemctl status grafana-server

