# Mini-debian
Bitcoin Basecamp is a GitHub repository that provides a comprehensive set of packages specifically tailored for Bitcoin-related software and services on a fresh Linux instance. Our repository is regularly updated to ensure that you have access to the latest versions of all the software packages you need to run a Bitcoin node, including Bitcoin Core, Electrs, and many other popular Bitcoin related tools.

Our repository is designed to make it easy for you to set up and maintain a reliable Bitcoin node on Linux. Whether you're a seasoned Bitcoin user or just getting started, Bitcoin Basecamp provides a solid foundation for your Bitcoin-related activities. We also provide detailed documentation and guides to help you get started with your Bitcoin node, including tips on security, performance, and optimization.

With Bitcoin Basecamp, you can be confident that you're using the best tools and packages available to run your Bitcoin node. Our team of experts is always available to provide support and guidance whenever you need it. So why wait? Check out Bitcoin Basecamp on GitHub today and start exploring the exciting world of Bitcoin on Linux!

## Table of Contents
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Configuration](#configuration)
  - [Scripts](#scripts)
  - [Configuration files](#configuration-files)
- [Documentation](#documentation)
  - [Getting started guide](#getting-started-guide)
  - [Troubleshooting guide](#troubleshooting-guide)
  - [Contributing guide](#contributing-guide)
- [License](#license)

## Getting Started
### Prerequisites
To use Bitcoin Basecamp, you'll need the following:

- A fresh Linux instance installed on your machine. Specifically, our repository is designed to work with Debian-based distributions, such as Debian 10 or later (amd64 architecture), Ubuntu, and Linux Mint.
- A basic understanding of how to use the command line interface (CLI), as many of the tools and packages in Bitcoin Basecamp are accessed via the command line.
- Linux system administration basics, including knowledge of package management, network configuration, and security best practices.
- Minimal computing resources, including disk space, memory, and processing power. Running a Bitcoin node requires a minimum of 100GB of disk space, 4GB of RAM, and a multi-core processor.

Before installing Bitcoin Basecamp, be sure to review the hardware requirements for running a Bitcoin node and ensure that your machine meets these requirements. Additionally, we recommend that you familiarize yourself with the basics of Bitcoin and related software, as this will help you get the most out of our repository.

### Installation
To install Bitcoin Basecamp and run the scripts inside the scripts/ directory, follow these steps:

1. Open a terminal window and run the following command to update your system's package index:

```sudo apt update```

2. Once the update is complete, run the following command to upgrade your system's packages:

```sudo apt upgrade```

3. Next, follow the script files instructions or run the following command to install Git on your system:

```sudo apt install git```

4. Once Git is installed, navigate to the directory where you want to store the repository and run the following command to clone the repository to your local system:

```git clone https://github.com/federicociro/Bitcoin-Basecamp.git```

5. Navigate to the scripts/ directory within the cloned repository:

```cd Bitcoin-Basecamp/scripts/```

6. Review the scripts in the scripts/ directory to ensure that they're appropriate for your use case.

7. Run the scripts in the order that you'd like them to be executed, using the following command:

```sudo ./script-name.sh```

You may need to modify the script's permissions to make it executable using the chmod command. For example, if you want to make the install-bitcoin-core.sh script executable, you would run the following command:

```chmod +x install.sh```

That's it! You should now have a fully functional Bitcoin node running on your Linux instance using the software and packages provided by Bitcoin Basecamp.

## Configuration
### Scripts


### Configuration files

## Documentation
### Getting started guide
### Troubleshooting guide
### Contributing guide

## License

