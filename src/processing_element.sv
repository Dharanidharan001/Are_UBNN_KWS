`timescale 1ns / 1ps

module processing_element #(
    parameter int PE_DATA_WIDTH = 2 // Bits processed per PE (DATA_WIDTH / NUM_PE)
)(
    input  logic                               clk,       // Dedicated gated_clk for this PE
    input  logic                               rst_n,
    input  logic [PE_DATA_WIDTH-1:0]           activation,
    input  logic [PE_DATA_WIDTH-1:0]           weight,
    output logic [PE_DATA_WIDTH-1:0]           and_out,
    output logic [$clog2(PE_DATA_WIDTH+1)-1:0] pe_result, // Local popcount result
    output logic                               pe_active, // High if any active unipolar product
    output logic [15:0]                        pe_active_cycles // Counter clocked by gated_clk
);
    assign and_out   = activation & weight;
    assign pe_active = |and_out;

    popcount #(
        .INPUT_WIDTH(PE_DATA_WIDTH)
    ) u_local_popcount (
        .in_vec(and_out),
        .count(pe_result)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pe_active_cycles <= 16'd0;
        end else begin
            pe_active_cycles <= pe_active_cycles + 16'd1;
        end
    end

endmodule
