#!/usr/bin/env bash
#=============================================================================
# Simulation runner script for ARe-UBNN-KWS
# Runs Icarus Verilog simulation and captures log and VCD waveforms.
#=============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

mkdir -p "${ROOT_DIR}/logs/simulation"
mkdir -p "${ROOT_DIR}/outputs/waveforms"

SIM_LOG="${ROOT_DIR}/logs/simulation/sim_run.log"
VCD_OUT="${ROOT_DIR}/outputs/waveforms/are_ubnn_kws.vcd"
VVP_OUT="${ROOT_DIR}/outputs/sim.vvp"

echo "=========================================================="
echo " Starting Simulation: ARe-UBNN-KWS (Icarus Verilog 12)"
echo "=========================================================="
echo "Log file: ${SIM_LOG}"

iverilog -g2012 \
    -I"${ROOT_DIR}/src" \
    -I"${ROOT_DIR}/tb" \
    "${ROOT_DIR}/src/popcount16.sv" \
    "${ROOT_DIR}/src/unipolar_pe.sv" \
    "${ROOT_DIR}/src/secded_encoder.sv" \
    "${ROOT_DIR}/src/secded_decoder.sv" \
    "${ROOT_DIR}/src/protected_weight_memory.sv" \
    "${ROOT_DIR}/src/pe_activity_detector.sv" \
    "${ROOT_DIR}/src/icg_cell.sv" \
    "${ROOT_DIR}/src/pe_array16.sv" \
    "${ROOT_DIR}/src/accumulator.sv" \
    "${ROOT_DIR}/src/threshold_unit.sv" \
    "${ROOT_DIR}/src/controller.sv" \
    "${ROOT_DIR}/src/are_ubnn_kws_top.sv" \
    "${ROOT_DIR}/tb/tb_top.sv" \
    -o "${VVP_OUT}" 2>&1 | tee "${SIM_LOG}"

echo "Running simulation with VVP..."
vvp "${VVP_OUT}" +VCD_FILE="${VCD_OUT}" 2>&1 | tee -a "${SIM_LOG}"

echo "Simulation completed successfully. Log saved to ${SIM_LOG}"
