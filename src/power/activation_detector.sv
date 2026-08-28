// =============================================================================
// Module: activation_detector
// File:   src/power/activation_detector.sv
//
// Purpose:
//   For each of the NUM_PES Processing Elements, determine whether its
//   activation vector is non-zero.
//
//   If ALL bits of an activation vector are zero, the PE result will be
//   zero regardless of the weight vector (0 AND anything = 0).
//   There is no need to update that PE's output register.
//
//   This module performs a simple OR-reduction per PE:
//     pe_active[i] = |activations[i]   (bitwise OR of all VEC_WIDTH bits)
//
//   Result:
//     pe_active[i] = 0  ->  PE i has all-zero activation (inactive)
//     pe_active[i] = 1  ->  PE i has at least one 1-bit (active)
//
// Type: COMBINATIONAL — no clock, no reset.
//       Drives pe_active inputs of pe_array (the clock-enable signals).
//
// Parameters:
//   NUM_PES   : number of PEs (default 16)
//   VEC_WIDTH : activation vector width (default 16)
//
// Ports:
//   activations_flat [NUM_PES*VEC_WIDTH-1:0] : all activation vectors packed
//   pe_active        [NUM_PES-1:0]           : per-PE activity flag
// =============================================================================

module activation_detector #(
    parameter int NUM_PES   = 16,
    parameter int VEC_WIDTH = 16
) (
    input  logic [NUM_PES*VEC_WIDTH-1:0] activations_flat,
    output logic [NUM_PES-1:0]           pe_active
);

    // For each PE, extract its activation vector and OR-reduce it.
    genvar g;
    generate
        for (g = 0; g < NUM_PES; g++) begin : gen_detect
            // Extract the VEC_WIDTH-bit activation slice for PE g
            // and perform a bitwise OR reduction.
            assign pe_active[g] = |activations_flat[g*VEC_WIDTH +: VEC_WIDTH];
        end
    endgenerate

endmodule
