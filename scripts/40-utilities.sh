#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "--------------------------------------------------"
echo "Installing utilities:"
# Prompt to install utilities
# tldr: Simplified and community-driven man pages
read -p "Install 'tldr' for simplified man pages? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install tldr
fi

# tree: List contents of directories in a tree-like format
read -p "Install 'tree' for directory listing? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install tree
fi

# logrotate: Rotate, compress, and remove log files
read -p "Install 'logrotate' for log rotation? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install logrotate
fi

# lnav: Log file navigator
read -p "Install 'lnav' for log file navigation? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install lnav
fi

# dnsutils: DNS utilities, including dig and nslookup
read -p "Install 'dnsutils' for DNS utilities (dig, nslookup, etc.)? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install dnsutils
fi

# qrencode: Encode and decode QR codes
read -p "Install 'qrencode' for QR code encoding and decoding? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install qrencode
fi

# borgbackup: Deduplicated and encrypted backups
read -p "Install 'borgbackup' for encrypted backups? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install borgbackup
fi

# rsync: Efficient file synchronization
read -p "Install 'rsync' for efficient file synchronization? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install rsync
fi

# rclone: Sync files and directories to/from cloud services
read -p "Install 'rclone' for syncing with cloud services? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install rclone
fi

# net-tools: Network configuration utilities (ifconfig, netstat, etc.)
read -p "Install 'net-tools' for network configuration utilities? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install net-tools
fi

# locate: A command-line utility that helps you find files and directories on your system
read -p "Install 'locate' for efficient file synchronization? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install locate
fi

# ncdu: A disk usage analyzer with an ncurses interface
read -p "Install 'ncdu' for efficient file synchronization? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install ncdu
fi

# curl: A command-line tool for transferring data from or to a server, using one of the supported protocols (HTTP, FTP, etc.)
read -p "Install 'curl' for efficient file synchronization? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install curl
fi

# sudo: A program that allows a user to run commands with the security privileges of another user (by default, the superuser).
read -p "Install 'sudo' for allowing privileged user access? [Y/n] " REPLY
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
    sudo apt install sudo
fi
