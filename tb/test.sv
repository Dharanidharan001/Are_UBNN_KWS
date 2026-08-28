`ifndef TEST_SV
`define TEST_SV

`include "environment.sv"

task automatic test_popcount();
    Scoreboard scb;
    begin
        $display("\n========================================================");
        $display("   TEST: POPCOUNT-16 STANDALONE VERIFICATION");
        $display("========================================================");
        env_run_popcount(scb);

        if (scb.mismatch_count == 0 && scb.match_count > 0) begin
            $display("[TEST PASSED] popcount16 successfully verified against golden model.");
        end else begin
            $display("[TEST FAILED] popcount16 encountered %0d mismatches!", scb.mismatch_count);
            $fatal(1, "Popcount verification failure.");
        end
    end
endtask

task automatic test_unipolar_pe();
    Scoreboard scb;
    begin
        $display("\n========================================================");
        $display("   TEST: UNIPOLAR-PE STANDALONE VERIFICATION");
        $display("========================================================");
        env_run_pe(scb);

        if (scb.mismatch_count == 0 && scb.match_count > 0) begin
            $display("[TEST PASSED] unipolar_pe successfully verified against golden model.");
        end else begin
            $display("[TEST FAILED] unipolar_pe encountered %0d mismatches!", scb.mismatch_count);
            $fatal(1, "Unipolar PE verification failure.");
        end
    end
endtask

task automatic test_secded();
    Scoreboard scb;
    begin
        $display("\n========================================================");
        $display("   TEST: SECDED HAMMING (22, 16) CODEC VERIFICATION");
        $display("========================================================");
        env_run_secded(scb);

        if (scb.mismatch_count == 0 && scb.match_count > 0) begin
            $display("[TEST PASSED] SECDED successfully corrected all single-bit errors and detected all double-bit errors.");
        end else begin
            $display("[TEST FAILED] SECDED encountered %0d mismatches!", scb.mismatch_count);
            $fatal(1, "SECDED verification failure.");
        end
    end
endtask

task automatic test_accelerator_full();
    Scoreboard scb;
    begin
        $display("\n========================================================");
        $display("   TEST: FULL ARe-UBNN-KWS ACCELERATOR SYSTEM TEST");
        $display("========================================================");
        env_run_accelerator(scb);

        if (scb.mismatch_count == 0 && scb.match_count > 0) begin
            $display("[TEST PASSED] ARe-UBNN-KWS accelerator successfully verified across all scenarios.");
        end else begin
            $display("[TEST FAILED] Accelerator system test encountered %0d mismatches!", scb.mismatch_count);
            $fatal(1, "Full accelerator verification failure.");
        end
    end
endtask

`endif
