//=============================================================================
// Project: ARe-UBNN-KWS
// Module:  are_ubnn_kws_if
// Description:
//   SystemVerilog interface connecting testbench components (Driver, Monitor)
//   to the DUT (popcount, PE, SECDED, baseline, and full accelerator top).
//=============================================================================

`timescale 1ns/1ps

interface are_ubnn_kws_if (input logic clk);
    // Global signals
    logic        rst_n;

    // Popcount standalone verification signals
    logic [15:0] popcount_in;
    logic [4:0]  popcount_out;

    // Standalone PE verification signals
    logic [15:0] pe_test_act;
    logic [15:0] pe_test_weight;
    logic        pe_test_en;
    logic [4:0]  pe_test_sum;
    logic [4:0]  pe_test_comb;

    // Standalone SECDED verification signals
    logic [15:0] secded_test_data;
    logic [21:0] secded_test_raw_cw;
    logic [21:0] secded_test_corrupt_cw;
    logic [15:0] secded_test_corrected;
    logic        secded_test_single_err;
    logic        secded_test_double_err;
    logic [4:0]  secded_test_syndrome;

    // Full Accelerator stimulus signals
    logic         load_weight;
    logic         load_activation;
    logic         start_inference;
    logic [3:0]   pe_sel;
    logic [15:0]  weight_in;
    logic [15:0]  activation_in;
    logic [255:0] activations_bus;
    logic [7:0]   threshold_in;
    logic         bypass_clock_gating;
    logic         test_en;

    // Fault injection interface
    logic        fault_inject_en;
    logic [3:0]  fault_pe_sel;
    logic [4:0]  fault_bit1;
    logic [4:0]  fault_bit2;
    logic        fault_is_double;

    // Full Accelerator outputs and observability hooks
    logic        busy;
    logic        done;
    logic        kws_output;
    logic [7:0]  accumulator_out;
    logic [8:0]  frame_sum_out;
    logic [15:0] pe_enable_out;
    logic [15:0] pe_gated_clocks_out;
    logic [4:0]  pe_active_count_out;
    logic [79:0] pe_results_bus;
    logic [79:0] pe_comb_bus;
    logic [15:0] corrected_weight_out;
    logic        single_error_corrected_out;
    logic        double_error_detected_out;
    logic [4:0]  ecc_syndrome_out;
    logic [21:0] raw_codeword_out;
    logic [21:0] corrupted_codeword_out;

endinterface
