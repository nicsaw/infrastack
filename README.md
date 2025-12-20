# pc-to-server

This project repurposes a Windows laptop into a server.

## Laptop Settings

Never sleep, hibernate, or shutdown.

Settings -> Power & battery -> Lid, power & sleep button controls -> Closing the lid will make my PC -> **Do Nothing**

MyAsus -> Device Settings -> Power & Performance -> Battery Health Charging -> **Maximum lifespan mode** (limits battery charge to 60%)

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

Set Ubuntu 24.04 as the default Linux distribution:

```powershell
wsl --set-default Ubuntu-24.04
```

Start WSL at Windows startup:

```powershell
schtasks /Create /F `
  /TN "Start WSL Ubuntu-24.04" `
  /SC ONSTART `
  /RL HIGHEST `
  /TR "wsl.exe -d Ubuntu-24.04 -u root --exec sleep infinity"
```

Run scheduled task manually:

```powershell
schtasks /Run /TN "Start WSL Ubuntu-24.04"
```

Enable Task Scheduler logging:

```powershell
wevtutil sl Microsoft-Windows-TaskScheduler/Operational /e:true
```

Update and upgrade the Ubuntu system:

```bash
sudo apt update && sudo apt upgrade -y
```

Install Git:

```bash
sudo apt install -y git
```

Clone this repository:

```bash
cd ~
git clone https://github.com/nicsaw/pc-to-server.git
cd pc-to-server
```

## Tailscale

### WSL

[Install Tailscale](https://tailscale.com/download/linux):

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

Enable the Tailscale service to start automatically at boot:

```bash
sudo systemctl enable --now tailscaled
```

Start Tailscale:

```bash
sudo tailscale up
```

### Windows

[Download Tailscale for Windows](https://tailscale.com/download/windows).

Start Tailscale:

```powershell
tailscale up --unattended=true
```

### macOS

[Install Tailscale with Homebrew](https://formulae.brew.sh/cask/tailscale-app):

```zsh
brew install --cask tailscale-app
```

Start Tailscale:

```zsh
tailscale up
```

## [OpenSSH](https://www.openssh.org)

### WSL

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

Connect from client to server:

```bash
ssh <WSL_USERNAME>@<TAILSCALE_IP>
```

### Windows

```powershell
# Install OpenSSH Server
Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*"
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start on boot, and start now
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

# Allow SSH from Tailscale
New-NetFirewallRule `
  -Name "OpenSSH-Server-Tailscale" `
  -DisplayName "OpenSSH Server (sshd) over Tailscale" `
  -Enabled True `
  -Direction Inbound `
  -Action Allow `
  -Protocol TCP `
  -LocalPort 22 `
  -RemoteAddress 100.64.0.0/10
```

Connect from client to server:

```bash
ssh <WINDOWS_USERNAME>@<TAILSCALE_IP>
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

Start Docker on boot:

```bash
sudo systemctl enable --now docker
```

## [Ollama](https://ollama.com) & [Open WebUI](https://openwebui.com)

Add your user to the `docker` group and apply the `docker` group immediately:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

[Start services](docker-compose.yml):

```bash
cd ~/pc-to-server
docker compose up -d
```

[Select an LLM](https://ollama.com/library) and download it:

```bash
docker exec -it ollama ollama pull <LLM>
```

Open [http://localhost:3000](http://localhost:3000).

### Connect from Client

If necessary, remove old SSH host key:

```zsh
ssh-keygen -R "<TAILSCALE_IP>"
```

Connect from client:

```zsh
ssh -N -L 3000:localhost:3000 <WSL_USERNAME>@<TAILSCALE_IP>
```
