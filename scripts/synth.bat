@echo off
setlocal
set REPO_ROOT=%~dp0..
set LOG_DIR=%REPO_ROOT%\logs\synthesis
set OUT_DIR=%REPO_ROOT%\outputs\synthesis
set SCRIPT_DIR=%REPO_ROOT%\scripts
set OSS=E:\oss-cad-suite-windows-x64-20260827\oss-cad-suite
set REPO_FWD=%REPO_ROOT:\=/%

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

echo ============================================================
echo   ARe-UBNN-KWS Yosys Synthesis (Baseline vs Enhanced)
echo ============================================================

REM --- BASELINE SYNTHESIS ---
set YS_BASE=%SCRIPT_DIR%\synth_baseline.ys
echo read_verilog -sv %REPO_FWD%/src/compute/popcount.sv > "%YS_BASE%"
echo read_verilog -sv %REPO_FWD%/src/compute/unipolar_pe.sv >> "%YS_BASE%"
echo read_verilog -sv %REPO_FWD%/src/compute/pe_array.sv >> "%YS_BASE%"
echo read_verilog -sv %REPO_FWD%/src/baseline/accumulator.sv >> "%YS_BASE%"
echo read_verilog -sv %REPO_FWD%/src/baseline/threshold_unit.sv >> "%YS_BASE%"
echo read_verilog -sv %REPO_FWD%/src/ecc/secded_encoder.sv >> "%YS_BASE%"
echo read_verilog -sv %REPO_FWD%/src/ecc/secded_decoder.sv >> "%YS_BASE%"
echo read_verilog -sv %REPO_FWD%/src/memory/protected_weight_memory.sv >> "%YS_BASE%"
echo read_verilog -sv %REPO_FWD%/src/power/activation_detector.sv >> "%YS_BASE%"
echo read_verilog -sv %REPO_FWD%/src/power/icg.sv >> "%YS_BASE%"
echo read_verilog -sv %REPO_FWD%/src/top/are_ubnn_kws_top.sv >> "%YS_BASE%"
echo chparam -set ENABLE_ENHANCED 0 are_ubnn_kws_top >> "%YS_BASE%"
echo synth -top are_ubnn_kws_top -flatten >> "%YS_BASE%"
echo opt -full >> "%YS_BASE%"
echo stat >> "%YS_BASE%"

echo Running Yosys Baseline...
call "%OSS%\environment.bat" && yosys "%YS_BASE%" > "%LOG_DIR%\yosys_baseline.log" 2>&1

REM --- ENHANCED SYNTHESIS ---
set YS_ENH=%SCRIPT_DIR%\synth_enhanced.ys
echo read_verilog -sv %REPO_FWD%/src/compute/popcount.sv > "%YS_ENH%"
echo read_verilog -sv %REPO_FWD%/src/compute/unipolar_pe.sv >> "%YS_ENH%"
echo read_verilog -sv %REPO_FWD%/src/compute/pe_array.sv >> "%YS_ENH%"
echo read_verilog -sv %REPO_FWD%/src/baseline/accumulator.sv >> "%YS_ENH%"
echo read_verilog -sv %REPO_FWD%/src/baseline/threshold_unit.sv >> "%YS_ENH%"
echo read_verilog -sv %REPO_FWD%/src/ecc/secded_encoder.sv >> "%YS_ENH%"
echo read_verilog -sv %REPO_FWD%/src/ecc/secded_decoder.sv >> "%YS_ENH%"
echo read_verilog -sv %REPO_FWD%/src/memory/protected_weight_memory.sv >> "%YS_ENH%"
echo read_verilog -sv %REPO_FWD%/src/power/activation_detector.sv >> "%YS_ENH%"
echo read_verilog -sv %REPO_FWD%/src/power/icg.sv >> "%YS_ENH%"
echo read_verilog -sv %REPO_FWD%/src/top/are_ubnn_kws_top.sv >> "%YS_ENH%"
echo chparam -set ENABLE_ENHANCED 1 are_ubnn_kws_top >> "%YS_ENH%"
echo synth -top are_ubnn_kws_top -flatten >> "%YS_ENH%"
echo opt -full >> "%YS_ENH%"
echo stat >> "%YS_ENH%"

echo Running Yosys Enhanced...
call "%OSS%\environment.bat" && yosys "%YS_ENH%" > "%LOG_DIR%\yosys_enhanced.log" 2>&1

REM Extract statistics
powershell -Command "$log = Get-Content '%LOG_DIR%\yosys_baseline.log'; $start = $log.IndexOf('=== are_ubnn_kws_top ==='); if ($start -ge 0) { $log[$start..($start+50)] | Out-File '%OUT_DIR%\baseline_statistics.txt' -Encoding UTF8 }"
powershell -Command "$log = Get-Content '%LOG_DIR%\yosys_enhanced.log'; $start = $log.IndexOf('=== are_ubnn_kws_top ==='); if ($start -ge 0) { $log[$start..($start+50)] | Out-File '%OUT_DIR%\enhanced_statistics.txt' -Encoding UTF8 }"

echo Synthesis complete!