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

## Ollama

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
