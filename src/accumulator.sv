`timescale 1ns / 1ps

module accumulator #(
    parameter int INPUT_WIDTH = 6,  // POPCOUNT output width ($clog2(DATA_WIDTH+1))
    parameter int ACC_WIDTH   = 32  // Accumulator precision
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   acc_clear,  // Reset accumulated sum
    input  logic                   acc_en,     // Accumulate current step
    input  logic [INPUT_WIDTH-1:0] data_in,    // POPCOUNT value to add
    output logic [ACC_WIDTH-1:0]   acc_out,    // Accumulated total
    output logic                   valid_out   // Status flag
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_out   <= '0;
            valid_out <= 1'b0;
        end else begin
            if (acc_clear && acc_en) begin
                acc_out   <= {{(ACC_WIDTH - INPUT_WIDTH){1'b0}}, data_in};
                valid_out <= 1'b1;
            end else if (acc_clear) begin
                acc_out   <= '0;
                valid_out <= 1'b0;
            end else if (acc_en) begin
                acc_out   <= acc_out + {{(ACC_WIDTH - INPUT_WIDTH){1'b0}}, data_in};
                valid_out <= 1'b1;
            end else begin
                valid_out <= 1'b0;
            end
        end
    end

endmodule
