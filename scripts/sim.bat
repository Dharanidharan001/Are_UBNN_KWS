@echo off
REM sim.bat - Windows wrapper to compile and simulate
REM Requires: Icarus Verilog installed and on PATH

setlocal
set REPO_ROOT=%~dp0..
set LOG_DIR=%REPO_ROOT%\logs\simulation
set OUT_DIR=%REPO_ROOT%\outputs\simulation

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

echo ============================================================
echo   ARe-UBNN-KWS Simulation
echo ============================================================

iverilog -g2012 ^
    -I "%REPO_ROOT%\tb\interfaces" ^
    -I "%REPO_ROOT%\tb\transactions" ^
    -I "%REPO_ROOT%\tb\generator" ^
    -I "%REPO_ROOT%\tb\driver" ^
    -I "%REPO_ROOT%\tb\monitor" ^
    -I "%REPO_ROOT%\tb\scoreboard" ^
    -I "%REPO_ROOT%\tb\environment" ^
    -o "%OUT_DIR%\sim.out" ^
    "%REPO_ROOT%\src\compute\popcount.sv" ^
    "%REPO_ROOT%\src\compute\unipolar_pe.sv" ^
    "%REPO_ROOT%\src\compute\pe_array.sv" ^
    "%REPO_ROOT%\src\baseline\accumulator.sv" ^
    "%REPO_ROOT%\src\baseline\threshold_unit.sv" ^
    "%REPO_ROOT%\src\ecc\secded_encoder.sv" ^
    "%REPO_ROOT%\src\ecc\secded_decoder.sv" ^
    "%REPO_ROOT%\src\memory\protected_weight_memory.sv" ^
    "%REPO_ROOT%\src\power\activation_detector.sv" ^
    "%REPO_ROOT%\src\power\icg.sv" ^
    "%REPO_ROOT%\src\top\are_ubnn_kws_top.sv" ^
    "%REPO_ROOT%\tb\top\tb_top.sv" ^
    2>&1 | tee "%LOG_DIR%\sim.log"

if errorlevel 1 (
    echo COMPILATION FAILED. See %LOG_DIR%\sim.log
    exit /b 1
)

echo Compilation successful. Running simulation...
cd /d "%REPO_ROOT%"
vvp "%OUT_DIR%\sim.out" 2>&1 | tee -a "%LOG_DIR%\sim.log"

echo.
echo Done. VCD: %OUT_DIR%\enhanced_waveform.vcd
