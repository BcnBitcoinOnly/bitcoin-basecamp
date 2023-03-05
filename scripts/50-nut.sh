#!/bin/bash
# Install Network UPS Tools and configure the UPS

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

script_loc=$(pwd)

# Install Tor
sudo apt update
sudo apt install -y nut

# Grep UPS name
sudo dmesg | grep -i ups

# Edit UPS configuration
echo "[myups]" >> /etc/nut/ups.conf
echo "    driver = usbhid-ups" >> /etc/nut/ups.conf
echo "    port = auto" >> /etc/nut/ups.conf

# Edit NUT configuration
sed -i 's/MODE=none/MODE=standalone/g' /etc/nut/nut.conf
sed -i 's/^#LISTEN 127.0.0.1/LISTEN 127.0.0.1/g' /etc/nut/nut.conf
sed -i 's/^#LISTEN ::1/LISTEN ::1/g' /etc/nut/nut.conf

# Edit UPS permission
echo "## Configured for NUT" >> /etc/udev/rules.d/50-nut-usbups.rules
echo "BUS=\"usb\", ACTION=\"add\", SUBSYSTEM=\"usb\", ATTR{idVendor}=\"*\", ATTR{idProduct}=\"*\", GROUP=\"nut\"" >> /etc/udev/rules.d/50-nut-usbups.rules

# Restart NUT service
systemctl restart nut-server