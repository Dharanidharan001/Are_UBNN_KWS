// =============================================================================
// Module: are_ubnn_kws_enhanced_wrapper
// Description: Hardcoded wrapper enabling the Enhanced architecture (SECDED + ICG)
// =============================================================================

module are_ubnn_kws_enhanced_wrapper #(
    parameter int NUM_PES         = 16,
    parameter int VEC_WIDTH       = 16,
    parameter int PE_RESULT_W     = 5,
    parameter int ACCUM_W         = 9,
    parameter int MEM_DEPTH       = 16,
    parameter int MEM_ADDR_W      = 4
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

    are_ubnn_kws_top #(
        .NUM_PES(NUM_PES),
        .VEC_WIDTH(VEC_WIDTH),
        .PE_RESULT_W(PE_RESULT_W),
        .ACCUM_W(ACCUM_W),
        .MEM_DEPTH(MEM_DEPTH),
        .MEM_ADDR_W(MEM_ADDR_W),
        .ENABLE_ENHANCED(1)
    ) u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .activations_flat(activations_flat),
        .threshold(threshold),
        .accum_en(accum_en),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_addr(rd_addr),
        .direct_weights_flat(direct_weights_flat),
        .fault_inject_en(fault_inject_en),
        .fault_mask(fault_mask),
        .keyword_detected(keyword_detected),
        .accumulated_sum(accumulated_sum),
        .pe_active(pe_active),
        .single_error_corrected(single_error_corrected),
        .double_error_detected(double_error_detected),
        .accum_valid(accum_valid)
    );

endmodule