#!/usr/bin/env bash
#=============================================================================
# ngspice Runner Script for ARe-UBNN-KWS
# Runs transient SPICE analysis of SKY130 ICG standard cell (dlclkp_1)
# Measures propagation delay, clock gating isolation, and dynamic power savings.
#=============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

mkdir -p "${ROOT_DIR}/outputs/reports"
mkdir -p "${ROOT_DIR}/logs/spice"

SPICE_DECK="${ROOT_DIR}/scripts/icg_sim.spice"
REPORT_FILE="${ROOT_DIR}/outputs/reports/ngspice_simulation_report.txt"

echo "=========================================================="
echo " Running ngspice SPICE Simulation: SKY130 ICG Standard Cell"
echo "=========================================================="
ngspice -b "${SPICE_DECK}" -o "${REPORT_FILE}"

echo ""
echo "Simulation Complete! Characterization Summary:"
tail -n 22 "${REPORT_FILE}"
