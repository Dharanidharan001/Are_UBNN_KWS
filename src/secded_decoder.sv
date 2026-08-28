`timescale 1ns / 1ps

module secded_decoder #(
    parameter int DATA_WIDTH  = 32,
    parameter int PARITY_BITS = 6,
    parameter int CODE_WIDTH  = DATA_WIDTH + PARITY_BITS + 1
)(
    input  logic [CODE_WIDTH-1:0]  encoded_data,
    output logic [DATA_WIDTH-1:0]  corrected_data,
    output logic                   single_error,
    output logic                   double_error,
    output logic                   error_detected,
    output logic [PARITY_BITS-1:0] syndrome
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

    logic [DATA_WIDTH-1:0]  rx_data;
    logic [PARITY_BITS-1:0] rx_hamming;
    logic                   rx_overall;
    logic                   overall_calc;
    logic                   overall_err;

    assign rx_data    = encoded_data[DATA_WIDTH-1:0];
    assign rx_hamming = encoded_data[DATA_WIDTH +: PARITY_BITS];
    assign rx_overall = encoded_data[CODE_WIDTH-1];

    always_comb begin
        for (int i = 0; i < PARITY_BITS; i++) begin
            logic s_bit;
            s_bit = rx_hamming[i];
            for (int d = 0; d < DATA_WIDTH; d++) begin
                if (((get_data_col(d) >> i) & 1) != 0) begin
                    s_bit = s_bit ^ rx_data[d];
                end
            end
            syndrome[i] = s_bit;
        end
        overall_calc = (^rx_data) ^ (^rx_hamming);
        overall_err  = overall_calc ^ rx_overall;

        single_error   = 1'b0;
        double_error   = 1'b0;
        error_detected = 1'b0;
        corrected_data = rx_data;

        if (syndrome == '0 && overall_err == 1'b0) begin
            // Condition: No Error
            single_error   = 1'b0;
            double_error   = 1'b0;
            error_detected = 1'b0;
            corrected_data = rx_data;
        end else if (overall_err == 1'b1) begin
            // Condition: Single-Bit Error
            single_error   = 1'b1;
            double_error   = 1'b0;
            error_detected = 1'b1;

            if (syndrome == '0) begin
                // Error was in the overall parity bit itself -> data is clean
                corrected_data = rx_data;
            end else begin
                // Check if syndrome matches any data bit column
                for (int d = 0; d < DATA_WIDTH; d++) begin
                    logic [PARITY_BITS-1:0] col_pattern;
                    col_pattern = get_data_col(d);
                    if (syndrome == col_pattern) begin
                        corrected_data[d] = ~rx_data[d]; // Correct single bit flip
                    end
                end

            end
        end else begin
            single_error   = 1'b0;
            double_error   = 1'b1;
            error_detected = 1'b1;
        end
    end

endmodule
