// =============================================================================
// Interface: bnn_interface
// Simplified for Icarus Verilog compatibility.
// No clocking blocks (Icarus has partial support only).
// Driver/monitor use @(posedge clk) directly.
// =============================================================================

interface bnn_interface #(
    parameter int NUM_PES     = 16,
    parameter int VEC_WIDTH   = 16,
    parameter int ACCUM_W     = 9,
    parameter int MEM_ADDR_W  = 4
) (
    input logic clk
);
    // DUT inputs
    logic                            rst_n;
    logic [NUM_PES*VEC_WIDTH-1:0]    activations_flat;
    logic [ACCUM_W-1:0]             threshold;
    logic                            accum_en;
    logic                            wr_en;
    logic [MEM_ADDR_W-1:0]          wr_addr;
    logic [VEC_WIDTH-1:0]           wr_data;
    logic [MEM_ADDR_W-1:0]          rd_addr;
    logic [NUM_PES*VEC_WIDTH-1:0]   direct_weights_flat;
    logic                            fault_inject_en;
    logic [21:0]                    fault_mask;

    // DUT outputs
    logic                            keyword_detected;
    logic [ACCUM_W-1:0]             accumulated_sum;
    logic [NUM_PES-1:0]             pe_active;
    logic                            single_error_corrected;
    logic                            double_error_detected;
    logic                            accum_valid;

endinterface