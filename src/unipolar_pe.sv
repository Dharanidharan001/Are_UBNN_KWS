`timescale 1ns/1ps

module unipolar_pe (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic [15:0] activation,
    input  logic [15:0] weight,
    output logic [4:0]  partial_sum,
    output logic [4:0]  comb_sum
);

    logic [15:0] and_result;
    assign and_result = activation & weight;

    logic [4:0] count_out;
    popcount16 u_popcount (
        .in_data (and_result),
        .count   (count_out)
    );

    assign comb_sum = count_out;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            partial_sum <= 5'd0;
        end else if (en) begin
            partial_sum <= count_out;
        end
    end

endmodule
