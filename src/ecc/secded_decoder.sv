// =============================================================================
// Module: secded_decoder
// File:   src/ecc/secded_decoder.sv
// Decode a 22-bit SECDED codeword.
//
// Syndrome computation (pure assign wires):
//   s[0] = XOR of positions covered by p1 = bits 0,2,4,6,8,10,12,14,16,18,20
//   s[1] = XOR of positions covered by p2 = bits 1,2,5,6,9,10,13,14,17,18
//   s[2] = XOR of positions covered by p4 = bits 3,4,5,6,11,12,13,14,19,20
//   s[3] = XOR of positions covered by p8 = bits 7,8,9,10,11,12,13,14
//   s[4] = XOR of positions covered by p16= bits 15,16,17,18,19,20
//
// Overall parity: p_ov = XOR of all 22 bits
//
// Error classification (always_comb):
//   syndrome==0 && p_ov==0  -> no error
//   syndrome==0 && p_ov==1  -> error in bit 21 (overall parity bit itself)
//   syndrome!=0 && p_ov==1  -> single-bit error at bit (syndrome-1)
//   syndrome!=0 && p_ov==0  -> double-bit error detected
// =============================================================================

module secded_decoder (
    input  logic [21:0] codeword,
    output logic [15:0] corrected_data,
    output logic        single_error_corrected,
    output logic        double_error_detected
);

    // --- Syndrome: pure combinational assigns ---
    wire s0 = codeword[0]  ^ codeword[2]  ^ codeword[4]  ^ codeword[6]  ^
              codeword[8]  ^ codeword[10] ^ codeword[12] ^ codeword[14] ^
              codeword[16] ^ codeword[18] ^ codeword[20];

    wire s1 = codeword[1]  ^ codeword[2]  ^ codeword[5]  ^ codeword[6]  ^
              codeword[9]  ^ codeword[10] ^ codeword[13] ^ codeword[14] ^
              codeword[17] ^ codeword[18];

    wire s2 = codeword[3]  ^ codeword[4]  ^ codeword[5]  ^ codeword[6]  ^
              codeword[11] ^ codeword[12] ^ codeword[13] ^ codeword[14] ^
              codeword[19] ^ codeword[20];

    wire s3 = codeword[7]  ^ codeword[8]  ^ codeword[9]  ^ codeword[10] ^
              codeword[11] ^ codeword[12] ^ codeword[13] ^ codeword[14];

    wire s4 = codeword[15] ^ codeword[16] ^ codeword[17] ^ codeword[18] ^
              codeword[19] ^ codeword[20];

    wire [4:0] syndrome = {s4, s3, s2, s1, s0};

    wire p_overall = ^codeword;  // XOR reduction of all 22 bits

    // --- Corrected codeword ---
    logic [21:0] corrected_cw;

    always_comb begin
        corrected_cw           = codeword;
        single_error_corrected = 1'b0;
        double_error_detected  = 1'b0;

        if (syndrome == 5'd0) begin
            if (p_overall == 1'b1) begin
                // Error in the overall parity bit (bit 21) itself
                corrected_cw[21]       = ~codeword[21];
                single_error_corrected = 1'b1;
            end
            // else: no error — pass through
        end else begin
            if (p_overall == 1'b1) begin
                // Single-bit error: flip bit at position (syndrome - 1)
                // syndrome is 1-based, index is 0-based
                case (syndrome)
                    5'd1:  corrected_cw[0]  = ~codeword[0];
                    5'd2:  corrected_cw[1]  = ~codeword[1];
                    5'd3:  corrected_cw[2]  = ~codeword[2];
                    5'd4:  corrected_cw[3]  = ~codeword[3];
                    5'd5:  corrected_cw[4]  = ~codeword[4];
                    5'd6:  corrected_cw[5]  = ~codeword[5];
                    5'd7:  corrected_cw[6]  = ~codeword[6];
                    5'd8:  corrected_cw[7]  = ~codeword[7];
                    5'd9:  corrected_cw[8]  = ~codeword[8];
                    5'd10: corrected_cw[9]  = ~codeword[9];
                    5'd11: corrected_cw[10] = ~codeword[10];
                    5'd12: corrected_cw[11] = ~codeword[11];
                    5'd13: corrected_cw[12] = ~codeword[12];
                    5'd14: corrected_cw[13] = ~codeword[13];
                    5'd15: corrected_cw[14] = ~codeword[14];
                    5'd16: corrected_cw[15] = ~codeword[15];
                    5'd17: corrected_cw[16] = ~codeword[16];
                    5'd18: corrected_cw[17] = ~codeword[17];
                    5'd19: corrected_cw[18] = ~codeword[18];
                    5'd20: corrected_cw[19] = ~codeword[19];
                    5'd21: corrected_cw[20] = ~codeword[20];
                    default: ; // syndrome > 21 -> impossible for 22-bit codeword
                endcase
                single_error_corrected = 1'b1;
            end else begin
                // Double-bit error: p_overall==0 but syndrome!=0
                double_error_detected = 1'b1;
            end
        end
    end

    // --- Extract corrected data bits ---
    assign corrected_data[0]  = corrected_cw[2];
    assign corrected_data[1]  = corrected_cw[4];
    assign corrected_data[2]  = corrected_cw[5];
    assign corrected_data[3]  = corrected_cw[6];
    assign corrected_data[4]  = corrected_cw[8];
    assign corrected_data[5]  = corrected_cw[9];
    assign corrected_data[6]  = corrected_cw[10];
    assign corrected_data[7]  = corrected_cw[11];
    assign corrected_data[8]  = corrected_cw[12];
    assign corrected_data[9]  = corrected_cw[13];
    assign corrected_data[10] = corrected_cw[14];
    assign corrected_data[11] = corrected_cw[16];
    assign corrected_data[12] = corrected_cw[17];
    assign corrected_data[13] = corrected_cw[18];
    assign corrected_data[14] = corrected_cw[19];
    assign corrected_data[15] = corrected_cw[20];

endmodule