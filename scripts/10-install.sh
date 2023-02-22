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

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update the system.
sudo apt update
sudo apt upgrade -y

# Prompt the user to set a hostname.
read -p "Enter a hostname (press Enter to skip): " hostname
if [ -n "$hostname" ]; then
  hostnamectl set-hostname "$hostname"
  echo "Hostname set to $hostname"
  echo "A reboot is needed to apply the changes."
fi

# Prompt the user to install ufw.
read -p "Install 'ufw' for a front-end for iptables? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
  sudo apt install ufw -y
  sudo ufw limit ssh
  sudo ufw enable
  echo "ufw installed and enabled. SSH traffic is limited."
else
  echo "ufw not installed. SSH traffic not limited."
fi

# replace $USER with the non-root user
#usermod -a -G sudo $USER

sudo useradd -m bitcoin
sudo useradd -m electrs
sudo useradd -m mempool
