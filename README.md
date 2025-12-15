# pc-to-server

## WSL

Run Windows PowerShell as Administrator.

Set WSL 2 as the default version for new Linux distributions:

```powershell
wsl --set-default-version 2
```

Find the latest version of Ubuntu LTS:

```powershell
wsl --list --online
```

Install the latest Ubuntu LTS release (currently `Ubuntu-22.04`):

```powershell
wsl --install Ubuntu-22.04
```

Update and upgrade the Ubuntu system:

```bash
sudo apt update && sudo apt upgrade -y
```

## [Ollama](https://ollama.com)

[Install Ollama](https://ollama.com/download/linux):

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

[Select an LLM](https://ollama.com/library) and install it:

```bash
ollama pull <LLM>
```

Run the LLM:

```bash
ollama run <LLM>
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

## Open WebUI
