`timescale 1ns/1ps

module pe_array16 (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [15:0]  pe_enable,
    input  logic         test_en,
    input  logic [255:0] activations,
    input  logic [255:0] weights,
    output logic [15:0]  gated_clocks,
    output logic [79:0]  pe_results,
    output logic [79:0]  pe_comb_results,
    output logic [4:0]   pe_active_count
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pe_instances

            icg_cell u_pe_icg (
                .clk_in  (clk),
                .enable  (pe_enable[i]),
                .test_en (test_en),
                .clk_out (gated_clocks[i])
            );

            unipolar_pe u_pe (
                .clk         (gated_clocks[i]),
                .rst_n       (rst_n),
                .en          (1'b1),
                .activation  (activations[16*i +: 16]),
                .weight      (weights[16*i +: 16]),
                .partial_sum (pe_results[5*i +: 5]),
                .comb_sum    (pe_comb_results[5*i +: 5])
            );
        end
    endgenerate

    popcount16 u_active_pe_counter (
        .in_data (pe_enable),
        .count   (pe_active_count)
    );

endmodule
