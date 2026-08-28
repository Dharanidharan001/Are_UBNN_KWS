# ARe-UBNN-KWS
## Fault-Tolerant and Sparsity-Aware Unipolar Binary Neural Network Accelerator for Edge Keyword Spotting

---

## Problem

Always-on edge AI keyword spotting requires an accelerator that is:
- **Ultra-low power** — inference must run continuously from a small battery or energy harvester.
- **Reliable** — memory bit-flips caused by radiation or process variation must not corrupt weights silently.
- **Efficient** — sparse activation patterns (many zero features) waste switching activity in naive designs.

---

## Solution — ARe-UBNN-KWS

An integrated ASIC-oriented accelerator combining three complementary mechanisms:

| Mechanism | Purpose |
|---|---|
| **Unipolar Binary Neural Network (UBNN)** | Replace MAC with AND + POPCOUNT |
| **Inline SECDED Weight Protection** | Correct single-bit; detect double-bit weight errors |
| **Per-PE Activation Sparsity Control** | Suppress unnecessary register updates on zero activations |

---

## Architecture Overview

```
     INPUT ACTIVATIONS [16 x 16-bit vectors]
                    |
          +---------v-----------+
          | Activation Detector |  <- per-PE OR-reduction
          +---------+-----------+
                    | pe_active[15:0]
                    v
       +----------------------------+
       |   16 Unipolar BNN PEs      |
       |  (AND + POPCOUNT per PE)   |
       +------------+---------------+
                    | pe_result[15:0]
                    v
           +-----------------+
           |   Accumulator   |  <- baseline module, unmodified
           +--------+--------+
                    |
           +--------v--------+
           | Threshold Unit  |
           +--------+--------+
                    |
              keyword_detected

Weight Path:
  raw_weight -> SECDED Encoder -> Protected Memory
  Protected Memory -> SECDED Decoder -> corrected_weight -> PEs
```

---

## Key Features

- 16 PEs, each computing AND + POPCOUNT on 16-bit activation/weight pairs
- SECDED Hamming(22,16): single-bit correction, double-bit detection per weight codeword
- Activation zero-detector: pe_active[i] = |activation[i]
- Safe clock-enable architecture with documented ASIC ICG mapping strategy
- Baseline vs Enhanced comparison framework
- Non-UVM custom transaction-based verification (generator, driver, monitor, scoreboard)
- 10 test scenarios including fault injection, sparsity, and mixed cases
- VCD waveform output for GTKWave

---

## Technologies

| Tool | Purpose |
|---|---|
| SystemVerilog (-g2012) | RTL and testbench |
| Icarus Verilog | Simulation |
| GTKWave | Waveform viewing |
| Yosys | Logic synthesis |
| OpenROAD / OpenLane | Physical implementation (if installed) |
| SKY130 PDK | Open-source 130 nm target |
| KLayout | Layout inspection |

---

## Repository Structure

```
README.md
docs/         <- architecture.md, verification_plan.md, implementation_plan.md, final_report.md
src/
  top/        <- are_ubnn_kws_top.sv
  compute/    <- popcount.sv, unipolar_pe.sv, pe_array.sv
  baseline/   <- accumulator.sv, threshold_unit.sv
  ecc/        <- secded_encoder.sv, secded_decoder.sv
  memory/     <- protected_weight_memory.sv
  power/      <- activation_detector.sv, icg.sv
tb/
  interfaces/ tb/transactions/ tb/generator/ tb/driver/
  tb/monitor/ tb/scoreboard/ tb/environment/ tb/tests/ tb/top/
constraints/  <- top.sdc
scripts/      <- sim.sh, synth.sh, run_all.sh, clean.sh
logs/         <- simulation/ synthesis/ pnr/
outputs/      <- simulation/ synthesis/ pnr/ reports/
presentation/
```

---

## How to Run Simulation

```bash
cd scripts && bash sim.sh
```
Logs: logs/simulation/sim.log   VCD: outputs/simulation/*.vcd

## How to View Waveforms

```bash
gtkwave outputs/simulation/enhanced_waveform.vcd
```

## How to Run Synthesis

```bash
cd scripts && bash synth.sh
```

## Results

| Metric | Baseline | Enhanced (Measured SKY130 Signoff) |
|---|---|---|
| Functional Simulation | 42/42 PASS | **42/42 PASS** |
| Generic Synthesis Cells | 1,801 cells | **3,078 cells** |
| SKY130 Standard Cells | — | **3,034 mapped stdcells** (7,542 total placed) |
| Die Area | — | **520 × 520 µm (0.27 mm²)** |
| Core Utilization | — | **16.95%** |
| Clock Target | — | **10.0 MHz (100.0 ns period)** |
| Max Frequency ($F_{max}$) | — | **22.38 MHz (Nominal) / 20.45 MHz (Worst SS)** |
| Setup Worst Slack | — | **+51.10 ns (Worst-case Slow corner)** |
| Hold Worst Slack | — | **+0.062 ns (Worst-case Fast corner)** |
| Total Power (10 MHz, 1.8V) | — | **1.573 mW** (0.845 mW internal, 0.728 mW switching, 60 nW leakage) |
| Worst-Case IR Drop | — | **0.30 mV (< 0.02% of 1.8V rail)** |
| Magic DRC Errors | — | **0 errors (PASS)** |
| KLayout DRC Errors | — | **0 errors (PASS)** |
| Netgen LVS | — | **Circuits match uniquely (PASS)** |
| SECDED Protection | None | **All 22 codeword bits corrected; double-bit detected** |
| Final GDSII Artifact | — | `outputs/pnr/gds/are_ubnn_kws_enhanced_wrapper.gds` (11.6 MB) |

---

## Limitations

- Accelerator receives pre-processed binary activations; microphone/MFCC front-end is outside the ASIC core boundary.
- RTL uses synchronous clock-enable (CE) architecture for glitch-free activity control.
- Extended Hamming (22,16) SECDED corrects single-bit errors and asserts an interrupt on double-bit errors (double-bit errors cannot be corrected).

## License

MIT

## Project Verification Status
- **RTL & Non-UVM Testbench:** VERIFIED (42/42 PASS)
- **Generic Synthesis:** VERIFIED (Yosys)
- **SKY130 Physical Implementation:** **VERIFIED** (OpenLane 2 / OpenROAD)
- **Signoff STA / Timing Closure:** **VERIFIED** (0 setup / 0 hold violations across 9 corners)
- **Quantitative Power & IR Drop:** **VERIFIED** (1.573 mW @ 10 MHz, 0.3 mV IR drop)
- **DRC & LVS Signoff:** **VERIFIED** (0 DRC / 0 LVS errors)
- **GDSII / Physical Layout:** **VERIFIED** (`outputs/pnr/gds/are_ubnn_kws_enhanced_wrapper.gds`)
