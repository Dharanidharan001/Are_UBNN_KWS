#!/usr/bin/env python3
#=============================================================================
# Static Timing Analysis (STA) Script using OpenROAD Engine
# Target: SKY130 HD library (100 MHz target clock / 10.0 ns period)
#=============================================================================

import os
import sys

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    root_dir = os.path.abspath(os.path.join(script_dir, ".."))

    lib_path = os.path.join(root_dir, "constraints", "sky130_fd_sc_hd__tt_025C_1v80.lib")
    tlef_path = os.path.join(root_dir, "constraints", "sky130_fd_sc_hd.tlef")
    lef_path = os.path.join(root_dir, "constraints", "sky130_fd_sc_hd_merged.lef")
    netlist_path = os.path.join(root_dir, "outputs", "netlist", "are_ubnn_kws_enhanced.netlist.v")
    sdc_path = os.path.join(root_dir, "constraints", "are_ubnn_kws.sdc")
    timing_rpt = os.path.join(root_dir, "outputs", "timing", "timing_report.rpt")
    timing_log = os.path.join(root_dir, "logs", "timing", "sta.log")

    os.makedirs(os.path.join(root_dir, "outputs", "timing"), exist_ok=True)
    os.makedirs(os.path.join(root_dir, "logs", "timing"), exist_ok=True)

    print("==========================================================")
    print(" Running Static Timing Analysis (STA): ARe-UBNN-KWS")
    print("==========================================================")

    try:
        import openroad as ord
    except ImportError as e:
        print(f"[ERROR] Failed to import openroad: {e}")
        sys.exit(1)

    tech = ord.Tech()
    design = ord.Design(tech)

    tcl_commands = [
        f"read_liberty {lib_path}",
        f"read_lef {tlef_path}",
        f"read_lef {lef_path}",
        f"read_verilog {netlist_path}",
        "link_design are_ubnn_kws_top",
        f"read_sdc {sdc_path}",
        "report_checks -path_delay max -fields {slew cap input fanout} -digits 4",
        "report_checks -path_delay min -digits 4",
        "report_worst_slack -max",
        "report_worst_slack -min",
        "report_tns"
    ]

    full_output = []
    for cmd in tcl_commands:
        full_output.append(f"\nsta> {cmd}")
        out = design.evalTclString(cmd)
        if out:
            full_output.append(str(out))

    report_content = "\n".join(full_output)
    print(report_content)

    with open(timing_rpt, "w") as f:
        f.write(report_content)
    with open(timing_log, "w") as f:
        f.write(report_content)

    print("==========================================================")
    print(f" Timing report saved to: {timing_rpt}")
    print("==========================================================")

if __name__ == "__main__":
    main()
