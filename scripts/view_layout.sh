#!/usr/bin/env bash
#=============================================================================
# KLayout Layout Inspection Runner for ARe-UBNN-KWS
# Launches KLayout GUI to inspect DEF/GDS files with SKY130 layer properties.
#=============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

GDS_FILE="${ROOT_DIR}/outputs/layout/are_ubnn_kws.gds"

if [ -f "${GDS_FILE}" ]; then
    echo "[INFO] Launching KLayout with GDSII: ${GDS_FILE}"
    DISPLAY=:0 WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir klayout "${GDS_FILE}" &
else
    echo "[INFO] Launching KLayout in standalone mode..."
    DISPLAY=:0 WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir klayout &
fi
