#!/usr/bin/env bash
#=============================================================================
# KLayout Layout Generator & PNG Exporter Runner
#=============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=========================================================="
echo " Running KLayout Layout Generation & Image Export"
echo "=========================================================="
klayout -b -r "${ROOT_DIR}/scripts/generate_klayout_output.py"
echo "Layout export completed. Check outputs/layout/ and outputs/reports/klayout_layout_report.txt"
