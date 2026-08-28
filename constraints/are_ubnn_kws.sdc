# ==========================================================================
# ARe-UBNN-KWS Top-Level Constraints (SDC)
# Target: SKY130 / OpenLane 2
# Realistic timing constraints for physical design (10 MHz target)
# ==========================================================================

# 1. Clock Definition
create_clock -name core_clk -period 100.000 [get_ports {clk}]

# 2. Clock Uncertainty (0.250 ns matches standard SKY130 on-chip jitter margin)
set_clock_uncertainty 0.250 [get_clocks core_clk]

# 3. Input Delays
set_input_delay 20.000 -clock core_clk [get_ports {activations_flat[*] threshold[*] accum_en wr_en wr_addr[*] wr_data[*] rd_addr[*] direct_weights_flat[*] fault_inject_en fault_mask[*]}]

# 4. Output Delays
set_output_delay 20.000 -clock core_clk [get_ports {keyword_detected accumulated_sum[*] pe_active[*] single_error_corrected double_error_detected accum_valid}]

# 5. Conservative electrical constraints
set_load 0.05 [all_outputs]
set_max_fanout 10 [get_ports {activations_flat[*] threshold[*] accum_en wr_en wr_addr[*] wr_data[*] rd_addr[*] direct_weights_flat[*] fault_inject_en fault_mask[*]}]

# 6. False Paths
set_false_path -from [get_ports {rst_n}]
