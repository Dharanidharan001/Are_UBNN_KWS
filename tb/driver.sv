//=============================================================================
// Project: ARe-UBNN-KWS
// File:    tb/driver.sv
// Description:
//   Testbench Driver component. Translates high-level transactions into
//   pin-level timing on the virtual interface `are_ubnn_kws_if`.
//=============================================================================

`ifndef DRIVER_SV
`define DRIVER_SV

`include "transaction.sv"

// Driver reset task
task automatic drv_reset();
    begin
        intf.rst_n               <= 1'b0;
        intf.load_weight         <= 1'b0;
        intf.load_activation     <= 1'b0;
        intf.start_inference     <= 1'b0;
        intf.pe_sel              <= 4'd0;
        intf.weight_in           <= 16'h0000;
        intf.activation_in       <= 16'h0000;
        intf.activations_bus     <= 256'd0;
        intf.threshold_in        <= 8'd0;
        intf.bypass_clock_gating <= 1'b0;
        intf.test_en             <= 1'b0;
        intf.fault_inject_en     <= 1'b0;
        intf.fault_pe_sel        <= 4'd0;
        intf.fault_bit1          <= 5'd0;
        intf.fault_bit2          <= 5'd0;
        intf.fault_is_double     <= 1'b0;
        intf.popcount_in         <= 16'h0000;
        intf.pe_test_act         <= 16'h0000;
        intf.pe_test_weight      <= 16'h0000;
        intf.pe_test_en          <= 1'b0;
        intf.secded_test_data    <= 16'h0000;
        intf.secded_test_corrupt_cw <= 22'd0;
        repeat (3) @(posedge intf.clk);
        intf.rst_n               <= 1'b1;
        repeat (2) @(posedge intf.clk);
    end
endtask

// Driver task for Popcount verification
task automatic drv_popcount(input transaction_t tr);
    begin
        @(posedge intf.clk);
        intf.popcount_in <= tr.popcount_in;
        #1;
    end
endtask

// Driver task for loading all 16 PE weights into protected memory
task automatic drv_load_all_weights(input transaction_t tr);
    integer p;
    begin
        for (p = 0; p < 16; p = p + 1) begin
            @(posedge intf.clk);
            intf.pe_sel      <= p[3:0];
            intf.weight_in   <= get_pe_word(tr.weights, p);
            intf.load_weight <= 1'b1;
            @(posedge intf.clk);
            intf.load_weight <= 1'b0;
        end
        @(posedge intf.clk);
    end
endtask

// Driver task for executing one full inference pass
task automatic drv_run_inference(input transaction_t tr);
    begin
        @(posedge intf.clk);
        intf.activations_bus <= tr.activations;
        intf.threshold_in    <= tr.threshold;
        intf.fault_inject_en <= tr.fault_en;
        intf.fault_pe_sel    <= tr.fault_pe;
        intf.fault_bit1      <= tr.fault_bit1;
        intf.fault_bit2      <= tr.fault_bit2;
        intf.fault_is_double <= tr.fault_double;

        // Trigger start of inference
        intf.start_inference <= 1'b1;
        @(posedge intf.clk);
        intf.start_inference <= 1'b0;

        // Wait until done signal is asserted by controller
        while (!intf.done) begin
            @(posedge intf.clk);
        end
        #1; // Settling time for sampling
    end
endtask

`endif // DRIVER_SV
