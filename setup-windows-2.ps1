Write-Host '🔵 Tailscale' -ForegroundColor Cyan
# https://winget.run/pkg/tailscale/tailscale
winget install -e --id Tailscale.Tailscale --accept-source-agreements --accept-package-agreements
Set-Service -Name Tailscale -StartupType Automatic
# tailscale up --unattended=true

Write-Host '🔵 RustDesk' -ForegroundColor Cyan
winget install --id=RustDesk.RustDesk -e --accept-source-agreements --accept-package-agreements
Set-Service -Name RustDesk -StartupType Automatic

Write-Host '🔵 OpenSSH Server' -ForegroundColor Cyan
# Install OpenSSH Server
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start on boot, and start now
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

# Allow SSH from Tailscale
New-NetFirewallRule -Name 'OpenSSH-Server-Tailscale' -DisplayName 'OpenSSH Server (sshd) over Tailscale' -Enabled True -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22 -RemoteAddress 100.64.0.0/10

Write-Host '🔵 WSL' -ForegroundColor Cyan
wsl --update
wsl --set-default-version 2
schtasks /Create /F /TN 'Start WSL Ubuntu-24.04' /SC ONSTART /RL HIGHEST /TR 'wsl.exe -d Ubuntu-24.04 -u root --exec sleep infinity'
wsl --install -d Ubuntu-24.04
wsl --set-default Ubuntu-24.04

$wslconfig_path = "$env:USERPROFILE\.wslconfig"
if (-not (Select-String -Path $wslconfig_path -Pattern "vmIdleTimeout=-1" -Quiet)) {
    Add-Content -Path $wslconfig_path -Value "vmIdleTimeout=-1"
}
