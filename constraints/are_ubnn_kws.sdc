#=============================================================================
# Synopsys Design Constraints (SDC) for ARe-UBNN-KWS
# Target Process: SKY130 (sky130_fd_sc_hd)
# Target Frequency: 100 MHz (Clock Period = 10.0 ns)
#=============================================================================

# Clock Definition (10.0 ns = 100 MHz)
create_clock -name clk -period 10.000 [get_ports clk]

# Clock Uncertainty (Jitter & Skew Margin: 250 ps)
set_clock_uncertainty 0.250 [get_clocks clk]

# Clock Transition (Slew: 150 ps)
set_clock_transition 0.150 [get_clocks clk]

# Input Constraints (20% clock period budget = 2.0 ns)
set_input_delay 2.000 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]

# Output Constraints (20% clock period budget = 2.0 ns)
set_output_delay 2.000 -clock clk [all_outputs]

# Load Constraint (Standard 50 fF capacitive load)
set_load 0.050 [all_outputs]

# Input Drive Strength (Representative SKY130 buffer drive)
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 [remove_from_collection [all_inputs] [get_ports clk]]
