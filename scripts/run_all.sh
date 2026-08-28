#!/usr/bin/env bash
# =============================================================================
# run_all.sh — Run simulation then synthesis
# =============================================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== STEP 1: Simulation ==="
bash "$SCRIPT_DIR/sim.sh"

echo ""
echo "=== STEP 2: Synthesis ==="
bash "$SCRIPT_DIR/synth.sh"

echo ""
echo "=== ALL STEPS COMPLETE ==="
echo "Outputs:"
find "$(dirname "$SCRIPT_DIR")/outputs" -type f | sort
