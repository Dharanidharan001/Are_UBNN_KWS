`ifndef TRANSACTION_SV
`define TRANSACTION_SV

typedef enum logic [3:0] {
    MODE_POPCOUNT     = 4'd0,
    MODE_NORMAL       = 4'd1,
    MODE_ALL_ZERO     = 4'd2,
    MODE_SPARSE       = 4'd3,
    MODE_DENSE        = 4'd4,
    MODE_SINGLE_FAULT = 4'd5,
    MODE_DOUBLE_FAULT = 4'd6,
    MODE_FAULT_SPARSE = 4'd7,
    MODE_RANDOM       = 4'd8
} test_mode_t;

typedef struct packed {
    test_mode_t   mode;
    logic [15:0]  popcount_in;
    logic [4:0]   expected_popcount;
    logic [255:0] weights;
    logic [255:0] activations;
    logic [7:0]   threshold;
    logic         fault_en;
    logic [3:0]   fault_pe;
    logic [4:0]   fault_bit1;
    logic [4:0]   fault_bit2;
    logic         fault_double;
    logic [79:0]  expected_pe_result;
    logic [15:0]  expected_pe_enable;
    logic [7:0]   expected_accumulator;
    logic         expected_kws_output;
    logic         expected_single_error;
    logic         expected_double_error;
} transaction_t;

function automatic logic [4:0] calc_popcount16(input logic [15:0] data);
    integer k;
    integer sum;
    begin
        sum = 0;
        for (k = 0; k < 16; k = k + 1) begin
            if (data[k] == 1'b1) sum = sum + 1;
        end
        calc_popcount16 = sum[4:0];
    end
endfunction

function automatic logic [15:0] get_pe_word(input logic [255:0] bus, input integer idx);
    case (idx)
        0:  get_pe_word = bus[15:0];
        1:  get_pe_word = bus[31:16];
        2:  get_pe_word = bus[47:32];
        3:  get_pe_word = bus[63:48];
        4:  get_pe_word = bus[79:64];
        5:  get_pe_word = bus[95:80];
        6:  get_pe_word = bus[111:96];
        7:  get_pe_word = bus[127:112];
        8:  get_pe_word = bus[143:128];
        9:  get_pe_word = bus[159:144];
        10: get_pe_word = bus[175:160];
        11: get_pe_word = bus[191:176];
        12: get_pe_word = bus[207:192];
        13: get_pe_word = bus[223:208];
        14: get_pe_word = bus[239:224];
        15: get_pe_word = bus[255:240];
        default: get_pe_word = 16'h0000;
    endcase
endfunction

function automatic logic [4:0] get_pe_res(input logic [79:0] bus, input integer idx);
    case (idx)
        0:  get_pe_res = bus[4:0];
        1:  get_pe_res = bus[9:5];
        2:  get_pe_res = bus[14:10];
        3:  get_pe_res = bus[19:15];
        4:  get_pe_res = bus[24:20];
        5:  get_pe_res = bus[29:25];
        6:  get_pe_res = bus[34:30];
        7:  get_pe_res = bus[39:35];
        8:  get_pe_res = bus[44:40];
        9:  get_pe_res = bus[49:45];
        10: get_pe_res = bus[54:50];
        11: get_pe_res = bus[59:55];
        12: get_pe_res = bus[64:60];
        13: get_pe_res = bus[69:65];
        14: get_pe_res = bus[74:70];
        15: get_pe_res = bus[79:75];
        default: get_pe_res = 5'd0;
    endcase
endfunction

`endif
