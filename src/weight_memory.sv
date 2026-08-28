// =============================================================================
// Project: ARe-UBNN-KWS Accelerator (VELTRAXX '26 - PS16 FUSION TECH)
// Module:  weight_memory
// Description:
//   SECDED-protected weight memory with integrated simulation-friendly fault
//   injection. Stores encoded weights generated via secded_encoder.
//   On the read path, the stored codeword is decoded combinationally via
//   secded_decoder, providing single-bit error correction and double-bit error
//   detection before unipolar binary computation begins.
//
// Architecture:
//   Raw Weight Input -> SECDED Encoder -> Memory Array
//                                                │
//                                                ▼
//                                  [Fault Injection Hook]
//                                                │
//                                                ▼
//                                          SECDED Decoder
//                                                │
//                                                ▼
//                       Corrected Weight (Zero Pipeline Latency)
// =============================================================================

`timescale 1ns / 1ps

module weight_memory #(
    parameter int DATA_WIDTH  = 32,
    parameter int PARITY_BITS = 6,
    parameter int CODE_WIDTH  = DATA_WIDTH + PARITY_BITS + 1,
    parameter int ADDR_WIDTH  = 4,
    parameter int DEPTH       = 1 << ADDR_WIDTH,
    parameter bit SYNC_READ   = 1'b0 // 0: combinational read, 1: registered read
)(
    input  logic                   clk,
    input  logic                   rst_n,

    // Write Interface (writes raw weights, automatically encoded)
    input  logic                   wr_en,
    input  logic [ADDR_WIDTH-1:0]  wr_addr,
    input  logic [DATA_WIDTH-1:0]  wr_data,

    // Read Interface
    input  logic [ADDR_WIDTH-1:0]  rd_addr,

    // Simulation Fault Injection Controls
    input  logic                   inject_fault_en,   // Dynamic runtime read-path corruption
    input  logic [CODE_WIDTH-1:0]  inject_fault_mask, // Bitmask of bits to flip
    input  logic                   inject_mem_en,     // In-memory permanent fault injection
    input  logic [ADDR_WIDTH-1:0]  inject_mem_addr,   // Target memory address to corrupt
    input  logic [CODE_WIDTH-1:0]  inject_mem_mask,   // Mask of bits to flip in memory

    // Read Outputs
    output logic [DATA_WIDTH-1:0]  corrected_weight,
    output logic                   single_error,
    output logic                   double_error,
    output logic                   error_detected,
    output logic [PARITY_BITS-1:0] syndrome,

    // Diagnostic & Waveform Observability
    output logic [CODE_WIDTH-1:0]  encoded_weight,    // Stored codeword
    output logic [CODE_WIDTH-1:0]  corrupted_weight   // Codeword after fault injection
);

    // -------------------------------------------------------------------------
    // Internal Memory Array storing SECDED codewords
    // -------------------------------------------------------------------------
    logic [CODE_WIDTH-1:0] mem [0:DEPTH-1];

    // -------------------------------------------------------------------------
    // Write Path: SECDED Encoding
    // -------------------------------------------------------------------------
    logic [PARITY_BITS-1:0] wr_hamming_parity;
    logic                   wr_overall_parity;
    logic [CODE_WIDTH-1:0]  wr_encoded_codeword;

    secded_encoder #(
        .DATA_WIDTH(DATA_WIDTH),
        .PARITY_BITS(PARITY_BITS),
        .CODE_WIDTH(CODE_WIDTH)
    ) u_encoder (
        .data_in(wr_data),
        .hamming_parity(wr_hamming_parity),
        .overall_parity(wr_overall_parity),
        .encoded_data(wr_encoded_codeword)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++) begin
                mem[i] <= '0;
            end
        end else begin
            // Normal write: store encoded codeword
            if (wr_en) begin
                mem[wr_addr] <= wr_encoded_codeword;
            end
            // Direct memory fault injection (corrupt stored bit in memory)
            if (inject_mem_en) begin
                mem[inject_mem_addr] <= mem[inject_mem_addr] ^ inject_mem_mask;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Read Path: Optional Registering & Fault Injection Hook
    // -------------------------------------------------------------------------
    logic [CODE_WIDTH-1:0] raw_read_word;

    generate
        if (SYNC_READ) begin : gen_sync_read
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    raw_read_word <= '0;
                end else begin
                    raw_read_word <= mem[rd_addr];
                end
            end
        end else begin : gen_async_read
            always_comb begin
                raw_read_word = mem[rd_addr];
            end
        end
    endgenerate

    assign encoded_weight = raw_read_word;

    // Apply dynamic runtime fault injection XOR mask
    assign corrupted_weight = raw_read_word ^ (inject_fault_en ? inject_fault_mask : '0);

    // -------------------------------------------------------------------------
    // Read Path: Combinational SECDED Decoding
    // -------------------------------------------------------------------------
    secded_decoder #(
        .DATA_WIDTH(DATA_WIDTH),
        .PARITY_BITS(PARITY_BITS),
        .CODE_WIDTH(CODE_WIDTH)
    ) u_decoder (
        .encoded_data(corrupted_weight),
        .corrected_data(corrected_weight),
        .single_error(single_error),
        .double_error(double_error),
        .error_detected(error_detected),
        .syndrome(syndrome)
    );

endmodule
