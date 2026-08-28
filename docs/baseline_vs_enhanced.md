# Baseline vs Enhanced Architecture Synthesis Overhead

This document provides a strictly verified comparison of the generic logic cell counts between the BASELINE and ENHANCED architectures. 

Both results were generated using Yosys generic synthesis with identical optimization passes (`opt -full` followed by `stat`).

| Metric | Baseline Architecture | Enhanced Architecture | Difference (Overhead) | Percentage Increase |
|--------|-----------------------|-----------------------|-----------------------|---------------------|
| **Total Generic Cells** | 1,801 | 3,078 | +1,277 cells | +70.9% |
| **D-Flip Flops (Registers)** | 90 | 442 | +352 registers | +391% |

### Analysis of Overhead
The enhanced configuration reports 1,277 more generic Yosys cells than the baseline configuration under the same synthesis flow, corresponding to a 70.9% increase in the reported generic cell count. This combined difference reflects the additional logic present in the enhanced architecture, which includes:
1. **SECDED Logic**: Extended Hamming SECDED (22,16)+1 parity encoder and decoder XOR trees, plus the wider 22-bit weight memory registers.
2. **Clock-Enable Architecture**: The baseline design simply sums the combinational PE outputs. The enhanced design adds explicit D-Flip-Flops with clock enables (`$_SDFFCE_PN0P_`) for the PE outputs, driven by the `activation_detector` and `icg` cells to suppress switching on zero activations.

*Note: These cell counts represent generic Yosys synthesis mapping and not physical SKY130 standard cells.*