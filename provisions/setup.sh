#!/bin/bash

# "Replacing source list"
sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

export DEBIAN_FRONTEND=noninteractive

# no repeated provision if docker exists.
if ! command -v /usr/bin/docker &> /dev/null
then
    # Install packages - note, no need to link node to nodejs, this is done already
    apt update && apt install -y build-essential curl unzip git jq 
    
    # ###### #
    # DOCKER #
    # ###### #
    # Add dependencies
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    
    # Add repo key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    # Add Docker repo
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    # Add Docker 
    apt update && apt install -y docker-ce docker-ce-cli containerd.io
    # Add Vagrant user to Docker group
    usermod -a -G docker vagrant
    # /usr/bin/docker
fi

# Add Docker-compose , -sS for slience
if ! command -v /usr/local/bin/docker-compose &> /dev/null
then
    sudo curl -sS -L "https://github.com/docker/compose/releases/download/v2.3.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# ###### #
# PODMAN #
# ###### #

# can not install podman via apt @ubuntu focal64
## . /etc/os-release
## echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
## curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | apt-key add -
## apt-get update
## apt-get -y upgrade
## apt-get -y install podman

# EOF
