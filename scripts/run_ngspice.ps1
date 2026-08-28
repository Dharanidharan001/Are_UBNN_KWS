# PowerShell ngspice runner for ARe-UBNN-KWS
$RootDir = Split-Path -Parent $PSScriptRoot
$WslRoot = "/mnt/c" + ($RootDir.Substring(2) -replace '\\', '/')
$Cmd = "cd '$WslRoot' && chmod +x scripts/run_ngspice.sh && ./scripts/run_ngspice.sh"

Write-Host "=========================================================="
Write-Host " Running ngspice SPICE Simulation via WSL"
Write-Host "=========================================================="
wsl -d Ubuntu -u root bash -c $Cmd

if ($LASTEXITCODE -ne 0) {
    Write-Error "ngspice simulation failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
} else {
    Write-Host "ngspice simulation PASSED."
}
