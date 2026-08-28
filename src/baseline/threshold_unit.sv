// =============================================================================
// Module: threshold_unit
// File:   src/baseline/threshold_unit.sv
//
// Purpose:
//   Compare the accumulated integer sum against a configurable integer
//   threshold.  Output a single binary decision bit.
//
//   In a BNN classifier:
//     if sum >= threshold  ->  keyword_detected = 1  (keyword present)
//     else                 ->  keyword_detected = 0  (no keyword)
//
//   The threshold is a runtime input, allowing the user to adjust
//   sensitivity without re-synthesizing the hardware.
//
// Type: COMBINATIONAL — no clock, no reset.
//
// Parameters:
//   ACCUM_W : width of the accumulated sum input (default 9)
//
// Ports:
//   accum_in         : accumulated sum from the accumulator
//   threshold        : comparison threshold (same width as accum_in)
//   valid_in         : asserted when accum_in is valid
//   keyword_detected : 1 if accum_in >= threshold AND valid_in is 1
// =============================================================================

module threshold_unit #(
    parameter int ACCUM_W = 9
) (
    input  logic [ACCUM_W-1:0] accum_in,
    input  logic [ACCUM_W-1:0] threshold,
    input  logic               valid_in,
    output logic               keyword_detected
);

    // Compare: output is 1 only when input is valid AND exceeds threshold.
    // Use unsigned comparison (both signals are natural integers).
    assign keyword_detected = valid_in & (accum_in >= threshold);

endmodule
