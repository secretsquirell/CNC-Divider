# Enclosure — Print & Assembly Notes (Stacked / Taller Layout)

File: `enclosure.scad` — open in **OpenSCAD** (free, openscad.org),
press F6 to render, then **File → Export → Export as STL**. Renders
base and lid side by side in one file.

This is the compact-footprint version: ~110×76mm, close to the
interconnect PCB's own 95×60mm size, versus ~160×76mm for the wide
side-by-side version. The trade is height — assembled height is about
47mm instead of ~34mm — because the Nano now sits on a raised shelf
**above** the PCB rather than beside it.

## Design approach — two stacked compartments
```
        ┌─────────────────────────────┐  ← lid: OLED / encoder / button
        ├─────────────────────────────┤
        │   Nano on card-edge rails    │  ← upper compartment
        │   (sits on the shelf)        │
        ├─────────────────────────────┤  ← shelf plate
        │   Interconnect PCB           │  ← lower compartment
        │   (on 4 short standoffs)     │
        └─────────────────────────────┘  ← base floor
```

The shelf is supported by 4 corner posts that do double duty: lower
down they hold the shelf up, and at the very top they're the same
bosses the lid screws into — one printed feature, two jobs, which is
also what keeps them out of the PCB's way (there wasn't room for
separate support posts once the box footprint shrank to nearly the
PCB's own size).

## Before you print — check these
- **Component clearance under the shelf.** The shelf sits 9mm above
  the PCB's top surface (`shelf_clearance_above_pcb`) — plenty for
  wires and small headers, but if you soldered anything unusually tall
  to the interconnect PCB, increase this value.
- **USB connector type and orientation.** The cutout is on the
  **right-hand wall** (not the rear) because the Nano's USB port faces
  along its length axis, out the open end of the card-edge rails —
  this was actually a bug in an earlier version of this design (fixed
  here) where the cutout was placed on the wrong wall. Confirm which
  connector your Nano clone uses (Mini-B/Micro-B/USB-C) and adjust
  `usb_cutout_w/h` before printing.
- `oled_board_w/h` and `oled_hole_dx/dy` — vary by supplier; measure
  yours (see the display-mounting note below).
- **Print supports under the shelf.** It spans the full interior
  (~105mm) unsupported at both long edges. Enable supports
  ("support on build plate only" is enough, not "everywhere") for the
  shelf region, or confirm your printer/slicer handles a 40mm+ bridge
  cleanly before skipping them — test a scrap piece first if unsure.

## Display mounting
The OLED is held two ways, combined: a shallow alignment recess sized
to the PCB, plus four printed standoffs with pilot holes for M2
self-tapping screws (driven in from inside the case before final
assembly). If your OLED board has no mounting holes (common on cheap
4-pin modules), skip the screws and just use the recess plus a dab of
hot glue or foam tape at the corners.

## Assembly order
1. Print `base` and `lid` (PLA/PETG, 0.2mm layers; supports under the
   shelf as noted above).
2. Screw the interconnect PCB onto its four lower standoffs (M3 x 6mm
   self-tapping) — do this before anything else is wired to it.
3. Slide the Nano into the card-edge rails on top of the shelf, USB
   end toward the right-hand wall cutout.
4. Seat the OLED PCB into the lid's alignment recess and drive four M2
   self-tapping screws into the printed standoffs (or glue/tape it if
   your board has no mounting holes).
5. Press the KY-040 encoder's threaded bushing and the index button
   through their lid holes and secure with their nuts.
6. Wire everything per `wiring_guide.md` and `pcb_build_guide.md` —
   short jumpers from the Nano's pins down to the PCB's input header
   below, then from the PCB's breakout headers out to the OLED,
   encoder, button, and the driver cable through the rear pass-through.
7. Screw the lid onto the four corner posts (M3 x 8mm self-tapping).

## Suggested driver enclosure
The DRV8825 (or TB6600/DM542, if you went that route) still stays in
its own small enclosure or is bolted directly to your machine frame —
not part of this box. Let me know if you'd like a matching printable
enclosure designed for it.
