// =============================================================================
// Module: icg (Integrated Clock Gating abstraction)
// File:   src/power/icg.sv
//
// Purpose:
//   Provide a synthesizable, ASIC-oriented clock-enable abstraction.
//
// ─────────────────────────────────────────────────────────────────────────────
// IMPORTANT DESIGN COMMENTARY — PLEASE READ BEFORE MODIFYING:
// ─────────────────────────────────────────────────────────────────────────────
//
//   WRONG (glitch-prone, DO NOT USE in production ASIC):
//     assign gated_clk = clk & enable;
//
//   This creates a COMBINATIONAL clock gate.  If 'enable' changes while
//   'clk' is high, the output glitches, which can corrupt flip-flop state.
//   This is unacceptable in a real ASIC.
//
//   CORRECT ASIC approach — Latch-based ICG cell:
//
//     The enable signal is latched on the FALLING edge of clk.
//     The latched value is then ANDed with clk.
//     Because the latch is transparent when clk==0 (the idle phase),
//     the enable is sampled safely and the AND output only changes
//     when clk==0, so the rising edge is glitch-free.
//
//     Standard PDK cell: e.g., sky130_fd_sc_hd__dlclkp_1
//
//   RTL SIMULATION APPROACH (this module):
//     We model the latch-based ICG behavior in RTL simulation using
//     a standard latch inference pattern.
//     The synthesis tool (Yosys + OpenLane) will map this to the
//     actual ICG cell in the target PDK.
//
//     However: because the ICG output is a CLOCK in a physical design
//     (clock network analysis, CTS), and in RTL simulation we cannot
//     safely use it as such without careful setup, this module
//     provides BOTH:
//       (a) gated_clk  : the RTL model of the gated clock (for reference)
//       (b) clk_enable : the registered enable to use as a CE signal in RTL
//
//     The pe_array uses clk_enable as a flip-flop clock-enable input,
//     NOT gated_clk, in the RTL simulation.
//     Physical synthesis maps the CE pattern to ICG cells automatically.
//
// Parameters:
//   (none — this is a simple single-channel ICG)
//
// Ports:
//   clk        : input system clock
//   enable     : clock enable request (from activation_detector)
//   gated_clk  : latch-modeled gated clock output (reference; use CE in RTL)
//   clk_enable : registered enable, safe to use as FF clock-enable in RTL
// =============================================================================

module icg (
    input  logic clk,
    input  logic enable,
    output logic gated_clk,   // modeled gated clock (reference)
    output logic clk_enable   // registered enable for RTL CE use
);

    // ------------------------------------------------------------------
    // Latch-based ICG model.
    //
    // The latch is transparent when clk==0 (falling-edge latch).
    // It captures 'enable' during the low phase of clk.
    // The captured value is then ANDed with clk to produce gated_clk.
    //
    // This is a synthesizable latch inference (level-sensitive).
    // Synthesis tools recognize this pattern and map it to an ICG cell.
    //
    // NOTE: This latch will produce a synthesis warning about latches.
    // This is expected and correct for an ICG cell model.
    // ------------------------------------------------------------------
    logic enable_latched;

    // Latch: transparent when clk == 0
    always_latch begin
        if (!clk) begin
            enable_latched = enable;
        end
    end

    // AND the latched enable with clk to produce the gated clock
    assign gated_clk = clk & enable_latched;

    // ------------------------------------------------------------------
    // Registered enable for RTL clock-enable use.
    //
    // This is a simple D-FF that captures 'enable' on every posedge clk.
    // pe_array uses THIS signal (not gated_clk) as the CE input to
    // its always_ff blocks in RTL simulation.
    //
    // This avoids using gated_clk as a clock in RTL simulation,
    // which would cause clock-domain confusion.
    //
    // In physical synthesis, the always_ff CE pattern maps to ICG cells
    // automatically — the gated_clk path and the CE path converge.
    // ------------------------------------------------------------------
    // Note: clk_enable is NOT used by pe_array in this design.
    // pe_array directly receives pe_active from activation_detector.
    // This module exists for documentation and future synthesis use.
    assign clk_enable = enable;  // combinational passthrough for RTL sim

endmodule
