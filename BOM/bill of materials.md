# Bill of Materials — Dividing Head Controller

Prices/listings change on Amazon; treat these as a starting point and
confirm specs (voltage, current rating, hole spacing) before buying.
The dividing head itself and its NEMA23 motor are assumed already owned
(the VEVOR K11-100).

| # | Part | Purpose | Example Amazon link |
|---|------|---------|----------------------|
| 1 | Arduino Nano V3.0, presoldered headers (ATmega328P, CH340, Mini-B USB, with cable) | Main controller | https://www.amazon.com/ELEGOO-Pre-soldered-ATmega-Compatible-Arduino/dp/B0D5LYFRQP |
| 1b | *(optional)* Nano IO screw-terminal expansion shield | Turns the Nano's small pin headers into secure screw terminals — makes permanent wiring much easier than Dupont jumpers alone | https://www.amazon.com/Compatible-Electronic-Component-Precision-Performance/dp/B0F47X3BWN |
| 2 | 0.96" SSD1306 128x64 I2C OLED display | Menu / status screen | https://www.amazon.com/UCTRONICS-SSD1306-Self-Luminous-Display-Raspberry/dp/B072Q2X2LL |
| 3 | KY-040 rotary encoder module (with push button) | Menu navigation & value entry | https://www.amazon.com/Cylewet-Encoder-15%C3%9716-5-Arduino-CYT1062/dp/B06XQTHDRR |
| 4 | 12mm momentary push button switch (panel mount) | Dedicated INDEX button | https://www.amazon.com/Momentary-Button-Switch-Waterproof-Mounting/dp/B07411Z79K |
| 5 | DRV8825 stepper driver module with heatsink (2–5 pack) | Drives the K11's NEMA23 motor from STEP/DIR signals — cheaper alternative to the TB6600 (see trade-off note below) | https://www.amazon.com/DRV8825-Current-Microstepping-Heatsink-STEPPER-DRIVER-DRV8825/dp/B07TYJ5WLC |
| 5b | Stepper driver expansion/breakout board (A4988/DRV8825-compatible, screw terminals) | Turns the DRV8825's bare 0.1" pins into secure screw terminals for the motor and power leads — much easier and safer than soldering directly to the driver module. Mounted inside the main enclosure's component bay | https://www.amazon.com/DAOKAI-Stepper-Expansion-DRV8825-Printer/dp/B0CR3ZD91Y |
| 6 | 24V 5A switching power supply | Single shared supply — powers the stepper driver directly, and the Nano/OLED/encoder through a buck converter | https://www.amazon.com/120W-Power-Supply-100V-240V-110V/dp/B07K9HBHGR |
| 7 | Anderson Powerpole connector kit (PP15/30/45, red+black housings + contacts) | Panel-mount power input for the main enclosure — polarized, disconnects the whole box from its supply without opening it | https://www.amazon.com/s?k=anderson+powerpole+connector+kit+red+black |
| 7b | LM2596 adjustable buck converter module (3A, screw terminals) | Steps the shared 24V rail down to a regulated 5V to power the Nano (and OLED/encoder through it) — do NOT power the Nano's 5V pin directly from 24V | https://www.amazon.com/LM2596-Converter-Module-Adjustable-Step-Down/dp/B0H2J7YKNS |
| 7c | Inline 5x20mm fuse holder + 5A fast-blow glass fuses | Protects the whole system — placed on the 24V line right after the power supply, before the switch/splitter | https://www.amazon.com/MECCANIXITY-5X20mm-Inline-Holder-Fast-Blow/dp/B0GX9DRFF2 |
| 7d | SPST toggle/rocker switch, 20A rated, 12mm panel mount | Main power switch for the 24V DC rail (safer to switch on the low-voltage side than mains) | https://www.amazon.com/MGI-SpeedWare-Latching-Toggle-Switch/dp/B0FXZF86JW |
| 7e | 2-in/8-out screw terminal power distribution block | Splits the fused, switched 24V rail cleanly to the driver and the buck converter without stacking multiple wires under one screw | https://www.amazon.com/Jienk-Terminal-Distribution-Mounting-Amplifier/dp/B0B55R8TRH |
| 7f | Electrolytic capacitor, 2200µF 35V (radial) | Bulk/snubber capacitor across the 24V rail near the driver, to absorb motor back-EMF spikes — skip if your driver or PSU already has one built in | https://www.amazon.com/s?k=2200uf+35v+radial+electrolytic+capacitor |
| 8 | Dupont jumper wire kit (M-M, M-F, F-F) | All Arduino ↔ module signal wiring | https://www.amazon.com/Elegoo-EL-CP-004-Multicolored-Breadboard-arduino/dp/B01EV70C78 |
| 9 | 22 AWG hookup wire, a few colors | Cleaner permanent wiring than jumpers, for inside the enclosure | https://www.amazon.com/s?k=22+awg+hookup+wire+kit+stranded |
| 10 | 4-conductor shielded cable (18-20 AWG), a few feet | From the DRV8825 (inside the main enclosure) out through the dedicated motor-wire hole to the K11's NEMA23 motor, if the stock cable is too short | https://www.amazon.com/s?k=4+conductor+shielded+stepper+motor+cable |
| 10b | 8-conductor cable (CAT5/CAT5e offcut, or 8-way ribbon cable with IDC connectors), a few feet | Connects the main board's pendant header to the pendant board — 8 wires straight through, no crossover | https://www.amazon.com/s?k=cat5+cable+bulk or https://www.amazon.com/s?k=8+way+ribbon+cable+idc+connector+kit |
| 10c | 2x15 pin female header, 2.54mm pitch, 0.6" row spacing (Arduino Nano socket-compatible) or straight male pin header strips | Optional — solder the Nano directly to the main board's 30-pad footprint per the build guide, or use header strips if you'd rather keep it socketed/removable | https://www.amazon.com/s?k=2.54mm+pin+header+2x15+arduino+nano |
| 10d | 1x8 pin header, 2.54mm pitch (male + female pair) | Main board's pendant connector and the pendant board's incoming connector, if you're using loose wires or ribbon cable rather than crimped connectors | https://www.amazon.com/s?k=1x8+pin+header+2.54mm |
| 11 | M3 x 6mm and M3 x 10mm machine screws (assorted kit) | Mounting encoder, driver, enclosure lid | https://www.amazon.com/s?k=M3+screw+assortment+kit+black |
| 11b | M2 x 6mm self-tapping screws (small pack) | Mounting the OLED PCB to the enclosure's printed standoffs | https://www.amazon.com/s?k=M2+self+tapping+screws+6mm |
| 12 | M2.5 or M3 brass heat-set inserts (optional) | Stronger screw bosses in a 3D printed enclosure | https://www.amazon.com/s?k=M3+brass+heat+set+inserts |
| 13 | Small project wire ties / adhesive cable clips | Cable management inside enclosure | https://www.amazon.com/s?k=small+cable+ties+wire+management |
| 14 | Double-sided copper-clad FR4 blank, at least 110x70mm | Main board (needs both sides — see `pcb_build_guide.md` for the two-layer etch/alignment process) | https://www.amazon.com/s?k=double+sided+copper+clad+board+fr4 |
| 15 | Single-sided copper-clad FR4 blank, at least 50x50mm | Pendant board | https://www.amazon.com/s?k=single+sided+copper+clad+board+fr4 |

## Notes on substitutions

- **Arduino Nano (#1):** Clones vary in USB connector — Mini-B (linked
  above, matches the official Arduino Nano), Micro-B, and USB-C
  versions are all functionally identical for this project. Pick
  whichever cable you already have, but note the enclosure's USB
  cutout position/size depends on which one you buy — check
  `enclosure_notes.md` before printing.
- **Nano IO shield (#1b):** Not required — you can wire directly to the
  Nano's pin headers with Dupont jumpers as in the original design —
  but for a build that will be bolted to a machine and used repeatedly,
  screw terminals are considerably more reliable than friction-fit
  jumper connectors.
- **Driver (#5, DRV8825):** This is a genuinely cheaper option (~$4–8
  vs ~$12–15 for the TB6600), but it caps out around ~1.5A per phase
  without cooling, or ~2.2A with the heatsink and some airflow — below
  the K11's NEMA23 motor's ~3A rating. In practice this is a reasonable
  trade for a dividing head, since it mostly rotates-then-holds between
  cuts rather than driving continuously under heavy load; it's a poor
  choice if you plan to rotate the head *while* actively milling
  (helical/spiral work) under significant cutting force — in that case
  spend the extra few dollars on the TB6600
  (https://www.amazon.com/Tofelf-Upgraded-TB6600-Subdivision-Controller/dp/B0BZYX7Z4Z)
  instead. See `wiring_guide.md` for DRV8825-specific setup (current
  calibration, microstep jumpers, RESET/SLEEP tie, and a capacitor
  requirement that's stricter than the TB6600's).
- **Power supply (#6):** 24V/5A is now more headroom than the DRV8825
  can actually use (it tops out around 2.2A with cooling) — that's
  fine, the supply just runs well under its limit. If you later switch
  to the TB6600 or DM542 for full NEMA23 torque, this same supply still
  comfortably covers it.
- **Buck converter (#7b):** Any LM2596-based module works; set it to
  5V with a multimeter *before* connecting it to the Nano (see
  `wiring_guide.md` for the calibration steps). A fixed-output 24V→5V
  module works too if you'd rather not tune a potentiometer.
- **Fuse rating (#7c):** 5A comfortably covers a single NEMA23 stepper
  driver plus the low-power Nano electronics. If you upsize to a
  higher-current motor/driver later, re-check the fuse rating against
  the driver's actual max current draw.
- **Power switch (#7d):** Any DC-rated toggle or rocker switch works;
  match the panel-mount hole to whatever you buy (12mm is common).
- **Distribution block (#7e):** Not strictly required — you can also
  just wire the driver and buck converter in parallel off the same
  screw terminal on the fuse holder or switch — but a proper
  distribution block makes for a much tidier and more serviceable
  build if you're mounting things semi-permanently.
- **Encoder (#3):** Any standard 5-pin KY-040 module works; the pack
  linked includes spares, which is worth it since the detent switches
  in these are a common failure point.
- Items 7f and 8–13 are commodity parts — buy whichever multi-packs are
  cheapest, exact brand doesn't matter.
