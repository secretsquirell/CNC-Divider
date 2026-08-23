# Enclosures — Print & Assembly Notes

Two separate boxes now, in place of the earlier single stacked design:

- `enclosure_main.scad` — main board (Nano-carrier PCB, DRV8825 driver,
  LM2596 buck converter, Anderson Powerpole power input)
- `enclosure_pendant.scad` — pendant board (OLED, rotary encoder, index
  button)

Both open the same way: press F6 in OpenSCAD to render, then File →
Export → Export as STL. Each file lays out its base and lid side by
side for printing.

## Main board enclosure

~194 × 84 × 22mm. Two zones on the floor: the PCB section (with 4
standoffs matched to the board's own verified-clear mounting holes)
and a component bay beside it for the buck converter and DRV8825.

**Before you print, check these:**
- **Buck converter and DRV8825 footprint.** Both are adhesive/hot-glue
  mounted onto a shallow printed placement outline rather than screw
  standoffs, since hole spacing on these cheap breakout modules varies
  a lot between suppliers. The outlines assume a common ~45×23mm buck
  module and ~22×16mm DRV8825 breakout — measure yours and adjust
  `buck_w/h` and `drv_w/h` if they're a different size before
  printing, or the module won't sit inside its outline.
- **Anderson Powerpole cutout.** Sized for a standard 2-pole gang,
  red+black housings dovetailed and stacked vertically — the common
  PP15/30/45 convention. The exact housing dimensions vary by current
  rating (PP15 vs PP30 vs PP45), so dry-fit your specific connector
  before committing to a print; the cutout includes a small retaining
  lip on three sides but is easy to hand-file larger if needed.
- **Motor wire hole placement.** Positioned near the DRV8825 for a
  short internal run — it's a simple round hole sized for a 4-conductor
  cable bundle (no strain relief built in; add a rubber grommet or
  zip-tie anchor point if the motor cable will see any flexing in use).
- **USB connector type and orientation** — same caveat as before: the
  Nano's USB cutout position/size depends on which clone you bought
  (Mini-B/Micro-B/USB-C). Confirm before printing.
- **Box height (22mm)** clears the buck converter's tallest component
  (its inductor, typically the highest point on the board) with some
  margin — if your specific module runs taller, increase `box_h_base`.

## Pendant enclosure

~63 × 64 × (12+6)mm. PCB standoffs on the base, OLED window/encoder
shaft hole/button hole in the lid — same general approach as the
original design's lid, just on its own smaller box now.

**Before you print, check these:**
- `oled_board_w/h` and `oled_hole_dx/dy` — vary by supplier; measure
  yours.
- **Encoder shaft hole diameter** (`enc_hole_d`) — matched to a common
  KY-040 module's threaded bushing; confirm against your specific part.
- **Incoming cable hole** — sized for the 8-conductor cable coming from
  the main enclosure; no connector is assumed inside this hole itself,
  so if you're using a panel-mount connector instead of a bare cable
  entry, resize accordingly.

## Assembly order (both boxes)
1. Print base + lid for each enclosure.
2. Solder/populate each PCB per `pcb_build_guide.md`.
3. Mount each PCB to its base on the printed standoffs (M3 screws).
4. For the main enclosure: glue the buck converter and DRV8825 into
   their placement outlines, then wire them to the main PCB's headers
   and to the Powerpole connector per `wiring_guide.md`.
5. Run the 8-conductor cable between the two boxes before closing
   either lid — much easier to solder/crimp with the boards accessible.
6. Close both lids (M3 screws into the corner posts; heat-set inserts
   recommended if you'll be opening these more than a couple of times).
