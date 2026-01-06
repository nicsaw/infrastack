Write-Host "🔵 Git" -ForegroundColor Cyan
winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements

$machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$env:Path = $machinePath + ";" + $userPath

$repoPath = "$HOME\pc-to-server"
if (Test-Path $repoPath) {
    cd $repoPath
    git pull
} else {
    cd $HOME
    git clone https://github.com/nicsaw/pc-to-server.git
    cd $repoPath
}

.\setup-windows.ps1