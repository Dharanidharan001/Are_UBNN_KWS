# Physical Design Execution & Signoff Checklist

**Design Target:** `are_ubnn_kws_enhanced_wrapper`  
**PDK:** SKY130 (`sky130_fd_sc_hd`)  
**Flow:** OpenLane 2 (v2.3.10) / OpenROAD / Yosys / Magic / Netgen / KLayout  

---

## Stage-by-Stage Verification Checklist

- [x] **Stage 01–04: Linter & Checker Passes**
  - Verilator lint passed. Zero unmapped constructs or timing issues.
- [x] **Stage 05–09: Yosys Synthesis & Tech Mapping**
  - Synthesized into 3,034 `sky130_fd_sc_hd` standard cells.
  - Zero unmapped cells. Netlist checks passed.
- [x] **Stage 10–12: SDC Parsing & Pre-PnR STA**
  - Explicit port constraints loaded without syntax errors. Pre-PnR timing verified.
- [x] **Stage 13–22: Floorplanning & PDN Generation**
  - Die Area: 520 × 520 µm (perimeter: 2,080 µm for 601 IO pins).
  - Clean `VPWR`/`VGND` power grid inserted.
- [x] **Stage 23–33: Global & Detailed Placement**
  - Density target: 30% (actual cell utilization: 16.95%).
  - 442 sequential DFFs and 2,548 combinational cells placed cleanly.
- [x] **Stage 34–37: Clock Tree Synthesis (CTS) & Timing Repair**
  - Clock tree inserted: 89 clk buffers, 51 clk inverters. Skew: 0.24 ns.
  - 352 hold buffers inserted. Setup WNS: +55.3 ns. Zero setup/hold violations.
- [x] **Stage 38–43: Global & Detailed Routing**
  - Global routing completed with 0 overflow.
  - Detailed routing completed across 4 iterations with 0 DRC violations.
  - Total routed wirelength: 162.77 mm.
- [x] **Stage 44–69: Parasitic Extraction (SPEF), Signoff STA, & Netgen LVS**
  - Multi-corner SPEF extraction complete.
  - Signoff STA clean across all 9 PVT corners (0 setup / 0 hold violations).
  - Netgen LVS: **Circuits match uniquely** (0 device/net differences).
- [x] **Stage 70–78: Physical DRC & GDSII Streaming**
  - Magic DRC: **0 errors**.
  - KLayout DRC (`sky130A_mr.drc`): **0 errors**.
  - Final GDSII generated: `outputs/pnr/gds/are_ubnn_kws_enhanced_wrapper.gds` (11.6 MB).
  - Final KLayout GDS generated: `outputs/pnr/klayout_gds/are_ubnn_kws_enhanced_wrapper.klayout.gds` (6.2 MB).