`timescale 1ns/1ps

module secded_decoder (
    input  logic [21:0] codeword_in,
    output logic [15:0] corrected_data,
    output logic        single_error_corrected,
    output logic        double_error_detected,
    output logic [4:0]  ecc_syndrome
);

    logic s1, s2, s4, s8, s16;
    assign s1 = codeword_in[0]  ^ codeword_in[2]  ^ codeword_in[4]  ^ codeword_in[6]  ^
                codeword_in[8]  ^ codeword_in[10] ^ codeword_in[12] ^ codeword_in[14] ^
                codeword_in[16] ^ codeword_in[18] ^ codeword_in[20];

    assign s2 = codeword_in[1]  ^ codeword_in[2]  ^ codeword_in[5]  ^ codeword_in[6]  ^
                codeword_in[9]  ^ codeword_in[10] ^ codeword_in[13] ^ codeword_in[14] ^
                codeword_in[17] ^ codeword_in[18];

    assign s4 = codeword_in[3]  ^ codeword_in[4]  ^ codeword_in[5]  ^ codeword_in[6]  ^
                codeword_in[11] ^ codeword_in[12] ^ codeword_in[13] ^ codeword_in[14] ^
                codeword_in[19] ^ codeword_in[20];

    assign s8 = codeword_in[7]  ^ codeword_in[8]  ^ codeword_in[9]  ^ codeword_in[10] ^
                codeword_in[11] ^ codeword_in[12] ^ codeword_in[13] ^ codeword_in[14];

    assign s16 = codeword_in[15] ^ codeword_in[16] ^ codeword_in[17] ^ codeword_in[18] ^
                 codeword_in[19] ^ codeword_in[20];

    logic [4:0] syn;
    assign syn = {s16, s8, s4, s2, s1};
    assign ecc_syndrome = syn;

    logic p_err;
    assign p_err = ^codeword_in;

    assign single_error_corrected = p_err;
    assign double_error_detected  = (!p_err) && (syn != 5'd0);

    logic [21:0] corrected_cw;
    integer b;
    always_comb begin
        corrected_cw = codeword_in;

        if (p_err && (syn >= 5'd1 && syn <= 5'd21)) begin
            corrected_cw[syn - 1] = ~codeword_in[syn - 1];
        end
    end

    assign corrected_data = {
        corrected_cw[20],
        corrected_cw[19],
        corrected_cw[18],
        corrected_cw[17],
        corrected_cw[16],
        corrected_cw[14],
        corrected_cw[13],
        corrected_cw[12],
        corrected_cw[11],
        corrected_cw[10],
        corrected_cw[9],
        corrected_cw[8],
        corrected_cw[6],
        corrected_cw[5],
        corrected_cw[4],
        corrected_cw[2]
    };

endmodule
