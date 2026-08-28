# Enhanced Run Audit Report

**Design:** `are_ubnn_kws_enhanced_wrapper`  
**Run ID:** `RUN_2026-08-28_15-58-06`  
**EDA Flow:** OpenLane 2 (v2.3.10) / OpenROAD / Yosys / Magic / Netgen / KLayout  
**PDK:** SkyWater 130 nm (`sky130_fd_sc_hd`)  

---

## 1. Flow Completion Status
- **Sequential Stages Completed:** 78 / 78 stages
- **Final Termination Message:** `Flow complete.` (Exit code: 0)
- **Design Rule Checking (DRC):** Passed (Magic: 0 errors, KLayout: 0 errors)
- **Layout vs. Schematic (LVS):** Passed (Netgen: Circuits match uniquely)
- **Static Timing Analysis (STA):** Passed (0 setup / 0 hold violations across all 9 PVT corners)

---

## 2. Stage-by-Stage Execution Log

| Stage ID | Step Name | Tool | Status | Output Artifact |
|---|---|---|---|---|
| 01 | `Verilator.Lint` | Verilator | PASS | Clean lint (0 errors) |
| 05–06 | `Yosys.Synthesis` | Yosys | PASS | 3,034 mapped standard cells |
| 07–09 | `Checker.YosysChecks` | Yosys | PASS | Zero unmapped cells / zero check errors |
| 10–12 | `OpenROAD.STAPrePNR` | OpenSTA | PASS | SDC parsed; setup slack positive |
| 13–22 | `OpenROAD.Floorplan` | OpenROAD | PASS | 520 × 520 µm die; PDN power grid inserted |
| 23–33 | `OpenROAD.Placement` | OpenROAD | PASS | Global & detailed placement; 16.95% utilization |
| 34–37 | `OpenROAD.CTS` | OpenROAD | PASS | Clock tree built (89 clkbuf, 51 clkinv; 0.24 ns skew) |
| 38–43 | `OpenROAD.Routing` | TritonRoute | PASS | Global routing (0 overflow); Detailed routing (0 DRCs) |
| 44–58 | `OpenROAD.RCX / STA` | OpenSTA | PASS | Multi-corner SPEF extraction & signoff STA |
| 59–69 | `Netgen.LVS` | Netgen | PASS | Circuits match uniquely (4,204 nets) |
| 70–78 | `Misc.ReportManufacturability` | Magic / KLayout | PASS | Final GDS, DEF, LEF streamed to `final/` |

---

## 3. Verified Artifact Locations

- Primary GDSII: `outputs/pnr/gds/are_ubnn_kws_enhanced_wrapper.gds` (11.6 MB)
- KLayout GDSII: `outputs/pnr/klayout_gds/are_ubnn_kws_enhanced_wrapper.klayout.gds` (6.2 MB)
- DEF Database: `outputs/pnr/def/are_ubnn_kws_enhanced_wrapper.def` (5.5 MB)
- Abstract LEF: `outputs/pnr/lef/are_ubnn_kws_enhanced_wrapper.lef` (146 KB)
- Post-Route Netlist: `outputs/pnr/nl/are_ubnn_kws_enhanced_wrapper.nl.v` (1.6 MB)
- Powered Netlist: `outputs/pnr/pnl/are_ubnn_kws_enhanced_wrapper.pnl.v` (3.2 MB)
- Full Metrics Database: `outputs/pnr/metrics.json`
- Sequential Execution Log: `logs/pnr/openlane_flow.log`
