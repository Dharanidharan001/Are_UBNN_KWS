// bnn_driver.sv
`ifndef BNN_DRIVER_SV
`define BNN_DRIVER_SV
`include "bnn_transaction.sv"

class bnn_driver;
    virtual bnn_interface #(16,16,9,4) vif;
    mailbox drv_mailbox;
    mailbox drv_to_scb;

    function new(virtual bnn_interface #(16,16,9,4) v,
                 mailbox drv_mb, mailbox scb_mb);
        vif         = v;
        drv_mailbox = drv_mb;
        drv_to_scb  = scb_mb;
    endfunction

    task apply_reset();
        vif.rst_n               = 1'b0;
        vif.activations_flat    = '0;
        vif.threshold           = 9'd8;
        vif.accum_en            = 1'b0;
        vif.wr_en               = 1'b0;
        vif.wr_addr             = '0;
        vif.wr_data             = '0;
        vif.rd_addr             = '0;
        vif.direct_weights_flat = '0;
        vif.fault_inject_en     = 1'b0;
        vif.fault_mask          = '0;
        repeat(4) @(posedge vif.clk);
        vif.rst_n = 1'b1;
        @(posedge vif.clk);
        $display("[DRIVER] Reset complete.");
    endtask

    task drive_transaction(bnn_transaction t);
        logic [255:0] flat_act;
        logic [255:0] flat_w;
        logic [21:0]  fmask;

        // Write weight to memory
        @(posedge vif.clk);
        #1;
        vif.wr_en   = 1'b1;
        vif.wr_addr = t.weight_addr;
        vif.wr_data = t.weight_data;
        @(posedge vif.clk);
        #1;
        vif.wr_en   = 1'b0;

        // Set read address
        vif.rd_addr = t.weight_addr;

        // Pack activations
        flat_act = '0;
        for (int i = 0; i < 16; i++)
            flat_act[i*16 +: 16] = t.activation[i];
        vif.activations_flat = flat_act[255:0];

        // Pack direct weights
        flat_w = '0;
        for (int i = 0; i < 16; i++)
            flat_w[i*16 +: 16] = t.weight_data;
        vif.direct_weights_flat = flat_w[255:0];

        vif.threshold = t.threshold;

        // Fault injection
        fmask = 22'b0;
        if (t.inject_fault) begin
            if (t.fault_bit1 >= 0 && t.fault_bit1 <= 21)
                fmask[t.fault_bit1] = 1'b1;
            if (t.fault_bit2 >= 0 && t.fault_bit2 <= 21)
                fmask[t.fault_bit2] = 1'b1;
            vif.fault_inject_en = 1'b1;
            vif.fault_mask      = fmask;
        end else begin
            vif.fault_inject_en = 1'b0;
            vif.fault_mask      = '0;
        end

        // Wait for combinational logic
        @(posedge vif.clk);
        #1;

        // Pulse accumulator enable
        vif.accum_en = 1'b1;
        @(posedge vif.clk);
        #1;
        vif.accum_en = 1'b0;

        // Wait for accumulator output
        @(posedge vif.clk);
        #1;

        // Clear fault injection
        vif.fault_inject_en = 1'b0;
        vif.fault_mask      = '0;

        drv_to_scb.put(t);
        $display("[DRIVER] Drove: %s", t.test_name);
    endtask

    task run();
        bnn_transaction t;
        apply_reset();
        forever begin
            drv_mailbox.get(t);
            drive_transaction(t);
        end
    endtask
endclass
`endif