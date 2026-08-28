`timescale 1ns/1ps

module pe_activity_detector (
    input  logic [255:0] activations,
    input  logic         bypass_gating,
    output logic [15:0]  pe_enable
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_activity_detect

            logic is_active;
            assign is_active = |activations[16*i +: 16];

            assign pe_enable[i] = bypass_gating ? 1'b1 : is_active;
        end
    endgenerate

endmodule
