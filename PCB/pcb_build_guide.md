# Laser-Etched Interconnect PCB — Build Guide

## What this board is

This is **not** a carrier board the Nano plugs into — the Nano stays in
its own 3D-printed enclosure (see `enclosure.scad`/`enclosure_notes.md`)
and connects to this board with short wires. This PCB is a small
**breakout/interconnect hub**: it takes the ~11 signal wires coming from
the Nano and distributes them (plus shared 5V/GND) out to the OLED,
encoder, index button, stepper driver, and power input, so you don't
end up with a rat's nest of loose Dupont jumpers inside the enclosure.

Single-sided, 95 x 60mm, hand-routed with **zero jumper wires** — every
net was checked programmatically for accidental shorts before finalizing
(see the routing notes at the bottom of this doc if you're curious).

## Files

- `pcb_copper_reference.svg` — shows the finished board as it should
  look after fabrication (copper-colored traces/pads with labels, drill
  centers marked). Use this to understand the layout and check your
  wiring against it — **don't** feed this one to the laser.
- `pcb_laser_mask.svg` — the actual file for your laser software. Pure
  black/white, no labels: **white = copper stays, black = laser
  removes.** Sized in real mm (95 x 60mm) so most laser software will
  import it at true scale — double check the imported size before
  running.

## Two ways to use the mask file, depending on your laser

**Option A — direct copper ablation** (needs a fiber laser, or a
higher-power diode laser ~10W+ that's proven able to remove copper foil):
Load a bare copper-clad FR4 blank, import `pcb_laser_mask.svg`, set your
software to engrave/fill the black regions only, and run at whatever
power/speed ablates the copper foil (35µm is common) without cutting
into the fiberglass beneath. Test on a scrap corner first.

**Option B — resist-mask + chemical etch** (works with any diode laser,
more forgiving, what most hobbyists actually use): Coat the copper-clad
blank with a resist (photoresist, or even a black permanent-marker
fill/spray paint), laser-engrave the black regions of the mask to strip
resist there, then etch the exposed copper away in ferric chloride or
ammonium persulfate as usual. The mask file works identically either
way — same black = remove, white = keep logic.

## Drilling

Lasers don't cut through 1.6mm FR4, so through-holes still need a hand
drill or drill press. `pcb_copper_reference.svg` marks the center of
every pad with a small circle — center-punch or use those as a guide,
drill ~0.8mm for signal wires (upsize if you're using a specific
connector's pin).

## Net list / pad reference

| Pad label | Net | Connects to |
|---|---|---|
| 5V, GND, SDA, SCL, D2, D3, D4, D5, D7, D8, D9 | — | wire in from the matching Arduino Nano pin |
| OLED VCC / GND / SDA / SCL | shared with 5V/GND/SDA/SCL | wire out to the SSD1306 module |
| ENC CLK / DT / SW | D2 / D3 / D4 | wire out to the KY-040 encoder |
| ENC VCC / GND | shared 5V/GND | wire out to the KY-040 encoder |
| BTN SIG / GND | D5 / shared GND | wire out to the index push button |
| DRV STEP / DIR / EN | D9 / D8 / D7 | wire out to the stepper driver's PUL+/DIR+/ENA+ |
| DRV GND | shared GND | wire out to the driver's PUL-/DIR-/ENA- (common ground) |
| PWR 5V / GND | shared 5V/GND | wire in from the LM2596 buck converter's output — this is how the board (and everything on it) gets powered from the shared 24V supply, per `wiring_guide.md` |

This matches the pin assignments in `dividing_head_controller.ino` and
`wiring_guide.md` exactly — no firmware changes needed.

## Routing notes (if you want to modify the layout)

The layout uses three columns: an **input column** (x=10mm) receiving
wires from the Nano, a **direct column** (x=28mm) for signals that map
one-to-one to a Nano pin (straight horizontal traces, one per row, so
they can never cross each other), and an **aux column** (x=58mm) for
the shared 5V/GND taps, fed by two comb-shaped bus structures routed
through the clear margins above (y<8mm) and below/left (x<10mm, y>34mm)
the main pin rows specifically so they don't cross any signal trace.
Every net was verified as a single connected region with no unintended
overlaps before export. If you edit pad positions, re-run that kind of
check before cutting a board — it's easy to introduce an accidental
short by eye that a quick geometry check catches immediately.
