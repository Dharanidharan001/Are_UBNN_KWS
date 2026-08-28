# PowerShell simulation runner for ARe-UBNN-KWS
param (
    [string]$TestName = "popcount"
)

$RootDir = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $RootDir "logs\simulation"
$WaveDir = Join-Path $RootDir "outputs\waveforms"
$OutputDir = Join-Path $RootDir "outputs"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
if (-not (Test-Path $WaveDir)) { New-Item -ItemType Directory -Path $WaveDir -Force | Out-Null }
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$LogFile = Join-Path $LogDir "sim_${TestName}.log"
$VcdFile = Join-Path $WaveDir "are_ubnn_kws.vcd"

Write-Host "=========================================================="
Write-Host " Running ARe-UBNN-KWS Simulation via WSL (Icarus 12.0)"
Write-Host " Log Destination : $LogFile"
Write-Host " VCD Destination : $VcdFile"
Write-Host "=========================================================="

# Convert Windows path to WSL path
$WslRoot = "/mnt/c" + ($RootDir.Substring(2) -replace '\\', '/')
$Cmd = "cd '$WslRoot' && chmod +x scripts/sim.sh && ./scripts/sim.sh"

wsl -d Ubuntu -u root bash -c $Cmd

if ($LASTEXITCODE -ne 0) {
    Write-Error "Simulation failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
} else {
    Write-Host "Simulation PASSED."
}
