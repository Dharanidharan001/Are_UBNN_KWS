`timescale 1ns / 1ps

module popcount #(
    parameter int INPUT_WIDTH = 32,
    parameter int COUNT_WIDTH = $clog2(INPUT_WIDTH + 1)
)(
    input  logic [INPUT_WIDTH-1:0] in_vec,
    output logic [COUNT_WIDTH-1:0] count
);

    always_comb begin
        count = '0;
        for (int i = 0; i < INPUT_WIDTH; i++) begin
            count = count + {{(COUNT_WIDTH-1){1'b0}}, in_vec[i]};
        end
    end

endmodule
