// bnn_environment.sv
`ifndef BNN_ENVIRONMENT_SV
`define BNN_ENVIRONMENT_SV
`include "bnn_transaction.sv"
`include "bnn_generator.sv"
`include "bnn_driver.sv"
`include "bnn_monitor.sv"
`include "bnn_scoreboard.sv"

class bnn_environment;
    bnn_generator  gen;
    bnn_driver     drv;
    bnn_monitor    mon;
    bnn_scoreboard scb;

    mailbox gen_to_drv;   // generator -> driver
    mailbox drv_to_scb;   // driver    -> scoreboard (stimulus)
    mailbox mon_to_scb;   // monitor   -> scoreboard (observations)

    virtual bnn_interface #(16,16,9,4) vif;

    function new(virtual bnn_interface #(16,16,9,4) v);
        vif        = v;
        gen_to_drv = new();
        drv_to_scb = new();
        mon_to_scb = new();
        gen = new(gen_to_drv, .seed(42), .num_rand(10));
        drv = new(vif, gen_to_drv, drv_to_scb);
        mon = new(vif, mon_to_scb);
        scb = new(drv_to_scb, mon_to_scb);
    endfunction

    task run(int num_tx = 21);
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_none
        // Wait: 21 transactions x ~7 cycles each + margin = ~200 cycles
        repeat(num_tx * 10 + 80) @(posedge vif.clk);
        scb.report();
    endtask
endclass
`endif