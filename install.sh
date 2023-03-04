#!/bin/bash

# Update package list and upgrade packages
echo "Updating package list..."
sudo apt update
sudo apt upgrade -y

# Prompt to install Git
read -p "Do you want to install Git? [y/n] " install_git
if [ "$install_git" = "y" ]; then
  echo "Installing Git..."
  sudo apt install -y git
  echo "Configuring Git..."
  read -p "Enter your name: " git_name
  read -p "Enter your email address: " git_email
  git config --global user.name "$git_name"
  git config --global user.email "$git_email"
fi

# Prompt to install curl
read -p "Do you want to install curl? [y/n] " install_curl
if [ "$install_curl" = "y" ]; then
  echo "Installing curl..."
  sudo apt install -y curl
fi

# Prompt to install wget
read -p "Do you want to install wget? [y/n] " install_wget
if [ "$install_wget" = "y" ]; then
  echo "Installing wget..."
  sudo apt install -y wget
fi

# Prompt to install vim
read -p "Do you want to install Vim? [y/n] " install_vim
if [ "$install_vim" = "y" ]; then
  echo "Installing Vim..."
  sudo apt install -y vim
fi

# Prompt to install htop
read -p "Do you want to install htop? [y/n] " install_htop
if [ "$install_htop" = "y" ]; then
  echo "Installing htop..."
  sudo apt install -y htop
fi

# Prompt to install Python and pip
read -p "Do you want to install Python and pip? [y/n] " install_python
if [ "$install_python" = "y" ]; then
  echo "Installing Python and pip..."
  sudo apt install -y python3 python3-pip
fi

# Prompt to install Node.js and npm
read -p "Do you want to install Node.js and npm? [y/n] " install_nodejs
if [ "$install_nodejs" = "y" ]; then
  echo "Installing Node.js and npm..."
  curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
  sudo apt install -y nodejs
fi

# Prompt to install Docker
read -p "Do you want to install Docker? [y/n] " install_docker
if [ "$install_docker" = "y" ]; then
  echo "Installing Docker..."
  sudo apt install -y docker.io
  echo "Adding user to Docker group..."
  sudo usermod -aG docker $USER
fi

# Prompt to install Zsh and Oh My Zsh
read -p "Do you want to install Zsh and Oh My Zsh? [y/n] " install_zsh
if [ "$install_zsh" = "y" ]; then
  echo "Installing Zsh..."
  sudo apt install -y zsh
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "Changing default shell to Zsh..."
  chsh -s $(which zsh)
fi

# Prompt to install Neovim
read -p "Do you want to install Neovim? [y/n] "
