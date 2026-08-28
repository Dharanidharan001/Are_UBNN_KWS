# SECDED Terminology

This document standardizes the SECDED terminology for the ARe-UBNN-KWS project based on the actual RTL implementation in `src/ecc/secded_encoder.sv` and `src/ecc/secded_decoder.sv`.

- **DATA WIDTH:** 16 bits
- **HAMMING PARITY BITS:** 5 bits (covering data and each other for single-error correction)
- **OVERALL PARITY BIT:** 1 bit (parity across all 21 preceding bits for double-error detection)
- **TOTAL CODEWORD WIDTH:** 22 bits

**CORRECT TERMINOLOGY:**
"Extended Hamming SECDED (22,16): 16 data bits + 5 Hamming parity bits + 1 overall parity bit"

**REASONING:**
Calling the full stored codeword "Hamming (21,16)" is factually incomplete because it omits the overall parity extension. The physical weight memory stores a 22-bit width. Therefore, "Extended Hamming SECDED (22,16)" is the strictly correct architectural description of the full 22-bit stored codeword protecting 16 bits of data.