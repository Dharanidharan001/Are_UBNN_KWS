# ARe-UBNN-KWS — OpenLane 2 Physical Implementation Evidence

**Technology:** SKY130A | **Library:** sky130_fd_sc_hd | **Target Clock:** 10 MHz (100 ns)

---

## Signoff Execution Status

- **Synthesis:** **PASS** (3,034 mapped stdcells, Yosys)
- **Floorplan:** **PASS** ($520 \times 520\ \mu\text{m}$ die, PDN inserted)
- **Placement:** **PASS** (7,542 placed cells, 16.95% utilization)
- **CTS:** **PASS** (140 clock cells, 0.450 ns skew)
- **Routing:** **PASS** (162.77 mm wirelength, 0 DRC violations)
- **Post-route STA:** **PASS** (Setup WNS: +51.10 ns, 0 setup/hold violations)
- **GDSII:** **GENERATED** (`outputs/pnr/gds/are_ubnn_kws_enhanced_wrapper.gds`, 11.08 MB)
- **DRC:** **0 errors (CLEAN)** (Magic & KLayout DRC)
- **LVS:** **MATCH (0 errors)** (Netgen LVS, 4,204 nets match uniquely)
- **Power:** **ESTIMATED** (1.5732 mW @ 10 MHz, 1.8V)

---

## 8 Key Quantitative Metrics

1. **Die Area:** $520 \times 520\ \mu\text{m}$ ($0.2704\ \text{mm}^2$)
2. **Active Cell Area:** 42,928.70 $\mu\text{m}^2$ (16.95% Core Utilization)
3. **Placed Instance Count:** 7,542 (442 DFFs, 2,548 Combinational Logic Cells)
4. **Worst-Case Setup Margin:** **+51.10 ns** (Slow Corner SS 100°C 1.6V)
5. **Worst-Case Hold Margin:** **+0.062 ns** (Fast Corner FF -40°C 1.95V)
6. **OpenROAD Estimated Power:** **1.5732 mW** (0.845 mW internal, 0.728 mW switching)
7. **Supply IR-Drop:** **0.2996 mV** ($<0.02\%$ of 1.8V Rail)
8. **Physical Verification:** **0 DRC / 0 LVS Errors** (Circuits match uniquely)
