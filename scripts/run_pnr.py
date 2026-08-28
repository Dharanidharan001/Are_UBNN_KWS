#!/usr/bin/env python3
import os
import sys
import traceback

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    root_dir = os.path.abspath(os.path.join(script_dir, ".."))

    lib_path = os.path.join(root_dir, "constraints", "sky130_fd_sc_hd__tt_025C_1v80.lib")
    tlef_path = os.path.join(root_dir, "constraints", "sky130_fd_sc_hd.tlef")
    lef_path = os.path.join(root_dir, "constraints", "sky130_fd_sc_hd_merged.lef")
    netlist_path = os.path.join(root_dir, "outputs", "netlist", "are_ubnn_kws_enhanced.netlist.v")
    sdc_path = os.path.join(root_dir, "constraints", "are_ubnn_kws.sdc")

    phys_dir = os.path.join(root_dir, "outputs", "physical")
    log_dir = os.path.join(root_dir, "logs", "openroad")
    os.makedirs(phys_dir, exist_ok=True)
    os.makedirs(log_dir, exist_ok=True)

    def_out = os.path.join(phys_dir, "are_ubnn_kws_placed.def")
    odb_out = os.path.join(phys_dir, "are_ubnn_kws.odb")

    import openroad as ord
    tech = ord.Tech()
    design = ord.Design(tech)

    flow_cmds = [
        f"read_liberty {lib_path}",
        f"read_lef {tlef_path}",
        f"read_lef {lef_path}",
        f"read_verilog {netlist_path}",
        "link_design are_ubnn_kws_top",
        f"read_sdc {sdc_path}",
        "initialize_floorplan -die_area {0 0 360 360} -core_area {20 20 340 340} -site unithd",
        "place_pins -hor_layer met3 -ver_layer met2",
        "global_placement -density 0.60",
        "detailed_placement",
        "check_placement",
        f"write_def {def_out}",
        f"write_db {odb_out}"
    ]

    for cmd in flow_cmds:
        print(f"[OpenROAD] Executing: {cmd}")
        sys.stdout.flush()
        try:
            res = design.evalTclString(cmd)
            print(f"  -> Returned: {res}")
            sys.stdout.flush()
        except Exception as e:
            print(f"  -> Failed command: {cmd}")
            print(f"  -> Exception: {e}")
            traceback.print_exc()
            sys.stdout.flush()
            break

if __name__ == "__main__":
    main()
