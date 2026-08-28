// =============================================================================
// Module: unipolar_pe
// File:   src/compute/unipolar_pe.sv
//
// Purpose:
//   One Processing Element for the Unipolar Binary Neural Network.
//
//   In a unipolar BNN:
//     - Weights and activations are binary: 0 or 1  (not -1/+1)
//     - The dot product is: AND each pair of bits, then count the 1s
//
//   Computation:
//     bitwise_and = activation & weight    (bitwise AND, element-wise)
//     result      = popcount(bitwise_and)  (count matching 1s)
//
//   The result is an integer between 0 and VEC_WIDTH, representing
//   how many activation bits "agree" with their weight bits.
//
// Type: COMBINATIONAL — no clock, no reset.
//       The parent pe_array registers the output.
//
// Parameters:
//   VEC_WIDTH  : bit-width of each activation/weight vector (default 16)
//   RESULT_W   : output width = ceil(log2(VEC_WIDTH+1)) = 5 for 16 bits
//
// Ports:
//   activation [VEC_WIDTH-1:0]  : input activation vector (binary, 0 or 1 per bit)
//   weight     [VEC_WIDTH-1:0]  : weight vector (binary, 0 or 1 per bit)
//   result     [RESULT_W-1:0]   : popcount of (activation AND weight)
//
// Connection:
//   Instantiated 16 times inside pe_array.
//   Weight comes from protected_weight_memory (corrected by SECDED decoder).
//   Activation comes from the input activation distribution logic.
// =============================================================================

module unipolar_pe #(
    parameter int VEC_WIDTH = 16,
    parameter int RESULT_W  = 5
) (
    input  logic [VEC_WIDTH-1:0] activation,
    input  logic [VEC_WIDTH-1:0] weight,
    output logic [RESULT_W-1:0]  result
);

    // Step 1: Element-wise AND of activation and weight vectors.
    //         Each bit of the output is 1 only when BOTH the
    //         activation bit and the weight bit are 1.
    logic [VEC_WIDTH-1:0] bitwise_and;
    assign bitwise_and = activation & weight;

    // Step 2: Count the number of 1s in the AND result.
    //         Instantiate the popcount module.
    popcount #(
        .WIDTH (VEC_WIDTH),
        .OUT_W (RESULT_W)
    ) u_popcount (
        .data_in (bitwise_and),
        .count   (result)
    );

endmodule
