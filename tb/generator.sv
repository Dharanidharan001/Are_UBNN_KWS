//=============================================================================
// Project: ARe-UBNN-KWS
// File:    tb/generator.sv
// Description:
//   Comprehensive transaction generator creating unit test vectors for
//   popcount and system-level test scenarios for the ARe-UBNN-KWS accelerator.
//=============================================================================

`ifndef GENERATOR_SV
`define GENERATOR_SV

`include "transaction.sv"

function automatic integer get_popcount_test_count();
    get_popcount_test_count = 56;
endfunction

task automatic gen_popcount_test(
    input  integer       idx,
    output transaction_t tr
);
    logic [15:0] vec;
    begin
        tr.mode                  = MODE_POPCOUNT;
        tr.weights               = 256'd0;
        tr.activations           = 256'd0;
        tr.threshold             = 8'd0;
        tr.fault_en              = 1'b0;
        tr.fault_pe              = 4'd0;
        tr.fault_bit1            = 5'd0;
        tr.fault_bit2            = 5'd0;
        tr.fault_double          = 1'b0;
        tr.expected_pe_result    = 80'd0;
        tr.expected_pe_enable    = 16'd0;
        tr.expected_accumulator  = 8'd0;
        tr.expected_kws_output   = 1'b0;
        tr.expected_single_error = 1'b0;
        tr.expected_double_error = 1'b0;

        case (idx)
            0: vec = 16'h0000; // All zeros -> 0
            1: vec = 16'hFFFF; // All ones  -> 16
            2: vec = 16'hAAAA; // Alternating 1010_1010_1010_1010 -> 8
            3: vec = 16'hF0F0; // Nibble alternating 1111_0000_1111_0000 -> 8
            default: begin
                if (idx >= 4 && idx < 20) begin
                    vec = (16'h0001 << (idx - 4));
                end else if (idx >= 20 && idx < 36) begin
                    vec = ~(16'h0001 << (idx - 20));
                end else begin
                    vec = $urandom();
                end
            end
        endcase

        tr.popcount_in = vec;
        tr.expected_popcount = calc_popcount16(vec);
    end
endtask

function automatic integer get_inference_test_count();
    get_inference_test_count = 8;
endfunction

task automatic gen_inference_test(
    input  integer       test_idx,
    output transaction_t tr,
    output string        test_name
);
    integer i;
    logic [15:0] w_arr [15:0];
    logic [15:0] a_arr [15:0];
    begin
        // Default clean values
        tr.popcount_in         = 16'd0;
        tr.expected_popcount   = 5'd0;
        tr.threshold           = 8'd32;
        tr.fault_en            = 1'b0;
        tr.fault_pe            = 4'd0;
        tr.fault_bit1          = 5'd0;
        tr.fault_bit2          = 5'd0;
        tr.fault_double        = 1'b0;

        // Default weights and activations
        for (i = 0; i < 16; i = i + 1) begin
            w_arr[i] = 16'hA500 ^ (i << 8) ^ (i * 16'h1111);
            a_arr[i] = 16'h0000;
        end

        case (test_idx)
            0: begin
                // 1. NORMAL INFERENCE
                test_name = "NORMAL_INFERENCE";
                tr.mode = MODE_NORMAL;
                tr.threshold = 8'd40;
                for (i = 0; i < 16; i = i + 1) begin
                    a_arr[i] = 16'h5555 ^ (i * 16'h0101);
                end
            end

            1: begin
                // 2. ALL_ZERO_ACTIVATION
                test_name = "ALL_ZERO_ACTIVATION";
                tr.mode = MODE_ALL_ZERO;
                tr.threshold = 8'd10;
                for (i = 0; i < 16; i = i + 1) begin
                    a_arr[i] = 16'h0000; // All PEs must be gated!
                end
            end

            2: begin
                // 3. SPARSE_ACTIVATION
                test_name = "SPARSE_ACTIVATION";
                tr.mode = MODE_SPARSE;
                tr.threshold = 8'd16;
                for (i = 0; i < 16; i = i + 1) a_arr[i] = 16'h0000;
                // Only PEs 0, 4, 8, 12 active
                a_arr[0]  = 16'hFFFF;
                a_arr[4]  = 16'hAAAA;
                a_arr[8]  = 16'hF0F0;
                a_arr[12] = 16'h00FF;
            end

            3: begin
                // 4. DENSE_ACTIVATION
                test_name = "DENSE_ACTIVATION";
                tr.mode = MODE_DENSE;
                tr.threshold = 8'd100;
                for (i = 0; i < 16; i = i + 1) begin
                    a_arr[i] = 16'hFFFF; // All bits 1
                end
            end

            4: begin
                // 5. SINGLE_BIT_WEIGHT_FAULT
                test_name = "SINGLE_BIT_WEIGHT_FAULT";
                tr.mode = MODE_SINGLE_FAULT;
                tr.threshold = 8'd30;
                for (i = 0; i < 16; i = i + 1) begin
                    a_arr[i] = 16'h0F0F;
                end
                // Inject fault in PE 3, bit 6 (data bit d3)
                tr.fault_en   = 1'b1;
                tr.fault_pe   = 4'd3;
                tr.fault_bit1 = 5'd6;
            end

            5: begin
                // 6. DOUBLE_BIT_WEIGHT_FAULT
                test_name = "DOUBLE_BIT_WEIGHT_FAULT";
                tr.mode = MODE_DOUBLE_FAULT;
                tr.threshold = 8'd30;
                for (i = 0; i < 16; i = i + 1) begin
                    a_arr[i] = 16'h0F0F;
                end
                // Inject double fault in PE 7, bits 2 and 4
                tr.fault_en     = 1'b1;
                tr.fault_pe     = 4'd7;
                tr.fault_bit1   = 5'd2;
                tr.fault_bit2   = 5'd4;
                tr.fault_double = 1'b1;
            end

            6: begin
                // 7. MANDATORY DEMONSTRATION TEST: FAULT + SPARSE (Section 29)
                test_name = "FAULT_PLUS_SPARSE";
                tr.mode = MODE_FAULT_SPARSE;
                tr.threshold = 8'd10;
                for (i = 0; i < 16; i = i + 1) a_arr[i] = 16'h0000;
                // PE0 = 0 (gated)
                a_arr[0] = 16'h0000;
                // PE1 = nonzero (active)
                a_arr[1] = 16'hABCD;
                // PE2 = 0 (gated)
                a_arr[2] = 16'h0000;
                // PE3 = nonzero (active)
                a_arr[3] = 16'h1234;
                // Other PEs mixed
                a_arr[5] = 16'hFFFF;
                a_arr[9] = 16'h5555;

                // Inject single-bit fault into PE1 weight codeword (bit 8 = data bit d4)
                tr.fault_en   = 1'b1;
                tr.fault_pe   = 4'd1;
                tr.fault_bit1 = 5'd8;
            end

            default: begin
                // 8. MULTIPLE_PE_MIXED_SPARSITY
                test_name = "MULTIPLE_PE_MIXED_SPARSITY";
                tr.mode = MODE_RANDOM;
                tr.threshold = 8'd45;
                for (i = 0; i < 16; i = i + 1) begin
                    if (i % 2 == 0) begin
                        a_arr[i] = 16'h0000; // Gated
                    end else begin
                        a_arr[i] = 16'hF0F0 ^ (i * 16'h0202); // Active
                    end
                end
            end
        endcase

        // Concatenate array to full 256-bit buses
        tr.weights = {
            w_arr[15], w_arr[14], w_arr[13], w_arr[12],
            w_arr[11], w_arr[10], w_arr[9],  w_arr[8],
            w_arr[7],  w_arr[6],  w_arr[5],  w_arr[4],
            w_arr[3],  w_arr[2],  w_arr[1],  w_arr[0]
        };

        tr.activations = {
            a_arr[15], a_arr[14], a_arr[13], a_arr[12],
            a_arr[11], a_arr[10], a_arr[9],  a_arr[8],
            a_arr[7],  a_arr[6],  a_arr[5],  a_arr[4],
            a_arr[3],  a_arr[2],  a_arr[1],  a_arr[0]
        };
    end
endtask

`endif // GENERATOR_SV
