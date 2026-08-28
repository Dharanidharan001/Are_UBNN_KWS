# Evidence Index

| Result | Source File | Exact Evidence |
|--------|-------------|----------------|
| RTL compilation | `outputs/simulation/sim.out` | `iverilog -g2012` completed with 0 errors |
| Final regression | `logs/simulation/final_regression.log` | `TOTAL  : 42`, `PASSED : 42`, `FAILED : 0` |
| Single-bit SECDED | `logs/simulation/final_regression.log` | Exhaustive `T4_single_bit_fault_bit_0` through `21` output `SEC=1`, `sum=128`, `kw=1` |
| Double-bit detection | `logs/simulation/final_regression.log` | `T5_double_bit_fault` outputs `DED=1` |
| Baseline synthesis | `outputs/synthesis/baseline_statistics.txt` | Yosys `stat` reports `1801 cells` |
| Enhanced synthesis | `outputs/synthesis/enhanced_statistics.txt` | Yosys `stat` reports `3078 cells` |
| Comparison methodology | `docs/synthesis_comparison_methodology.md` | Details the `ENABLE_ENHANCED` parameter selection during synthesis |