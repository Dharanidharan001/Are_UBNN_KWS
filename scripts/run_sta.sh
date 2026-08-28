#!/usr/bin/env bash
#=============================================================================
# Static Timing Analysis (STA) Runner Script for ARe-UBNN-KWS
# Executes OpenROAD timing engine on the SKY130 mapped gate-level netlist.
#=============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

mkdir -p "${ROOT_DIR}/outputs/timing"
mkdir -p "${ROOT_DIR}/logs/timing"

echo "=========================================================="
echo " Running Static Timing Analysis (STA) via OpenROAD"
echo "=========================================================="
python3 "${ROOT_DIR}/scripts/run_sta.py"
echo "STA completed successfully. Report in outputs/timing/timing_report.rpt"
