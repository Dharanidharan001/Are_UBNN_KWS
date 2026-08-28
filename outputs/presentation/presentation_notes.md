# ARe-UBNN-KWS: Slide-by-Slide Presentation Notes

**Project:** Adaptive Reliable Unipolar Binary Neural Network Accelerator for Edge Keyword Spotting  
**Target Duration:** 5 Minutes | Hackathon Pitch Format  

---

### Slide 1: Title & The Vision
- **Visual:** Project Title, SKY130 badge, OpenROAD badge, zero-negative slack badge.
- **Speaker Script:**
  > "Good day, judges. We are excited to present **ARe-UBNN-KWS**: an Adaptive, Reliable Unipolar Binary Neural Network Accelerator targeting SkyWater 130nm silicon for edge keyword spotting.
  > Today's voice interfaces are everywhere—from medical wearables to industrial drones—but deploying neural networks on battery-operated edge silicon requires balancing two aggressive tradeoffs: **zero-overhead hardware reliability** and **sub-milliwatt energy consumption**."

---

### Slide 2: The Dual Bottleneck of Edge Silicon
- **Visual:** Two split panels: Left showing cosmic ray bit-flip in SRAM leading to false wake-word; Right showing battery drain during silent pauses.
- **Speaker Script:**
  > "Edge silicon operates in harsh physical environments. Radiation and voltage fluctuations cause soft bit-flips in weight memory. A single flipped bit corrupts neural classification, causing missed alerts or false triggers.
  > Simultaneously, speech features exhibit massive sparsity—between 40% and 80% of audio frames are silence or pauses. Running standard digital multiply-accumulate engines burns continuous dynamic power on zeros.
  > We solved both problems simultaneously without adding a single cycle of pipeline latency."

---

### Slide 3: Core UBNN Architecture & The 16 PEs
- **Visual:** Block diagram highlighting 16 parallel PEs, Wallace tree popcount, and baseline accumulator.
- **Speaker Script:**
  > "We adopted a Unipolar BNN mathematical formulation where activations and weights are binary 0s and 1s. This transforms complex MAC units into 16 parallel 1-bit AND gates, followed by a 4-stage balanced Wallace adder tree popcount.
  > 16 Processing Elements operate concurrently, producing 5-bit partial results that feed a baseline 4-stage balanced adder accumulator and saturating register. Our baseline accumulator remains 100% architecturally intact."

---

### Slide 4: Innovation A - Inline SECDED Reliability
- **Visual:** Codeword diagram of Extended Hamming (22, 16) with parity equations, syndrome decoder, and zero-pipeline callout.
- **Speaker Script:**
  > "Our first major innovation is an **Inline Extended Hamming (22, 16) SECDED Codec**.
  > Rather than using slow multi-cycle memory scrubs, we placed 16 parallel combinational decoders directly on the weight memory read bus.
  > If an SRAM cell flips during active inference, the decoder detects the 5-bit syndrome and corrects the bit in under 3.9 nanoseconds. Single-bit errors achieve 100% hardware correction; double-bit errors are flagged via telemetry. Most importantly, it adds zero pipeline stages."

---

### Slide 5: Innovation B - Dynamic Sparsity-Aware Clock Gating
- **Visual:** Activity detector reduction-OR gate connected to `sky130_fd_sc_hd__dlclkp_1` standard cell, showing gated waveforms.
- **Speaker Script:**
  > "Our second innovation addresses power. We implemented a fine-grained activity detector that evaluates each PE's 16-bit activation vector.
  > If an audio feature is silent—all zeros—that specific PE's Integrated Clock Gating cell, mapped to SKY130 standard cell `dlclkp_1`, cuts the clock to that PE's registers.
  > Dynamic switching power drops to zero for that PE. The accumulator simply receives a masked zero, preserving exact mathematical precision while extending battery life."

---

### Slide 6: Verification Proof & The Mandatory Fault+Sparse Test
- **Visual:** Verification matrix showing 489/489 passed assertions, GTKWave waveform screenshot highlighting SEC=1, DED=0, and PE gating.
- **Speaker Script:**
  > "We executed a comprehensive verification suite in Icarus Verilog 12.0 with a self-checking Scoreboard.
  > We verified 56 popcount vectors, 16 PE tests, 308 exhaustive SECDED permutations, and 8 system-level inference scenarios—with **489 out of 489 assertions passing (100%) and zero mismatches**.
  > In our mandatory demonstration test—injecting a live weight bit-flip while half the PEs were clock-gated—the accelerator corrected the weight on-the-fly, kept inactive PEs quiet, and produced the exact golden classification."

---

### Slide 7: SKY130 Synthesis & Timing Closure
- **Visual:** Yosys synthesis comparison table (1,866 baseline cells vs 6,399 enhanced cells, 60,324 um^2 area) and OpenROAD timing slack report (+2.51 ns setup, +0.27 ns hold, 0.00 ns TNS).
- **Speaker Script:**
  > "We synthesized both the Baseline and Enhanced designs using Yosys targeting SkyWater 130nm HD standard cells.
  > The Enhanced accelerator requires 6,399 standard cells occupying 60,324 square microns.
  > Using OpenROAD and OpenSTA with genuine SKY130 liberty files and 100 MHz SDC constraints, our worst setup slack is **+2.51 nanoseconds** and worst hold slack is **+0.27 nanoseconds**. We achieved **Zero Negative Slack** and full timing closure with 33% frequency headroom."

---

### Slide 8: Conclusion & Q&A
- **Visual:** Summary bullet points, GitHub repo link, team credits.
- **Speaker Script:**
  > "In summary: ARe-UBNN-KWS delivers domain-specific silicon innovation for edge AI—combining zero-latency fault tolerance, dynamic energy conservation, full open-source SKY130 implementation, and proven timing closure.
  > Thank you, and we look forward to your questions!"
