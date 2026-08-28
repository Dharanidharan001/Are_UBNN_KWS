# Baseline vs. Enhanced Physical Design PPA Comparison

**Technology:** SkyWater 130 nm (`sky130_fd_sc_hd`)  
**Target Clock:** 10.0 MHz ($T_{clk} = 100.0\text{ ns}$)  
**Die Dimensions:** $520.00 \times 520.00\ \mu\text{m}$ (Die Area: $270,400\ \mu\text{m}^2$)  
**Baseline Run ID:** `RUN_2026-08-28_16-11-55` (`ENABLE_ENHANCED=0`)  
**Enhanced Run ID:** `RUN_2026-08-28_15-58-06` (`ENABLE_ENHANCED=1`)  

---

## 1. Comprehensive PPA Comparison Table

| Metric Category | Metric Name | Baseline Design | Enhanced Design | Delta ($\Delta$) | Delta (%) | Interpretation |
|---|---|---|---|---|---|---|
| **Cell Count** | Sequential Cells (DFFs) | 90 | 442 | +352 | +391.1% | Added 22-bit weight registers & enable latches |
| | Combinational Logic Cells | 1,515 | 2,548 | +1,033 | +68.2% | Extended Hamming encoder/decoder + activity logic |
| | Timing Repair Buffers | 534 | 712 | +178 | +33.3% | Buffer insertion for CTS & hold margin |
| | Clock Buffers / Inverters | 15 | 140 | +125 | +833.3% | Expanded clock network for 16-PE enable domain |
| | Antenna Diodes | 19 | 49 | +30 | +157.9% | Antenna protection on long cross-core routes |
| | **Total Standard Cells** | **1,624** | **3,034** | **+1,410** | **+86.8%** | Total synthesized standard cells |
| | **Total Placed Instances** | **5,799** | **7,542** | **+1,743** | **+30.1%** | Includes taps, buffers, and diodes |
| **Area & Utilization** | Standard Cell Area ($\mu\text{m}^2$) | 20,274.40 | 42,928.70 | +22,654.30 | +111.7% | Logic and storage silicon overhead |
| | Core Utilization (%) | 8.01% | 16.95% | +8.94% | +111.6% | Fits comfortably within 520×520 µm die |
| **Routing** | Routed Wirelength ($\mu\text{m}$) | 82,204 | 162,771 | +80,567 | +98.0% | Long bus distribution across 16 PEs |
| | Routing Congestion / Overflow | 0 | 0 | 0 | 0.0% | Clean global and detailed routing |
| **Timing** | Setup Worst Slack (Nominal, ns) | +57.84 | +55.49 | -2.35 | -4.1% | 2.35 ns extra delay from SECDED decoder |
| | Setup Worst Slack (Slow SS, ns) | +56.03 | +51.10 | -4.93 | -8.8% | Timing closure achieved with >51 ns margin |
| | Hold Worst Slack (Fast FF, ns) | +0.120 | +0.062 | -0.058 | -48.3% | Zero hold violations across all corners |
| | Clock Network Skew (ns) | 0.253 | 0.450 | +0.197 | +77.9% | Controlled skew across larger register count |
| | Derived Max Frequency ($F_{max}$) | 23.82 MHz | 22.38 MHz | -1.44 MHz | -6.0% | $F_{max}$ reduced by only 6.0% |
| **Power (10 MHz)** | Internal Cell Power (mW) | 0.3682 | 0.8450 | +0.4768 | +129.5% | Additional registers and parity XOR trees |
| | Switching Power (mW) | 0.4186 | 0.7281 | +0.3095 | +73.9% | Interconnect charging across longer routes |
| | Static Leakage Power ($\mu\text{W}$) | 0.0306 | 0.0601 | +0.0295 | +96.4% | Negligible leakage in 130 nm process |
| | **Total Estimated Power (mW)** | **0.7868** | **1.5732** | **+0.7864** | **+99.9%** | Total dynamic + static signoff power |
| **Physical Signoff** | Magic DRC Errors | 0 | 0 | 0 | 0.0% | Clean physical mask rules |
| | KLayout DRC Errors | 0 | 0 | 0 | 0.0% | Clean physical mask rules |
| | Netgen LVS Errors | 0 | 0 | 0 | 0.0% | Layout matches schematic netlist |

---

## 2. Engineering Trade-Off & Reliability Analysis

### Why the Overhead is Justified:
1. **Radiation and Soft-Error Reliability:**  
   The baseline architecture provides zero protection against single-event upsets (SEUs) or SRAM bit-flips. A single corrupt bit in weight memory produces undetected classification errors in always-on keyword detection. The Enhanced design's Extended Hamming SECDED (22,16) engine guarantees **100% correction of all single-bit errors** and **100% detection of double-bit faults** in real-time during inference.
2. **Sparsity-Aware Energy Suppression:**  
   While baseline power is lower under 100% dense random activity due to fewer cells, the Enhanced architecture's per-PE activation detector suppresses register clocking and popcount evaluation on sparse audio frames (common in speech silence/background noise), cutting PE dynamic toggling when speech features are inactive.
3. **Silicon Feasibility:**  
   Even with the SECDED and clock-enable additions, the total active silicon area is only $0.043\text{ mm}^2$ (occupying $<17\%$ of a standard $520 \times 520\ \mu\text{m}$ edge padframe). Both designs achieve timing closure at 10 MHz with $>50\text{ ns}$ setup margin and pass complete DRC and LVS signoff.
