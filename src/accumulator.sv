`timescale 1ns/1ps

module accumulator (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        clear,
    input  logic        en,
    input  logic [79:0] pe_results,
    output logic [7:0]  acc_value,
    output logic [8:0]  frame_sum
);

    logic [4:0] pe [15:0];
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pe_unpack
            assign pe[i] = pe_results[5*i +: 5];
        end
    endgenerate

    logic [5:0] s1 [7:0];
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_stage1
            assign s1[i] = {1'b0, pe[2*i]} + {1'b0, pe[2*i+1]};
        end
    endgenerate

    logic [6:0] s2 [3:0];
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_stage2
            assign s2[i] = {1'b0, s1[2*i]} + {1'b0, s1[2*i+1]};
        end
    endgenerate

    logic [7:0] s3 [1:0];
    assign s3[0] = {1'b0, s2[0]} + {1'b0, s2[1]};
    assign s3[1] = {1'b0, s2[2]} + {1'b0, s2[3]};

    logic [8:0] sum16;
    assign sum16 = {1'b0, s3[0]} + {1'b0, s3[1]};
    assign frame_sum = sum16;

    logic [7:0] acc_reg;
    logic [9:0] next_sum;
    assign next_sum = {2'b00, acc_reg} + {1'b0, sum16};

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_reg <= 8'd0;
        end else if (clear) begin
            acc_reg <= 8'd0;
        end else if (en) begin
            if (next_sum > 10'd255) begin
                acc_reg <= 8'hFF;
            end else begin
                acc_reg <= next_sum[7:0];
            end
        end
    end

    assign acc_value = acc_reg;

endmodule
