`timescale 1ns/1ps

module baseline_ubnn_kws_top (
    input  logic         clk,
    input  logic         rst_n,

    input  logic         start_inference,
    input  logic         load_weight,
    input  logic [3:0]   weight_pe_sel,
    input  logic [15:0]  weight_data_in,
    input  logic [255:0] activations_in,
    input  logic [7:0]   threshold_in,

    output logic         busy,
    output logic         done,
    output logic         kws_output,
    output logic [7:0]   accumulator_val,
    output logic [8:0]   frame_sum,
    output logic [79:0]  pe_results
);

    logic [2:0] current_state;
    logic       ctrl_weight_wr_en;
    logic       ctrl_pe_eval_en;
    logic       ctrl_accum_en;
    logic       ctrl_accum_clear;

    controller u_controller (
        .clk             (clk),
        .rst_n           (rst_n),
        .start_inference (start_inference),
        .load_weight_cmd (load_weight),
        .clear_acc_cmd   (1'b0),
        .busy            (busy),
        .done            (done),
        .state_out       (current_state),
        .weight_wr_en    (ctrl_weight_wr_en),
        .pe_eval_en      (ctrl_pe_eval_en),
        .accum_en        (ctrl_accum_en),
        .accum_clear     (ctrl_accum_clear)
    );

    logic [15:0] raw_weight_mem [15:0];
    integer k;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (k = 0; k < 16; k = k + 1) begin
                raw_weight_mem[k] <= 16'd0;
            end
        end else if (ctrl_weight_wr_en) begin
            raw_weight_mem[weight_pe_sel] <= weight_data_in;
        end
    end

    logic [255:0] raw_weights;
    genvar w_idx;
    generate
        for (w_idx = 0; w_idx < 16; w_idx = w_idx + 1) begin : gen_raw_weights
            assign raw_weights[16*w_idx +: 16] = raw_weight_mem[w_idx];
        end
    endgenerate

    logic [79:0] pe_reg_results;
    logic [79:0] pe_comb_out;
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_baseline_pe
            unipolar_pe u_pe (
                .clk         (clk),
                .rst_n       (rst_n),
                .en          (ctrl_pe_eval_en),
                .activation  (activations_in[16*i +: 16]),
                .weight      (raw_weights[16*i +: 16]),
                .partial_sum (pe_reg_results[5*i +: 5]),
                .comb_sum    (pe_comb_out[5*i +: 5])
            );
        end
    endgenerate

    assign pe_results = pe_reg_results;

    logic [7:0] accumulated_sum;
    logic [8:0] current_frame_sum;

    accumulator u_accumulator (
        .clk        (clk),
        .rst_n      (rst_n),
        .clear      (ctrl_accum_clear),
        .en         (ctrl_accum_en),
        .pe_results (pe_reg_results),
        .acc_value  (accumulated_sum),
        .frame_sum  (current_frame_sum)
    );

    assign accumulator_val = accumulated_sum;
    assign frame_sum       = current_frame_sum;

    threshold_unit u_threshold (
        .accumulator_val (accumulated_sum),
        .threshold_val   (threshold_in),
        .kws_output      (kws_output)
    );

endmodule
