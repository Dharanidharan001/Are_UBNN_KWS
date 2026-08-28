`timescale 1ns/1ps

module popcount16 (
    input  logic [15:0] in_data,
    output logic [4:0]  count
);

    logic [1:0] s1 [7:0];
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_stage1
            assign s1[i] = {1'b0, in_data[2*i]} + {1'b0, in_data[2*i+1]};
        end
    endgenerate

    logic [2:0] s2 [3:0];
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_stage2
            assign s2[i] = {1'b0, s1[2*i]} + {1'b0, s1[2*i+1]};
        end
    endgenerate

    logic [3:0] s3 [1:0];
    assign s3[0] = {1'b0, s2[0]} + {1'b0, s2[1]};
    assign s3[1] = {1'b0, s2[2]} + {1'b0, s2[3]};

    assign count = {1'b0, s3[0]} + {1'b0, s3[1]};

endmodule
