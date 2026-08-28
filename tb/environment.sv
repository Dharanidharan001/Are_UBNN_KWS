//=============================================================================
// Project: ARe-UBNN-KWS
// File:    tb/environment.sv
// Description:
//   Verification Environment wiring together Generator, Driver, Monitor,
//   and Scoreboard to execute all verification suites.
//=============================================================================

`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

task automatic env_run_popcount(output Scoreboard scb_out);
    transaction_t tr;
    integer total_tests;
    integer t_idx;
    logic [4:0] actual_count;
    Scoreboard scb;
    begin
        scb = new();
        $display("[ENV] Initializing Popcount Test Environment...");
        drv_reset();

        total_tests = get_popcount_test_count();
        $display("[ENV] Generating and executing %0d popcount test vectors...", total_tests);

        for (t_idx = 0; t_idx < total_tests; t_idx = t_idx + 1) begin
            gen_popcount_test(t_idx, tr);
            drv_popcount(tr);
            mon_sample_popcount(actual_count);
            scb.check_popcount(tr, actual_count);
        end

        scb.report("POPCOUNT-16 UNIT");
        scb_out = scb;
    end
endtask

task automatic env_run_pe(output Scoreboard scb_out);
    Scoreboard scb;
    integer i;
    logic [15:0] test_acts [7:0];
    logic [15:0] test_weights [7:0];
    logic        test_ens [7:0];
    logic [4:0]  prev_reg;
    begin
        scb = new();
        $display("[ENV] Initializing Unipolar PE Verification...");
        drv_reset();

        test_acts[0] = 16'h0000; test_weights[0] = 16'hFFFF; test_ens[0] = 1'b1;
        test_acts[1] = 16'hFFFF; test_weights[1] = 16'hFFFF; test_ens[1] = 1'b1;
        test_acts[2] = 16'hAAAA; test_weights[2] = 16'h5555; test_ens[2] = 1'b1;
        test_acts[3] = 16'hAAAA; test_weights[3] = 16'hAAAA; test_ens[3] = 1'b1;
        test_acts[4] = 16'hF0F0; test_weights[4] = 16'h3333; test_ens[4] = 1'b1;
        // Test gating: en = 0 with changing inputs
        test_acts[5] = 16'hFFFF; test_weights[5] = 16'hFFFF; test_ens[5] = 1'b0;
        test_acts[6] = 16'h1234; test_weights[6] = 16'h5678; test_ens[6] = 1'b0;
        // Re-enable
        test_acts[7] = 16'h00FF; test_weights[7] = 16'h000F; test_ens[7] = 1'b1;

        for (i = 0; i < 8; i = i + 1) begin
            prev_reg = intf.pe_test_sum;
            @(posedge intf.clk);
            intf.pe_test_act    <= test_acts[i];
            intf.pe_test_weight <= test_weights[i];
            intf.pe_test_en     <= test_ens[i];
            @(posedge intf.clk);
            #1; // Settling
            scb.check_pe(test_acts[i], test_weights[i], test_ens[i],
                         intf.pe_test_comb, intf.pe_test_sum, prev_reg);
        end

        scb.report("UNIPOLAR-PE UNIT");
        scb_out = scb;
    end
endtask

task automatic env_run_secded(output Scoreboard scb_out);
    Scoreboard scb;
    integer p, bit_pos;
    logic [15:0] patterns [3:0];
    logic [21:0] raw_cw;
    string desc;
    begin
        scb = new();
        $display("[ENV] Initializing SECDED Hamming (22, 16) Verification...");

        patterns[0] = 16'h1234;
        patterns[1] = 16'hAAAA;
        patterns[2] = 16'hFFFF;
        patterns[3] = 16'h55AA;

        for (p = 0; p < 4; p = p + 1) begin
            // 1. Clean test (No errors)
            intf.secded_test_data <= patterns[p];
            #1;
            raw_cw = intf.secded_test_raw_cw;
            intf.secded_test_corrupt_cw <= raw_cw;
            #1;
            $sformat(desc, "Pat_%0d_Clean", p);
            scb.check_secded(patterns[p], intf.secded_test_corrected,
                             intf.secded_test_single_err, intf.secded_test_double_err,
                             1'b0, 1'b0, desc);

            // 2. Exhaustive Single-bit error test for all 22 bit positions!
            for (bit_pos = 0; bit_pos < 22; bit_pos = bit_pos + 1) begin
                intf.secded_test_corrupt_cw <= raw_cw ^ (22'b1 << bit_pos);
                #1;
                $sformat(desc, "Pat_%0d_Bit_%0d_Fault", p, bit_pos);
                scb.check_secded(patterns[p], intf.secded_test_corrected,
                                 intf.secded_test_single_err, intf.secded_test_double_err,
                                 1'b1, 1'b0, desc);
            end

            // 3. Representative Double-bit error tests
            intf.secded_test_corrupt_cw <= raw_cw ^ (22'b1 << 0) ^ (22'b1 << 1);
            #1;
            $sformat(desc, "Pat_%0d_Double_Bit_0_1", p);
            scb.check_secded(patterns[p], intf.secded_test_corrected,
                             intf.secded_test_single_err, intf.secded_test_double_err,
                             1'b0, 1'b1, desc);

            intf.secded_test_corrupt_cw <= raw_cw ^ (22'b1 << 2) ^ (22'b1 << 4);
            #1;
            $sformat(desc, "Pat_%0d_Double_Bit_2_4", p);
            scb.check_secded(patterns[p], intf.secded_test_corrected,
                             intf.secded_test_single_err, intf.secded_test_double_err,
                             1'b0, 1'b1, desc);

            intf.secded_test_corrupt_cw <= raw_cw ^ (22'b1 << 5) ^ (22'b1 << 10);
            #1;
            $sformat(desc, "Pat_%0d_Double_Bit_5_10", p);
            scb.check_secded(patterns[p], intf.secded_test_corrected,
                             intf.secded_test_single_err, intf.secded_test_double_err,
                             1'b0, 1'b1, desc);

            intf.secded_test_corrupt_cw <= raw_cw ^ (22'b1 << 15) ^ (22'b1 << 21);
            #1;
            $sformat(desc, "Pat_%0d_Double_Bit_15_21", p);
            scb.check_secded(patterns[p], intf.secded_test_corrected,
                             intf.secded_test_single_err, intf.secded_test_double_err,
                             1'b0, 1'b1, desc);
        end

        scb.report("SECDED HAMMING (22, 16) CODEC");
        scb_out = scb;
    end
endtask

task automatic env_run_accelerator(output Scoreboard scb_out);
    Scoreboard scb;
    transaction_t tr;
    integer num_tests;
    integer t;
    string test_name;
    begin
        scb = new();
        $display("\n========================================================");
        $display("   STARTING FULL ACCELERATOR SYSTEM INFERENCE SUITE");
        $display("========================================================");
        drv_reset();

        num_tests = get_inference_test_count();

        for (t = 0; t < num_tests; t = t + 1) begin
            gen_inference_test(t, tr, test_name);
            $display("[ACCEL TEST %0d/%0d] Running: %s", t+1, num_tests, test_name);

            // Load weights into protected memory
            drv_load_all_weights(tr);

            // Run inference
            drv_run_inference(tr);

            // Verify with scoreboard
            scb.check_inference(
                tr,
                intf.kws_output,
                intf.accumulator_out,
                intf.pe_enable_out,
                intf.single_error_corrected_out,
                intf.double_error_detected_out,
                intf.pe_results_bus,
                test_name
            );

            // Display active telemetry for this test
            $display("  -> Active PEs: %0d/16 | Acc: %0d | Threshold: %0d | KWS: %b | SEC: %b | DED: %b",
                     intf.pe_active_count_out, intf.accumulator_out, intf.threshold_in,
                     intf.kws_output, intf.single_error_corrected_out, intf.double_error_detected_out);
        end

        scb.report("FULL ACCELERATOR SYSTEM");
        scb_out = scb;
    end
endtask

`endif // ENVIRONMENT_SV
