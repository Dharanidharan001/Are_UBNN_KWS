`timescale 1ns/1ps

module icg_cell (
    input  logic clk_in,
    input  logic enable,
    input  logic test_en,
    output logic clk_out
);

    logic en_or_test;
    assign en_or_test = enable | test_en;

`ifdef SYNTHESIS

    sky130_fd_sc_hd__dlclkp_1 u_sky130_icg (
        .CLK  (clk_in),
        .GATE (en_or_test),
        .GCLK (clk_out)
    );
`else

    logic en_latched;
    always_latch begin
        if (!clk_in) begin
            en_latched <= en_or_test;
        end
    end

    assign clk_out = clk_in & en_latched;
`endif

endmodule
