// =============================================================================
// Module: accumulator
// File:   src/baseline/accumulator.sv
//
// Purpose:
//   Sum the POPCOUNT results from all NUM_PES Processing Elements into a
//   single accumulated integer.
//
//   This is the BASELINE accumulator.  It must NOT be modified by the
//   enhanced architecture.  The enhanced top-level connects corrected
//   weights and activation-gated PE results to this same module.
//
// Type: SEQUENTIAL — registered output for clean pipeline boundary.
//
// Parameters:
//   NUM_PES      : number of PEs (default 16)
//   PE_RESULT_W  : width of each PE result (default 5, covers 0..16)
//   ACCUM_W      : width of accumulated sum
//                  Max value = NUM_PES * VEC_WIDTH = 16 * 16 = 256 -> 9 bits
//
// Ports:
//   clk          : system clock
//   rst_n        : active-low synchronous reset
//   en           : accumulator latch enable (use this instead of free-running)
//   pe_results   : flat bus of all PE results [NUM_PES * PE_RESULT_W - 1 : 0]
//   accum_out    : accumulated integer output
//   valid_out    : pulses 1 one cycle after en to signal valid output
//
// Operation:
//   On the rising edge of clk, when en==1:
//     accum_out = sum of all NUM_PES pe_results
//
// Note on pe_results bus packing:
//   PE 0 result is at bits [PE_RESULT_W-1 : 0]
//   PE 1 result is at bits [2*PE_RESULT_W-1 : PE_RESULT_W]
//   etc.
// =============================================================================

module accumulator #(
    parameter int NUM_PES     = 16,
    parameter int PE_RESULT_W = 5,
    parameter int ACCUM_W     = 9
) (
    input  logic                              clk,
    input  logic                              rst_n,
    input  logic                              en,
    input  logic [NUM_PES*PE_RESULT_W-1:0]   pe_results,
    output logic [ACCUM_W-1:0]               accum_out,
    output logic                              valid_out
);

    // ------------------------------------------------------------------
    // Combinational sum of all PE results.
    // We unpack the flat bus into individual PE result words.
    // ------------------------------------------------------------------
    logic [ACCUM_W-1:0] sum_comb;

    always_comb begin
        sum_comb = '0;
        for (int i = 0; i < NUM_PES; i++) begin
            // Extract PE i's result from the flat bus
            sum_comb = sum_comb +
                {{(ACCUM_W - PE_RESULT_W){1'b0}},
                 pe_results[i*PE_RESULT_W +: PE_RESULT_W]};
        end
    end

    // ------------------------------------------------------------------
    // Sequential register: capture sum on rising clock edge when en==1.
    // Reset clears both accum and valid.
    // ------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            accum_out <= '0;
            valid_out <= 1'b0;
        end else if (en) begin
            accum_out <= sum_comb;
            valid_out <= 1'b1;
        end else begin
            // Hold previous value; clear valid to indicate stale data
            valid_out <= 1'b0;
        end
    end

endmodule
