// bnn_generator.sv
`ifndef BNN_GENERATOR_SV
`define BNN_GENERATOR_SV
`include "bnn_transaction.sv"

class bnn_generator;
    mailbox gen_to_drv;   // unparameterized mailbox (Icarus compatible)
    int     num_random;
    int     rand_seed;

    function new(mailbox mb, int seed = 42, int num_rand = 10);
        gen_to_drv = mb;
        rand_seed  = seed;
        num_random = num_rand;
    endfunction

    // ----- Directed tests -----
    task generate_directed();
        bnn_transaction t;

        // T1: Normal inference
        t = new("T1_normal_inference");
        for (int i = 0; i < 16; i++) t.activation[i] = 16'hA5A5;
        t.weight_data = 16'hA5A5; t.threshold = 9'd10;
        gen_to_drv.put(t);

        // T2: All-zero activation PE0
        t = new("T2_zero_activation_PE0");
        for (int i = 0; i < 16; i++) t.activation[i] = 16'hFFFF;
        t.activation[0] = 16'h0000;
        t.weight_data = 16'hFFFF; t.threshold = 9'd5;
        gen_to_drv.put(t);

        // T3: Non-zero activation PE0
        t = new("T3_nonzero_activation_PE0");
        for (int i = 0; i < 16; i++) t.activation[i] = 16'h0000;
        t.activation[0] = 16'h0001;
        t.weight_data = 16'hFFFF; t.threshold = 9'd1;
        gen_to_drv.put(t);

        // T4: Single-bit fault
        t = new("T4_single_bit_fault");
        for (int i = 0; i < 16; i++) t.activation[i] = 16'hFFFF;
        t.weight_data = 16'hAAAA; t.threshold = 9'd5;
        t.inject_fault = 1; t.fault_bit1 = 3; t.fault_bit2 = -1;
        gen_to_drv.put(t);

        // T5: Double-bit fault
        t = new("T5_double_bit_fault");
        for (int i = 0; i < 16; i++) t.activation[i] = 16'hFFFF;
        t.weight_data = 16'hAAAA; t.threshold = 9'd5;
        t.inject_fault = 1; t.fault_bit1 = 3; t.fault_bit2 = 7;
        gen_to_drv.put(t);

        // T6: Mixed sparse
        t = new("T6_mixed_sparse");
        for (int i = 0; i < 16; i++)
            t.activation[i] = (i < 8) ? 16'hFFFF : 16'h0000;
        t.weight_data = 16'hFFFF; t.threshold = 9'd50;
        gen_to_drv.put(t);

        // T7: Fault during active inference
        t = new("T7_fault_during_inference");
        for (int i = 0; i < 16; i++) t.activation[i] = 16'h5555;
        t.weight_data = 16'h5555; t.threshold = 9'd8;
        t.inject_fault = 1; t.fault_bit1 = 10; t.fault_bit2 = -1;
        gen_to_drv.put(t);

        // T8: Sparse + fault
        t = new("T8_sparse_plus_fault");
        for (int i = 0; i < 16; i++)
            t.activation[i] = (i % 2 == 0) ? 16'hF0F0 : 16'h0000;
        t.weight_data = 16'hF0F0; t.threshold = 9'd20;
        t.inject_fault = 1; t.fault_bit1 = 5; t.fault_bit2 = -1;
        gen_to_drv.put(t);

        // T9a: All ones
        t = new("T9a_all_ones");
        for (int i = 0; i < 16; i++) t.activation[i] = 16'hFFFF;
        t.weight_data = 16'hFFFF; t.threshold = 9'd200;
        gen_to_drv.put(t);

        // T9b: All zeros
        t = new("T9b_all_zeros");
        for (int i = 0; i < 16; i++) t.activation[i] = 16'h0000;
        t.weight_data = 16'h0000; t.threshold = 9'd1;
        gen_to_drv.put(t);

        // T9c: Zero threshold
        t = new("T9c_zero_threshold");
        for (int i = 0; i < 16; i++) t.activation[i] = 16'h0000;
        t.weight_data = 16'hFFFF; t.threshold = 9'd0;
        gen_to_drv.put(t);

        $display("[GENERATOR] Directed tests generated.");
    endtask

    task generate_random();
        bnn_transaction t;
        void'($urandom(rand_seed));
        for (int r = 0; r < num_random; r++) begin
            t = new($sformatf("T10_random_%0d", r));
            for (int i = 0; i < 16; i++) t.activation[i] = $urandom();
            t.weight_data = $urandom();
            t.threshold   = 9'($urandom_range(1, 100));
            gen_to_drv.put(t);
        end
        $display("[GENERATOR] %0d random tests generated.", num_random);
    endtask

    task run();
        generate_directed();
        generate_random();
    endtask
endclass
`endif