`timescale 1ns/1ps

module secded_encoder (
    input  logic [15:0] data_in,
    output logic [21:0] codeword_out
);

    logic p1, p2, p4, p8, p16, p_overall;

    assign p1 = data_in[0]  ^ data_in[1]  ^ data_in[3]  ^ data_in[4]  ^
                data_in[6]  ^ data_in[8]  ^ data_in[10] ^ data_in[11] ^
                data_in[13] ^ data_in[15];

    assign p2 = data_in[0]  ^ data_in[2]  ^ data_in[3]  ^ data_in[5]  ^
                data_in[6]  ^ data_in[9]  ^ data_in[10] ^ data_in[12] ^
                data_in[13];

    assign p4 = data_in[1]  ^ data_in[2]  ^ data_in[3]  ^ data_in[7]  ^
                data_in[8]  ^ data_in[9]  ^ data_in[10] ^ data_in[14] ^
                data_in[15];

    assign p8 = data_in[4]  ^ data_in[5]  ^ data_in[6]  ^ data_in[7]  ^
                data_in[8]  ^ data_in[9]  ^ data_in[10];

    assign p16 = data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[14] ^
                 data_in[15];

    assign p_overall = p1 ^ p2 ^ data_in[0] ^ p4 ^ data_in[1] ^ data_in[2] ^
                       data_in[3] ^ p8 ^ data_in[4] ^ data_in[5] ^ data_in[6] ^
                       data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^
                       p16 ^ data_in[11] ^ data_in[12] ^ data_in[13] ^
                       data_in[14] ^ data_in[15];

    assign codeword_out = {
        p_overall,
        data_in[15],
        data_in[14],
        data_in[13],
        data_in[12],
        data_in[11],
        p16,
        data_in[10],
        data_in[9],
        data_in[8],
        data_in[7],
        data_in[6],
        data_in[5],
        data_in[4],
        p8,
        data_in[3],
        data_in[2],
        data_in[1],
        p4,
        data_in[0],
        p2,
        p1
    };

endmodule
