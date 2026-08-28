// bnn_monitor.sv
`ifndef BNN_MONITOR_SV
`define BNN_MONITOR_SV
`include "bnn_transaction.sv"

class bnn_monitor;
    virtual bnn_interface #(16,16,9,4) vif;
    mailbox mon_to_scb;

    function new(virtual bnn_interface #(16,16,9,4) v, mailbox scb_mb);
        vif        = v;
        mon_to_scb = scb_mb;
    endfunction

    task run();
        bnn_transaction obs;
        // Wait for reset to deassert
        @(posedge vif.clk iff vif.rst_n);
        @(posedge vif.clk);

        forever begin
            // Wait for accum_valid to pulse
            @(posedge vif.clk iff vif.accum_valid);
            // Sample outputs one cycle after valid
            @(posedge vif.clk);
            obs = new("monitor_obs");
            obs.observed_keyword    = vif.keyword_detected;
            obs.observed_sum        = vif.accumulated_sum;
            obs.observed_pe_active  = vif.pe_active;
            obs.observed_sec        = vif.single_error_corrected;
            obs.observed_ded        = vif.double_error_detected;

            $display("[MONITOR] kw=%0b sum=%0d pe_act=0x%04h SEC=%0b DED=%0b",
                obs.observed_keyword, obs.observed_sum, obs.observed_pe_active,
                obs.observed_sec, obs.observed_ded);

            mon_to_scb.put(obs);
        end
    endtask
endclass
`endif