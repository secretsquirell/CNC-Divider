# Enclosure — Print & Assembly Notes (Arduino Nano version)

File: `enclosure.scad` — open in **OpenSCAD** (free, openscad.org),
press F6 to render, then **File → Export → Export as STL**. It renders
the base and lid side by side in one file so you can slice both at
once, or comment out one `base();` / `lid();` call at the bottom to
export them separately.

This box is noticeably smaller than an Uno-based one (85×55×~34mm vs
120×85×40mm) since the Nano itself is only 45×18mm.

## Design approach
Control pendant only: Nano, OLED, rotary encoder, and index button. The
stepper driver stays in its own enclosure (heat + higher current), fed
through the rear cable pass-through, which also carries the Nano's own
5V/USB power in if you're running a USB cable out to a wall adapter
rather than powering the Nano from VIN.

## Layout (top panel, i.e. the lid)
```
 ┌─────────────────────────────────────┐
 │  [ OLED WINDOW ]           ( o )     │  encoder
 │                                      │
 │                             ( ● )    │  index button
 └─────────────────────────────────────┘
```

## Nano mounting — read this before printing
The standard Arduino Nano has **no mounting holes**; it's designed to
plug into a breadboard, with header pins running along both long
edges. Instead of standoffs, this enclosure prints a pair of **card-edge
rails** in the base — narrow slots that the bare edges of the Nano PCB
slide into, gripping it in place without any screws (similar to how a
graphics card slots into a desktop PC). Slide the Nano in from the open
top before you screw the lid on.

- If your Nano has pin headers pre-soldered (most do), the headers
  point downward into the case — make sure `rail_h` (height of the
  rails off the floor) clears your header pin length, or the rails
  will hit the header shroud. The default assumes ~4mm clearance;
  bump `rail_h` up if your headers are taller.
- If you'd rather not deal with rails, an easier alternative is to
  glue two strips of double-sided foam tape to the case floor and
  stick the Nano down flat, headers-down — works fine for a low-
  vibration desktop-style control box.

## Before you print — check these against your actual parts
- **USB connector type** — official Arduino Nano uses Mini-B; most
  Amazon clones use Micro-B or USB-C. The `usb_cutout_w/h` values
  default to a size that fits USB-C or Mini-B loosely; measure your
  actual board/cable and adjust before printing, since Micro-B is
  narrower.
- `oled_board_w/h` — 0.96" I2C OLED PCB sizes vary by supplier; measure
  yours before printing.
- `enc_hole_d` / `btn_hole_d` — sized for a standard KY-040 (7mm
  threaded bushing) and a 12mm panel-mount button.

## Assembly order
1. Print `base` and `lid` (PLA/PETG, 0.2mm layers, no supports needed
   in this orientation).
2. Slide the Nano into the card-edge rails, USB end toward the rear
   cutout.
3. Slide the OLED PCB into the pocket behind the lid's window from the
   underside; hot-glue lightly to keep it seated against the window.
4. Press the KY-040 encoder's threaded bushing and the index button
   through their lid holes and secure with their nuts.
5. Wire everything per `wiring_guide.md`; route the driver cable
   through the rear pass-through.
6. Screw the lid onto the base's four corner bosses (M3 x 8mm
   self-tapping).

## Suggested driver enclosure
The TB6600/DM542 driver is usually sold with its own metal case with
mounting ears — in most builds it's easiest to bolt that directly to
your machine frame near the K11 rather than 3D print a second box. If
you'd like a printable, ventilated enclosure for the driver too, let me
know and I'll design a matching one.
