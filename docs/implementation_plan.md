# ARe-UBNN-KWS Implementation Plan

## 1. Development Phases

| Phase | Task | Status |
|---|---|---|
| 1 | Repository structure | DONE |
| 2 | Documentation | DONE |
| 3 | Baseline RTL | TODO |
| 4 | Baseline verification | TODO |
| 5 | Compile and fix baseline | TODO |
| 6 | Verify baseline | TODO |
| 7 | SECDED encoder | TODO |
| 8 | SECDED decoder | TODO |
| 9 | SECDED verification | TODO |
| 10 | Protected weight memory | TODO |
| 11 | Activation detector | TODO |
| 12 | ICG/clock-enable | TODO |
| 13 | Enhanced top-level integration | TODO |
| 14 | Full enhanced verification | TODO |
| 15 | VCD waveform generation | TODO |
| 16 | Yosys synthesis | TODO |
| 17 | Physical design (if tools available) | TODO |
| 18 | Final documentation | TODO |

## 2. Simulation Flow

```
iverilog -g2012 -o sim.out [RTL files] [TB files]
vvp sim.out
gtkwave outputs/simulation/*.vcd
```

## 3. Synthesis Flow

```
yosys -p "
  read_verilog -sv [RTL files]
  synth -top are_ubnn_kws_top
  write_verilog outputs/synthesis/netlist.v
  stat > outputs/synthesis/statistics.txt
"
```

## 4. Physical Design Flow (if OpenLane available)

```
flow.tcl -design are_ubnn_kws -pdk sky130A
```

## 5. Clock Target

Proposed: 100 MHz (10 ns period) for initial synthesis.
Actual achievable frequency depends on synthesis results.
Do not claim timing closure until actual reports confirm it.

## 6. Verification Files Compilation Order

1. src/compute/popcount.sv
2. src/compute/unipolar_pe.sv
3. src/compute/pe_array.sv
4. src/baseline/accumulator.sv
5. src/baseline/threshold_unit.sv
6. src/ecc/secded_encoder.sv
7. src/ecc/secded_decoder.sv
8. src/memory/protected_weight_memory.sv
9. src/power/activation_detector.sv
10. src/power/icg.sv
11. src/top/are_ubnn_kws_top.sv
12. tb/interfaces/bnn_interface.sv
13. tb/transactions/bnn_transaction.sv
14. tb/generator/bnn_generator.sv
15. tb/driver/bnn_driver.sv
16. tb/monitor/bnn_monitor.sv
17. tb/scoreboard/bnn_scoreboard.sv
18. tb/environment/bnn_environment.sv
19. tb/tests/baseline_test.sv
20. tb/tests/secded_test.sv
21. tb/tests/enhanced_test.sv
22. tb/top/tb_top.sv
