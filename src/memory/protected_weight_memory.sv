// =============================================================================
// Module: protected_weight_memory
// File:   src/memory/protected_weight_memory.sv
//
// Purpose:
//   A dual-port synchronous weight memory with inline SECDED protection.
//
//   Write path:
//     raw_weight (16-bit) -> secded_encoder -> 22-bit codeword -> memory[]
//
//   Read path:
//     memory[] -> 22-bit codeword -> secded_decoder
//              -> corrected_weight (16-bit) -> BNN PE array
//              -> single_error_corrected flag
//              -> double_error_detected flag
//
//   Fault Injection (SIMULATION ONLY):
//     Two simulation-only inputs allow the testbench to flip bits in the
//     stored codeword.  These signals are NEVER part of a synthesizable
//     production flow.
//
//     fault_inject_en  : when 1, the memory read is XOR'd with fault_mask
//     fault_mask       : 22-bit mask of bits to flip in the read codeword
//
//     In synthesis: tie fault_inject_en=0 and fault_mask=0.
//     The synthesis tool will optimize away the XOR gates.
//
// Parameters:
//   DEPTH      : number of weight entries (default 16, one per PE)
//   DATA_W     : data width (default 16 bits)
//   CW_W       : codeword width (default 22 for SECDED Extended Hamming SECDED (22,16))
//   ADDR_W     : address width (default 4 for depth=16)
//
// Ports:
//   clk                    : system clock
//   rst_n                  : active-low synchronous reset (clears memory on reset)
//   wr_en                  : write enable
//   wr_addr [ADDR_W-1:0]   : write address
//   wr_data [DATA_W-1:0]   : raw weight data to write (unprotected)
//   rd_addr [ADDR_W-1:0]   : read address
//   corrected_weight[DATA_W-1:0] : SECDED-corrected read data
//   single_error_corrected : single-bit error was corrected on this read
//   double_error_detected  : double-bit error detected on this read
//   // Simulation-only fault injection:
//   fault_inject_en        : 1 = inject fault on read codeword
//   fault_mask [CW_W-1:0]  : bitmask of bits to flip
// =============================================================================

module protected_weight_memory #(
    parameter int DEPTH  = 16,
    parameter int DATA_W = 16,
    parameter int CW_W   = 22,
    parameter int ADDR_W = 4
) (
    input  logic                clk,
    input  logic                rst_n,

    // Write port
    input  logic                wr_en,
    input  logic [ADDR_W-1:0]  wr_addr,
    input  logic [DATA_W-1:0]  wr_data,

    // Read port
    input  logic [ADDR_W-1:0]  rd_addr,
    output logic [DATA_W-1:0]  corrected_weight,
    output logic               single_error_corrected,
    output logic               double_error_detected,

    // Simulation-only fault injection (tie to 0 in synthesis)
    input  logic               fault_inject_en,
    input  logic [CW_W-1:0]   fault_mask
);

    // ------------------------------------------------------------------
    // Memory array: stores 22-bit SECDED codewords
    // ------------------------------------------------------------------
    logic [CW_W-1:0] mem [DEPTH];

    // ------------------------------------------------------------------
    // Write path: encode raw weight before storing
    // ------------------------------------------------------------------
    logic [CW_W-1:0] encoded_codeword;

    secded_encoder u_encoder (
        .data_in  (wr_data),
        .codeword (encoded_codeword)
    );

    // Loop index declared at module scope for Icarus Verilog compatibility
    int mem_rst_idx;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // Initialize all memory to encoded zero on reset
            // all-zeros is a valid SECDED codeword for data=0
            for (mem_rst_idx = 0; mem_rst_idx < DEPTH; mem_rst_idx++) begin
                mem[mem_rst_idx] <= '0;
            end
        end else if (wr_en) begin
            mem[wr_addr] <= encoded_codeword;
        end
    end

    // ------------------------------------------------------------------
    // Read path: read codeword, optionally inject fault, then decode
    // ------------------------------------------------------------------
    logic [CW_W-1:0] raw_codeword;
    logic [CW_W-1:0] faulted_codeword;

    // Read the stored codeword (combinational read for simplicity)
    assign raw_codeword = mem[rd_addr];

    // Fault injection: XOR with fault_mask when fault_inject_en==1.
    // In synthesis with fault_inject_en tied to 0, this simplifies to:
    //   faulted_codeword = raw_codeword ^ 0 = raw_codeword
    // The synthesis tool will optimize away this XOR.
    assign faulted_codeword = fault_inject_en ? (raw_codeword ^ fault_mask)
                                              : raw_codeword;

    // SECDED decode
    secded_decoder u_decoder (
        .codeword              (faulted_codeword),
        .corrected_data        (corrected_weight),
        .single_error_corrected(single_error_corrected),
        .double_error_detected (double_error_detected)
    );

endmodule
