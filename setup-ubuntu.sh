#!/usr/bin/env bash
set -e

echo "🔵 Updating and upgrading system packages"
sudo apt update && sudo apt upgrade -y

# Git
echo "🔵 Git"
sudo apt install -y git curl
git clone https://github.com/nicsaw/pc-to-server.git ~/pc-to-server || echo "⚠️ ~/pc-to-server already exists."
cd ~/pc-to-server

# OpenSSH
echo "🔵 OpenSSH"
sudo apt install -y openssh-server
sudo systemctl enable --now ssh

# Docker
echo "🔵 Docker"
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

# NVIDIA Container Toolkit - https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
echo "🔵 NVIDIA Container Toolkit"
## Install the prerequisites for the instructions below
sudo apt-get update && sudo apt-get install -y --no-install-recommends \
   curl \
   gnupg2

## Configure the production repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

## Update the packages list from the repository
sudo apt-get update

## Install the NVIDIA Container Toolkit packages
sudo apt-get install -y nvidia-container-toolkit

## Configure the Docker daemon to enable the NVIDIA Container Runtime
sudo nvidia-ctk runtime configure --runtime=docker

## Restart Docker to apply the changes
sudo systemctl restart docker

# Cloudflared
echo "🔵 Cloudflared"
cp .env.example .env

# n8n
echo "🔵 n8n"
mkdir -p ~/pc-to-server/services/n8n/local-files

# Ollama & Open WebUI
echo "🔵 Ollama & Open WebUI"
cd ~/pc-to-server
sg docker -c "docker compose up -d"
# docker exec ollama ollama pull llama3.1

# Tailscale
echo "🔵 Tailscale"
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable --now tailscaled
sudo tailscale up
