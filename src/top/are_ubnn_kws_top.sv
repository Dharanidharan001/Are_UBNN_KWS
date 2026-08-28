// =============================================================================
// Module: are_ubnn_kws_top
// File:   src/top/are_ubnn_kws_top.sv
// (Fixed: genvar placement, generate-if structure)
// =============================================================================

module are_ubnn_kws_top #(
    parameter int NUM_PES         = 16,
    parameter int VEC_WIDTH       = 16,
    parameter int PE_RESULT_W     = 5,
    parameter int ACCUM_W         = 9,
    parameter int MEM_DEPTH       = 16,
    parameter int MEM_ADDR_W      = 4,
    parameter int ENABLE_ENHANCED = 1
) (
    input  logic                              clk,
    input  logic                              rst_n,
    input  logic [NUM_PES*VEC_WIDTH-1:0]      activations_flat,
    input  logic [ACCUM_W-1:0]               threshold,
    input  logic                              accum_en,
    input  logic                              wr_en,
    input  logic [MEM_ADDR_W-1:0]            wr_addr,
    input  logic [VEC_WIDTH-1:0]             wr_data,
    input  logic [MEM_ADDR_W-1:0]            rd_addr,
    input  logic [NUM_PES*VEC_WIDTH-1:0]     direct_weights_flat,
    input  logic                              fault_inject_en,
    input  logic [21:0]                      fault_mask,
    output logic                              keyword_detected,
    output logic [ACCUM_W-1:0]              accumulated_sum,
    output logic [NUM_PES-1:0]              pe_active,
    output logic                              single_error_corrected,
    output logic                              double_error_detected,
    output logic                              accum_valid
);

    logic [VEC_WIDTH-1:0]           corrected_weight_single;
    logic [NUM_PES*VEC_WIDTH-1:0]   weights_to_pe;
    logic [NUM_PES-1:0]             pe_active_internal;
    logic [NUM_PES*PE_RESULT_W-1:0] pe_results_flat;

    // ---------------------------------------------------------------
    // Enhanced: SECDED-protected weight memory + broadcast to all PEs
    // ---------------------------------------------------------------
    generate
        if (ENABLE_ENHANCED) begin : gen_enhanced_weight

            protected_weight_memory #(
                .DEPTH  (MEM_DEPTH),
                .DATA_W (VEC_WIDTH),
                .CW_W   (22),
                .ADDR_W (MEM_ADDR_W)
            ) u_weight_mem (
                .clk                   (clk),
                .rst_n                 (rst_n),
                .wr_en                 (wr_en),
                .wr_addr               (wr_addr),
                .wr_data               (wr_data),
                .rd_addr               (rd_addr),
                .corrected_weight      (corrected_weight_single),
                .single_error_corrected(single_error_corrected),
                .double_error_detected (double_error_detected),
                .fault_inject_en       (fault_inject_en),
                .fault_mask            (fault_mask)
            );

            // Broadcast the corrected weight to all PEs
            for (genvar g = 0; g < NUM_PES; g++) begin : gen_weight_bcast
                assign weights_to_pe[g*VEC_WIDTH +: VEC_WIDTH] = corrected_weight_single;
            end

            // Activation sparsity detection
            activation_detector #(
                .NUM_PES   (NUM_PES),
                .VEC_WIDTH (VEC_WIDTH)
            ) u_act_detect (
                .activations_flat (activations_flat),
                .pe_active        (pe_active_internal)
            );

        end else begin : gen_baseline_weight

            assign weights_to_pe           = direct_weights_flat;
            assign corrected_weight_single  = '0;
            assign single_error_corrected   = 1'b0;
            assign double_error_detected    = 1'b0;
            assign pe_active_internal       = {NUM_PES{1'b1}};

        end
    endgenerate

    assign pe_active = pe_active_internal;

    // ---------------------------------------------------------------
    // PE Array
    // ---------------------------------------------------------------
    pe_array #(
        .NUM_PES     (NUM_PES),
        .VEC_WIDTH   (VEC_WIDTH),
        .PE_RESULT_W (PE_RESULT_W)
    ) u_pe_array (
        .clk             (clk),
        .rst_n           (rst_n),
        .activations_flat(activations_flat),
        .weights_flat    (weights_to_pe),
        .pe_active       (pe_active_internal),
        .pe_results_flat (pe_results_flat)
    );

    // ---------------------------------------------------------------
    // BASELINE Accumulator (unmodified)
    // ---------------------------------------------------------------
    accumulator #(
        .NUM_PES     (NUM_PES),
        .PE_RESULT_W (PE_RESULT_W),
        .ACCUM_W     (ACCUM_W)
    ) u_accum (
        .clk        (clk),
        .rst_n      (rst_n),
        .en         (accum_en),
        .pe_results (pe_results_flat),
        .accum_out  (accumulated_sum),
        .valid_out  (accum_valid)
    );

    // ---------------------------------------------------------------
    // Threshold Unit
    // ---------------------------------------------------------------
    threshold_unit #(
        .ACCUM_W (ACCUM_W)
    ) u_threshold (
        .accum_in        (accumulated_sum),
        .threshold       (threshold),
        .valid_in        (accum_valid),
        .keyword_detected(keyword_detected)
    );

endmodule
