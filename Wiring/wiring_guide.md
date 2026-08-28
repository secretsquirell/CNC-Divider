# Dividing Head Controller — Wiring Guide (Arduino Nano)

## Important note on the K11
The VEVOR K11-100 dividing head is a mechanical unit + NEMA23 4-lead
stepper motor with a 6:1 belt reduction. **It does not include a driver.**
The Arduino sends STEP/DIR/ENABLE logic signals to a DRV8825 stepper
driver mounted inside the same enclosure as the Nano, and that driver
supplies the actual motor current to the K11's NEMA23 motor.

```
        Arduino  ──STEP/DIR/EN──▶  DRV8825 (same box)  ──A+/A-/B+/B-──▶  K11 NEMA23 motor
      (logic only)                 (does the power)          (out through its own
                                                                dedicated wall hole)
```

## Two enclosures, one cable between them
This build is split into two boxes:

- **Main board enclosure** — the Nano-carrier PCB (Nano soldered
  directly to it), the DRV8825 driver, and the LM2596 buck converter,
  all in one box. Power comes in through a panel-mount Anderson
  Powerpole pair. Two more holes exit this box separately: one for the
  4-wire stepper motor cable, one for the 8-conductor cable to the
  pendant.
- **Pendant enclosure** — the OLED, rotary encoder, and index button,
  connected back to the main board by that 8-conductor cable.

Keeping the motor leads and the pendant cable on physically separate
holes (rather than bundling everything through one opening) keeps the
higher-current motor wiring away from the low-level I2C/encoder
signals in the same cable run — worth doing even over a short distance
inside the box.

**Driver choice affects torque headroom.** This build uses a DRV8825
module — a cheaper option (~$4–8) than a TB6600 (~$12–15), but it caps
out around 1.5A per phase without cooling, or ~2.2A with a heatsink and
airflow, below the K11 motor's ~3A rating. That's a reasonable trade
for a dividing head, which mostly rotates-then-holds between cuts
rather than driving continuously under heavy load — but if you plan to
rotate the head *while* actively milling under real cutting force
(helical/spiral work), use a TB6600 or DM542 instead for the extra
torque margin; both are pin-compatible with everything below (same
STEP/DIR/ENABLE wiring), though a TB6600 is a boxed module and won't
fit the driver bay's footprint — mount it externally instead if you go
that route.

## Shared power supply architecture
A single 24V supply powers both the DRV8825 (directly) and the Arduino
Nano (through the buck converter, since the Nano's onboard regulator
isn't meant to drop 24V down to 5V continuously). Power enters the main
enclosure through a panel-mount **Anderson Powerpole** pair (red = 24V+,
black = 24V–) rather than a bare cable gland — Powerpoles are
polarized, rated well above what this build draws, and let you
disconnect the whole box from its supply without opening it up. The
24V rail still has a fuse and power switch ahead of the Powerpole
connector, external to this enclosure.

```
  AC mains
     │
     ▼
┌───────────┐     ┌────────┐     ┌─────────┐     ┌────────────────────┐
│  24V 5A   │────▶│  Fuse  │────▶│  Power  │────▶│ Anderson Powerpole   │
│  supply   │     │ (5A)   │     │ switch  │     │ pair (panel mount)   │
└───────────┘     └────────┘     └─────────┘     └────────────────────┘
                                                     │              │
                                          (inside the main enclosure, from here down)
                                                     ▼              ▼
                                          ┌─────────────────┐  ┌──────────────┐
                                          │ DRV8825 driver   │  │ LM2596 buck   │
                                          │ VMOT / GND       │  │ converter     │
                                          │ (24V direct)     │  │ IN+ 24V→OUT  │
                                          └─────────────────┘  │ 5V regulated  │
                                                                 └──────────────┘
                                                                        │
                                                                        ▼
                                                          Nano 5V pin + GND
                                                        (also powers OLED,
                                                         encoder via the
                                                         pendant cable)
```

**Why not just power the Nano from the driver's 24V or from VIN
directly?** The Nano's onboard linear regulator is rated for the
board's own current draw only (a few hundred mA) and is only meant to
take up to about 12V comfortably — running it continuously from 24V
would waste a lot of power as heat and risks overheating the regulator.
A small buck converter set to 5V and wired straight into the Nano's 5V
pin (bypassing the onboard regulator entirely) is the standard, safe
way to share one supply between logic and power electronics.

**Fuse the 24V input, not each branch separately** — one fuse sized for
the combined worst-case draw (motor + electronics) ahead of the
splitter protects the whole system; that's simpler and just as safe as
fusing each branch for a project this size.

## Block diagram

```
                          +5V (from Nano)                  +24V (driver PSU, separate)
                            │                                    │
        ┌───────────────┐   │        ┌────────────────────┐     │
        │  Arduino Nano │   │        │   DRV8825 driver    │     │
        │ (D13 end up)  │   │        │   module            │─────┘  (VMOT)
        │               │   │        │                     │
        │   A4 (SDA)────┼───┼────────┤                     │
        │   A5 (SCL)────┼───┤        │  STEP  ◄──── D9     │
        │               │            │  DIR   ◄──── D8     │
        │   D2 ─────────┼── Encoder CLK   ENABLE ◄── D7     │
        │   D3 ─────────┼── Encoder DT    GND   ── GND      │
        │   D4 ─────────┼── Encoder SW    VDD   ── Nano 5V  │
        │        (+ GND)│                 RESET ─┬ tied     │
        │   D5 ─────────┼── Index button  SLEEP ─┘ together │
        │               │                 (pulled HIGH)     │
        │   GND ────────┼─────────────────┴──── GND (common!) │
        │   5V ─────────┘                                      │
        └───────────────┘                 A1 A2 B1 B2 ─────────┼──▶ K11 NEMA23
        (USB Mini-B or Micro-B,          └──────────────────────    motor (4 wires)
         depending on which Nano
         you bought — see BOM)

        OLED (SSD1306 128x64, I2C):
          VCC → 5V (or 3.3V — check your module's silkscreen)
          GND → GND
          SCL → A5
          SDA → A4
```

## Pin table

| Signal | Arduino Nano pin | Notes |
|---|---|---|
| OLED SDA | A4 | I2C data |
| OLED SCL | A5 | I2C clock |
| OLED VCC | 5V | some modules want 3.3V — check silkscreen |
| OLED GND | GND | |
| Encoder CLK | D2 | must be interrupt-capable (D2 or D3) |
| Encoder DT | D3 | |
| Encoder SW | D4 | to GND when pressed, uses internal pull-up |
| Index button | D5 | other leg to GND, uses internal pull-up |
| Driver STEP | D9 | |
| Driver DIR | D8 | |
| Driver ENABLE | D7 | active LOW on the DRV8825 (matches the sketch) |
| Driver GND | GND | common ground with Nano |
| Driver VDD (logic power) | Nano 5V | DRV8825 needs a separate logic-side 5V feed, not just STEP/DIR/GND |
| Nano 5V (power in) | buck converter OUT+ | fed from the shared 24V rail, NOT USB, when running standalone |
| Nano GND (power in) | buck converter OUT- | common with 24V supply GND |

## Nano-specific notes

- **The Nano solders directly onto the main PCB now** — all 30 pins,
  full 2-row 0.1" footprint — rather than sitting separately and
  wiring in with jumpers. See `pcb_build_guide.md` for the exact
  footprint and net list. Solder every pin on both sides of the board
  (see the build guide's note on why that matters even for unused
  pins).
- **USB connector varies by supplier.** The official Arduino Nano uses
  Mini-B; most Amazon clones (CH340-based) use Micro-B. Check which one
  you bought before printing the enclosure's USB cutout position/size.
- **Power the Nano from the shared 24V supply via the buck converter's
  5V output → Nano's "5V" pin, not USB.** This lets the whole system
  run from one wall supply. You can still plug in USB separately for
  reprogramming; the Nano automatically prioritizes whichever source is
  higher voltage at the moment (so leaving both connected is fine, and
  common practice for the Nano's diode-OR'd power inputs — but don't
  power the buck converter's 5V output back INTO the USB port itself,
  only into the 5V pin).
- **Uploading**: most clone Nanos need Tools → Processor → "ATmega328P
  (Old Bootloader)" in the Arduino IDE, or the upload will fail with a
  "programmer not responding" error.

## Setting up the LM2596 buck converter (24V → 5V)
1. Before connecting it to the Nano, power the LM2596 module alone from
   the 24V supply and measure its output with a multimeter.
2. Turn the onboard potentiometer (small screwdriver) until the output
   reads as close to **5.00V** as you can get it. Recheck after a few
   minutes — these modules can drift slightly as they warm up.
3. Only then connect OUT+ to the Nano's 5V pin and OUT– to GND. Getting
   the voltage right *before* connecting it protects the Nano — feeding
   it much more than 5V through the 5V pin bypasses the onboard
   regulator's protection entirely.
4. Common ground: the buck converter's input GND, output GND, the
   Nano's GND, and the stepper driver's GND must all be tied together.

## Setting up the DRV8825 driver

> **Note:** if you're using the StepperOnline-style "5056" industrial
> driver instead (opto-isolated PUL/DIR/ENA inputs, DIP-switch current
> and microstep settings) — see the dedicated section below instead of
> this one. This section is for the original bare DRV8825 module build.

The DRV8825 is a bare module, not an assembled box like the TB6600 —
it needs a few extra setup steps the TB6600 doesn't:

1. **Tie RESET to SLEEP together** and pull that joined pin HIGH (to
   VDD/5V). Without this the chip stays in a low-power reset state and
   the motor won't move at all. Many of the cheap "expansion board"
   breakouts (see BOM) do this automatically — check yours; if you're
   wiring the bare module directly, add this jumper yourself.
2. **Set the microstep resolution** with the MS1/MS2/MS3 pins (tie each
   to VDD for HIGH or GND for LOW):

   | MS1 | MS2 | MS3 | Resolution |
   |---|---|---|---|
   | L | L | L | Full step |
   | H | L | L | 1/2 |
   | L | H | L | 1/4 |
   | H | H | L | 1/8 |
   | L | L | H | 1/16 |
   | H | L | H | 1/32 |

   Whatever you choose, set the matching value in the firmware's
   Calibrate menu (Driver microstep) so the steps-per-degree math stays
   correct.
3. **Set the current limit** with the onboard potentiometer — this is
   the step that protects both the driver and the motor:
   - Power the driver alone (motor and STEP/DIR disconnected) from your
     24V supply.
   - With a multimeter, measure DC voltage between the potentiometer's
     wiper (the metal screw itself is usually the test point) and any
     GND pin.
   - The DRV8825's current limit follows `Current = Vref × 2`. For a
     conservative, cool-running setting well within the module's
     no-heatsink capability, aim for **Vref ≈ 0.6–0.7V** (~1.2–1.4A). If
     you've mounted the heatsink and have some airflow, you can go
     higher, up to **Vref ≈ 1.0–1.1V** (~2.0–2.2A) — don't exceed that
     without active cooling.
   - Turn the potentiometer with a small screwdriver while watching the
     multimeter; there's no "correct direction" printed consistently
     across clone boards, so adjust slowly and re-check.
4. **The bulk capacitor from the Critical Wiring Notes section below is
   not optional for this driver** — the DRV8825 is specifically
   documented as vulnerable to voltage-spike damage from motor back-EMF
   without one nearby, even at 24V. Mount the capacitor as close to the
   driver's VMOT/GND pins as your wiring allows.

## Setting up the 5056 stepper driver

This driver is a different class of part from the DRV8825/A3967 —
opto-isolated differential inputs, DIP-switch configuration, and a
current rating (up to 5.6A on most "5056" boards) with real headroom
above the K11 motor's 3A rating. If you've swapped to this driver, use
this section instead of the DRV8825 one above; the firmware has
already been updated to match (see the comments in `setup()` around
`stepper.setPinsInverted()`).

**Wiring — this is not the same as STEP/DIR/EN wiring:**
- Tie **PUL+, DIR+, and ENA+ together to the Nano's 5V.**
- Wire **PUL- to the Nano's STEP pin (D9), DIR- to DIR (D8), ENA- to
  ENABLE (D7).**
- This is opposite polarity from the DRV8825/A3967: a step happens
  when the Nano pulls PUL- LOW (sinking current through the opto), not
  when it goes HIGH. The firmware already accounts for this.
- **Enable polarity varies by driver model and isn't something to
  assume** — after wiring, test it: if the motor only refuses to move
  with ENA connected but works fine with ENA+/ENA- left disconnected,
  the sense is inverted from what the firmware expects. The fix is a
  one-line change (`digitalWrite(PIN_ENABLE, LOW)` → `HIGH` in
  `setup()`), not a rewiring job.

**Current limit — set with SW1/SW2/SW3, read directly off your
driver's printed table** (values vary slightly between boards, so
don't assume the numbers below without checking your own label):
- For the K11's 3A-rated motor, the closest setting *at or under* 3A is
  usually preferable to rounding up — don't pick a setting above the
  motor's rating.
- **SW4 controls idle current**: half-current standby vs. full current
  at all times. For a dividing head, which needs to hold its position
  firmly against cutting force between indexes (not just idle),
  **full current is the right choice**, not the half-current standby
  mode some of these drivers default to for 3D-printer-style use.

**Microstep — set with SW5/SW6/SW7/SW8, read directly off your
driver's printed table.** Don't guess this from a photo — a
transcription error here silently produces wrong angles, which is a
much worse failure mode than the driver simply not working. Pick a
value (8 or 16 is a reasonable default for smooth motion without
excessive step frequency), read the exact switch positions off your
own unit's label, and set that same number in the firmware's Calibrate
menu (Driver microstep) so the steps-per-degree math matches. As
before, a quick sanity check once it's running: command a full 360°
move and confirm the chuck completes exactly one turn.

## Wiring the motor to the driver

The DRV8825's two output pairs are usually labeled **A1/A2** and
**B1/B2** on the breakout's silkscreen (some boards print it as
1A/1B and 2A/2B instead — same idea). The 5056 driver labels the same
concept **A+/A-** and **B+/B-** on its screw terminals. Either way,
each pair drives one full coil of the K11's NEMA23 motor. What matters
is that each pair connects to one whole coil — not two wires from
different coils.

**Find the coil pairs with a multimeter before connecting anything —
don't trust wire color alone**, since it isn't standardized between
motor manufacturers:
1. Set the meter to resistance/continuity.
2. Test all 6 possible combinations among the motor's 4 wires.
3. Exactly 2 pairs should show low resistance (typically a few ohms
   for a NEMA23) — those are your two coils.
4. The other 4 combinations should show open/infinite resistance,
   confirming the coils are electrically isolated from each other, as
   they should be in a proper 4-lead bipolar motor.

A common (not universal) color scheme is black+green = coil A,
red+blue = coil B — worth checking if VEVOR included a wiring label
with the K11's motor cable, but verify with the meter regardless.

Connect one coil to A1/A2 (or A+/A- on the 5056), the other to B1/B2
(or B+/B-) — it doesn't matter which physical coil you call "A" vs
"B." Within a pair, swapping the two wires only reverses that coil's
polarity, which just reverses the motor's rotation direction for a
given DIR signal; it won't damage anything or cause erratic operation.
If the K11 turns backward from what you expect once everything's
wired up, there's no need to re-wire — just flip the `direction`
setting in the firmware's menu.

**Power the driver off before connecting or disconnecting the
motor.** Hot-plugging motor phases on a powered driver can spike the
output stage from back-EMF and damage it — always connect the motor
first, then power up.

## Wiring the Anderson Powerpoles
- Crimp (preferred) or solder 24V+ into a red PP15/30/45 housing and
  24V– into a black one, then dovetail them together — red on top,
  black on bottom is the common convention, but what matters most is
  being consistent across every connector you build so plugs are never
  ambiguous.
- Powerpoles have no inherent polarity lockout by color alone — the
  physical dovetail only tells you the two halves fit together, not
  which one is positive. Label the mating cable end too, especially if
  anyone else might plug it in.
- On the enclosure side, solder short leads from the panel-mount
  housing to: the buck converter's IN+/IN– and the DRV8825's VMOT/GND
  (or a small internal terminal block/bus if you'd rather not double up
  wires on one housing's solder cup).

## Critical wiring notes

1. **Common ground is mandatory.** Arduino GND, the driver's signal-side
   GND, the buck converter's GND, and the 24V power supply's negative
   terminal must all be tied together, or STEP/DIR pulses will be
   unreliable or won't register.
2. **The NEMA23 motor draws its current from the driver's 24V rail, not
   through the Arduino.** The Arduino only ever sees logic-level
   STEP/DIR/ENABLE signals.
3. **Set the DRV8825's current limit** using its onboard potentiometer
   (see "Setting up the DRV8825 driver" above) and your chosen
   microstepping via the MS1/MS2/MS3 pins — update the "Driver
   microstep" value in the firmware's Calibrate menu to match.
4. **Driver ENABLE polarity**: the DRV8825 enables its outputs when EN
   is pulled LOW, which is what the sketch assumes — no changes needed.
5. Keep the 4-wire motor cable separate from the STEP/DIR signal wiring
   where practical (don't bundle them together) to reduce electrical
   noise on the pulse lines.
6. **A bulk capacitor across the 24V rail near the driver is mandatory
   for the DRV8825** (1000–2200µF, rated ≥35V) — see the dedicated note
   above. Cheap DRV8825 modules don't include this themselves.
7. **Fuse the 24V input** (see BOM) between the power supply and
   everything else. The DRV8825 draws far less than the TB6600 would
   (≤2.2A vs up to 4A), so a 5A fuse is comfortably conservative here —
   no need to downsize it.
8. **Switch on the low-voltage (24V DC) side**, not the mains side —
   it's safer to wire, and a DC-rated toggle/rocker switch is cheap and
   widely available (see BOM).

## Steps-per-degree math (for reference)

```
steps_per_degree = (motor_steps_per_rev × microstep × gear_ratio) / 360
```

Defaults in firmware: 200 steps/rev × 8 microstep × 6.0 gear ratio ÷ 360
= **26.67 steps/degree**. If you change the driver's microstepping DIP
switches, update the "Driver microstep" value in the Calibrate menu to
match — the firmware recalculates automatically.
