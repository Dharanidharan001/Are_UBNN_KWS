# ARe-UBNN-KWS Verification Plan

## 1. Methodology

Non-UVM custom transaction-based verification.
No uvm_pkg, no UVM macros, no UVM base classes.
Uses: SystemVerilog classes, mailboxes, virtual interfaces.

## 2. Verification Architecture

```
          TEST
           |
      ENVIRONMENT
  +--------+--------+
  |        |        |
GENERATOR DRIVER SCOREBOARD
  |        |        ^
  |        v        |
  |    INTERFACE    |
  |        |        |
  |        v        |
  |       DUT       |
  |        |        ^
  +-----> MONITOR --+
```

## 3. Transaction Fields

| Field | Type | Description |
|---|---|---|
| activation[NUM_PES][VEC_WIDTH] | logic | Input activation vectors |
| weight[VEC_WIDTH] | logic | Raw weight for one PE |
| inject_fault | bit | Request fault injection |
| fault_bit1 | int | First bit to flip (0..21 in codeword) |
| fault_bit2 | int | Second bit to flip (-1 = none) |
| pe_select | int | Which PE to use for single-PE tests |
| expected_keyword | bit | Golden expected output |
| test_name | string | Human-readable test identifier |

## 4. Test Scenarios

| Test | Scenario | Expected |
|---|---|---|
| T1 | Normal inference, no faults | keyword_detected matches golden |
| T2 | All-zero activation on PE0 | pe_active[0]==0 |
| T3 | Non-zero activation on PE0 | pe_active[0]==1 |
| T4 | Single-bit fault in weight storage | single_error_corrected==1, result matches golden |
| T5 | Double-bit fault | double_error_detected==1 |
| T6 | Mixed sparse pattern (8 active, 8 inactive PEs) | Correct pe_active pattern |
| T7 | Single-bit fault during active inference | Correction + correct final result |
| T8 | Mixed sparse + single-bit fault | Both mechanisms verified simultaneously |
| T9 | Corner cases (all-ones, all-zeros weight/activation) | Correct boundary behavior |
| T10 | Random regression (fixed seed for reproducibility) | All pass |

## 5. Golden Model (Scoreboard)

For BNN computation:
  bitwise_and = activation & corrected_weight
  popcount = count_ones(bitwise_and)
  sum = sum of popcount across all active PEs
  keyword = (sum >= threshold)

For SECDED:
  T4: corrected_weight must equal original weight; inference result must match fault-free golden
  T5: double_error_detected must assert; no correction claimed

## 6. Scoreboard Pass/Fail Criteria

PASS: DUT output matches golden model output AND ECC flags match expected values
FAIL: Any mismatch; print test name, expected, actual, ECC status

Final report: TOTAL / PASSED / FAILED counts.

## 7. Waveform Evidence Groups

Groups for GTKWave:
- CLOCK_AND_RESET: clk, rst_n
- INPUTS: activation[*], weight_addr, weight_data
- WEIGHT_MEMORY: stored_codeword, corrected_weight
- ECC: single_error_corrected, double_error_detected
- PE_ACTIVITY: pe_active[15:0]
- PE_RESULTS: pe_result[15:0]
- ACCUMULATOR: accumulated_sum
- FINAL_OUTPUT: keyword_detected
