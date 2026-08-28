`timescale 1ns / 1ps

module pe_clock_gating #(
    parameter int ACT_WIDTH = 2 // Activation vector slice width per PE
)(
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic [ACT_WIDTH-1:0] activation,
    output logic                 pe_enable,
    output logic                 gated_clk
);
  assign pe_enable = |activation;

`ifdef USE_SKY130_ICG

    sky130_fd_sc_hd__dlclkp u_sky130_icg (
        .CLK  (clk),
        .GATE (pe_enable),
        .GCLK (gated_clk)
    );
`else
    logic en_latched;

    always_latch begin
        if (!rst_n) begin
            en_latched <= 1'b0;
        end else if (!clk) begin
            en_latched <= pe_enable;
        end
    end

    assign gated_clk = clk & en_latched;
`endif

endmodule
