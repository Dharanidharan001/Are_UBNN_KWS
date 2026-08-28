# Final Evidence Table

| Requirement | Evidence | Status | Measured Metric |
|---|---|---|---|
| RTL simulation | `outputs/simulation/sim.out` | **VERIFIED** | Full functional match |
| 42-test regression | `logs/simulation/final_regression.log` | **VERIFIED** | 42/42 PASS |
| SECDED single-bit testing | `logs/simulation/final_regression.log` | **VERIFIED** | Bits 0–21 tested & corrected |
| SECDED double-bit detection | `logs/simulation/final_regression.log` | **VERIFIED** | Double-bit flags asserted |
| Generic synthesis | `outputs/synthesis/enhanced_statistics.txt` | **VERIFIED** | 3,078 generic cells |
| SKY130 mapping | `outputs/pnr/nl/are_ubnn_kws_enhanced_wrapper.nl.v` | **VERIFIED** | `sky130_fd_sc_hd` (3,034 synth cells) |
| Floorplanning | `outputs/pnr/def/are_ubnn_kws_enhanced_wrapper.def` | **VERIFIED** | 520 × 520 µm die, 253,240 µm² core |
| Placement | `outputs/pnr/odb/are_ubnn_kws_enhanced_wrapper.odb` | **VERIFIED** | 7,542 placed cells (442 DFFs, 16.95% util) |
| CTS | `outputs/pnr/final/metrics.json` | **VERIFIED** | 89 clk buffers, 51 clk inverters, 0.24 ns skew |
| Routing | `outputs/pnr/def/are_ubnn_kws_enhanced_wrapper.def` | **VERIFIED** | 162.77 mm total wirelength, 0 overflows |
| Signoff STA | `outputs/pnr/metrics.json` | **VERIFIED** | Evaluated across all 9 PVT corners |
| Timing closure | `outputs/pnr/metrics.json` | **VERIFIED** | **0 setup / 0 hold violations** (Setup WNS: +51.10 ns) |
| Power analysis | `outputs/pnr/metrics.json` | **VERIFIED** | **1.573 mW total** (10 MHz, 1.8V, nom_tt_025C_1v80) |
| VCD switching activity | `outputs/simulation/enhanced_waveform.vcd` | **VERIFIED** | Activity suppression confirmed |
| GDSII | `outputs/pnr/gds/are_ubnn_kws_enhanced_wrapper.gds` | **VERIFIED** | 11.6 MB (Streamed from Magic & KLayout) |
| KLayout GDS | `outputs/pnr/klayout_gds/are_ubnn_kws_enhanced_wrapper.klayout.gds` | **VERIFIED** | 6.2 MB GDSII ready for visual inspection |
| DRC | `outputs/pnr/metrics.json` | **VERIFIED** | **0 errors** (Magic DRC: 0, KLayout DRC: 0) |
| LVS | `outputs/pnr/metrics.json` | **VERIFIED** | **0 errors** (Netgen LVS: Circuits match uniquely) |
| NGSpice demonstration | `docs/ngspice_demo.md` | PENDING | SPICE deck provided |