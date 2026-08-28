// =============================================================================
// Module: secded_encoder
// File:   src/ecc/secded_encoder.sv
// SECDED Extended Hamming SECDED (22,16): 16 data bits + 5 Hamming parity bits + 1 overall parity bit
//
// Codeword layout (0-indexed):
//   bit  0 = p1   (Hamming parity, covers positions 1,3,5,7,9,11,13,15,17,19,21)
//   bit  1 = p2   (covers 2,3,6,7,10,11,14,15,18,19)
//   bit  2 = d[0]
//   bit  3 = p4   (covers 4,5,6,7,12,13,14,15,20,21)
//   bit  4 = d[1]
//   bit  5 = d[2]
//   bit  6 = d[3]
//   bit  7 = p8   (covers 8..15)
//   bit  8 = d[4]
//   bit  9 = d[5]
//   bit 10 = d[6]
//   bit 11 = d[7]
//   bit 12 = d[8]
//   bit 13 = d[9]
//   bit 14 = d[10]
//   bit 15 = p16  (covers 16..21)
//   bit 16 = d[11]
//   bit 17 = d[12]
//   bit 18 = d[13]
//   bit 19 = d[14]
//   bit 20 = d[15]
//   bit 21 = p_overall (XOR of bits 0..20)
//
// Type: COMBINATIONAL (pure assign).
// =============================================================================

module secded_encoder (
    input  logic [15:0] data_in,
    output logic [21:0] codeword
);

    // --- Data bits placed at their designated codeword positions ---
    wire d0  = data_in[0];
    wire d1  = data_in[1];
    wire d2  = data_in[2];
    wire d3  = data_in[3];
    wire d4  = data_in[4];
    wire d5  = data_in[5];
    wire d6  = data_in[6];
    wire d7  = data_in[7];
    wire d8  = data_in[8];
    wire d9  = data_in[9];
    wire d10 = data_in[10];
    wire d11 = data_in[11];
    wire d12 = data_in[12];
    wire d13 = data_in[13];
    wire d14 = data_in[14];
    wire d15 = data_in[15];

    // --- Hamming parity bits (even parity over data bits only) ---
    // p1 covers positions 1,3,5,7,9,11,13,15,17,19,21
    //    data positions: 3,5,7,9,11,13,15,17,19,21 -> d0,d1,d3,d4,d6,d8,d10,d11,d13,d15
    wire p1  = d0 ^ d1 ^ d3 ^ d4 ^ d6 ^ d8 ^ d10 ^ d11 ^ d13 ^ d15;

    // p2 covers positions 2,3,6,7,10,11,14,15,18,19
    //    data positions: 3,6,7,10,11,14,15,18,19 -> d0,d2,d3,d5,d6,d9,d10,d12,d13
    wire p2  = d0 ^ d2 ^ d3 ^ d5 ^ d6 ^ d9 ^ d10 ^ d12 ^ d13;

    // p4 covers positions 4,5,6,7,12,13,14,15,20,21
    //    data positions: 5,6,7,12,13,14,15,20,21 -> d1,d2,d3,d7,d8,d9,d10,d14,d15
    wire p4  = d1 ^ d2 ^ d3 ^ d7 ^ d8 ^ d9 ^ d10 ^ d14 ^ d15;

    // p8 covers positions 8,9,10,11,12,13,14,15
    //    data positions: 9,10,11,12,13,14,15 -> d4,d5,d6,d7,d8,d9,d10
    wire p8  = d4 ^ d5 ^ d6 ^ d7 ^ d8 ^ d9 ^ d10;

    // p16 covers positions 16,17,18,19,20,21
    //    data positions: 17,18,19,20,21 -> d11,d12,d13,d14,d15
    wire p16 = d11 ^ d12 ^ d13 ^ d14 ^ d15;

    // Build the 21-bit Hamming codeword (before overall parity)
    wire [20:0] cw21;
    assign cw21[0]  = p1;
    assign cw21[1]  = p2;
    assign cw21[2]  = d0;
    assign cw21[3]  = p4;
    assign cw21[4]  = d1;
    assign cw21[5]  = d2;
    assign cw21[6]  = d3;
    assign cw21[7]  = p8;
    assign cw21[8]  = d4;
    assign cw21[9]  = d5;
    assign cw21[10] = d6;
    assign cw21[11] = d7;
    assign cw21[12] = d8;
    assign cw21[13] = d9;
    assign cw21[14] = d10;
    assign cw21[15] = p16;
    assign cw21[16] = d11;
    assign cw21[17] = d12;
    assign cw21[18] = d13;
    assign cw21[19] = d14;
    assign cw21[20] = d15;

    // Overall parity bit: XOR of all 21 bits
    wire p_overall = ^cw21;

    // Assemble 22-bit codeword
    assign codeword = {p_overall, cw21};

endmodule