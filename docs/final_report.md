# ARe-UBNN-KWS: Final Engineering Report

**Project Name:** ARe-UBNN-KWS  
**Full Title:** Adaptive/Reconfigurable Unipolar Binary Neural Network Accelerator for Edge Keyword Spotting  
**Technology:** SkyWater 130 nm CMOS (`sky130_fd_sc_hd`)  
**Design Environment:** OpenLane 2 (v2.3.10) / OpenROAD / Yosys / Magic / Netgen / KLayout  
**Final Status:** **PHYSICALLY IMPLEMENTED & SIGNOFF VERIFIED (GDSII COMPLETE)**  

---

## 1. Executive Summary

The **ARe-UBNN-KWS** project delivers an open-source, fault-tolerant, and sparsity-aware hardware accelerator designed for always-on edge Keyword Spotting (KWS). Targeting the open-source **SkyWater 130 nm (SKY130)** process, the design replaces power-hungry Multiply-Accumulate (MAC) units with energy-efficient **Unipolar Binary Arithmetic** ($\text{AND} + \text{POPCOUNT}$), incorporates **Extended Hamming (22,16) SECDED** on-chip weight protection, and uses **per-PE synchronous clock-enable** activity suppression.

Both the **Enhanced Architecture** (`ENABLE_ENHANCED=1`) and a structurally equivalent **Baseline Architecture** (`ENABLE_ENHANCED=0`) were implemented through the complete RTL-to-GDSII flow in OpenLane 2.3.10. Both designs achieved full physical verification (**0 DRC errors**, **0 LVS errors**), closed timing across all 9 PVT corners at 10 MHz with $>50\text{ ns}$ setup slack, and streamed verified GDSII layout databases.

---

## 2. Architecture & Arithmetic Foundation

### 2.1 Unipolar Binary Computation
Unlike conventional bipolar Binary Neural Networks (BNNs) where activations $x_i \in \{-1, +1\}$ require $\text{XNOR}$ operations and integer offsets, the unipolar representation uses $x_i, w_i \in \{0, 1\}$:
$$x_i \cdot w_i = x_i \land w_i \quad (\text{Single 2-input AND gate})$$
$$\text{PE Output} = \text{POPCOUNT}_{16}(X \land W) = \sum_{k=0}^{15} (x_k \land w_k)$$

### 2.2 Extended Hamming SECDED (22,16) Weight Protection
To ensure resilience against single-event upsets (SEUs) and radiation in edge deployment, each 16-bit weight vector is stored as a 22-bit SECDED codeword:
- **16 Data Bits** ($d_0 \dots d_{15}$)
- **5 Hamming Parity Bits** ($p_1, p_2, p_4, p_8, p_{16}$) covering overlapping power-of-two bit positions
- **1 Overall Parity Bit** ($p_{overall} = \bigoplus_{k=0}^{20} \text{cw}[k]$)
- **Correction Capability:** $100\%$ real-time single-bit error correction across all 22 bit positions; $100\%$ double-bit error detection with interrupt signaling.

### 2.3 Per-PE Sparsity-Aware Activity Control
Speech features exhibit significant temporal silence and zero activations. A 16-channel `activation_detector` performs parallel OR-reductions on incoming feature vectors. When PE input $X_i = 0$, `pe_active[i]` is deasserted, synchronously gating the PE output registers and eliminating dynamic switching dissipation during silence frames.

---

## 3. Verification Summary

- **Environment:** Non-UVM SystemVerilog testbench (`Test`, `Environment`, `Interface`, `Transaction`, `Generator`, `Driver`, `Monitor`, `Scoreboard`).
- **Total Test Cases Executed:** **42 / 42 Tests Passed (100%)**
- **SECDED Coverage:** Exhaustive single-bit fault injection tested across **all 22 codeword bits (0–21)** with bit-accurate correction verified in the scoreboard.
- **Double-Bit Coverage:** Verified non-correction flag assertion without false data corruption.
- **Post-PnR Regression Log:** `logs/simulation/final_regression_post_pnr.log`

---

## 4. Physical Design & Signoff Implementation (SKY130)

| Physical Stage | Tool | Enhanced Design (`RUN_2026-08-28_15-58-06`) | Baseline Design (`RUN_2026-08-28_16-11-55`) | Status |
|---|---|---|---|---|
| **Synthesis** | Yosys | 3,034 mapped standard cells | 1,624 mapped standard cells | PASS |
| **Die Dimensions** | OpenROAD | $520.00 \times 520.00\ \mu\text{m}$ ($0.2704\text{ mm}^2$) | $520.00 \times 520.00\ \mu\text{m}$ ($0.2704\text{ mm}^2$) | PASS |
| **Cell Area** | OpenROAD | $42,928.70\ \mu\text{m}^2$ ($16.95\%$ core util) | $20,274.40\ \mu\text{m}^2$ ($8.01\%$ core util) | PASS |
| **CTS Insertion** | OpenROAD | 89 buffers, 51 inverters ($0.24\text{ ns}$ skew) | 9 buffers, 6 inverters ($0.25\text{ ns}$ skew) | PASS |
| **Hold Repair** | OpenROAD | 352 hold buffers inserted | 0 hold buffers required | PASS |
| **Total Placed Instances** | OpenROAD | 7,542 standard cells | 5,799 standard cells | PASS |
| **Routed Wirelength** | TritonRoute | $162.77\text{ mm}$ (0 violations) | $82.20\text{ mm}$ (0 violations) | PASS |
| **Signoff STA Setup WNS** | OpenSTA | **$+51.10\text{ ns}$** (Worst SS corner) | **$+56.03\text{ ns}$** (Worst SS corner) | PASS |
| **Signoff STA Hold WNS** | OpenSTA | **$+0.062\text{ ns}$** (Worst FF corner) | **$+0.120\text{ ns}$** (Worst FF corner) | PASS |
| **Estimated Total Power** | OpenROAD | **$1.5732\text{ mW}$** (@ 10 MHz, 1.8V) | **$0.7868\text{ mW}$** (@ 10 MHz, 1.8V) | PASS |
| **Worst-Case IR Drop** | OpenROAD | **$0.30\text{ mV}$** ($<0.02\%$ on $1.8\text{ V}$ rail) | **$0.18\text{ mV}$** | PASS |
| **Magic DRC** | Magic | **0 errors** | **0 errors** | PASS |
| **KLayout DRC** | KLayout | **0 errors** (`sky130A_mr.drc`) | **0 errors** (`sky130A_mr.drc`) | PASS |
| **Netgen LVS** | Netgen | **Circuits match uniquely (0 errors)** | **Circuits match uniquely (0 errors)** | PASS |
| **GDSII Streamout** | OpenLane | `outputs/pnr/gds/*.gds` (11.6 MB) | `outputs/pnr/baseline/gds/*.gds` | PASS |

---

## 5. Circuit-Level Characterization (NGSpice)

- **Primitive Tested:** `sky130_fd_sc_hd__and2_1` unipolar binary multiplier cell.
- **PDK Models:** SKY130A BSIM4 analog device models (`sky130.lib.spice tt`).
- **Results:**
  - Full truth-table logical transitions verified across 40 ns window.
  - Low-to-High Propagation Delay ($t_{pd, \text{LH}}$): **$129.0\text{ ps}$** ($C_{load} = 10\text{ fF}$).
  - Output Rise Time ($t_{\text{rise}}$): **$147.1\text{ ps}$**.
  - Dynamic Energy per Multiply: **$2.71\text{ fJ}$**.
- **Artifact:** `presentation/assets/ngspice_waveform.png`.

---

## 6. Generated Presentation Assets

All assets are located in [`presentation/assets/`](file:///E:/Are_UBNN_KWS/self/presentation/assets/):
1. `architecture.png`: Microarchitecture and datapath diagram.
2. `enhanced_gds_full.png`: Full die layout rendering ($520 \times 520\ \mu\text{m}$).
3. `enhanced_gds_core.png`: Standard-cell core and clock/power grid rendering.
4. `enhanced_gds_routing_zoom.png`: Zoomed $60 \times 60\ \mu\text{m}$ detailed multi-layer routing view.
5. `baseline_vs_enhanced.png`: 4-panel PPA comparison (Cells, Area/Wirelength, Power, Timing).
6. `timing_summary.png`: Multi-corner signoff timing slack across all 9 PVT corners.
7. `power_summary.png`: Power consumption breakdown (Internal vs. Switching vs. Leakage).
8. `ngspice_waveform.png`: Analog transistor-level simulation waveforms.

---

## 7. Known Scope & Engineering Limitations

- **Microphone Front-End:** Audio acquisition (ADC and MFCC feature extraction) resides external to the digital accelerator core.
- **Double-Bit Errors:** The Extended Hamming (22,16) engine detects double-bit faults and asserts an interrupt flag; automatic correction is mathematically limited to single-bit faults.
- **Power Numbers:** Reported power metrics represent post-route static and dynamic vectorless estimates generated by the OpenROAD power engine at $10\text{ MHz}$, $1.8\text{ V}$, $25^\circ\text{C}$; they do not represent physically measured silicon power.
