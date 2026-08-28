// =============================================================================
// Project: ARe-UBNN-KWS Accelerator (VELTRAXX '26 - PS16 FUSION TECH)
// Module:  are_ubnn_kws_top
// Description:
//   Top-level synthesizable RTL for the Adaptive Reconfigurable Unipolar
//   Binary Neural Network Keyword Spotting (ARe-UBNN-KWS) accelerator.
//
// Baseline Features:
//   - Domain-specific unipolar binary inference accelerator for edge KWS.
//   - 16 parallel Processing Elements (PEs) executing unipolar binary AND.
//   - High-throughput combinational POPCOUNT tree.
//   - Synchronous baseline accumulator.
//
// Mandated Hardening & Efficiency Upgrades:
//   1. Inline SECDED Fault Tolerance:
//      - Single-Error Correction, Double-Error Detection on weight memory reads.
//      - Real-time combinational correction of single-bit weight upsets.
//      - Explicit detection and flagging of double-bit uncorrectable errors.
//      - Zero additional pipeline stages within the read/compute cycle.
//   2. Fine-Grained Sparsity-Aware Dynamic Clock Gating:
//      - 16 independent zero-detectors evaluating activation vectors.
//      - 16 ASIC-safe integrated clock gating (ICG) cells (sky130_fd_sc_hd__dlclkp).
//      - Gates off clocks to inactive PEs (pe_enable = |activation).
//
// Debug & Observability:
//   Exposes all key diagnostic signals for verification and waveform audit:
//   single_error, double_error, syndrome, corrected_weight, pe_enable[15:0],
//   gated_clk[15:0], pe_result[15:0], popcount_out, accumulator_out.
// =============================================================================

`timescale 1ns / 1ps

module are_ubnn_kws_top #(
    parameter int DATA_WIDTH  = 32,
    parameter int NUM_PE      = 16,
    parameter int PARITY_BITS = 6,
    parameter int CODE_WIDTH  = DATA_WIDTH + PARITY_BITS + 1, // 39 for 32b
    parameter int ADDR_WIDTH  = 4,
    parameter int DEPTH       = 1 << ADDR_WIDTH,              // 16 entries
    parameter int ACC_WIDTH   = 32,
    parameter int PE_WIDTH    = DATA_WIDTH / NUM_PE,          // 2 bits per PE
    parameter int POP_WIDTH   = $clog2(DATA_WIDTH + 1)        // 6 bits (0..32)
)(
    input  logic                   clk,
    input  logic                   rst_n,

    // Inference Execution Controls
    input  logic                   inference_en,      // Step inference & accumulate
    input  logic                   acc_clear,         // Reset accumulator sum
    input  logic [DATA_WIDTH-1:0]  activation,        // Activation vector
    input  logic [ADDR_WIDTH-1:0]  weight_rd_addr,    // Target weight entry

    // Weight Memory Programming Port
    input  logic                   weight_wr_en,      // Write enable
    input  logic [ADDR_WIDTH-1:0]  weight_wr_addr,    // Write address
    input  logic [DATA_WIDTH-1:0]  weight_wr_data,    // Raw weight to encode & store

    // Simulation Fault Injection Controls
    input  logic                   inject_fault_en,   // Dynamic runtime corruption
    input  logic [CODE_WIDTH-1:0]  inject_fault_mask, // Fault bitmask
    input  logic                   inject_mem_en,     // In-memory corruption
    input  logic [ADDR_WIDTH-1:0]  inject_mem_addr,   // Memory address to corrupt
    input  logic [CODE_WIDTH-1:0]  inject_mem_mask,   // Memory fault mask

    // Computation Outputs
    output logic [ACC_WIDTH-1:0]   accumulator_out,   // Final accumulated inference sum
    output logic [POP_WIDTH-1:0]   popcount_out,      // Current cycle's POPCOUNT value
    output logic                   valid_out,         // Result valid flag

    // Verification, SECDED & Waveform Observability Signals
    output logic                   single_error,      // SECDED single-bit error flag
    output logic                   double_error,      // SECDED double-bit error flag
    output logic                   error_detected,    // SECDED error detected flag
    output logic [PARITY_BITS-1:0] syndrome,          // SECDED syndrome bits
    output logic [DATA_WIDTH-1:0]  corrected_weight,  // Corrected weight to PEs
    output logic [CODE_WIDTH-1:0]  encoded_weight,    // Codeword stored in memory
    output logic [CODE_WIDTH-1:0]  corrupted_weight,  // Codeword entering SECDED decoder
    output logic [NUM_PE-1:0]      pe_enable,         // Independent clock enables for 16 PEs
    output logic [NUM_PE-1:0]      gated_clk,         // Gated clocks for 16 PEs
    output logic [NUM_PE-1:0]      pe_result,         // Per-PE activity indicator bit
    output logic [DATA_WIDTH-1:0]  pe_and_vector      // Unipolar binary AND products
);

    // -------------------------------------------------------------------------
    // 1. SECDED-Protected Weight Memory
    // -------------------------------------------------------------------------
    weight_memory #(
        .DATA_WIDTH (DATA_WIDTH),
        .PARITY_BITS(PARITY_BITS),
        .CODE_WIDTH (CODE_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .DEPTH      (DEPTH),
        .SYNC_READ  (1'b0) // Combinational read: zero pipeline stage penalty
    ) u_weight_mem (
        .clk              (clk),
        .rst_n            (rst_n),
        .wr_en            (weight_wr_en),
        .wr_addr          (weight_wr_addr),
        .wr_data          (weight_wr_data),
        .rd_addr          (weight_rd_addr),
        .inject_fault_en  (inject_fault_en),
        .inject_fault_mask(inject_fault_mask),
        .inject_mem_en    (inject_mem_en),
        .inject_mem_addr  (inject_mem_addr),
        .inject_mem_mask  (inject_mem_mask),
        .corrected_weight (corrected_weight),
        .single_error     (single_error),
        .double_error     (double_error),
        .error_detected   (error_detected),
        .syndrome         (syndrome),
        .encoded_weight   (encoded_weight),
        .corrupted_weight (corrupted_weight)
    );

    // -------------------------------------------------------------------------
    // 2. 16 Parallel Processing Elements with Fine-Grained Clock Gating
    // -------------------------------------------------------------------------
    logic [$clog2(PE_WIDTH+1)-1:0] pe_local_pop [0:NUM_PE-1];
    logic [15:0]                   pe_cycles    [0:NUM_PE-1];

    generate
        for (genvar i = 0; i < NUM_PE; i++) begin : gen_pe_array
            // Dynamic Sparsity Clock Gating Unit for PE i
            pe_clock_gating #(
                .ACT_WIDTH(PE_WIDTH)
            ) u_pe_cg (
                .clk        (clk),
                .rst_n      (rst_n),
                .activation (activation[i*PE_WIDTH +: PE_WIDTH]),
                .pe_enable  (pe_enable[i]),
                .gated_clk  (gated_clk[i])
            );

            // Processing Element i: Unipolar AND + Local POPCOUNT
            processing_element #(
                .PE_DATA_WIDTH(PE_WIDTH)
            ) u_pe (
                .clk              (gated_clk[i]),
                .rst_n            (rst_n),
                .activation       (activation[i*PE_WIDTH +: PE_WIDTH]),
                .weight           (corrected_weight[i*PE_WIDTH +: PE_WIDTH]),
                .and_out          (pe_and_vector[i*PE_WIDTH +: PE_WIDTH]),
                .pe_result        (pe_local_pop[i]),
                .pe_active        (pe_result[i]),
                .pe_active_cycles (pe_cycles[i])
            );
        end
    endgenerate

    // -------------------------------------------------------------------------
    // 3. Global POPCOUNT Tree
    // -------------------------------------------------------------------------
    popcount #(
        .INPUT_WIDTH(DATA_WIDTH),
        .COUNT_WIDTH(POP_WIDTH)
    ) u_global_popcount (
        .in_vec (pe_and_vector),
        .count  (popcount_out)
    );

    // -------------------------------------------------------------------------
    // 4. Baseline Synchronous Accumulator
    // -------------------------------------------------------------------------
    accumulator #(
        .INPUT_WIDTH(POP_WIDTH),
        .ACC_WIDTH  (ACC_WIDTH)
    ) u_accumulator (
        .clk       (clk),
        .rst_n     (rst_n),
        .acc_clear (acc_clear),
        .acc_en    (inference_en),
        .data_in   (popcount_out),
        .acc_out   (accumulator_out),
        .valid_out (valid_out)
    );

endmodule
