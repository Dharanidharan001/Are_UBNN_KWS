# ARe-UBNN-KWS Build & Automation Flow Guide

## 1. Toolchain Prerequisites

The development and verification flow requires only standard, open-source EDA tools available on Ubuntu / WSL2 or native Linux:

| Tool | Minimum Version | Tested Version | Role in Flow |
| :--- | :---: | :---: | :--- |
| **Icarus Verilog** | 12.0 | `v12.0 (devel)` | SystemVerilog Compilation & Behavioral Simulation |
| **VVP** | 12.0 | `v12.0` | Simulation Runtime Engine & VCD Waveform Dumper |
| **GTKWave** | 3.3 | `v3.3.126` | Interactive Waveform Inspection & Debugging |
| **Yosys** | 0.50 | `v0.52` | Logic Synthesis & SKY130 Standard Cell Technology Mapping |
| **OpenROAD** | 0.0.1 | `v0.0.1` | Static Timing Analysis (OpenSTA) & Physical Implementation |
| **KLayout** | 0.28 | `v0.30` | Layout Inspection (DEF/GDSII) |

---

## 2. Directory Layout & Artifact Destinations

```
ARe_UBNN_KWS/
├── constraints/
│   ├── are_ubnn_kws.sdc                  # SDC Timing Constraints (100 MHz)
│   ├── sky130_fd_sc_hd__tt_025C_1v80.lib # Standard cell timing library (12 MB)
│   ├── sky130_fd_sc_hd.tlef              # Technology LEF (13 layers, 25 vias)
│   └── sky130_fd_sc_hd_merged.lef        # Cell LEF (441 macros)
├── outputs/
│   ├── waveforms/are_ubnn_kws.vcd        # Simulation VCD waveform trace
│   ├── waveforms/are_ubnn_kws.gtkw       # GTKWave session configuration
│   ├── netlist/*.netlist.v               # Gate-level mapped Verilog netlists
│   ├── synthesis/*_report.txt            # Area and cell count comparison reports
│   └── timing/timing_report.rpt          # OpenROAD Static Timing Analysis report
└── logs/
    ├── simulation/sim_run.log            # Icarus simulation log
    ├── synthesis/synth_*.log             # Yosys synthesis logs
    └── timing/sta.log                    # OpenROAD STA log
```

---

## 3. Step-by-Step Flow Execution

Both Linux (`bash`) and Windows (`PowerShell`) wrappers are provided in `scripts/`.

### Step 1: RTL Functional Simulation & Verification
Compiles all RTL modules and testbench classes, executes 489 self-checking assertions across unit tests and system inference runs, and writes waveform dumps:

```powershell
# Windows PowerShell
.\ARe_UBNN_KWS\scripts\sim.ps1
```
```bash
# Linux / WSL
chmod +x ./ARe_UBNN_KWS/scripts/sim.sh
./ARe_UBNN_KWS/scripts/sim.sh
```

### Step 2: Waveform Inspection in GTKWave
Opens GTKWave with pre-configured color-coded signal groupings:
```bash
gtkwave outputs/waveforms/are_ubnn_kws.vcd outputs/waveforms/are_ubnn_kws.gtkw
```

### Step 3: Yosys SKY130 Synthesis (Baseline vs Enhanced)
Synthesizes both the unprotected baseline architecture and the enhanced SECDED+ICG architecture into SkyWater 130nm standard cells:
```powershell
# Windows PowerShell
.\ARe_UBNN_KWS\scripts\synth.ps1
```
```bash
# Linux / WSL
./ARe_UBNN_KWS/scripts/synth.sh
```
*Outputs:*
- `outputs/netlist/are_ubnn_kws_enhanced.netlist.v`
- `outputs/netlist/are_ubnn_kws_baseline.netlist.v`
- `outputs/synthesis/synthesis_comparison_report.txt`

### Step 4: Static Timing Analysis (STA)
Executes OpenROAD timing verification on the mapped gate-level netlist:
```powershell
# Windows PowerShell
.\ARe_UBNN_KWS\scripts\run_sta.ps1
```
```bash
# Linux / WSL
./ARe_UBNN_KWS/scripts/run_sta.sh
```
*Outputs:*
- `outputs/timing/timing_report.rpt`
- `logs/timing/sta.log`

### Step 5: Physical Layout Inspection in KLayout
Launches KLayout to inspect DEF or GDS geometry:
```powershell
# Windows PowerShell
.\ARe_UBNN_KWS\scripts\view_layout.ps1
```
```bash
# Linux / WSL
./ARe_UBNN_KWS/scripts/view_layout.sh
```
