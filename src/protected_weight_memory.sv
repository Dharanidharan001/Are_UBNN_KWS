`timescale 1ns/1ps

module protected_weight_memory (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         wr_en,
    input  logic [3:0]   wr_addr,
    input  logic [15:0]  wr_data,

    input  logic         fault_inject_en,
    input  logic [3:0]   fault_pe_sel,
    input  logic [4:0]   fault_bit1,
    input  logic [4:0]   fault_bit2,
    input  logic         fault_is_double,

    output logic [255:0] corrected_weights,
    output logic         single_error_corrected,
    output logic         double_error_detected,

    output logic [21:0]  monitored_raw_cw,
    output logic [21:0]  monitored_corrupt_cw,
    output logic [15:0]  monitored_corrected,
    output logic [4:0]   monitored_syndrome
);

    logic [21:0] weight_mem [15:0];

    logic [21:0] encoded_wr_codeword;
    secded_encoder u_write_encoder (
        .data_in      (wr_data),
        .codeword_out (encoded_wr_codeword)
    );

    integer k;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (k = 0; k < 16; k = k + 1) begin
                weight_mem[k] <= 22'd0;
            end
        end else if (wr_en) begin
            weight_mem[wr_addr] <= encoded_wr_codeword;
        end
    end

    logic [21:0] raw_cw [15:0];
    logic [21:0] read_cw [15:0];
    logic [15:0] corrected_w [15:0];
    logic [15:0] sec_flags;
    logic [15:0] ded_flags;
    logic [4:0]  syndromes [15:0];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_read_decoders
            assign raw_cw[i] = weight_mem[i];

            always_comb begin
                read_cw[i] = raw_cw[i];
                if (fault_inject_en && (fault_pe_sel == i[3:0])) begin
                    read_cw[i] = raw_cw[i] ^ (22'b1 << fault_bit1);
                    if (fault_is_double) begin
                        read_cw[i] = read_cw[i] ^ (22'b1 << fault_bit2);
                    end
                end
            end

            secded_decoder u_read_decoder (
                .codeword_in            (read_cw[i]),
                .corrected_data         (corrected_w[i]),
                .single_error_corrected (sec_flags[i]),
                .double_error_detected  (ded_flags[i]),
                .ecc_syndrome           (syndromes[i])
            );

            assign corrected_weights[16*i +: 16] = corrected_w[i];
        end
    endgenerate

    assign single_error_corrected = |sec_flags;
    assign double_error_detected  = |ded_flags;

    assign monitored_raw_cw      = raw_cw[fault_pe_sel];
    assign monitored_corrupt_cw  = read_cw[fault_pe_sel];
    assign monitored_corrected   = corrected_w[fault_pe_sel];
    assign monitored_syndrome    = syndromes[fault_pe_sel];

endmodule
