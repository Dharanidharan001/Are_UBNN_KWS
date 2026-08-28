# ARe-UBNN-KWS Architecture

## 1. System Boundary

The ASIC boundary is the BNN inference accelerator.
Inputs arrive as pre-processed binary activation vectors (e.g., binarized MFCC features).
Microphone acquisition and feature extraction are outside the ASIC scope.

## 2. Baseline Architecture

```
Activations[i]   Weights[i]
     |               |
     +------AND------+
           |
        POPCOUNT
           |
       pe_result[i]   (5-bit count, 0..16)
           |
       Accumulator    (sums all 16 PE results)
           |
       accumulated_sum
           |
       Threshold Unit (compare against threshold)
           |
       keyword_detected (1-bit)
```

### Baseline Modules

| Module | File | Type |
|---|---|---|
| popcount | src/compute/popcount.sv | Combinational |
| unipolar_pe | src/compute/unipolar_pe.sv | Combinational |
| pe_array | src/compute/pe_array.sv | Mixed (sequential output register) |
| accumulator | src/baseline/accumulator.sv | Sequential |
| threshold_unit | src/baseline/threshold_unit.sv | Combinational |
| are_ubnn_kws_top (baseline) | src/top/are_ubnn_kws_top.sv | Top-level |

### Parameters

| Parameter | Default | Description |
|---|---|---|
| NUM_PES | 16 | Number of Processing Elements |
| VEC_WIDTH | 16 | Bits per activation/weight vector |
| ACCUM_WIDTH | 9 | Accumulator width (ceil(log2(16*16))+1) |
| THRESHOLD_WIDTH | 9 | Threshold comparator width |

## 3. Enhanced Architecture

The enhanced architecture adds three mechanisms on top of the baseline.
The baseline accumulator module is NOT modified.

### 3.1 SECDED Weight Protection

Extended Hamming SECDED (22,16): 16 data bits + 5 Hamming parity bits + 1 overall parity bit.

Parity bit positions (1-indexed in codeword): 1, 2, 4, 8, 16
Data bits occupy positions: 3,5,6,7,9,10,11,12,13,14,15,17,18,19,20,21

Write path: raw_weight[15:0] -> secded_encoder -> codeword[21:0] -> memory
Read path:  memory -> codeword[21:0] -> secded_decoder -> corrected_weight[15:0]

SECDED distinguishes:
- No error:         syndrome==0, overall_parity matches => pass through
- Single-bit error: syndrome!=0, overall_parity mismatch => correct bit at syndrome position
- Double-bit error: syndrome!=0, overall_parity matches => detect only, assert flag

### 3.2 Activation Sparsity Detection

For each PE i:
  pe_active[i] = |activation[i]   (bitwise OR reduction)

If pe_active[i]==0: the activation vector is all zeros.
The PE result will be zero regardless of weights.
The sequential accumulator does not need this PE's contribution.

Architecture: activation_detector.sv computes all 16 pe_active signals combinationally.

### 3.3 Safe Clock-Enable Architecture

IMPORTANT DISTINCTION:

RTL clock enable (what we implement):
  Always use the system clock edge.
  Use an enable signal to gate the register update:
    always_ff @(posedge clk) if (pe_active[i]) pe_result_reg[i] <= new_result;

Physical ASIC ICG (what this maps to):
  A latch-based integrated clock-gating cell (e.g., sky130_fd_sc_hd__dlclkp_1)
  holds the clock-enable in a latch on the falling edge of clk,
  then ANDs with clk to produce a glitch-free gated clock.
  This eliminates switching activity inside the PE when it is inactive.

The RTL in icg.sv provides a synthesizable clock-enable abstraction.
The synthesis tool (Yosys + OpenLane) maps this to ICG cells in the target PDK.

## 4. Enhanced Module Hierarchy

```
are_ubnn_kws_top
  |- protected_weight_memory
  |    |- secded_encoder (write path)
  |    |- secded_decoder (read path)  [also exposes single/double error flags]
  |
  |- activation_detector   [16 OR-reductions -> pe_active[15:0]]
  |
  |- pe_array (enhanced)
  |    |- unipolar_pe[0..15]
  |    |    |- popcount
  |    |- icg[0..15]         [clock-enable per PE]
  |
  |- accumulator             [BASELINE MODULE, unmodified]
  |- threshold_unit
```

## 5. Critical Timing Path

```
Weight read (memory output)
  -> SECDED decoder (combinational: XOR tree for syndrome)
  -> corrected_weight
  -> AND gate (with activation)
  -> POPCOUNT (carry-save adder tree)
  -> Existing sequential boundary (pe_result register)
```

No new pipeline stages are inserted for SECDED or clock gating.

## 6. Debug/Status Signals Exposed at Top Level

| Signal | Width | Description |
|---|---|---|
| pe_active | 16 | Per-PE activation status |
| single_error_corrected | 1 | SECDED single-bit correction occurred |
| double_error_detected | 1 | SECDED double-bit error detected |
| pe_result | 16x5 | Raw POPCOUNT result per PE |
| accumulated_sum | 9 | Accumulator output |
| keyword_detected | 1 | Final threshold comparison output |
