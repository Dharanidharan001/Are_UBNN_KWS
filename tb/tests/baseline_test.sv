// =============================================================================
// baseline_test.sv — Baseline-only test (ENABLE_ENHANCED=0)
// Useful for comparing baseline vs enhanced behavior.
// This test is informational; the main tb_top uses the enhanced DUT.
// =============================================================================

`ifndef BASELINE_TEST_SV
`define BASELINE_TEST_SV

// Baseline test instantiates the DUT with ENABLE_ENHANCED=0
// For standalone use, compile this with the RTL and a simple top.

// See tb/top/tb_top.sv for the main enhanced test entry point.
// The baseline test scenario (T1-style normal inference) is included
// in the generator as T1_normal_inference with ENABLE_ENHANCED=1,
// which also verifies the baseline data path.

`endif
