# top.sdc — Timing constraints for ARe-UBNN-KWS
# Target: 100 MHz (10 ns period)
# Tool: OpenROAD / OpenLane + SKY130 PDK
#
# IMPORTANT: These are PROPOSED constraints.
# Do not claim timing closure until actual STA reports confirm it.

# Clock definition
create_clock -name clk -period 10.0 [get_ports clk]

# Input delay: assume inputs arrive within 2 ns of rising clock edge
set_input_delay  2.0 -clock clk [all_inputs]

# Output delay: assume outputs must be stable 2 ns before next clock edge
set_output_delay 2.0 -clock clk [all_outputs]

# Clock uncertainty: 0.1 ns jitter
set_clock_uncertainty 0.1 [get_clocks clk]

# Clock transition: 0.15 ns
set_clock_transition 0.15 [get_clocks clk]

# False path on fault injection input (static during synthesis evaluation)
# set_false_path -from [get_ports fault_inject_en]
# set_false_path -from [get_ports fault_mask*]
# (Uncomment if synthesis tool supports false paths and you want to
#  relax timing on fault injection — for production, tie these to 0)
