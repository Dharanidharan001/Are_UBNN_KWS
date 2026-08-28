#!/usr/bin/env bash
# =============================================================================
# clean.sh — Remove generated files safely (preserves source and docs)
# =============================================================================
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Cleaning generated files..."

# Remove simulation outputs
rm -f "$REPO_ROOT/outputs/simulation/"*.vcd
rm -f "$REPO_ROOT/outputs/simulation/"*.out

# Remove synthesis outputs
rm -f "$REPO_ROOT/outputs/synthesis/"*.v
rm -f "$REPO_ROOT/outputs/synthesis/"*.txt
rm -f "$REPO_ROOT/outputs/synthesis/"*.json

# Remove PNR outputs
rm -f "$REPO_ROOT/outputs/pnr/"*

# Remove logs
rm -f "$REPO_ROOT/logs/simulation/"*
rm -f "$REPO_ROOT/logs/synthesis/"*
rm -f "$REPO_ROOT/logs/pnr/"*

# Remove temp synthesis script
rm -f "$REPO_ROOT/scripts/synth.ys"

echo "Clean complete. Source files preserved."
