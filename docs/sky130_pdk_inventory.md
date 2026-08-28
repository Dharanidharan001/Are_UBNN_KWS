# SKY130 PDK Inventory

## Installation Path
`E:\sky130_glade`

## PDK Classification
Partial SKY130 Library (Missing standard cells and timing files)

## Standard Cell Libraries Found
None. The directory `libraries\sky130_fd_sc_hd` exists but is empty (no `cells` directory or collateral).

## Liberty Files
None. (0 `.lib` files found in the entire PDK tree).

## LEF Files
Found LEF files only for primitive devices (`sky130_fd_pr`). No standard cell LEFs found.
- Example: `libraries\sky130_fd_pr\latest\cells\cap_vpp_...\*.lef`

## GDS Files
Found GDS files only for primitive/RF devices (`sky130_fd_pr`). No standard cell GDS found.
- Example: `libraries\sky130_fd_pr\latest\cells\rf_pfet_01v8\*.gds`

## SPICE Models
Found SPICE models for primitive devices (`sky130_fd_pr`).
- Example: `libraries\sky130_fd_pr\latest\cells\cap_mim_m3\*.model.spice`

## Physical Design Readiness
NOT READY

## Missing Components
- All standard cell libraries (e.g., `sky130_fd_sc_hd`, `sky130_fd_sc_hs`, etc.)
- All standard cell Liberty (`.lib`) timing files
- All standard cell LEF files
- All standard cell GDS files
- OpenLane / OpenROAD technology configuration files