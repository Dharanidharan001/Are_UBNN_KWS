// =============================================================================
// Module: pe_array
// File:   src/compute/pe_array.sv
//
// Purpose:
//   Instantiate NUM_PES (default 16) unipolar_pe instances.
//   Distribute activation vectors and weight vectors to each PE.
//   Register the PE outputs for a clean pipeline boundary.
//
//   This module handles BOTH the baseline and enhanced cases:
//   - pe_active[i] enables the output register of PE i (clock enable).
//   - In the baseline, pe_active is tied to all-ones externally.
//   - In the enhanced architecture, pe_active comes from activation_detector.
//
// Type: MIXED — combinational PE computation, sequential output registration.
//
// Parameters:
//   NUM_PES      : number of Processing Elements (default 16)
//   VEC_WIDTH    : activation/weight vector width (default 16)
//   PE_RESULT_W  : PE output width (default 5)
//
// Ports:
//   clk                  : system clock
//   rst_n                : active-low synchronous reset
//   activations_flat     : all activation vectors packed flat
//                          [NUM_PES * VEC_WIDTH - 1 : 0]
//                          PE0 at [VEC_WIDTH-1:0], PE1 at [2*VEC_WIDTH-1:VEC_WIDTH] etc.
//   weights_flat         : all weight vectors packed flat (same layout)
//   pe_active            : per-PE enable (from activation_detector or tied 1)
//   pe_results_flat      : registered PE results packed flat
//                          [NUM_PES * PE_RESULT_W - 1 : 0]
//
// Clock-Enable Architecture:
//   For each PE i:
//     On posedge clk:
//       if pe_active[i] == 1: pe_result_reg[i] <= pe_comb[i]
//       else:                  hold previous value (no toggle)
//
//   This is a SAFE SYNTHESIZABLE clock-enable pattern.
//   It does NOT create a combinational clock gate.
//   The synthesis tool can infer an integrated clock-gating cell (ICG)
//   from this pattern when targeting a PDK with ICG cells.
//
// =============================================================================

module pe_array #(
    parameter int NUM_PES     = 16,
    parameter int VEC_WIDTH   = 16,
    parameter int PE_RESULT_W = 5
) (
    input  logic                                 clk,
    input  logic                                 rst_n,
    // Activation input: one vector per PE, packed
    input  logic [NUM_PES*VEC_WIDTH-1:0]         activations_flat,
    // Weight input: one vector per PE, packed (corrected weights from SECDED)
    input  logic [NUM_PES*VEC_WIDTH-1:0]         weights_flat,
    // Per-PE enable: 1 = active (non-zero activation), 0 = inactive
    input  logic [NUM_PES-1:0]                   pe_active,
    // Registered PE results, packed flat
    output logic [NUM_PES*PE_RESULT_W-1:0]       pe_results_flat
);

    // ------------------------------------------------------------------
    // Combinational PE outputs (before registration)
    // ------------------------------------------------------------------
    logic [PE_RESULT_W-1:0] pe_comb [NUM_PES];

    // ------------------------------------------------------------------
    // Instantiate NUM_PES unipolar_pe instances
    // ------------------------------------------------------------------
    genvar g;
    generate
        for (g = 0; g < NUM_PES; g++) begin : gen_pe
            unipolar_pe #(
                .VEC_WIDTH (VEC_WIDTH),
                .RESULT_W  (PE_RESULT_W)
            ) u_pe (
                .activation (activations_flat[g*VEC_WIDTH +: VEC_WIDTH]),
                .weight     (weights_flat[g*VEC_WIDTH +: VEC_WIDTH]),
                .result     (pe_comb[g])
            );
        end
    endgenerate

    // ------------------------------------------------------------------
    // Clock-enable output registers.
    //
    // IMPORTANT DESIGN NOTE:
    //   We use the standard synthesis-friendly clock-enable pattern:
    //     always_ff @(posedge clk) if (enable) reg <= data;
    //
    //   This is NOT a combinational clock gate.
    //   The flip-flop always clocks; only its D-input MUX is selected.
    //   When pe_active[i]==0, the register holds its previous value and
    //   does NOT toggle — saving switching power.
    //
    //   Synthesis tools (Yosys, Design Compiler, etc.) with ICG support
    //   will automatically convert this pattern into a latch-based
    //   integrated clock-gating cell (e.g., sky130_fd_sc_hd__dlclkp_1)
    //   that generates a glitch-free gated clock.
    // ------------------------------------------------------------------
    logic [PE_RESULT_W-1:0] pe_result_reg [NUM_PES];

    generate
        for (g = 0; g < NUM_PES; g++) begin : gen_pe_reg
            always_ff @(posedge clk) begin
                if (!rst_n) begin
                    pe_result_reg[g] <= '0;
                end else if (pe_active[g]) begin
                    // PE is active: latch the new combinational result
                    pe_result_reg[g] <= pe_comb[g];
                end
                // pe_active[g]==0: hold previous value — no update, no toggle
            end
        end
    endgenerate

    // ------------------------------------------------------------------
    // Pack registered results into the flat output bus.
    // ------------------------------------------------------------------
    generate
        for (g = 0; g < NUM_PES; g++) begin : gen_pack
            assign pe_results_flat[g*PE_RESULT_W +: PE_RESULT_W] = pe_result_reg[g];
        end
    endgenerate

endmodule
