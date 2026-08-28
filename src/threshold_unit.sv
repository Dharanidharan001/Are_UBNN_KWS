`timescale 1ns/1ps

module threshold_unit (
    input  logic [7:0] accumulator_val,
    input  logic [7:0] threshold_val,
    output logic       kws_output
);

    assign kws_output = (accumulator_val >= threshold_val) ? 1'b1 : 1'b0;

endmodule
