// bnn_scoreboard.sv — Golden model comparison
`ifndef BNN_SCOREBOARD_SV
`define BNN_SCOREBOARD_SV
`include "bnn_transaction.sv"

class bnn_scoreboard;
    mailbox drv_to_scb;
    mailbox mon_to_scb;
    int total_tests  = 0;
    int passed_tests = 0;
    int failed_tests = 0;

    function new(mailbox drv_mb, mailbox mon_mb);
        drv_to_scb = drv_mb;
        mon_to_scb = mon_mb;
    endfunction

    // Golden popcount for 16-bit word
    function automatic int golden_popcount(logic [15:0] v);
        int cnt = 0;
        for (int b = 0; b < 16; b++) cnt += int'(v[b]);
        return cnt;
    endfunction

    // Golden accumulated sum: sum popcount(act[i] & weight) for active PEs
    function automatic int golden_sum(
        logic [15:0] activation[16],
        logic [15:0] weight
    );
        int s = 0;
        for (int i = 0; i < 16; i++) begin
            if (|activation[i])  // PE is active if any activation bit is set
                s += golden_popcount(activation[i] & weight);
        end
        return s;
    endfunction

    task check(bnn_transaction stim, bnn_transaction obs);
        int  exp_sum;
        bit  exp_kw;
        bit  pass = 1'b1;
        total_tests++;

        if (stim.inject_fault && stim.fault_bit2 >= 0) begin
            // Double-bit fault: only check DED flag
            if (!obs.observed_ded) begin
                $display("[FAIL] %s: Expected DED=1 got 0", stim.test_name);
                pass = 1'b0;
            end
        end else begin
            // Normal or single-bit fault
            exp_sum = golden_sum(stim.activation, stim.weight_data);
            exp_kw  = (exp_sum >= int'(stim.threshold));

            if (obs.observed_keyword !== exp_kw) begin
                $display("[FAIL] %s: kw expected=%0b actual=%0b (sum=%0d exp_sum=%0d thr=%0d)",
                    stim.test_name, exp_kw, obs.observed_keyword,
                    obs.observed_sum, exp_sum, stim.threshold);
                pass = 1'b0;
            end
            if (int'(obs.observed_sum) !== exp_sum) begin
                $display("[FAIL] %s: sum expected=%0d actual=%0d",
                    stim.test_name, exp_sum, obs.observed_sum);
                pass = 1'b0;
            end
            if (stim.inject_fault && stim.fault_bit2 < 0) begin
                if (!obs.observed_sec) begin
                    $display("[FAIL] %s: Expected SEC=1 got 0", stim.test_name);
                    pass = 1'b0;
                end
            end
        end

        // PE activity checks
        if (stim.test_name == "T2_zero_activation_PE0") begin
            if (obs.observed_pe_active[0] !== 1'b0) begin
                $display("[FAIL] %s: pe_active[0] expected=0 got=%0b",
                    stim.test_name, obs.observed_pe_active[0]);
                pass = 1'b0;
            end
        end
        if (stim.test_name == "T3_nonzero_activation_PE0") begin
            if (obs.observed_pe_active[0] !== 1'b1) begin
                $display("[FAIL] %s: pe_active[0] expected=1 got=%0b",
                    stim.test_name, obs.observed_pe_active[0]);
                pass = 1'b0;
            end
        end

        if (pass) begin
            $display("[PASS] %s", stim.test_name);
            passed_tests++;
        end else
            failed_tests++;
    endtask

    task run();
        bnn_transaction stim, obs;
        forever begin
            drv_to_scb.get(stim);
            mon_to_scb.get(obs);
            check(stim, obs);
        end
    endtask

    function void report();
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
    endfunction
endclass
`endif