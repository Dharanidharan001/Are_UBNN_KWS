# PowerShell synthesis runner for ARe-UBNN-KWS
$RootDir = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $RootDir "logs\synthesis"
$NetDir = Join-Path $RootDir "outputs\netlist"
$SynthDir = Join-Path $RootDir "outputs\synthesis"
$RptDir = Join-Path $RootDir "outputs\reports"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
if (-not (Test-Path $NetDir)) { New-Item -ItemType Directory -Path $NetDir -Force | Out-Null }
if (-not (Test-Path $SynthDir)) { New-Item -ItemType Directory -Path $SynthDir -Force | Out-Null }
if (-not (Test-Path $RptDir)) { New-Item -ItemType Directory -Path $RptDir -Force | Out-Null }

Write-Host "=========================================================="
Write-Host " Running ARe-UBNN-KWS Synthesis Flow via WSL (Yosys)"
Write-Host "=========================================================="

# Convert Windows path to WSL path
$WslRoot = "/mnt/c" + ($RootDir.Substring(2) -replace '\\', '/')
$Cmd = "cd '$WslRoot' && chmod +x scripts/synth.sh && ./scripts/synth.sh"

wsl -d Ubuntu -u root bash -c $Cmd

if ($LASTEXITCODE -ne 0) {
    Write-Error "Synthesis failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
} else {
    Write-Host "Synthesis PASSED."
}
