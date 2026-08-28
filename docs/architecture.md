# ARe-UBNN-KWS Microarchitecture Specification

## 1. Introduction to Unipolar Binary Neural Networks (UBNNs)

Traditional artificial neural networks require floating-point (FP32) or integer (INT8) multiply-accumulate (MAC) units. In ultra-low-power edge keyword spotting applications, full MAC operations impose prohibitive area and power overheads.

### Unipolar vs Bipolar BNN Formulation
Standard Bipolar BNNs map binary values to $\{-1, +1\}$, requiring XNOR gates and signed popcount accumulators. In contrast, **Unipolar BNNs (UBNNs)** map signals directly to $\{0, 1\}$:
- Activations $A \in \{0, 1\}^{16}$
- Weights $W \in \{0, 1\}^{16}$

The inner product of two unipolar binary vectors simplifies to:
$$\text{DotProduct}(A, W) = \sum_{k=0}^{15} (A_k \land W_k) = \text{POPCOUNT}(A \land W)$$

This mathematical formulation replaces power-hungry digital multipliers with 16 parallel 1-bit `AND` gates, followed by a combinatorial `POPCOUNT` adder tree.

---

## 2. Block-by-Block Microarchitecture

```
+---------------------------------------------------------------------------------------------------+
|                                      are_ubnn_kws_top                                             |
|                                                                                                   |
|   +-----------------------+     +-------------------------------+     +-----------------------+   |
|   | Protected Weight Mem  |     | Fine-Grained Activity Detector|     |    5-State FSM        |   |
|   | 16 x 22-bit Registers |     |  pe_enable[i] = |act[i]       |     |    Controller         |   |
|   | Inline SECDED Decoder |     +-------------------------------+     +-----------------------+   |
|   +-----------------------+                    |                                                  |
|              | Corrected Weights [255:0]       v pe_enable[15:0]                                  |
|              |               +-----------------------------------+                                |
|              |               | 16 x ASIC ICG Standard Cells      |                                |
|              |               | sky130_fd_sc_hd__dlclkp_1         |                                |
|              |               +-----------------------------------+                                |
|              |                                 |                                                  |
|              v                                 v gated_clks[15:0]                                 |
|   +-------------------------------------------------------------+                                 |
|   |                   16-PE Processing Element Array            |                                 |
|   | PE0: AND + Popcount16 -> 5-bit reg                          |                                 |
|   | PE1: AND + Popcount16 -> 5-bit reg                          |                                 |
|   | ...                                                         |                                 |
|   | PE15: AND + Popcount16 -> 5-bit reg                         |                                 |
|   +-------------------------------------------------------------+                                 |
|                                  |                                                                |
|                                  v effective_pe_results [79:0]                                    |
|   +-------------------------------------------------------------+                                 |
|   |       Baseline 4-Stage Balanced Accumulator Subsystem       |                                 |
|   |  8 x 6-bit -> 4 x 7-bit -> 2 x 8-bit -> 1 x 9-bit Adder     |                                 |
|   |  Saturating 8-bit Register (0..255)                         |                                 |
|   +-------------------------------------------------------------+                                 |
|                                  | accumulator_val [7:0]                                          |
|                                  v                                                                |
|   +-------------------------------------------------------------+                                 |
|   | Integer Threshold Unit (accumulator_val >= threshold_val)   |                                 |
|   +-------------------------------------------------------------+                                 |
|                                  |                                                                |
|                                  v kws_output                                                     |
+---------------------------------------------------------------------------------------------------+
```

---

## 3. Popcount-16 Wallace Adder Tree (`popcount16.sv`)

The 16-bit population counter computes the number of active high bits using a 4-stage balanced Wallace adder tree with zero timing loops:

```
Inputs: in_data[15:0] (16 bits)

Stage 1: 5 Full Adders (3:2) + 1 Half Adder (2:2)
  Inputs: 15 bits -> 5 x 2-bit sums; 1 bit -> pass-through
Stage 2: Compression into 3-bit intermediate sums
Stage 3: 4-bit intermediate sum
Stage 4: Final 5-bit summation (Range: 0 to 16)
```

By avoiding linear ripple-carry chains, maximum combinational delay is kept below $1.8\text{ ns}$ in SKY130 HD standard cells.

---

## 4. Processing Element Array (`pe_array16.sv` & `unipolar_pe.sv`)

The accelerator contains 16 parallel processing elements ($PE_0 \dots PE_{15}$). Each PE computes:
1. Combinational bitwise AND: `and_vector = activation & weight` (16 bits)
2. Fast popcount: `popcount16(and_vector)` (produces 5-bit result $0 \dots 16$)
3. Clock-gated output register: latches partial sum when enabled by its specific ICG gated clock.

---

## 5. Mandatory Enhancement A: Inline SECDED Hamming (22, 16) Codec

### Motivation & Fault Model
In edge IoT silicon deployed in unshielded environments, terrestrial cosmic rays (neutrons, alpha particles) cause single-event upsets (SEUs) in SRAM arrays. In a BNN, a bit-flip in a weight vector flips dot products, leading to misclassification.

### Codeword Bit Mapping
To protect 16 bits of data ($d_0 \dots d_{15}$), 5 Hamming parity bits ($p_1, p_2, p_4, p_8, p_{16}$) plus 1 overall parity bit ($p_{overall}$) are added, resulting in a 22-bit codeword:

```
Codeword Index:   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21
Hamming Position: 1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22
Content:          p1  p2  d0  p4  d1  d2  d3  p8  d4  d5  d6  d7  d8  d9 d10 p16 d11 d12 d13 d14 d15 pov
```

### Parity Generation Equations
$$p_1 = d_0 \oplus d_1 \oplus d_3 \oplus d_4 \oplus d_6 \oplus d_8 \oplus d_{10} \oplus d_{11} \oplus d_{13} \oplus d_{15}$$
$$p_2 = d_0 \oplus d_2 \oplus d_3 \oplus d_5 \oplus d_6 \oplus d_9 \oplus d_{10} \oplus d_{12} \oplus d_{13}$$
$$p_4 = d_1 \oplus d_2 \oplus d_3 \oplus d_7 \oplus d_8 \oplus d_9 \oplus d_{10} \oplus d_{14} \oplus d_{15}$$
$$p_8 = d_4 \oplus d_5 \oplus d_6 \oplus d_7 \oplus d_8 \oplus d_9 \oplus d_{10}$$
$$p_{16} = d_{11} \oplus d_{12} \oplus d_{13} \oplus d_{14} \oplus d_{15}$$
$$p_{overall} = \bigoplus_{k=0}^{20} \text{cw}[k]$$

### Error Syndrome & Hardware Decoding Truth Table
On reading from memory, the 5-bit syndrome $S = \{s_{16}, s_8, s_4, s_2, s_1\}$ and overall parity mismatch $P$ are computed combinatorially:

| Syndrome ($S$) | Overall Parity ($P$) | Fault Classification | Hardware Action |
| :---: | :---: | :--- | :--- |
| $= 0$ | $= 0$ | **Clean Codeword** | `data_out = cw_data`, `sec = 0`, `ded = 0` |
| $\neq 0$ | $= 1$ | **Single-Bit Error** | Flip corrupted bit at position $S$; `sec = 1`, `ded = 0` |
| $\neq 0$ | $= 0$ | **Double-Bit Error** | Cannot correct; flag `ded = 1`, `sec = 0` |
| $= 0$ | $= 1$ | **Overall Parity Bit Error** | Data is intact; `sec = 1`, `ded = 0` |

### Zero Pipeline Stage Inline Rationale
The entire SECDED decoder logic consists of XOR trees and a single stage of correction multiplexers with a total combinational delay of under $2.2\text{ ns}$. Because our clock period is $10.0\text{ ns}$ (100 MHz), the inline decoder sits directly in the read-data path between the weight registers and the PE array with **zero additional pipeline stages**, keeping the single-cycle execution of the core completely intact.

---

## 6. Mandatory Enhancement B: Dynamic Sparsity-Aware Clock Gating

### Sparsity in Speech Recognition
Keyword spotting models process spectral audio features (MFCCs or filterbanks). During silent intervals between words, energy in acoustic frames is zero or negligible.

### Activity Detection Logic
For each PE $i \in [0..15]$:
$$\text{pe\_enable}[i] = \bigvee_{k=0}^{15} \text{activation}[i][k]$$

If $\text{activation}[i] = 16\text{'h0000}$, $\text{pe\_enable}[i] = 0$.

### Glitch-Free ASIC Integrated Clock Gating (ICG)
To eliminate clock glitches when the enable toggles, the accelerator instantiates the foundry-certified standard cell `sky130_fd_sc_hd__dlclkp_1`:
- Transparent active-low latch locks the enable on the negative clock phase.
- AND gate gates the master clock during the high phase.
- Dedicated `test_en` pin provides scan-chain DFT bypass.

```
       clk --------+
                   |
                   v
  enable ----+-->[ D-Latch ]----+
             |   (Active Low)   |
  test_en ---+                  v
                            +-------+
       clk ---------------->|  AND  |------> gated_pe_clock[i]
                            +-------+
```

When a PE is gated:
1. Dynamic switching in the clock tree and flip-flops of that PE is reduced to zero.
2. The partial sum output feeding the baseline accumulator is masked to `5'd0`.
3. The baseline accumulator sums only active PEs, producing the mathematically identical classification.

---

## 7. Baseline Accumulator Subsystem (`accumulator.sv`)

To respect the hackathon rule that the baseline accumulator must remain architecturally unmodified, the accumulator is implemented as an independent 4-stage balanced adder tree summing 16 x 5-bit partial results:
- Stage 1: 8 x 6-bit adders
- Stage 2: 4 x 7-bit adders
- Stage 3: 2 x 8-bit adders
- Stage 4: 1 x 9-bit adder
- Output Register: 8-bit saturating register with synchronous clear and enable. If the frame sum exceeds 255, it saturates at `8'hFF`.

---

## 8. Finite State Machine Controller (`controller.sv`)

The accelerator is managed by a deterministic 5-state Moore FSM:
1. **`S_IDLE` (000):** System is ready; awaits `start_inference` or `load_weight`.
2. **`S_LOAD` (001):** Writes weight data into protected weight memory with inline SECDED encoding.
3. **`S_COMPUTE` (010):** Evaluates sparsity detector, enables active ICGs, computes dot products, latches PE partial sums.
4. **`S_ACCUM` (011):** Accumulator sums 16 partial results and latches frame accumulator register.
5. **`S_DONE` (100):** Asserts `done` strobe, evaluates threshold decision, reports telemetry.
