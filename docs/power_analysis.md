# Quantitative Power & IR-Drop Analysis

**Design:** `are_ubnn_kws_enhanced_wrapper`  
**Technology:** SKY130 (`sky130_fd_sc_hd`)  
**Operating Conditions:** 1.8V, 25°C, 10.0 MHz clock (`nom_tt_025C_1v80`)  
**Tool Source:** OpenROAD Signoff Power & PSM Engines (`outputs/pnr/metrics.json`)  

---

## 1. Power Consumption Breakdown

| Power Component | Value | Percentage | Description |
|---|---|---|---|
| **Internal Power** | **0.8450 mW** | 53.71% | Charging/discharging internal cell capacitances & short-circuit current |
| **Switching Power** | **0.7281 mW** | 46.28% | Charging/discharging interconnect capacitances & pin loads |
| **Leakage Power** | **60.05 nW** | 0.0038% | Subthreshold and gate leakage at 25°C |
| **Total Dynamic + Static Power** | **1.5732 mW** | **100.0%** | Full chip power at 10 MHz nominal operation |

---

## 2. Power Distribution Network (PDN) & IR-Drop

| Metric | Measured Value | Spec / Rail | Status |
|---|---|---|---|
| Nominal Supply Voltage ($V_{PWR}$) | 1.8000 V | 1.80 V Rail | PASS |
| Worst-Case Voltage on $V_{PWR}$ | 1.7997 V | $> 1.70$ V | PASS |
| Worst-Case IR Drop on $V_{PWR}$ | **0.2996 mV** ($< 0.02\%$) | $< 90$ mV (5%) | **EXCELLENT** |
| Worst-Case Ground Bounce on $V_{GND}$ | **0.3476 mV** | $< 90$ mV (5%) | **EXCELLENT** |
| Power Grid Violations | **0** | 0 | **CLEAN** |

**Conclusion:** The generated PDN grid delivers power across the 520×520 µm die with sub-millivolt IR drop (<0.02% of supply), guaranteeing signal integrity and stable supply rails during peak neural network activations.