#!/bin/bash -xe
################################################################################################
# * Author        : doungni
# * Email         : doungni@doungni.com
# * Last modified : 2015-12-02 16:09
# * Filename      : InstallDocker.sh
# * Description   : Only used for Ubuntu 14.04.x LTS
################################################################################################

# https://docs.docker.com/engine/installation/ubuntulinux/

# 1.Prerequisites
# Docker requires a 64-bit installation regardless of your Ubuntu version. Additionally, your kernel must be 3.10 at minimum. The latest 3.10 minor version or a newer maintained version are also acceptable.

# [1] Update your apt sources
# [1.1] Add the new gpg key.
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# [1.2] Open the /etc/apt/sources.list.d/docker.list file in your favorite editor. If the file doesn’t exist, create it. Remove any existing entries.
if [ ! -f "/etc/apt/sources.list.d/docker.list" ]; then
    cat > /etc/apt/sources.list.d/docker.list << EOF
deb https://apt.dockerproject.org/repo ubuntu-trusty main
EOF
fi

# [1.3] Update the apt package index.
update_return=`sudo apt-get update && echo yes || echo no`
if [ "x${update_return}" == "xno"  ]
    sudo apt-get install apt-transport-https -y
fi
# [1.4] Purge the old repo if it exists.
sudo apt-get purge lxc-docker

# [1.5] Verify that apt is pulling from the right repository.
sudo apt-cache policy docker-engine

# [2] Prerequisites by Ubuntu Version
# [2.1] Update your package manager.
sudo apt-get update

# [2.2] Install the recommended package.
sudo apt-get install linux-image-extra-$(uname -r) -y 

# 2.Install
# Make sure you have installed the prerequisites for your Ubuntu version. Then, install Docker using the following:

# [1] Log into your Ubuntu installation as a user with sudo privileges.

# [2] Update your apt package index.
sudo apt-get update

# [3] Install Docker.
sudo apt-get install docker-engine -y

# [4] Start the docker daemon.
service docker start

# [5] Verify docker is installed correctly.
docker run hello-world
