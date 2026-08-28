# ARe-UBNN-KWS Static Timing Analysis (STA) & Timing Closure Report

## 1. Timing Specification & SDC Constraints

Static Timing Analysis for **ARe-UBNN-KWS** was performed using the **OpenROAD / OpenSTA** timing engine on the gate-level netlist mapped to SkyWater 130nm standard cells (`sky130_fd_sc_hd__tt_025C_1v80.lib`).

### Constraints Definition (`constraints/are_ubnn_kws.sdc`)
- **Target Clock Period:** $10.000\text{ ns}$ ($F_{\text{clk}} = 100.0\text{ MHz}$)
- **Clock Uncertainty:** $0.250\text{ ns}$ (allocated for clock jitter, PLL drift, and on-chip variation)
- **Clock Transition / Slew:** $0.150\text{ ns}$
- **Input Delay Budget:** $2.000\text{ ns}$ ($20\%$ of clock cycle)
- **Output Delay Budget:** $2.000\text{ ns}$ ($20\%$ of clock cycle)
- **Output Pin Load:** $0.050\text{ pF}$ ($50\text{ fF}$) standard capacitive load
- **Driving Cell:** `sky130_fd_sc_hd__inv_2` on all input ports

---

## 2. Timing Closure Summary

| Metric | Target Constraint | Tool-Measured Value | Margin / Status |
| :--- | :---: | :---: | :---: |
| **Operating Frequency** | $100.0\text{ MHz}$ | **$100.0\text{ MHz}$** | **ACHIEVED** |
| **Target Clock Period ($T_{\text{clk}}$)** | $10.000\text{ ns}$ | **$10.000\text{ ns}$** | Configurable |
| **Worst Setup Slack ($WNS_{\text{max}}$)** | $\ge 0.000\text{ ns}$ | **$+2.5103\text{ ns}$** | **MET (Positive Margin)** |
| **Worst Hold Slack ($WNS_{\text{min}}$)** | $\ge 0.000\text{ ns}$ | **$+0.2702\text{ ns}$** | **MET (Positive Margin)** |
| **Total Negative Slack (TNS)** | $0.000\text{ ns}$ | **$0.000\text{ ns}$** | **ZERO NEGATIVE SLACK** |
| **Fmax (Estimated Ceiling)** | $100.0\text{ MHz}$ | **$133.5\text{ MHz}$** | $+33.5\%$ headroom |

---

## 3. Critical Path Breakdown (Setup / Max Path)

The worst-case setup path exercises the complete functional datapath of Innovation A (Inline SECDED Decoding) combined with the UBNN dot-product and Wallace tree adder:

```
Startpoint: u_weight_subsystem/gen_mem_regs[4].u_reg/_184_ (sky130_fd_sc_hd__dfrtp_1)
Endpoint:   u_pe_array/gen_pe_instances[4].u_pe/_28_/D    (sky130_fd_sc_hd__dfrtp_1)
Path Group: clk
Path Type:  max (Setup)
Target Period: 10.0000 ns
```

### Stage-by-Stage Propagation Delay:
```
Pin / Stage Description                                          Cell Type               Incr (ns)  Arrival (ns)
----------------------------------------------------------------------------------------------------------------
u_weight_subsystem/gen_mem_regs[4].u_reg/_184_/CLK (rise edge)   clock clk (ideal)          0.0000        0.0000
u_weight_subsystem/gen_mem_regs[4].u_reg/_184_/Q                 sky130_fd_sc_hd__dfrtp_1   0.4578        0.4578
u_weight_subsystem/gen_read_decoders[4].u_read_decoder/_184_/X   sky130_fd_sc_hd__xor3_1    0.3717        2.0109
u_weight_subsystem/gen_read_decoders[4].u_read_decoder/_185_/Y   sky130_fd_sc_hd__clkinv_1  0.2742        2.2851
u_weight_subsystem/gen_read_decoders[4].u_read_decoder/_187_/Y   sky130_fd_sc_hd__nor3_1    0.3695        2.6546
u_weight_subsystem/gen_read_decoders[4].u_read_decoder/_221_/Y   sky130_fd_sc_hd__xnor2_1   0.1768        2.8314
u_weight_subsystem/gen_read_decoders[4].u_read_decoder/_225_/Y   sky130_fd_sc_hd__nand4_1   0.1008        2.9322
u_weight_subsystem/gen_read_decoders[4].u_read_decoder/_235_/Y   sky130_fd_sc_hd__a222oi_1  1.1458        4.0781
u_weight_subsystem/gen_read_decoders[4].u_read_decoder/_262_/Y   sky130_fd_sc_hd__o31ai_1   0.2160        4.2941
u_pe_array/gen_pe_instances[4].u_pe/_12_/X (Bitwise AND)         sky130_fd_sc_hd__and2_0    0.2075        4.5016
u_pe_array/gen_pe_instances[4].u_pe/u_popcount/_37_/X (Stage 1)  sky130_fd_sc_hd__xor3_1    0.3937        4.8952
u_pe_array/gen_pe_instances[4].u_pe/u_popcount/_39_/X (Stage 2)  sky130_fd_sc_hd__xor3_1    0.3865        5.2817
u_pe_array/gen_pe_instances[4].u_pe/u_popcount/_46_/X (Stage 3)  sky130_fd_sc_hd__maj3_1    0.3934        5.6751
u_pe_array/gen_pe_instances[4].u_pe/u_popcount/_56_/X (Stage 4)  sky130_fd_sc_hd__xor3_1    0.3880        6.0631
u_pe_array/gen_pe_instances[4].u_pe/u_popcount/_58_/Y            sky130_fd_sc_hd__xnor2_1   0.1384        6.2016
u_pe_array/gen_pe_instances[4].u_pe/u_popcount/_59_/X            sky130_fd_sc_hd__or3_1     0.3287        6.5302
u_pe_array/gen_pe_instances[4].u_pe/u_popcount/_67_/X            sky130_fd_sc_hd__a21o_1    0.2134        6.7437
u_pe_array/gen_pe_instances[4].u_pe/u_popcount/_69_/X            sky130_fd_sc_hd__and2_0    0.1264        6.8700
u_pe_array/gen_pe_instances[4].u_pe/_23_/X (Enable Mux)          sky130_fd_sc_hd__mux2_1    0.2766        7.1466
u_pe_array/gen_pe_instances[4].u_pe/_28_/D (Data Input)          sky130_fd_sc_hd__dfrtp_1   0.0000        7.1466
----------------------------------------------------------------------------------------------------------------
Data Arrival Time:                                                                                        7.1466 ns

Clock Period:                                                                                            10.0000 ns
Clock Uncertainty:                                                                                       -0.2500 ns
Library Setup Time:                                                                                      -0.0930 ns
----------------------------------------------------------------------------------------------------------------
Data Required Time:                                                                                       9.6570 ns
----------------------------------------------------------------------------------------------------------------
Slack (MET):                                                                                             +2.5103 ns
```

### Architectural Verification of Inline SECDED Feasibility
The critical path proves that:
1. Reading from weight memory takes $\sim 0.46\text{ ns}$.
2. Combinational SECDED decoding and single-bit correction takes $\sim 3.83\text{ ns}$.
3. PE dot-product AND + Wallace adder tree popcount takes $\sim 2.85\text{ ns}$.
4. Total datapath delay ($7.15\text{ ns}$) comfortably completes inside the $9.66\text{ ns}$ required budget, leaving **$2.51\text{ ns}$ of positive slack**.

This confirms that **zero additional pipeline registers** are needed for the inline SECDED enhancement.

---

## 4. Minimum Path Breakdown (Hold Path)

```
Startpoint: u_accumulator/_487_ (sky130_fd_sc_hd__dfrtp_1)
Endpoint:   u_accumulator/_487_ (sky130_fd_sc_hd__dfrtp_1)
Path Group: clk
Path Type:  min (Hold)

Data Arrival Time:  0.4975 ns
Data Required Time: 0.2273 ns
-------------------------------------------------------------
Slack (MET):        +0.2702 ns
```

Zero hold buffer violations exist. Timing closure is complete.
