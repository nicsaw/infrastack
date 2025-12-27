#!/usr/bin/env bash
set -e

sudo apt update && sudo apt upgrade -y

# Git
sudo apt install -y git curl
git clone https://github.com/nicsaw/pc-to-server.git ~/pc-to-server || echo "⚠️ ~/pc-to-server already exists."
cd ~/pc-to-server

# OpenSSH
sudo apt install -y openssh-server
sudo systemctl enable --now ssh

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
sudo systemctl enable --now docker

# Ollama & Open WebUI
cd ~/pc-to-server
sg docker -c "docker compose up -d"
# docker exec ollama ollama pull llama3.1

# Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable --now tailscaled
sudo tailscale up
