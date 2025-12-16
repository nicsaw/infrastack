# pc-to-server

## WSL

Run Windows PowerShell as Administrator.

Set WSL 2 as the default version for new Linux distributions:

```powershell
wsl --set-default-version 2
```

Find the latest Ubuntu LTS release:

```powershell
wsl --list --online
```

Install the latest Ubuntu LTS release (currently `Ubuntu-24.04`):

```powershell
wsl --install Ubuntu-24.04
```

Update and upgrade the Ubuntu system:

```bash
sudo apt update && sudo apt upgrade -y
```

## [Docker](https://docs.docker.com/engine/install/ubuntu)

### [Install using the `apt` repository](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository):

1. Set up Docker's `apt` repository.

```bash
# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
```

2. Install the Docker packages.

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## [Ollama](https://ollama.com) & [Open WebUI](https://openwebui.com)

Add your user to the `docker` group and apply the `docker` group immediately:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

Start services:

```bash
docker compose up -d
```

[Select an LLM](https://ollama.com/library) and download it:

```bash
docker exec -it ollama ollama pull <LLM>
```

Open [http://localhost:3000](http://localhost:3000).
