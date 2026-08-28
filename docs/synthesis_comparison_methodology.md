# Synthesis Comparison Methodology

This document outlines how the generic synthesis area comparison between the Baseline and Enhanced architectures was performed.

### 1. Exact Top Module
Both synthesis runs use the exact same top-level wrapper module: `are_ubnn_kws_top`.

### 2. Exact Parameter Values
The architectures are toggled via the `ENABLE_ENHANCED` SystemVerilog parameter during elaboration:
- **Baseline Configuration:** `chparam -set ENABLE_ENHANCED 0 are_ubnn_kws_top`
- **Enhanced Configuration:** `chparam -set ENABLE_ENHANCED 1 are_ubnn_kws_top`

### 3. Exact Yosys Commands
Both configurations are synthesized using the exact same optimization passes:
```tcl
synth -top are_ubnn_kws_top -flatten
opt -full
stat
```

### 4. RTL Files Included
Both runs read the exact same set of SystemVerilog source files using `read_verilog -sv`. The synthesis tool dynamically discards uninstantiated modules.

### 5. Why the Comparison is Fair
The `are_ubnn_kws_top.sv` module utilizes a standard SystemVerilog `generate if` block. When `ENABLE_ENHANCED == 0`, the synthesis tool structurally removes the `protected_weight_memory` and `activation_detector` modules, replacing them with direct wire assignments and hardcoding the `pe_active` signal to all 1s. This ensures that the baseline synthesis result contains only the core datapath, without any overhead from the reliability or sparsity features.

### 6. Functionality Present in Baseline
- `pe_array` (16 unipolar PEs)
- `accumulator`
- `threshold_unit`
- Direct flat weight and activation routing

### 7. Additional Functionality Present in Enhanced
- `protected_weight_memory` (incorporating `secded_encoder` and `secded_decoder`)
- `activation_detector` (generating dynamic clock-enables for sparsity)

### 8. Important Limitations
This is a generic-cell area comparison derived from Yosys generic mapping. It demonstrates the relative logical complexity (measured in logic gates and flip-flops) added by the enhanced features. It is not a physical standard-cell area comparison (e.g., SKY130), nor does it account for physical routing overhead.