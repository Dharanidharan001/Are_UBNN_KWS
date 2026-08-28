`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "transaction.sv"

class Scoreboard;
    int match_count;
    int mismatch_count;

    function new();
        match_count = 0;
        mismatch_count = 0;
    endfunction

    function void reset_stats();
        match_count = 0;
        mismatch_count = 0;
    endfunction

    function void check_popcount(input transaction_t tr, input logic [4:0] actual_count);
        if ($isunknown(actual_count)) begin
            $display("[SCB ERROR] Popcount output contains X or Z: in=16'h%04x actual=%b", tr.popcount_in, actual_count);
            mismatch_count = mismatch_count + 1;
        end else if (actual_count === tr.expected_popcount) begin
            match_count = match_count + 1;
        end else begin
            $display("[SCB MISMATCH] Popcount in=16'h%04x | Expected=%0d, Got=%0d",
                     tr.popcount_in, tr.expected_popcount, actual_count);
            mismatch_count = mismatch_count + 1;
        end
    endfunction

    function void check_pe(
        input logic [15:0] act,
        input logic [15:0] weight,
        input logic        en,
        input logic [4:0]  comb_sum,
        input logic [4:0]  reg_sum,
        input logic [4:0]  prev_reg_sum
    );
        logic [4:0] expected;
        expected = calc_popcount16(act & weight);

        if ($isunknown(comb_sum) || $isunknown(reg_sum)) begin
            $display("[SCB ERROR] PE output contains X or Z: comb=%b reg=%b", comb_sum, reg_sum);
            mismatch_count = mismatch_count + 1;
            return;
        end

        if (comb_sum === expected) begin
            match_count = match_count + 1;
        end else begin
            $display("[SCB MISMATCH] PE comb sum mismatch! act=%h weight=%h exp=%0d got=%0d",
                     act, weight, expected, comb_sum);
            mismatch_count = mismatch_count + 1;
        end

        if (en) begin
            if (reg_sum === expected) begin
                match_count = match_count + 1;
            end else begin
                $display("[SCB MISMATCH] PE reg sum mismatch when enabled! exp=%0d got=%0d", expected, reg_sum);
                mismatch_count = mismatch_count + 1;
            end
        end else begin

            if (reg_sum === prev_reg_sum) begin
                match_count = match_count + 1;
            end else begin
                $display("[SCB MISMATCH] PE clock gating failed! Register changed when disabled: prev=%0d got=%0d",
                         prev_reg_sum, reg_sum);
                mismatch_count = mismatch_count + 1;
            end
        end
    endfunction

    function void check_secded(
        input logic [15:0] orig_data,
        input logic [15:0] corrected_data,
        input logic        single_err,
        input logic        double_err,
        input logic        exp_single_err,
        input logic        exp_double_err,
        input string       test_case_desc
    );
        if ($isunknown(corrected_data) || $isunknown(single_err) || $isunknown(double_err)) begin
            $display("[SCB ERROR] SECDED output contains X/Z! data=%b s_err=%b d_err=%b",
                     corrected_data, single_err, double_err);
            mismatch_count = mismatch_count + 1;
            return;
        end

        if (single_err === exp_single_err) begin
            match_count = match_count + 1;
        end else begin
            $display("[SCB MISMATCH] [%s] single_error_corrected mismatch! Exp=%b, Got=%b",
                     test_case_desc, exp_single_err, single_err);
            mismatch_count = mismatch_count + 1;
        end

        if (double_err === exp_double_err) begin
            match_count = match_count + 1;
        end else begin
            $display("[SCB MISMATCH] [%s] double_error_detected mismatch! Exp=%b, Got=%b",
                     test_case_desc, exp_double_err, double_err);
            mismatch_count = mismatch_count + 1;
        end

        if (!exp_double_err) begin
            if (corrected_data === orig_data) begin
                match_count = match_count + 1;
            end else begin
                $display("[SCB MISMATCH] [%s] Data correction failed! Orig=16'h%04x, Got=16'h%04x",
                         test_case_desc, orig_data, corrected_data);
                mismatch_count = mismatch_count + 1;
            end
        end
    endfunction

    function void check_inference(
        input transaction_t tr,
        input logic         actual_kws,
        input logic [7:0]   actual_acc,
        input logic [15:0]  actual_pe_en,
        input logic         actual_sec,
        input logic         actual_ded,
        input logic [79:0]  actual_pe_results,
        input string        test_name
    );
        integer i;
        integer total_golden_sum;
        logic [15:0] exp_pe_en;
        logic [4:0]  exp_pe_res [15:0];
        logic [7:0]  exp_acc;
        logic        exp_kws;
        logic        exp_sec;
        logic        exp_ded;
        logic [15:0] act_i, w_i;
        logic [4:0]  pe_res_i;
        logic        is_double_fault;

        total_golden_sum = 0;
        is_double_fault = tr.fault_en && tr.fault_double;
        exp_sec = tr.fault_en && (!tr.fault_double);
        exp_ded = tr.fault_en && tr.fault_double;

        if ($isunknown(actual_kws) || $isunknown(actual_acc) || $isunknown(actual_pe_en) ||
            $isunknown(actual_sec) || $isunknown(actual_ded)) begin
            $display("[SCB ERROR] [%s] Unknown/X value observed! kws=%b acc=%b pe_en=%b sec=%b ded=%b",
                     test_name, actual_kws, actual_acc, actual_pe_en, actual_sec, actual_ded);
            mismatch_count = mismatch_count + 1;
            return;
        end

        for (i = 0; i < 16; i = i + 1) begin
            act_i = get_pe_word(tr.activations, i);
            w_i   = get_pe_word(tr.weights, i);
            exp_pe_en[i] = (|act_i);
            exp_pe_res[i] = calc_popcount16(act_i & w_i);

            if (exp_pe_en[i]) begin
                total_golden_sum = total_golden_sum + exp_pe_res[i];
            end

            pe_res_i = get_pe_res(actual_pe_results, i);
            if (exp_pe_en[i] && !(is_double_fault && (i == tr.fault_pe))) begin
                if (pe_res_i === exp_pe_res[i]) begin
                    match_count = match_count + 1;
                end else begin
                    $display("[SCB MISMATCH] [%s] PE%0d result mismatch! Exp=%0d, Got=%0d",
                             test_name, i, exp_pe_res[i], pe_res_i);
                    mismatch_count = mismatch_count + 1;
                end
            end
        end

        if (actual_pe_en === exp_pe_en) begin
            match_count = match_count + 1;
        end else begin
            $display("[SCB MISMATCH] [%s] PE Enable vector mismatch! Exp=16'b%b, Got=16'b%b",
                     test_name, exp_pe_en, actual_pe_en);
            mismatch_count = mismatch_count + 1;
        end

        if (actual_sec === exp_sec && actual_ded === exp_ded) begin
            match_count = match_count + 1;
        end else begin
            $display("[SCB MISMATCH] [%s] SECDED flags mismatch! Exp(SEC=%b, DED=%b), Got(SEC=%b, DED=%b)",
                     test_name, exp_sec, exp_ded, actual_sec, actual_ded);
            mismatch_count = mismatch_count + 1;
        end

        if (!is_double_fault) begin
            if (total_golden_sum > 255) exp_acc = 8'hFF;
            else exp_acc = total_golden_sum[7:0];

            if (actual_acc === exp_acc) begin
                match_count = match_count + 1;
            end else begin
                $display("[SCB MISMATCH] [%s] Accumulator value mismatch! Exp=%0d, Got=%0d",
                         test_name, exp_acc, actual_acc);
                mismatch_count = mismatch_count + 1;
            end

            exp_kws = (exp_acc >= tr.threshold);
            if (actual_kws === exp_kws) begin
                match_count = match_count + 1;
            end else begin
                $display("[SCB MISMATCH] [%s] KWS output mismatch! Exp=%b, Got=%b (Acc=%0d, Thresh=%0d)",
                         test_name, exp_kws, actual_kws, exp_acc, tr.threshold);
                mismatch_count = mismatch_count + 1;
            end
        end
    endfunction

    function void report(string block_name = "BLOCK");
        $display("\n========================================================");
        $display("   VERIFICATION SUMMARY: %s", block_name);
        $display("========================================================");
        $display(" Total Assertions Tested: %0d", match_count + mismatch_count);
        $display(" Passed Matches         : %0d", match_count);
        $display(" Detected Mismatches    : %0d", mismatch_count);
        if (mismatch_count == 0 && match_count > 0) begin
            $display(" STATUS: [PASS] All assertions verified successfully.");
        end else begin
            $display(" STATUS: [FAIL] Verification detected errors.");
        end
        $display("========================================================\n");
    endfunction
endclass

`endif
