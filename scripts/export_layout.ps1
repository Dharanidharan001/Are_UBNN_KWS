# PowerShell runner for KLayout batch layout generation & PNG export
$RootDir = Split-Path -Parent $PSScriptRoot
$WslRoot = "/mnt/c" + ($RootDir.Substring(2) -replace '\\', '/')
$Cmd = "cd '$WslRoot' && chmod +x scripts/export_layout.sh && ./scripts/export_layout.sh"

Write-Host "=========================================================="
Write-Host " Running KLayout Batch Generation & Image Export via WSL"
Write-Host "=========================================================="
wsl -d Ubuntu -u root bash -c $Cmd

if ($LASTEXITCODE -ne 0) {
    Write-Error "KLayout export failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
} else {
    Write-Host "KLayout export PASSED."
}
