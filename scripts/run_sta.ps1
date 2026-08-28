# PowerShell Static Timing Analysis runner for ARe-UBNN-KWS
$RootDir = Split-Path -Parent $PSScriptRoot
$TimingDir = Join-Path $RootDir "outputs\timing"
$LogDir = Join-Path $RootDir "logs\timing"

if (-not (Test-Path $TimingDir)) { New-Item -ItemType Directory -Path $TimingDir -Force | Out-Null }
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

Write-Host "=========================================================="
Write-Host " Running Static Timing Analysis (STA) via OpenROAD in WSL"
Write-Host "=========================================================="

$WslRoot = "/mnt/c" + ($RootDir.Substring(2) -replace '\\', '/')
$Cmd = "cd '$WslRoot' && chmod +x scripts/run_sta.sh && ./scripts/run_sta.sh"

wsl -d Ubuntu -u root bash -c $Cmd

if ($LASTEXITCODE -ne 0) {
    Write-Error "STA failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
} else {
    Write-Host "STA PASSED."
}
