// =============================================================================
// tb_top.sv — Flat procedural testbench for ARe-UBNN-KWS
// Compatible with Icarus Verilog -g2012
// =============================================================================
`timescale 1ns/1ps

module tb_top;

    localparam int NUM_PES     = 16;
    localparam int VEC_WIDTH   = 16;

    // Clock
    logic clk;
    initial clk = 0;
    always #5 clk = ~clk;

    // DUT signals
    logic                         rst_n;
    logic [NUM_PES*VEC_WIDTH-1:0] activations_flat;
    logic [8:0]                   threshold;
    logic                         accum_en;
    logic                         wr_en;
    logic [3:0]                   wr_addr;
    logic [15:0]                  wr_data;
    logic [3:0]                   rd_addr;
    logic [NUM_PES*VEC_WIDTH-1:0] direct_weights_flat;
    logic                         fault_inject_en;
    logic [21:0]                  fault_mask;
    logic                         keyword_detected;
    logic [8:0]                   accumulated_sum;
    logic [15:0]                  pe_active;
    logic                         single_error_corrected;
    logic                         double_error_detected;
    logic                         accum_valid;

    // DUT
    are_ubnn_kws_top #(
        .NUM_PES(16),.VEC_WIDTH(16),.PE_RESULT_W(5),
        .ACCUM_W(9),.MEM_DEPTH(16),.MEM_ADDR_W(4),
        .ENABLE_ENHANCED(1)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .activations_flat(activations_flat),
        .threshold(threshold), .accum_en(accum_en),
        .wr_en(wr_en), .wr_addr(wr_addr), .wr_data(wr_data),
        .rd_addr(rd_addr),
        .direct_weights_flat(direct_weights_flat),
        .fault_inject_en(fault_inject_en), .fault_mask(fault_mask),
        .keyword_detected(keyword_detected),
        .accumulated_sum(accumulated_sum),
        .pe_active(pe_active),
        .single_error_corrected(single_error_corrected),
        .double_error_detected(double_error_detected),
        .accum_valid(accum_valid)
    );

    // VCD
    initial begin
        $dumpfile("outputs/simulation/enhanced_waveform.vcd");
        $dumpvars(0, tb_top);
    end

    // Scoreboard counters
    int total_tests  = 0;
    int passed_tests = 0;
    int failed_tests = 0;

    // Golden popcount
    function automatic int gpc(input logic [15:0] v);
        int c = 0;
        for (int b = 0; b < 16; b++) c += int'(v[b]);
        return c;
    endfunction

    // Golden accumulated sum
    // Activations and weight are passed as packed buses
    function automatic int golden_sum(
        input logic [NUM_PES*VEC_WIDTH-1:0] acts_flat,
        input logic [15:0]                  weight
    );
        int s = 0;
        for (int i = 0; i < NUM_PES; i++) begin
            logic [15:0] a;
            a = acts_flat[i*VEC_WIDTH +: VEC_WIDTH];
            if (|a) s += gpc(a & weight);
        end
        return s;
    endfunction

    // Apply reset
    task apply_reset();
        rst_n               = 1'b0;
        activations_flat    = '0;
        threshold           = 9'd8;
        accum_en            = 1'b0;
        wr_en               = 1'b0;
        wr_addr             = 4'd0;
        wr_data             = 16'd0;
        rd_addr             = 4'd0;
        direct_weights_flat = '0;
        fault_inject_en     = 1'b0;
        fault_mask          = '0;
        repeat(4) @(posedge clk); #1;
        rst_n = 1'b1;
        @(posedge clk); #1;
        $display("[TB] Reset complete.");
    endtask

    // Run one inference test
    // acts_flat: packed activation bus (16 x 16-bit)
    // weight   : 16-bit weight
    // thr      : threshold
    // inj      : inject fault
    // fb1,fb2  : fault bits (-1 = unused)
    // tname    : test name string
    task run_test(
        input logic [NUM_PES*VEC_WIDTH-1:0] acts_flat,
        input logic [15:0]                  weight,
        input logic [8:0]                   thr,
        input bit                           inj,
        input int                           fb1,
        input int                           fb2,
        input string                        tname
    );
        logic [NUM_PES*VEC_WIDTH-1:0] flat_w;
        logic [21:0] fmask;
        int          exp_sum;
        bit          exp_kw;
        bit          pass;
        // Captured outputs
        logic [8:0]  cap_sum;
        logic [15:0] cap_pe_active;
        logic        cap_sec;
        logic        cap_ded;
        logic        cap_kw;

        // ---- Mini-reset to clear PE registers ----
        // This ensures each test starts from a known state
        rst_n = 1'b0;
        activations_flat = '0;  // clear inputs so we don't latch old data!
        direct_weights_flat = '0;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst_n = 1'b1;
        @(posedge clk); #1;

        // Pack weight bus
        flat_w = '0;
        for (int i = 0; i < NUM_PES; i++)
            flat_w[i*VEC_WIDTH +: VEC_WIDTH] = weight;

        // Write weight to memory (after reset)
        @(posedge clk); #1;
        wr_en   = 1'b1;
        wr_addr = 4'd0;
        wr_data = weight;
        @(posedge clk); #1;
        wr_en   = 1'b0;

        // Set up inputs
        rd_addr             = 4'd0;
        activations_flat    = acts_flat;
        direct_weights_flat = flat_w;
        threshold           = thr;

        // Fault injection
        fmask = 22'd0;
        if (inj) begin
            if (fb1 >= 0 && fb1 <= 21) fmask[fb1] = 1'b1;
            if (fb2 >= 0 && fb2 <= 21) fmask[fb2] = 1'b1;
            fault_inject_en = 1'b1;
            fault_mask      = fmask;
        end else begin
            fault_inject_en = 1'b0;
            fault_mask      = '0;
        end

        // Wait for PE combinational logic to settle (1 cycle after inputs)
        @(posedge clk); #1;

        // Capture PE activity (combinational signal, valid now)
        cap_pe_active = pe_active;
        cap_sec       = single_error_corrected;
        cap_ded       = double_error_detected;

        // Pulse accumulator enable — PE results register was clocked on the
        // previous posedge, so pe_results_flat is stable now
        accum_en = 1'b1;
        @(posedge clk); #1;
        
        // At this point, the accumulator has registered the sum and valid_out is high.
        // Combinational logic in threshold_unit now computes keyword_detected.
        accum_en = 1'b0;
        
        // Wait a tiny bit for combinational threshold logic to settle in the same cycle
        #1;
        cap_sum = accumulated_sum;
        cap_kw  = keyword_detected;

        @(posedge clk); #1;   // move to the next cycle where valid_out clears

        // Clear fault injection
        fault_inject_en = 1'b0;
        fault_mask      = '0;

        @(posedge clk); #1;  // settling gap before next test

        // --- Scoreboard ---
        total_tests++;
        pass = 1'b1;

        if (inj && fb2 >= 0) begin
            // Double-bit fault: check DED
            if (!cap_ded) begin
                $display("[FAIL] %s: Expected DED=1 got 0", tname);
                pass = 1'b0;
            end
        end else begin
            exp_sum = golden_sum(acts_flat, weight);
            exp_kw  = (exp_sum >= int'(thr));

            if (cap_kw !== exp_kw) begin
                $display("[FAIL] %s: kw exp=%0b act=%0b sum=%0d exp_sum=%0d thr=%0d",
                    tname, exp_kw, cap_kw, cap_sum, exp_sum, thr);
                pass = 1'b0;
            end
            if (int'(cap_sum) !== exp_sum) begin
                $display("[FAIL] %s: sum exp=%0d act=%0d",
                    tname, exp_sum, cap_sum);
                pass = 1'b0;
            end
            if (inj && fb2 < 0) begin
                if (!cap_sec) begin
                    $display("[FAIL] %s: Expected SEC=1 got 0", tname);
                    pass = 1'b0;
                end
            end
        end

        // PE activity checks
        if (tname == "T2_zero_activation_PE0") begin
            if (cap_pe_active[0] !== 1'b0) begin
                $display("[FAIL] %s: pe_active[0] exp=0 got=%0b", tname, cap_pe_active[0]);
                pass = 1'b0;
            end
        end
        if (tname == "T3_nonzero_activation_PE0") begin
            if (cap_pe_active[0] !== 1'b1) begin
                $display("[FAIL] %s: pe_active[0] exp=1 got=%0b", tname, cap_pe_active[0]);
                pass = 1'b0;
            end
        end

        if (pass) begin
            $display("[PASS] %s  sum=%0d kw=%0b SEC=%0b DED=%0b pe_act=0x%04h",
                tname, cap_sum, cap_kw,
                cap_sec, cap_ded, cap_pe_active);
            passed_tests++;
        end else
            failed_tests++;
    endtask

    // Test activation builder: all same value
    function automatic logic [NUM_PES*VEC_WIDTH-1:0] all_act(logic [15:0] v);
        logic [NUM_PES*VEC_WIDTH-1:0] f;
        for (int i = 0; i < NUM_PES; i++) f[i*VEC_WIDTH +: VEC_WIDTH] = v;
        return f;
    endfunction

    // Test activation builder: each PE gets individual value from a 16-element arg
    // (not used directly — we build inline)

    // Main test sequence
    logic [NUM_PES*VEC_WIDTH-1:0] acts;
    logic [15:0]                  rw;
    logic [8:0]                   rthr;

    initial begin
        $display("============================================================");
        $display("  ARe-UBNN-KWS Verification  %0t", $time);
        $display("============================================================");
        apply_reset();

        // T1: Normal inference
        acts = all_act(16'hA5A5);
        run_test(acts, 16'hA5A5, 9'd10, 0, -1, -1, "T1_normal_inference");

        // T2: All-zero activation PE0
        acts = all_act(16'hFFFF);
        acts[0*VEC_WIDTH +: VEC_WIDTH] = 16'h0000;
        run_test(acts, 16'hFFFF, 9'd5, 0, -1, -1, "T2_zero_activation_PE0");

        // T3: Non-zero activation PE0 only
        acts = all_act(16'h0000);
        acts[0*VEC_WIDTH +: VEC_WIDTH] = 16'h0001;
        run_test(acts, 16'hFFFF, 9'd1, 0, -1, -1, "T3_nonzero_activation_PE0");

        // T4: Exhaustive Single-bit fault (test all 22 bits)
        acts = all_act(16'hFFFF);
        for (int b = 0; b < 22; b++) begin
            string tname;
            tname = $sformatf("T4_single_bit_fault_bit_%0d", b);
            run_test(acts, 16'hAAAA, 9'd5, 1, b, -1, tname);
        end

        // T5: Double-bit fault
        acts = all_act(16'hFFFF);
        run_test(acts, 16'hAAAA, 9'd5, 1, 3, 7, "T5_double_bit_fault");

        // T6: Mixed sparse (PE0..7 active, PE8..15 inactive)
        acts = '0;
        for (int i = 0; i < 8; i++)  acts[i*VEC_WIDTH +: VEC_WIDTH] = 16'hFFFF;
        for (int i = 8; i < 16; i++) acts[i*VEC_WIDTH +: VEC_WIDTH] = 16'h0000;
        run_test(acts, 16'hFFFF, 9'd50, 0, -1, -1, "T6_mixed_sparse");

        // T7: Single-bit fault during active inference
        acts = all_act(16'h5555);
        run_test(acts, 16'h5555, 9'd8, 1, 10, -1, "T7_fault_during_inference");

        // T8: Sparse + single-bit fault
        acts = '0;
        for (int i = 0; i < 16; i++)
            acts[i*VEC_WIDTH +: VEC_WIDTH] = (i % 2 == 0) ? 16'hF0F0 : 16'h0000;
        run_test(acts, 16'hF0F0, 9'd20, 1, 5, -1, "T8_sparse_plus_fault");

        // T9a: All ones
        acts = all_act(16'hFFFF);
        run_test(acts, 16'hFFFF, 9'd200, 0, -1, -1, "T9a_all_ones");

        // T9b: All zeros
        acts = all_act(16'h0000);
        run_test(acts, 16'h0000, 9'd1, 0, -1, -1, "T9b_all_zeros");

        // T9c: Zero threshold
        acts = all_act(16'h0000);
        run_test(acts, 16'hFFFF, 9'd0, 0, -1, -1, "T9c_zero_threshold");

        // T10: Random regression (10 tests, fixed seed=42)
        begin
            integer rseed;
            int r;
            string rname;
            rseed = 42;
            rseed = $urandom(rseed);  // seed the PRNG with integer register
            for (r = 0; r < 10; r++) begin
                for (int i = 0; i < 16; i++)
                    acts[i*VEC_WIDTH +: VEC_WIDTH] = $urandom();
                rw   = $urandom();
                rthr = 9'($urandom_range(1, 100));
                rname = $sformatf("T10_random_%0d", r);
                run_test(acts, rw, rthr, 0, -1, -1, rname);
            end
        end



        // Final report
        $display("");
        $display("================================================");
        $display("  ARe-UBNN-KWS VERIFICATION SUMMARY");
        $display("  TOTAL  : %0d", total_tests);
        $display("  PASSED : %0d", passed_tests);
        $display("  FAILED : %0d", failed_tests);
        $display("================================================");
        if (failed_tests == 0)
            $display("  *** ALL TESTS PASSED ***");
        else
            $display("  *** %0d TEST(S) FAILED ***", failed_tests);
        $display("================================================");
        $display("[TB] Done at %0t ns", $time);
        $finish;
    end

    initial begin #5000000; $display("[TB] TIMEOUT"); $finish; end

endmodule