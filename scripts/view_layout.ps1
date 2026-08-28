# PowerShell KLayout inspection runner for ARe-UBNN-KWS
$RootDir = Split-Path -Parent $PSScriptRoot
$WslRoot = "/mnt/c" + ($RootDir.Substring(2) -replace '\\', '/')
$Cmd = "cd '$WslRoot' && chmod +x scripts/view_layout.sh && ./scripts/view_layout.sh"

Write-Host "Launching KLayout from WSL..."
wsl -d Ubuntu -u root bash -c $Cmd
