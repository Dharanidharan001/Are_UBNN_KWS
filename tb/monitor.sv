`ifndef MONITOR_SV
`define MONITOR_SV

`include "transaction.sv"

task automatic mon_sample_popcount(output logic [4:0] count);
    begin
        count = intf.popcount_out;
    end
endtask

`endif
