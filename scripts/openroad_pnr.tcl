#=============================================================================
# OpenROAD Physical Design Flow Script: ARe-UBNN-KWS
# Target: SKY130 High Density (sky130_fd_sc_hd)
#=============================================================================

# 1. Read Technology LEF & Cell LEFs
read_lef constraints/sky130_fd_sc_hd.tlef
read_lef constraints/sky130_fd_sc_hd_merged.lef

# 2. Read Timing Liberty
read_liberty constraints/sky130_fd_sc_hd__tt_025C_1v80.lib

# 3. Read Gate-Level Synthesized Netlist
read_verilog outputs/netlist/are_ubnn_kws_enhanced.netlist.v
link_design are_ubnn_kws_top

# 4. Read SDC Timing Constraints (100 MHz target)
read_sdc constraints/are_ubnn_kws.sdc

# 5. Floorplanning (Core utilization 55%, aspect ratio 1.0)
initialize_floorplan -site unithd \
                     -die_area {0 0 350.0 350.0} \
                     -core_area {15.0 15.0 335.0 335.0}

# 6. Make Metal Routing Tracks
make_tracks li1  -x_offset 0.23 -x_pitch 0.46 -y_offset 0.17 -y_pitch 0.34
make_tracks met1 -x_offset 0.17 -x_pitch 0.34 -y_offset 0.17 -y_pitch 0.34
make_tracks met2 -x_offset 0.23 -x_pitch 0.46 -y_offset 0.23 -y_pitch 0.46
make_tracks met3 -x_offset 0.34 -x_pitch 0.68 -y_offset 0.34 -y_pitch 0.68
make_tracks met4 -x_offset 0.46 -x_pitch 0.92 -y_offset 0.46 -y_pitch 0.92
make_tracks met5 -x_offset 1.70 -x_pitch 3.40 -y_offset 1.70 -y_pitch 3.40

# 7. IO Pin Placement
place_pins -hor_layer met3 -ver_layer met2

# 8. Global Placement
global_placement -density 0.60

# 9. Detailed Placement
detailed_placement
check_placement

# 10. Clock Tree Synthesis (TritonCTS)
clock_tree_synthesis -root_clk clk \
                     -buf_list {sky130_fd_sc_hd__clkbuf_1 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4}

# 11. Global & Detailed Routing
global_route
detailed_route

# 12. Export DEF & Final Timing
write_def outputs/physical/are_ubnn_kws_final.def
write_db  outputs/physical/are_ubnn_kws_final.odb
report_checks -path_delay max -digits 4
