# Static Timing Analysis (STA) Signoff Summary

**Design:** `are_ubnn_kws_enhanced_wrapper`  
**Technology:** SKY130 (`sky130_fd_sc_hd`)  
**Target Clock Period:** 100.0 ns (10.0 MHz)  
**Clock Uncertainty:** 0.250 ns  

---

## 1. Multi-Corner Signoff Results

| Timing Corner | Setup Worst Slack (ns) | Setup Violations | Hold Worst Slack (ns) | Hold Violations | Max Slew Vio | Max Cap Vio |
|---|---|---|---|---|---|---|
| `nom_tt_025C_1v80` | **+55.31** | 0 | **+0.230** | 0 | 0 | 0 |
| `min_tt_025C_1v80` | **+55.31** | 0 | **+0.225** | 0 | 0 | 0 |
| `max_tt_025C_1v80` | **+55.31** | 0 | **+0.230** | 0 | 0 | 0 |
| `nom_ss_100C_1v60` | **+51.50** | 0 | **+0.696** | 0 | 0 | 0 |
| `min_ss_100C_1v60` | **+51.50** | 0 | **+0.696** | 0 | 17 | 1 |
| `max_ss_100C_1v60` (Slow) | **+51.10** | **0** | **+0.705** | **0** | 87 | 6 |
| `nom_ff_n40C_1v95` | **+57.17** | 0 | **+0.062** | 0 | 0 | 0 |
| `min_ff_n40C_1v95` (Fast) | **+57.17** | **0** | **+0.062** | **0** | 0 | 0 |
| `max_ff_n40C_1v95` | **+56.92** | 0 | **+0.066** | 0 | 0 | 0 |

---

## 2. Clock Tree & Frequency Capabilities

- **Clock Network Skew (Nominal):** 0.241 ns
- **Clock Tree Insertion Delay:** 0.483 ns (min) – 0.724 ns (max)
- **Clock Buffer Cells:** 89 buffers + 51 inverters (140 CTS cells total)
- **Worst-Case Setup Critical Path:** 48.90 ns (in Slow Corner `max_ss_100C_1v60`)
- **Maximum Operating Frequency ($F_{max}$):**
  $$\text{Period}_{min} = 100.0 - 51.10 = 48.90\text{ ns} \implies F_{max} \approx 20.45\text{ MHz (Worst-Case SS Corner)}$$
  $$\text{Period}_{min, \text{nom}} = 100.0 - 55.31 = 44.69\text{ ns} \implies F_{max, \text{nom}} \approx 22.38\text{ MHz (Nominal TT Corner)}$$

**Conclusion:** The design easily meets timing closure with **zero setup and zero hold violations** across all process, voltage, and temperature corners.