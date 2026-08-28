#!/usr/bin/env bash
#=============================================================================
# Synthesis Runner Script for ARe-UBNN-KWS
# Synthesizes both BASELINE and ENHANCED architectures targeting SKY130 HD library.
# Extracts exact tool-generated cell counts and areas for genuine comparison.
#=============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

mkdir -p "${ROOT_DIR}/logs/synthesis"
mkdir -p "${ROOT_DIR}/outputs/netlist"
mkdir -p "${ROOT_DIR}/outputs/synthesis"
mkdir -p "${ROOT_DIR}/outputs/reports"

ENHANCED_LOG="${ROOT_DIR}/logs/synthesis/synth_enhanced.log"
BASELINE_LOG="${ROOT_DIR}/logs/synthesis/synth_baseline.log"
COMPARISON_RPT="${ROOT_DIR}/outputs/synthesis/synthesis_comparison_report.txt"

echo "=========================================================="
echo " 1. Running ENHANCED Architecture Synthesis (SKY130)"
echo "=========================================================="
cd "${ROOT_DIR}"
yosys -s "${ROOT_DIR}/scripts/synth_enhanced.ys" 2>&1 | tee "${ENHANCED_LOG}"

echo "=========================================================="
echo " 2. Running BASELINE Architecture Synthesis (SKY130)"
echo "=========================================================="
yosys -s "${ROOT_DIR}/scripts/synth_baseline.ys" 2>&1 | tee "${BASELINE_LOG}"

echo "=========================================================="
echo " 3. Generating Architectural Comparison Report"
echo "=========================================================="

ENH_CELLS=$(grep -E "Number of cells:" "${ENHANCED_LOG}" | tail -n 1 | awk '{print $4}')
ENH_AREA=$(grep -E "Chip area for top module" "${ENHANCED_LOG}" | tail -n 1 | awk '{print $7}')

BASE_CELLS=$(grep -E "Number of cells:" "${BASELINE_LOG}" | tail -n 1 | awk '{print $4}')
BASE_AREA=$(grep -E "Chip area for top module" "${BASELINE_LOG}" | tail -n 1 | awk '{print $7}')

cat << EOF > "${COMPARISON_RPT}"
=============================================================================
             ARe-UBNN-KWS vs BASELINE SYNTHESIS COMPARISON REPORT
=============================================================================
Technology Target : SKY130 High Density (sky130_fd_sc_hd__tt_025C_1v80)
Synthesis Engine  : Yosys Open Synthesis Suite

-----------------------------------------------------------------------------
 METRIC                       BASELINE ARCHITECTURE    ENHANCED ARCHITECTURE
-----------------------------------------------------------------------------
 Target Design                baseline_ubnn_kws_top    are_ubnn_kws_top
 Total Standard Cell Count    ${BASE_CELLS:-N/A}                      ${ENH_CELLS:-N/A}
 Total Chip Area (um^2)       ${BASE_AREA:-N/A}                 ${ENH_AREA:-N/A}
 Inline SECDED Protection     None                     Hamming (22, 16) Codec
 Weight Fault Resilience      Vulnerable (0-bit)       1-bit Correct, 2-bit Detect
 Dynamic Power Reduction      None (Always ON)         Sparsity-aware ICG Gating
 Pipeline Latency Added       0 stages                 0 stages (Unmodified Datapath)
-----------------------------------------------------------------------------

RELIABILITY & EFFICIENCY ANALYSIS:
  - The Enhanced design adds inline SECDED Hamming (22, 16) protection directly
    at the weight memory read interface, providing 100% single-bit correction
    and double-bit detection during active inference without pipeline stalls.
  - The fine-grained activity detector gates inactive Processing Elements when
    their activation vector is all-zero (sparse frames), eliminating dynamic
    clock and register toggling.
=============================================================================
EOF

cat "${COMPARISON_RPT}"
cp "${COMPARISON_RPT}" "${ROOT_DIR}/outputs/reports/synthesis_summary.rpt"
echo "Synthesis complete. Report saved to ${COMPARISON_RPT}"
