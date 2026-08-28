# KLayout Physical Layout Visualization & Presentation Assets

**Design:** `ARe-UBNN-KWS` (Enhanced & Baseline Wrappers)  
**Technology:** SkyWater 130 nm CMOS (`sky130_fd_sc_hd`)  
**KLayout Version:** KLayout v0.29.4 (Inside OpenLane 2.3.10 Container)  
**Rendering Method:** Off-screen standalone KLayout Python API (`pya.LayoutView`) with `sky130A.lyt` and `sky130A.lyp` technology layer properties  

---

## 1. Verified GDSII Source Files

- **Enhanced Design GDSII:** `outputs/pnr/gds/are_ubnn_kws_enhanced_wrapper.gds` (11.6 MB)
- **Baseline Design GDSII:** `outputs/pnr/baseline/gds/are_ubnn_kws_baseline_wrapper.gds` (8.8 MB)

Both files were verified on disk and inspected for their true physical dimensions:
- **Top Cell (Enhanced):** `are_ubnn_kws_enhanced_wrapper`  
  **Physical Bounding Box:** $(0.00, 0.00)\ \mu\text{m}$ to $(520.00, 520.00)\ \mu\text{m}$ ($520.00 \times 520.00\ \mu\text{m}$)
- **Top Cell (Baseline):** `are_ubnn_kws_baseline_wrapper`  
  **Physical Bounding Box:** $(0.00, 0.00)\ \mu\text{m}$ to $(520.00, 520.00)\ \mu\text{m}$ ($520.00 \times 520.00\ \mu\text{m}$)

---

## 2. Generated Judge-Ready Presentation Images

All images were rendered directly from the real layout mask databases and are archived in [`presentation/assets/judge_demo/`](file:///E:/Are_UBNN_KWS/self/presentation/assets/judge_demo/):

### Enhanced Architecture (`are_ubnn_kws_enhanced_wrapper`)

| Image File | Resolution | File Size | Viewport Description |
|---|---|---|---|
| [`enhanced_full_die.png`](file:///E:/Are_UBNN_KWS/self/presentation/assets/judge_demo/enhanced_full_die.png) | $1800 \times 1800$ | **916 KB** | Full $520 \times 520\ \mu\text{m}$ die view showing complete PR_BOUNDARY, 601 perimeter IO pins, power rings, and internal core mesh. |
| [`enhanced_placement_zoom.png`](file:///E:/Are_UBNN_KWS/self/presentation/assets/judge_demo/enhanced_placement_zoom.png) | $1800 \times 1600$ | **933 KB** | Central standard-cell placement region ($200 \times 180\ \mu\text{m}$ window across $[160, 360] \times [170, 350]\ \mu\text{m}$) showing 16-PE array, SECDED memory, and clock distribution. |
| [`enhanced_routing_detail.png`](file:///E:/Are_UBNN_KWS/self/presentation/assets/judge_demo/enhanced_routing_detail.png) | $1800 \times 1800$ | **680 KB** | Detailed multi-layer routing inspection ($60 \times 60\ \mu\text{m}$ window across $[230, 290] \times [230, 290]\ \mu\text{m}$) showing individual `met1`-`met4` wire tracks, vias, and cell contacts. |

### Baseline Architecture (`are_ubnn_kws_baseline_wrapper`)

| Image File | Resolution | File Size | Viewport Description |
|---|---|---|---|
| [`baseline_full_die.png`](file:///E:/Are_UBNN_KWS/self/presentation/assets/judge_demo/baseline_full_die.png) | $1800 \times 1800$ | **819 KB** | Full $520 \times 520\ \mu\text{m}$ baseline physical layout showing unenhanced core and power grid. |
| [`baseline_placement_zoom.png`](file:///E:/Are_UBNN_KWS/self/presentation/assets/judge_demo/baseline_placement_zoom.png) | $1800 \times 1600$ | **856 KB** | Baseline central standard-cell placement view ($200 \times 180\ \mu\text{m}$ window). |
| [`baseline_routing_detail.png`](file:///E:/Are_UBNN_KWS/self/presentation/assets/judge_demo/baseline_routing_detail.png) | $1800 \times 1800$ | **806 KB** | Baseline detailed routing inspection ($60 \times 60\ \mu\text{m}$ window). |

---

## 3. Windows Commands to Open & Inspect Images

```powershell
# Open Enhanced Layout Images
Invoke-Item "E:\Are_UBNN_KWS\self\presentation\assets\judge_demo\enhanced_full_die.png"
Invoke-Item "E:\Are_UBNN_KWS\self\presentation\assets\judge_demo\enhanced_placement_zoom.png"
Invoke-Item "E:\Are_UBNN_KWS\self\presentation\assets\judge_demo\enhanced_routing_detail.png"

# Open Baseline Layout Images
Invoke-Item "E:\Are_UBNN_KWS\self\presentation\assets\judge_demo\baseline_full_die.png"
Invoke-Item "E:\Are_UBNN_KWS\self\presentation\assets\judge_demo\baseline_placement_zoom.png"
Invoke-Item "E:\Are_UBNN_KWS\self\presentation\assets\judge_demo\baseline_routing_detail.png"
```

---

## 4. Recommended Presentation Sequence for Judges

1. **Slide 1 (Full Physical Realization):** `enhanced_full_die.png` — Show full tapeout-ready $520 \times 520\ \mu\text{m}$ die with 601 IO pins and clean power distribution.
2. **Slide 2 (Architecture Placement):** `enhanced_placement_zoom.png` — Highlight standard-cell rows containing the 16 unipolar PEs and SECDED parity engines.
3. **Slide 3 (Routing Quality):** `enhanced_routing_detail.png` — Demonstrate clean multi-layer interconnect with zero DRC violations.
4. **Slide 4 (Comparative Assessment):** `baseline_full_die.png` vs. `enhanced_full_die.png` — Contrast standard-cell area and routing density between baseline and enhanced implementations.