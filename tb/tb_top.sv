`timescale 1ns/1ps

`include "interface.sv"

module tb_top;

    logic clk;
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    are_ubnn_kws_if intf (clk);

    popcount16 u_popcount16 (
        .in_data (intf.popcount_in),
        .count   (intf.popcount_out)
    );

    unipolar_pe u_pe_inst (
        .clk         (clk),
        .rst_n       (intf.rst_n),
        .en          (intf.pe_test_en),
        .activation  (intf.pe_test_act),
        .weight      (intf.pe_test_weight),
        .partial_sum (intf.pe_test_sum),
        .comb_sum    (intf.pe_test_comb)
    );

    secded_encoder u_secded_enc (
        .data_in      (intf.secded_test_data),
        .codeword_out (intf.secded_test_raw_cw)
    );

    secded_decoder u_secded_dec (
        .codeword_in            (intf.secded_test_corrupt_cw),
        .corrected_data         (intf.secded_test_corrected),
        .single_error_corrected (intf.secded_test_single_err),
        .double_error_detected  (intf.secded_test_double_err),
        .ecc_syndrome           (intf.secded_test_syndrome)
    );

    are_ubnn_kws_top u_accel_top (
        .clk                    (clk),
        .rst_n                  (intf.rst_n),
        .start_inference        (intf.start_inference),
        .load_weight            (intf.load_weight),
        .weight_pe_sel          (intf.pe_sel),
        .weight_data_in         (intf.weight_in),
        .activations_in         (intf.activations_bus),
        .threshold_in           (intf.threshold_in),
        .bypass_clock_gating    (intf.bypass_clock_gating),
        .test_en                (intf.test_en),
        .fault_inject_en        (intf.fault_inject_en),
        .fault_pe_sel           (intf.fault_pe_sel),
        .fault_bit1             (intf.fault_bit1),
        .fault_bit2             (intf.fault_bit2),
        .fault_is_double        (intf.fault_is_double),
        .busy                   (intf.busy),
        .done                   (intf.done),
        .kws_output             (intf.kws_output),
        .accumulator_val        (intf.accumulator_out),
        .frame_sum              (intf.frame_sum_out),
        .pe_enable              (intf.pe_enable_out),
        .pe_gated_clocks        (intf.pe_gated_clocks_out),
        .pe_active_count        (intf.pe_active_count_out),
        .pe_results             (intf.pe_results_bus),
        .pe_comb_results        (intf.pe_comb_bus),
        .single_error_corrected (intf.single_error_corrected_out),
        .double_error_detected  (intf.double_error_detected_out),
        .monitored_raw_cw       (intf.raw_codeword_out),
        .monitored_corrupt_cw   (intf.corrupted_codeword_out),
        .monitored_corrected_w  (intf.corrected_weight_out),
        .monitored_syndrome     (intf.ecc_syndrome_out)
    );

    initial begin
        string vcd_file;
        if (!$value$plusargs("VCD_FILE=%s", vcd_file)) begin
            vcd_file = "outputs/waveforms/are_ubnn_kws.vcd";
        end
        $dumpfile(vcd_file);
        $dumpvars(0, tb_top);
    end

    `include "test.sv"

    initial begin
        $display("--------------------------------------------------------");
        $display("   STARTING SIMULATION: ARe-UBNN-KWS HARNESS");
        $display("--------------------------------------------------------");

        test_popcount();

        test_unipolar_pe();

        test_secded();

        test_accelerator_full();

        #20;
        $display("[TB_TOP] Simulation completed cleanly.");
        $finish(0);
    end

endmodule
