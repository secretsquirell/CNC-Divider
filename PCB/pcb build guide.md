# PCB Build Guide — Main Board + Pendant Board

This replaces the earlier single "interconnect breakout" board. The Arduino
Nano now solders directly onto the main board. The human-interface parts
(OLED, encoder, index button) live on a separate pendant board, connected
to the main board by an 8-conductor cable.

## Mounting the Nano — female headers, not direct solder

If your Nano came with pin headers pre-soldered (common — check the BOM
entry you bought), it can't be soldered flat into the main board the
way a bare Nano could. Instead, solder **two 1x15 female pin header
strips** (0.1"/2.54mm pitch) into the same 30 through-holes described
below, then plug the Nano into them like a shield. The hole positions,
spacing, and net list are all identical either way — the routing in
this guide doesn't change, only what you solder into those holes.

This is arguably the better approach regardless of which Nano you
have: a socketed Nano can be swapped out in seconds if it ever fails,
without touching the board's soldering. If you'd rather solder a bare
Nano's legs directly through the board instead (skipping the header
strips), that works too — just be sure to solder every leg on both
sides of the board either way, per the note below.

## Trace and pad sizing
Traces are 1.0mm wide and pads are 1.9mm square — both sized generously
for hand-etching and hand-soldering (thicker traces etch more reliably
and are less prone to breaking; bigger pads are more forgiving to
solder and to drill). 1.9mm is close to the practical ceiling at this
board's 2.54mm (0.1") pin pitch — the tightest-spaced pads (the
power-in header's GND/5V pair, which sit at a 2mm diagonal offset
rather than the usual straight 2.54mm row spacing) cap out at 2.0mm
before touching, so 1.9mm leaves a small margin there while staying as
large as the layout allows everywhere else.

## Do you need to bridge anything by hand?

**No.** The main board uses two copper layers (front/top and back/bottom),
but every single point where a trace needs to move from one layer to the
other happens to land exactly on a component's own through-hole — a Nano
pin, a header pin, or a screw-terminal hole. When you solder that
component on both sides of the board (normal practice for a hand-etched,
non-plated board), the solder itself wicks through the hole and
electrically joins the top and bottom copper at that spot. That's your
"bridge" — no separate jumper wire required anywhere on either board.

**The one thing this depends on:** solder every through-hole component
pin on *both* sides of the board, even where a pin only mechanically
needs it on one side. If you'd rather not do that, or a specific hole
ends up hard to reach with solder from both sides, add a short offcut of
wire through that hole as a manual bridge — but as designed, none are
needed.

## Main board — layers and alignment

- Etch the TOP mask (`main_top_laser_mask.svg`) on one face.
- Etch the BOTTOM mask (`main_bottom_laser_mask.svg`) on the other face.
  This file is already mirrored left-right so that when you flip the
  blank over (like turning a page), its holes line up with the top
  layer's holes.
- **Before etching either side**, drill (or center-punch) the four
  corner mounting holes and at least two pin-header reference holes
  (e.g. the Nano's D13 pin and the VIN pin) all the way through the
  blank first. Use those as registration pins/marks when you flip the
  board to align the second mask — this is the main source of error in
  a two-sided hand-etch, so it's worth taking slowly.
- Drill all through-holes only after both sides are etched, so the same
  holes serve as your alignment reference throughout.

## Main board net list

| Net | Nano pin | Reaches |
|---|---|---|
| STEP | D9 | Driver header pin 3 |
| DIR | D8 | Driver header pin 4 |
| EN | D7 | Driver header pin 5 |
| SDA | A4 | Pendant header pin 5 |
| SCL | A5 | Pendant header pin 6 |
| ENC_CLK | D2 | Pendant header pin 4 |
| ENC_DT | D3 | Pendant header pin 3 |
| ENC_SW | D4 | Pendant header pin 2 |
| BTN_SIG | D5 | Pendant header pin 1 |
| GND | (either GND pin) | Driver header pin 2, Pendant header pin 7, Power-in header pin 1 |
| 5V | 5V pin | Driver header pin 1 (VDD), Pendant header pin 8, Power-in header pin 2 |

Driver header (5-pin, connects to your DRV8825 breakout): VDD, GND,
STEP, DIR, EN — in that order.

Pendant header (8-pin, connects via cable to the pendant board): BTN_SIG,
ENC_SW, ENC_DT, ENC_CLK, SDA, SCL, GND, 5V — in that order. Wire the
pendant cable pin-for-pin straight through (pin 1 to pin 1, etc.) — the
pendant board's incoming header uses the identical order, so no crossover
is needed.

Power-in header (2-pin): GND, 5V — this is where the buck converter's
output lands, feeding the whole board.

## Pendant board net list

Incoming 8-pin header (same order as above): BTN_SIG, ENC_SW, ENC_DT,
ENC_CLK, SDA, SCL, GND, 5V.

- OLED header (4-pin): VCC, GND, SDA, SCL
- Encoder header (5-pin): CLK, DT, SW, GND, VCC
- Button header (2-pin): SIG, GND

## Cable between the boards

Any 8-conductor cable works — a cut length of CAT5/CAT5e (8 wires) is a
cheap, common option, as is an 8-way ribbon cable with IDC connectors.
Keep wire pairs for SDA/SCL and the encoder lines away from noisy runs if
you route the cable near the stepper wiring; twisting the SDA/GND and
SCL/GND pairs together is cheap insurance if you see I2C glitches at
longer cable lengths (over ~1m).

## Verification method (for anyone extending this design)

Both boards were routed and checked programmatically: every trace segment
was modeled as a rectangle, connected regions were found with a
union-find over pairwise rectangle overlap, and the check confirmed (a)
each net's pads all resolve to one shared connected region, (b) no two
different nets' pads ever resolve to the same region, and (c) for the
main board, no pad is touched by conflicting top-layer and bottom-layer
regions. All of that passed clean on the final layout in this guide.
