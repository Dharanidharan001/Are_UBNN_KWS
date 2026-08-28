#!/usr/bin/env bash
# =============================================================================
# sim.sh — Compile and simulate ARe-UBNN-KWS with Icarus Verilog
# Run from: any directory (uses absolute paths)
# =============================================================================
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs/simulation"
OUT_DIR="$REPO_ROOT/outputs/simulation"

mkdir -p "$LOG_DIR" "$OUT_DIR"

SIM_OUT="$OUT_DIR/sim.out"
SIM_LOG="$LOG_DIR/sim.log"

echo "============================================================"
echo "  ARe-UBNN-KWS Simulation"
echo "============================================================"
echo "Repo: $REPO_ROOT"

RTL_FILES=(
    "$REPO_ROOT/src/compute/popcount.sv"
    "$REPO_ROOT/src/compute/unipolar_pe.sv"
    "$REPO_ROOT/src/compute/pe_array.sv"
    "$REPO_ROOT/src/baseline/accumulator.sv"
    "$REPO_ROOT/src/baseline/threshold_unit.sv"
    "$REPO_ROOT/src/ecc/secded_encoder.sv"
    "$REPO_ROOT/src/ecc/secded_decoder.sv"
    "$REPO_ROOT/src/memory/protected_weight_memory.sv"
    "$REPO_ROOT/src/power/activation_detector.sv"
    "$REPO_ROOT/src/power/icg.sv"
    "$REPO_ROOT/src/top/are_ubnn_kws_top.sv"
    "$REPO_ROOT/tb/top/tb_top.sv"
)

# Change to repo root so that $dumpfile("outputs/simulation/...") resolves correctly
cd "$REPO_ROOT"

echo "Compiling..."
iverilog -g2012 \
    -I "$REPO_ROOT/tb/interfaces" \
    -I "$REPO_ROOT/tb/transactions" \
    -I "$REPO_ROOT/tb/generator" \
    -I "$REPO_ROOT/tb/driver" \
    -I "$REPO_ROOT/tb/monitor" \
    -I "$REPO_ROOT/tb/scoreboard" \
    -I "$REPO_ROOT/tb/environment" \
    -o "$SIM_OUT" \
    "${RTL_FILES[@]}" \
    2>&1 | tee "$SIM_LOG"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "COMPILATION FAILED. See $SIM_LOG"
    exit 1
fi

echo "Compilation successful. Running simulation..."
vvp "$SIM_OUT" 2>&1 | tee -a "$SIM_LOG"

echo ""
echo "Done. VCD: $OUT_DIR/enhanced_waveform.vcd"
