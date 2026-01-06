Write-Host '🔵 Git' -ForegroundColor Cyan
winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

$repoPath = Join-Path $HOME 'pc-to-server'
if (Test-Path $repoPath) {
    cd $repoPath
    git pull
} else {
    cd $HOME
    git clone https://github.com/nicsaw/pc-to-server.git
    cd $repoPath
}

.\setup-windows-2.ps1