# OpenLane Physical Implementation Evidence

**Design:** `are_ubnn_kws_enhanced_wrapper`  
**PDK / Process:** SKY130A (sky130_fd_sc_hd)  
**OpenLane Run Tag:** `RUN_2026-08-28_15-58-06`  
**Run Status:** **PASS (78/78 Stages Completed)**  

---

## 1. High-Level Flow Signoff Matrix

| Item | Result | Evidence |
|------|--------|----------|
| **Technology** | SKY130A | `sky130A` PDK configuration via Volare (`libs.ref/sky130_fd_sc_hd`) |
| **Standard Cell Library** | `sky130_fd_sc_hd` | `scripts/openlane/config.json` |
| **Target Clock** | 10 MHz / 100.0 ns | `constraints/are_ubnn_kws.sdc` (Line 8: `create_clock -period 100.0`) |
| **Synthesis** | **PASS** | Stage 06 `Yosys.Synthesis` (`3,034` mapped cells, 0 check errors) |
| **Floorplan** | **PASS** | Stage 20 `OpenROAD.GeneratePDN` ($520 \times 520\ \mu\text{m}$ die, clean grid) |
| **Placement** | **PASS** | Stage 33 `OpenROAD.DetailedPlacement` (7,542 placed instances) |
| **CTS** | **PASS** | Stage 34 `OpenROAD.CTS` (89 clkbuf, 51 clkinv; 0.450 ns skew) |
| **Routing** | **PASS** | Stage 38 Global Routing & Stage 39 Detailed Routing (0 DRC violations) |
| **Post-route STA** | **PASS** | Stage 70/71 `Checker.SetupViolations` / `HoldViolations` (0 violations across 9 corners) |
| **GDSII** | **GENERATED** | `outputs/pnr/gds/are_ubnn_kws_enhanced_wrapper.gds` (11.08 MB) |
| **DRC** | **CLEAN (0 errors)** | Stage 74 `Misc.ReportManufacturability` (Magic: 0, KLayout: 0) |
| **LVS** | **MATCH** | Stage 68/69 `Netgen.LVS` & `Checker.LVS` ("Circuits match uniquely", 0 errors) |
| **Power** | **ESTIMATED** | Stage 58 `OpenROAD.STA` Power Analysis (1.5732 mW @ 10 MHz, 1.8V, 25°C) |

---

## 2. Key Measured/Estimated Metrics

All values below were extracted directly from the signed-off database `scripts/openlane/runs/RUN_2026-08-28_15-58-06/final/metrics.json`:

| Metric | Final Result | Notes |
|--------|--------------|-------|
| **Die Dimensions / Area** | $520.00 \times 520.00\ \mu\text{m}$ (270,400 $\mu\text{m}^2$) | Perimeter: $2,080\ \mu\text{m}$ (accommodates 601 IO pins) |
| **Core Dimensions / Area** | $503.24 \times 503.24\ \mu\text{m}$ (253,240 $\mu\text{m}^2$) | Standard-cell core bounding box |
| **Placed Instance Area** | 42,928.70 $\mu\text{m}^2$ | Active standard-cell silicon area |
| **Core Placement Density** | 16.95% | Target density: 30% |
| **Total Placed Instances** | 7,542 | Includes tap cells, buffers, and antenna diodes |
| **Sequential Cells (D-FFs)** | 442 | 442 flip-flops |
| **Combinational Logic Cells** | 2,548 | AND logic + Wall-Tree POPCOUNT + SECDED XOR trees |
| **Clock Tree Cells** | 140 (89 buf + 51 inv) | Max skew: 0.450 ns |
| **Timing Repair Buffers** | 712 (352 hold buffers) | 0 setup repair buffers required |
| **Total Routed Wirelength** | 162,771 $\mu\text{m}$ (162.77 mm) | 0 global routing overflows / 0 detailed DRCs |
| **Worst Setup Slack (Slow SS Corner)** | **+51.10 ns** | Worst-case setup margin (`max_ss_100C_1v60`) |
| **Worst Setup Slack (Nominal TT Corner)** | **+55.49 ns** | Nominal setup margin (`nom_tt_025C_1v80`) |
| **Worst Hold Slack (Fast FF Corner)** | **+0.062 ns** | Worst-case hold margin (`min_ff_n40C_1v95`) |
| **Setup Violations (All 9 Corners)** | **0** (Setup TNS = 0.00 ns) | Clean timing closure |
| **Hold Violations (All 9 Corners)** | **0** (Hold TNS = 0.00 ns) | Clean timing closure |
| **Estimated Internal Power** | 0.8450 mW | OpenROAD signoff power engine (53.71%) |
| **Estimated Switching Power** | 0.7281 mW | Interconnect capacitive dissipation (46.28%) |
| **Estimated Static Leakage Power** | 0.0601 $\mu\text{W}$ | Subthreshold leakage at 25°C (0.0038%) |
| **Estimated Total Power** | **1.5732 mW** | At 10.0 MHz, 1.80 V, 25°C (`nom_tt_025C_1v80`) |
| **Worst-Case IR Drop on $V_{PWR}$** | 0.2996 mV | $< 0.02\%$ of 1.8V supply rail |
| **Magic DRC Errors** | **0** | Clean physical design rules |
| **KLayout DRC Errors** | **0** | Clean manufacturing rules (`sky130A_mr.drc`) |
| **Netgen LVS Status** | **MATCH (0 errors)** | 4,204 nets and 2,199 devices match uniquely |
