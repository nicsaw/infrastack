# pc-to-server

This project repurposes a Windows laptop into a server, with a macOS client used for administration and access.

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
wsl --install -d Ubuntu-24.04
```

Set Ubuntu 24.04 as the default Linux distribution:

```powershell
wsl --set-default Ubuntu-24.04
```

Start WSL at Windows startup:

```powershell
schtasks /Create /F /TN "Start WSL Ubuntu-24.04" /SC MINUTE /MO 1 /RL HIGHEST /TR "wsl.exe -d Ubuntu-24.04 -u root --exec sleep infinity"
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

## Private Submodules

The [`external/n8n`](.gitmodules) submodule points at a private repository, so the server needs a [GitHub deploy key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys) to clone it.

Generate a deploy key on WSL:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/n8n_deploy -N "" -C "wsl-deploy@n8n"
cat ~/.ssh/n8n_deploy.pub
```

Add the public key to the private repository:

1. `https://github.com/nicsaw/n8n/settings/keys`
1. `Add deploy key`
1. Paste the contents of `~/.ssh/n8n_deploy.pub`
1. Leave `Allow write access` unchecked
1. `Add key`

Tell SSH to use the deploy key for `github.com`:

```bash
cat >> ~/.ssh/config <<'EOF'

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/n8n_deploy
  IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config
```

Test authentication:

```bash
ssh -T git@github.com
```

Expected: `Hi nicsaw/n8n! You've successfully authenticated, but GitHub does not provide shell access.`

Initialise the submodule:

```bash
./update-submodules.sh
```

## [Tailscale](https://tailscale.com)

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

## [RustDesk](https://rustdesk.com)

### [Windows](https://tailscale.com/kb/1599/rustdesk)

[Install RustDesk for Windows](https://rustdesk.com/docs/en/self-host/client-deployment/#winget):

```powershell
winget install --id=RustDesk.RustDesk -e
```

RustDesk -> Settings -> Security -> Enable direct IP access -> Port `21118` -> Apply

Start RustDesk on boot:

```powershell
Set-Service -Name rustdesk -StartupType Automatic
```

### macOS

Install RustDesk for macOS:

```zsh
brew install --cask rustdesk
```

Go to the **Control Remote Desktop** box and paste the `100.x.x.x` Tailscale IP address for the device you want to connect to.

## [OpenSSH](https://www.openssh.org)

### WSL

[Install OpenSSH server](https://documentation.ubuntu.com/server/how-to/security/openssh-server/#install-openssh):

```bash
sudo apt update
sudo apt install -y openssh-server
```

Start OpenSSH server and enable to start automatically at boot:

```bash
sudo systemctl enable --now ssh
```

Check OpenSSH service status:

```bash
sudo systemctl status ssh
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
New-NetFirewallRule -Name "OpenSSH-Server-Tailscale" -DisplayName "OpenSSH Server (sshd) over Tailscale" -Enabled True -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22 -RemoteAddress 100.64.0.0/10
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

Add your user to the `docker` group and apply the `docker` group immediately:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

[Start services](compose.yaml):

```bash
cd ~/pc-to-server
docker compose up -d
```

## [Ollama](https://ollama.com) & [Open WebUI](https://openwebui.com)

[Select an LLM](https://ollama.com/library) and download it:

```bash
docker exec -it ollama ollama pull <LLM>
```

## [Cloudflared](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel)

Open [https://dash.cloudflare.com](https://dash.cloudflare.com)

Connect a website to Cloudflare:

1. [`Domains -> Onboard a domain`](https://dash.cloudflare.com/<ACCOUNT_ID>/domains/overview)
1. `Enter an existing domain -> Continue`
1. Select the free plan -> `Continue to activation`
1. Follow the steps to update nameservers

Create a tunnel:

1. [`Zero Trust -> Networks -> Connectors`](https://one.dash.cloudflare.com/<ACCOUNT_ID>/networks/connectors)
1. [`Cloudflare Tunnels -> Add a tunnel -> Select Cloudflared -> Name your tunnel`](https://one.dash.cloudflare.com/<ACCOUNT_ID>/networks/connectors/cloudflare-tunnels/add/cfd_tunnel)
1. `Save tunnel`
1. Select `Docker` as the environment
1. Copy the token -> `Next`
1. Add a published application route for n8n
   1. Set Hostname
      1. Subdomain: `n8n`
      1. Domain: `nicholassaw.com`
   1. Set Service
      1. Type: `HTTP`
      1. URL: `n8n:5678`
1. `Complete setup`

Create configuration file from template:

```bash
cp .env.example .env
```

Replace [`CLOUDFLARE_TUNNEL_TOKEN`](.env.example) with the copied token.

## [n8n](https://docs.n8n.io/hosting)

### [Google Cloud Console](https://console.cloud.google.com)

1. Create New Project

1. APIs & Services -> OAuth consent screen
   1. Audience: `External`
   1. `Create`

1. APIs & Services -> Credentials
   1. `Create Credentials -> OAuth client ID`
   1. Application type: `Web application`
   1. Name: `n8n`
   1. Authorized redirect URIs: `https://n8n.nicholassaw.com/rest/oauth2-credential/callback`
   1. `Create`
   1. Copy `Client ID` and `Client secret` to [n8n Credentials](https://n8n.nicholassaw.com/credentials)

1. APIs & Services -> OAuth consent screen -> Audience -> Test users
   1. `Add users`: Add the email to be used for authentication

1. APIs & Services -> Library
   1. Enable required APIs

## [OpenClaw](https://docs.openclaw.ai)

```bash
mkdir -p ~/pc-to-server/services/openclaw/config ~/pc-to-server/services/openclaw/workspace
```

[SSH Tunnel](https://docs.openclaw.ai/gateway/remote#ssh-tunnel-cli-+-tools):

```zsh
ssh -N -L 18789:127.0.0.1:18789 user@host
```
