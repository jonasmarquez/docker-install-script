#!/bin/bash -x

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# MANAGE DOCKER USERS

sudo usermod -aG docker $USER
# You can also run the following command to activate the changes to groups:
newgrp docker

# Check version
sudo docker --version

# To install a specific version of Docker Engine, specify each package by its fully qualified package name.
# List the available versions:
# apt-cache madison docker-ce | awk '{ print $3 }'
# export DOCKER_VERSION=5:20.10.24~3-0~ubuntu-jammy
# sudo apt-get install -y docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io docker-buildx-plugin docker-compose-plugin

# REF: https://docs.docker.com/engine/install/ubuntu/