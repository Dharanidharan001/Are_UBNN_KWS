// bnn_transaction.sv — Verification transaction class
`ifndef BNN_TRANSACTION_SV
`define BNN_TRANSACTION_SV

class bnn_transaction;
    // Activation vectors (one per PE)
    logic [15:0] activation [16];
    // Weight
    logic [15:0] weight_data;
    logic [3:0]  weight_addr;
    // Threshold
    logic [8:0]  threshold;
    // Fault injection
    bit          inject_fault;
    int          fault_bit1;
    int          fault_bit2;   // -1 = no second fault
    // Test identity
    int          pe_select;    // -1 = all PEs
    string       test_name;
    // Expected
    bit          expected_keyword;
    logic [8:0]  expected_sum;
    // Observed (filled by monitor)
    bit          observed_keyword;
    logic [8:0]  observed_sum;
    logic [15:0] observed_pe_active;
    bit          observed_sec;
    bit          observed_ded;

    function new(string name = "tx");
        test_name    = name;
        inject_fault = 0;
        fault_bit1   = 0;
        fault_bit2   = -1;
        pe_select    = -1;
        threshold    = 9'd8;
        weight_addr  = 4'd0;
        weight_data  = 16'd0;
        foreach (activation[i]) activation[i] = 16'd0;
    endfunction

    function void display(string prefix = "");
        $display("%s[%s] inj=%0b f1=%0d f2=%0d thr=%0d wd=0x%04h exp_kw=%0b obs_kw=%0b SEC=%0b DED=%0b",
            prefix, test_name, inject_fault, fault_bit1, fault_bit2,
            threshold, weight_data, expected_keyword, observed_keyword,
            observed_sec, observed_ded);
    endfunction

    function bnn_transaction copy();
        bnn_transaction t = new(test_name);
        t.weight_data  = weight_data;
        t.weight_addr  = weight_addr;
        t.threshold    = threshold;
        t.inject_fault = inject_fault;
        t.fault_bit1   = fault_bit1;
        t.fault_bit2   = fault_bit2;
        t.pe_select    = pe_select;
        foreach (activation[i]) t.activation[i] = activation[i];
        t.expected_keyword = expected_keyword;
        t.expected_sum     = expected_sum;
        return t;
    endfunction
endclass
`endif