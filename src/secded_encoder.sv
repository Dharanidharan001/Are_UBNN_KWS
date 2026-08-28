`timescale 1ns / 1ps

module secded_encoder #(
    parameter int DATA_WIDTH  = 32,
    parameter int PARITY_BITS = 6, 
    parameter int CODE_WIDTH  = DATA_WIDTH + PARITY_BITS + 1 
)(
    input  logic [DATA_WIDTH-1:0]  data_in,
    output logic [PARITY_BITS-1:0] hamming_parity,
    output logic                   overall_parity,
    output logic [CODE_WIDTH-1:0]  encoded_data
);
    function automatic [31:0] get_data_col(input integer idx);
        integer count;
        integer val;
        begin
            count = 0;
            val = 1;
            get_data_col = 32'd3;
            while (count <= idx) begin
                if ((val & (val - 1)) != 0) begin
                    if (count == idx) begin
                        get_data_col = val;
                    end
                    count = count + 1;
                end
                val = val + 1;
            end
        end
    endfunction
    always_comb begin
        for (int i = 0; i < PARITY_BITS; i++) begin
            logic p_bit;
            p_bit = 1'b0;
            for (int d = 0; d < DATA_WIDTH; d++) begin
                if (((get_data_col(d) >> i) & 1) != 0) begin
                    p_bit = p_bit ^ data_in[d];
                end
            end
            hamming_parity[i] = p_bit;
        end

        overall_parity = (^data_in) ^ (^hamming_parity);

        encoded_data = {overall_parity, hamming_parity, data_in};
    end

endmodule
