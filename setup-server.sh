#!/usr/bin/env bash
set -e

sudo apt update && sudo apt upgrade -y

# OpenSSH
sudo apt install -y openssh-server
sudo systemctl enable ssh --now

# Docker
## 1. Set up Docker's `apt` repository.
### Add Docker's official GPG key:
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

### Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

## 2. Install the Docker packages.
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## Add user to docker group
sudo usermod -aG docker "$USER"
newgrp docker

# Ollama & Open WebUI
curl -fsSL https://raw.githubusercontent.com/nicsaw/pc-to-server/main/docker-compose.yml -o docker-compose.yml
docker compose up -d
docker exec ollama ollama pull llama3.1
