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
| 5 | TB6600 4A stepper driver (9–42V) | Drives the K11's NEMA23 motor from STEP/DIR signals | https://www.amazon.com/Tofelf-Upgraded-TB6600-Subdivision-Controller/dp/B0BZYX7Z4Z |
| 6 | 24V 5A switching power supply | Single shared supply — powers the stepper driver directly, and the Nano/OLED/encoder through a buck converter | https://www.amazon.com/120W-Power-Supply-100V-240V-110V/dp/B07K9HBHGR |
| 7 | 5.5x2.1mm DC barrel jack to screw terminal adapter | Break out the 24V supply's output into screw terminals | https://www.amazon.com/2-1mm-5-5mm-Screw-Terminal-Single/dp/B018RE432Q |
| 7b | LM2596 adjustable buck converter module (3A, screw terminals) | Steps the shared 24V rail down to a regulated 5V to power the Nano (and OLED/encoder through it) — do NOT power the Nano's 5V pin directly from 24V | https://www.amazon.com/LM2596-Converter-Module-Adjustable-Step-Down/dp/B0H2J7YKNS |
| 7c | Inline 5x20mm fuse holder + 5A fast-blow glass fuses | Protects the whole system — placed on the 24V line right after the power supply, before the switch/splitter | https://www.amazon.com/MECCANIXITY-5X20mm-Inline-Holder-Fast-Blow/dp/B0GX9DRFF2 |
| 7d | SPST toggle/rocker switch, 20A rated, 12mm panel mount | Main power switch for the 24V DC rail (safer to switch on the low-voltage side than mains) | https://www.amazon.com/MGI-SpeedWare-Latching-Toggle-Switch/dp/B0FXZF86JW |
| 7e | 2-in/8-out screw terminal power distribution block | Splits the fused, switched 24V rail cleanly to the driver and the buck converter without stacking multiple wires under one screw | https://www.amazon.com/Jienk-Terminal-Distribution-Mounting-Amplifier/dp/B0B55R8TRH |
| 7f | Electrolytic capacitor, 2200µF 35V (radial) | Bulk/snubber capacitor across the 24V rail near the driver, to absorb motor back-EMF spikes — skip if your driver or PSU already has one built in | https://www.amazon.com/s?k=2200uf+35v+radial+electrolytic+capacitor |
| 8 | Dupont jumper wire kit (M-M, M-F, F-F) | All Arduino ↔ module signal wiring | https://www.amazon.com/Elegoo-EL-CP-004-Multicolored-Breadboard-arduino/dp/B01EV70C78 |
| 9 | 22 AWG hookup wire, a few colors | Cleaner permanent wiring than jumpers, for inside the enclosure | https://www.amazon.com/s?k=22+awg+hookup+wire+kit+stranded |
| 10 | 4-conductor shielded cable (18-20 AWG), a few feet | Extension from driver to the K11's NEMA23 motor if the stock cable is too short | https://www.amazon.com/s?k=4+conductor+shielded+stepper+motor+cable |
| 11 | M3 x 6mm and M3 x 10mm machine screws (assorted kit) | Mounting Arduino, encoder, driver, enclosure lid | https://www.amazon.com/s?k=M3+screw+assortment+kit+black |
| 12 | M2.5 or M3 brass heat-set inserts (optional) | Stronger screw bosses in a 3D printed enclosure | https://www.amazon.com/s?k=M3+brass+heat+set+inserts |
| 13 | Small project wire ties / adhesive cable clips | Cable management inside enclosure | https://www.amazon.com/s?k=small+cable+ties+wire+management |

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
- **Driver (#5):** A DM542 (digital, quieter, better microstepping
  linearity) is a solid step-up from the TB6600 if you want smoother
  low-speed motion for fine divisions — same STEP/DIR/EN wiring.
- **Power supply (#6):** Match the voltage/current to your driver and
  motor. 24V/5A comfortably covers a single NEMA23 at up to ~3A plus
  the Nano/OLED/encoder's small additional draw (well under 500mA); if
  you run the motor near its rated current continuously, consider
  stepping up to a 36V supply for more torque headroom (check your
  driver's max voltage rating first, and the LM2596's 40V max input
  before doing so).
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
