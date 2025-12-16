# pc-to-server

This project repurposes a Windows laptop into a server.

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

## [OpenSSH](https://www.openssh.org)

[Install OpenSSH server](https://documentation.ubuntu.com/server/how-to/security/openssh-server/#install-openssh):

```bash
sudo apt update
sudo apt install -y openssh-server
```

Start OpenSSH server:

```bash
sudo systemctl start ssh
```

Check OpenSSH service status:

```bash
sudo systemctl status ssh
```

Enable the OpenSSH server to start automatically at boot:

```bash
sudo systemctl enable --now ssh
```

Get Ubuntu IP address (use the first IP address):

```powershell
wsl hostname -I
```

Forward Windows port 2222 to Ubuntu port 22:

```powershell
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=2222 connectaddress=<UBUNUTU_IP> connectport=22
```

Allow inbound TCP connections to port 2222 through Windows Defender Firewall.

```powershell
New-NetFirewallRule -DisplayName "WSL SSH Port 2222" -Direction Inbound -Protocol TCP -LocalPort 2222 -Action Allow
```

Get Windows LAN IP address:

```powershell
ipconfig
```

Connect from client:

```
ssh -p 2222 <USERNAME>@<WINDOWS_LAN_IP>
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
