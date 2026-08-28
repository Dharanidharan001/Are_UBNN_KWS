// =============================================================================
// Module: popcount
// File:   src/compute/popcount.sv
//
// Purpose:
//   Count the number of logic-1 bits in an N-bit input vector.
//   This is the Population Count (POPCOUNT) operation — the heart of
//   the Unipolar BNN computation.
//
//   After AND-ing the activation and weight vectors, we need to know how
//   many bits are 1.  This count is the "dot product" in unipolar BNN.
//
// Type: COMBINATIONAL — no clock, no reset.
//
// Parameters:
//   WIDTH   : number of input bits (default 16)
//   OUT_W   : output width = ceil(log2(WIDTH+1)) = 5 for WIDTH=16
//
// Ports:
//   data_in [WIDTH-1:0]    : bit vector to count
//   count   [OUT_W-1:0]    : number of 1-bits (0 to WIDTH)
//
// Implementation:
//   Simple binary adder tree.  Readable, synthesizable, and easily
//   parameterized.  For WIDTH=16 the depth is 4 addition levels.
//
// Testing:
//   Apply all-zeros  -> count should be 0
//   Apply all-ones   -> count should be 16
//   Apply alternating-> count should be 8
// =============================================================================

module popcount #(
    parameter int WIDTH = 16,
    parameter int OUT_W = 5     // must be >= ceil(log2(WIDTH+1))
) (
    input  logic [WIDTH-1:0] data_in,
    output logic [OUT_W-1:0] count
);

    // -------------------------------------------------------------------
    // Adder tree.
    // Level 0: each single bit contributes value 0 or 1.
    // We extend each bit to a 2-bit value, then add pairs, widening as
    // needed.  Verilog addition automatically handles the widening.
    // -------------------------------------------------------------------

    // For WIDTH=16:
    //   Stage 1:  8 x 2-bit sums   (pairs of 1-bit inputs)
    //   Stage 2:  4 x 3-bit sums   (pairs of 2-bit inputs)
    //   Stage 3:  2 x 4-bit sums   (pairs of 3-bit inputs)
    //   Stage 4:  1 x 5-bit sum    (pair of 4-bit inputs)

    // Using a generate loop makes it parameterizable.
    // For clarity, we also show the explicit 16-bit sum as a fallback.

    // Generic: just sum all bits.  The synthesis tool will produce an
    // efficient adder tree.  This is correct and synthesizable.
    always_comb begin
        count = '0;
        for (int i = 0; i < WIDTH; i++) begin
            count = count + {{(OUT_W-1){1'b0}}, data_in[i]};
        end
    end

endmodule
