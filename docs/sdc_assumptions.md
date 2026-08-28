# SDC Constraints and Assumptions

This document delineates verified RTL design facts from the initial timing assumptions codified in `constraints/are_ubnn_kws.sdc`.

## Verified Design Facts (from `src/top/are_ubnn_kws_top.sv`)
- **Top Module:** `are_ubnn_kws_top`
- **Clock Port:** `clk`
- **Reset Port:** `rst_n` (Active-low, synchronous reset)
- **Synchronous Data Inputs:** `activations_flat`, `threshold`, `wr_addr`, `wr_data`, `rd_addr`, `direct_weights_flat`, `fault_mask`
- **Control Inputs:** `accum_en`, `wr_en`, `fault_inject_en`
- **Outputs:** `keyword_detected`, `accumulated_sum`, `pe_active`, `single_error_corrected`, `double_error_detected`, `accum_valid`

## Initial Timing Assumptions (Unverified Physically)
The current SDC relies on the following conservative assumptions tailored for a hackathon prototype. These are NOT physically validated values and must be optimized during the actual OpenLane/OpenROAD physical design flow.

1. **Clock Period:** Assumes 100 ns (10 MHz). This is an intentionally relaxed target to ensure a clean initial routing and implementation.
2. **Clock Uncertainty:** Assumes 5.0 ns (5%) to account for clock tree skew and jitter.
3. **Input Delay:** Assumes 20.0 ns (20% of clock period) for all data and control inputs (except `clk` and `rst_n`), modeling arrival from an upstream synchronous block.
4. **Output Delay:** Assumes 20.0 ns (20% of clock period) for all outputs, modeling downstream setup time requirements.
5. **Load/Fanout:** Assumes a nominal load of 0.05 pF on outputs and a max fanout limit of 10 on inputs (these are typically overridden by OpenLane's internal characterization).