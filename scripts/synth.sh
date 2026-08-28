#!/usr/bin/env bash
# =============================================================================
# synth.sh — Yosys synthesis for ARe-UBNN-KWS
# =============================================================================
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs/synthesis"
OUT_DIR="$REPO_ROOT/outputs/synthesis"
SCRIPT_DIR="$REPO_ROOT/scripts"

mkdir -p "$LOG_DIR" "$OUT_DIR"

echo "============================================================"
echo "  ARe-UBNN-KWS Yosys Synthesis"
echo "============================================================"
echo "Repo: $REPO_ROOT"

if ! command -v yosys &> /dev/null; then
    echo "ERROR: yosys not found in PATH."
    echo "  Install OSS CAD Suite from: https://github.com/YosysHQ/oss-cad-suite-build"
    echo "  Then add <oss-cad-suite>/bin to PATH."
    exit 1
fi

YOSYS_SCRIPT="$SCRIPT_DIR/synth.ys"

# Write Yosys script using absolute paths
cat > "$YOSYS_SCRIPT" << YOSYS_EOF
# ARe-UBNN-KWS Yosys synthesis script
# RTL files only (no testbench)

read_verilog -sv $REPO_ROOT/src/compute/popcount.sv
read_verilog -sv $REPO_ROOT/src/compute/unipolar_pe.sv
read_verilog -sv $REPO_ROOT/src/compute/pe_array.sv
read_verilog -sv $REPO_ROOT/src/baseline/accumulator.sv
read_verilog -sv $REPO_ROOT/src/baseline/threshold_unit.sv
read_verilog -sv $REPO_ROOT/src/ecc/secded_encoder.sv
read_verilog -sv $REPO_ROOT/src/ecc/secded_decoder.sv
read_verilog -sv $REPO_ROOT/src/memory/protected_weight_memory.sv
read_verilog -sv $REPO_ROOT/src/power/activation_detector.sv
read_verilog -sv $REPO_ROOT/src/power/icg.sv
read_verilog -sv $REPO_ROOT/src/top/are_ubnn_kws_top.sv

# Synthesize with flattening for area estimate
synth -top are_ubnn_kws_top -flatten

# Generic technology mapping
techmap
opt -full

# Print statistics to log
stat

# Write synthesized netlist
write_verilog -noattr $OUT_DIR/netlist.v
write_json $OUT_DIR/netlist.json
YOSYS_EOF

echo "Running Yosys..."
yosys "$YOSYS_SCRIPT" 2>&1 | tee "$LOG_DIR/yosys.log"

# Extract stat block to a summary file
if grep -q "=== are_ubnn_kws_top ===" "$LOG_DIR/yosys.log"; then
    grep -A 40 "=== are_ubnn_kws_top ===" "$LOG_DIR/yosys.log" > "$OUT_DIR/statistics.txt"
    echo ""
    echo "Statistics extracted to: $OUT_DIR/statistics.txt"
fi

echo ""
echo "Synthesis complete."
echo "Netlist : $OUT_DIR/netlist.v"
echo "Log     : $LOG_DIR/yosys.log"
