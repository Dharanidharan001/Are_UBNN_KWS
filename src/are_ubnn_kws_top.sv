`timescale 1ns/1ps

module are_ubnn_kws_top (
    input  logic         clk,
    input  logic         rst_n,

    input  logic         start_inference,
    input  logic         load_weight,
    input  logic [3:0]   weight_pe_sel,
    input  logic [15:0]  weight_data_in,
    input  logic [255:0] activations_in,
    input  logic [7:0]   threshold_in,
    input  logic         bypass_clock_gating,
    input  logic         test_en,

    input  logic         fault_inject_en,
    input  logic [3:0]   fault_pe_sel,
    input  logic [4:0]   fault_bit1,
    input  logic [4:0]   fault_bit2,
    input  logic         fault_is_double,

    output logic         busy,
    output logic         done,
    output logic         kws_output,
    output logic [7:0]   accumulator_val,
    output logic [8:0]   frame_sum,

    output logic [15:0]  pe_enable,
    output logic [15:0]  pe_gated_clocks,
    output logic [4:0]   pe_active_count,
    output logic [79:0]  pe_results,
    output logic [79:0]  pe_comb_results,
    output logic         single_error_corrected,
    output logic         double_error_detected,
    output logic [21:0]  monitored_raw_cw,
    output logic [21:0]  monitored_corrupt_cw,
    output logic [15:0]  monitored_corrected_w,
    output logic [4:0]   monitored_syndrome
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

    logic [255:0] corrected_weights;

    protected_weight_memory u_weight_subsystem (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .wr_en                  (ctrl_weight_wr_en),
        .wr_addr                (weight_pe_sel),
        .wr_data                (weight_data_in),
        .fault_inject_en        (fault_inject_en),
        .fault_pe_sel           (fault_pe_sel),
        .fault_bit1             (fault_bit1),
        .fault_bit2             (fault_bit2),
        .fault_is_double        (fault_is_double),
        .corrected_weights      (corrected_weights),
        .single_error_corrected (single_error_corrected),
        .double_error_detected  (double_error_detected),
        .monitored_raw_cw       (monitored_raw_cw),
        .monitored_corrupt_cw   (monitored_corrupt_cw),
        .monitored_corrected    (monitored_corrected_w),
        .monitored_syndrome     (monitored_syndrome)
    );

    logic [15:0] dynamic_pe_en;

    pe_activity_detector u_activity_detector (
        .activations   (activations_in),
        .bypass_gating (bypass_clock_gating),
        .pe_enable     (dynamic_pe_en)
    );

    assign pe_enable = dynamic_pe_en;

    logic [79:0] pe_reg_results;
    logic [79:0] pe_comb_out;
    logic [4:0]  active_count;
    logic [15:0] gated_clks;

    logic [15:0] qualified_pe_en;
    assign qualified_pe_en = dynamic_pe_en & {16{ctrl_pe_eval_en | bypass_clock_gating}};

    pe_array16 u_pe_array (
        .clk             (clk),
        .rst_n           (rst_n),
        .pe_enable       (qualified_pe_en),
        .test_en         (test_en),
        .activations     (activations_in),
        .weights         (corrected_weights),
        .gated_clocks    (gated_clks),
        .pe_results      (pe_reg_results),
        .pe_comb_results (pe_comb_out),
        .pe_active_count (active_count)
    );

    logic [4:0] top_active_count;
    popcount16 u_frame_active_pe_counter (
        .in_data (dynamic_pe_en),
        .count   (top_active_count)
    );

    assign pe_results      = pe_reg_results;
    assign pe_comb_results = pe_comb_out;
    assign pe_active_count = top_active_count;
    assign pe_gated_clocks = gated_clks;

    logic [79:0] effective_pe_results;
    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1) begin : gen_effective_pe
            assign effective_pe_results[5*j +: 5] = dynamic_pe_en[j] ? pe_reg_results[5*j +: 5] : 5'd0;
        end
    endgenerate

    logic [7:0] accumulated_sum;
    logic [8:0] current_frame_sum;

    accumulator u_accumulator (
        .clk        (clk),
        .rst_n      (rst_n),
        .clear      (ctrl_accum_clear),
        .en         (ctrl_accum_en),
        .pe_results (effective_pe_results),
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
